import SwiftUI
import Combine
import FirebaseAuth

/// Handles authentication. Email/password via Firebase Auth, gated to
/// academy email domains only. Also tracks the signed-in user's
/// Firestore profile so the rest of the app can read it.
@MainActor
final class AuthService: ObservableObject {

    @Published var user: FirebaseAuth.User?
    @Published var errorMessage: String?

    /// The signed-in user's Firestore profile. Populated whenever
    /// Firebase Auth state becomes signed-in; nil when signed out.
    @Published var currentUser: User?

    private var listenerHandle: AuthStateDidChangeListenerHandle?
    private let userService = UserService()

    /// Email domains allowed to use the app. Add more here as cohorts
    /// expand — it's an array on purpose.
    private let allowedDomains = ["msu.idserve.net"]

    init() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            self?.user = firebaseUser
            // Load (or clear) the Firestore profile to match.
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let firebaseUser {
                    self.currentUser = try? await self.userService.fetchUser(id: firebaseUser.uid)
                } else {
                    self.currentUser = nil
                }
            }
        }
    }

    // MARK: - Domain gate

    /// True if the email belongs to an allowed academy domain.
    private func isAllowed(email: String) -> Bool {
        guard let domain = email.lowercased().split(separator: "@").last else {
            return false
        }
        return allowedDomains.contains(String(domain))
    }

    // MARK: - Email + password

    /// Simple sign-up: Auth account + a minimal User document. The
    /// User starts with just id + email; name and other fields are
    /// filled in via Settings (or by the real onboarding flow later).
    func signUp(email: String, password: String) async {
        errorMessage = nil
        guard isAllowed(email: email) else {
            errorMessage = "Please use your academy email (@msu.idserve.net)."
            return
        }
        do {
            // 1. Create the Auth account.
            let result = try await Auth.auth().createUser(
                withEmail: email, password: password)

            // 2. Write a minimal User document, keyed by the uid.
            let newUser = User(id: result.user.uid, name: "", email: email)
            try await userService.saveUser(newUser)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Full registration: creates the Auth account AND writes the
    /// matching User profile to Firestore. Designed for the onboarding
    /// flow once the design team finishes it.
    func register(email: String, password: String,
                  name: String, cohort: String) async {
        errorMessage = nil
        guard isAllowed(email: email) else {
            errorMessage = "Please use your academy email (@msu.idserve.net)."
            return
        }
        do {
            let result = try await Auth.auth().createUser(
                withEmail: email, password: password)
            let newUser = User(
                id: result.user.uid,
                name: name,
                email: email,
                cohort: cohort
            )
            try await userService.saveUser(newUser)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        guard isAllowed(email: email) else {
            errorMessage = "Please use your academy email (@msu.idserve.net)."
            return
        }
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sign out

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Profile reload

    /// Reloads the current user's profile from Firestore. Called by
    /// Settings after a successful field edit so the UI reflects it.
    func reloadCurrentUser() async {
        guard let uid = user?.uid else { return }
        currentUser = try? await userService.fetchUser(id: uid)
    }
}

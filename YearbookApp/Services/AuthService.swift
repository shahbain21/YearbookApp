import SwiftUI
import Combine
import FirebaseAuth

/// Handles authentication. Email/password via Firebase Auth, gated to
/// academy email domains only.
@MainActor
final class AuthService: ObservableObject {

    @Published var user: FirebaseAuth.User?
    @Published var errorMessage: String?

    private var listenerHandle: AuthStateDidChangeListenerHandle?
    private let userService = UserService()

    /// Email domains allowed to use the app. Add more here as cohorts
    /// expand — it's an array on purpose.
    private let allowedDomains = ["msu.idserve.net"]

    init() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
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

    /// Simple sign-up: Auth account only. Used by the current
    /// SignInView until the real onboarding flow replaces it.
    func signUp(email: String, password: String) async {
        errorMessage = nil
        guard isAllowed(email: email) else {
            errorMessage = "Please use your academy email (@msu.idserve.net)."
            return
        }
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
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
            // 1. Create the Auth account.
            let result = try await Auth.auth().createUser(
                withEmail: email, password: password)

            // 2. Write the matching User profile, keyed by uid.
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
}

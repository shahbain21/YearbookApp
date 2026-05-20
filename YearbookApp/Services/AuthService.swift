import SwiftUI
import Combine
import FirebaseAuth

/// Handles authentication. Email/password via Firebase Auth, gated to
/// academy email domains only. Also tracks the signed-in user's
/// Firestore profile so the rest of the app can read it.
@MainActor
final class AuthService: ObservableObject {

    // MARK: - Published state

    /// The raw Firebase Auth user. Nil = signed out.
    @Published var user: FirebaseAuth.User?

    /// The signed-in user's Firestore profile. Populated whenever
    /// Firebase Auth state becomes signed-in; nil when signed out.
    @Published var currentUser: User?

    /// Surfaces the most recent auth error to the UI.
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private var listenerHandle: AuthStateDidChangeListenerHandle?
    private let userService = UserService()

    /// Email domains allowed to use the app. Add more here as cohorts
    /// expand — it's an array on purpose.
    private let allowedDomains = ["msu.idserve.net"]

    // MARK: - Lifecycle

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

    // MARK: - Sign up

    /// Simple sign-up: Auth account + a minimal User document. Used by
    /// the current SignInView. When the real onboarding flow is wired,
    /// this can be removed and `register(...)` used instead.
    func signUp(email: String, password: String) async {
        errorMessage = nil
        guard isAllowed(email: email) else {
            errorMessage = "Please use your academy email (@msu.idserve.net)."
            return
        }
        do {
            let result = try await Auth.auth().createUser(
                withEmail: email, password: password)
            let newUser = User(id: result.user.uid, name: "", email: email)
            try await userService.saveUser(newUser)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Full registration: creates the Auth account AND writes the
    /// matching User profile to Firestore. Designed for the onboarding
    /// flow once the design team finishes it. `hasCompletedOnboarding`
    /// stays false on the User; onboarding flips it via
    /// `markOnboardingComplete()`.
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

    // MARK: - Sign in / out

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

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Profile management

    /// Reloads the current user's profile from Firestore. Called by
    /// Settings after a successful field edit so the UI reflects it.
    func reloadCurrentUser() async {
        guard let uid = user?.uid else { return }
        currentUser = try? await userService.fetchUser(id: uid)
    }

    /// Called by the onboarding flow when the user finishes or skips.
    /// Flips hasCompletedOnboarding to true so the app routes them
    /// from onboarding into the main tabs, then refreshes currentUser.
    func markOnboardingComplete() async {
        guard let uid = user?.uid else { return }
        do {
            try await userService.updateField(
                userID: uid,
                keyPath: \User.hasCompletedOnboarding,
                value: true
            )
            await reloadCurrentUser()
        } catch {
            errorMessage = "Couldn't save your progress."
        }
    }
}

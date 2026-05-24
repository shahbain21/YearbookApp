import SwiftUI
import Combine
import FirebaseAuth

/// Handles authentication. Email/password via Firebase Auth, gated to
/// academy email domains AND requiring email verification. Also tracks
/// the signed-in user's Firestore profile so the rest of the app can
/// read it.
@MainActor
final class AuthService: ObservableObject {

    // MARK: - Published state

    @Published var user: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var errorMessage: String?

    /// Mirrors user?.isEmailVerified — published separately so views
    /// can react when verification status changes (it doesn't change
    /// the underlying auth user object, so we have to track it).
    @Published var isEmailVerified: Bool = false

    // MARK: - Dependencies

    private var listenerHandle: AuthStateDidChangeListenerHandle?
    private let userService = UserService()
    private let allowedDomains = ["msu.idserve.net"]

    // MARK: - Lifecycle

    init() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            self?.user = firebaseUser
            self?.isEmailVerified = firebaseUser?.isEmailVerified ?? false
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

    private func isAllowed(email: String) -> Bool {
        guard let domain = email.lowercased().split(separator: "@").last else {
            return false
        }
        return allowedDomains.contains(String(domain))
    }

    // MARK: - Sign up

    /// Sign up + send verification email. User must verify before the
    /// app lets them past the gate (handled in YearbookApp routing).
    func signUp(email: String, password: String) async {
        errorMessage = nil
        guard isAllowed(email: email) else {
            errorMessage = "Please use your academy email (@msu.idserve.net)."
            return
        }
        do {
            let result = try await Auth.auth().createUser(
                withEmail: email, password: password)

            // Write minimal User document.
            let newUser = User(id: result.user.uid, name: "", email: email)
            try await userService.saveUser(newUser)

            // Send the verification email.
            try await result.user.sendEmailVerification()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Full registration with profile fields. Same verification flow.
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
            try await result.user.sendEmailVerification()
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

    // MARK: - Email verification

    /// Re-send the verification email. The link Firebase sent originally
    /// expires after a while; users on a slow inbox may need a fresh one.
    func resendVerificationEmail() async {
        errorMessage = nil
        do {
            try await user?.sendEmailVerification()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Refresh the user from Firebase to pick up a verification that
    /// happened in the email client (we don't get a push when it does).
    /// Called by the "I've verified" button on the gate screen.
    func reloadVerificationStatus() async {
        errorMessage = nil
        do {
            try await user?.reload()
            isEmailVerified = user?.isEmailVerified ?? false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Profile management

    func reloadCurrentUser() async {
        guard let uid = user?.uid else { return }
        currentUser = try? await userService.fetchUser(id: uid)
    }

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

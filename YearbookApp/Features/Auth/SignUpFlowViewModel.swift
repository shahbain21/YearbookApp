//
//  SignUpFlowViewModel.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/23/26.
//


import SwiftUI
import Combine
import FirebaseAuth

/// Shared state for the two-step sign-up flow. The credentials view
/// fills email/password; the profile view fills the rest; the final
/// submit calls AuthService.register and marks onboarding complete.
@MainActor
final class SignUpFlowViewModel: ObservableObject {

    // Step 1 — credentials
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    // Step 2 — profile
    @Published var name = ""
    @Published var quote = ""
    @Published var birthday: Date?
    @Published var role: String = "Project Manager"   // matches the hi-fi picker
    @Published var cohort: String = "AM"
    @Published var linkedIn = ""
    @Published var instagram = ""

    // Flow state
    @Published var isWorking = false
    @Published var errorMessage: String?

    /// Step 1 validation — email non-empty, passwords match, min length.
    var canAdvanceFromCredentials: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }

    /// Step 2 validation — name is the only required field.
    var canSubmitProfile: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Final submit: register the user with everything we collected,
    /// then mark onboarding complete so they don't see the legacy
    /// onboarding screen. Email verification happens automatically
    /// inside register().
    func submit(auth: AuthService, userService: UserService) async -> Bool {
        guard canSubmitProfile else { return false }
        isWorking = true
        errorMessage = nil

        // 1. Create the Auth account + minimal User document.
        await auth.register(
            email: email,
            password: password,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            cohort: cohort
        )

        // If register set an error, bail.
        if let err = auth.errorMessage {
            errorMessage = err
            isWorking = false
            return false
        }

        // 2. Fill in the remaining profile fields and mark onboarding done.
        if let uid = auth.user?.uid {
            do {
                var user = try await userService.fetchUser(id: uid) ?? User(
                    id: uid, name: name, email: email)
                user.quote = quote
                user.birthday = birthday
                user.role = role
                user.linkedIn = linkedIn
                user.instagram = instagram
                user.hasCompletedOnboarding = true
                try await userService.saveUser(user)
                await auth.reloadCurrentUser()
            } catch {
                errorMessage = "Account created, but couldn't save profile."
                isWorking = false
                return false
            }
        }

        isWorking = false
        return true
    }
}

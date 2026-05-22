//
//  OnboardingViewModel.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import SwiftUI
import Combine
import FirebaseAuth

/// Holds the in-progress onboarding state. The view binds to these
/// fields step by step; on finish, all of them are written to the
/// User document in one save.
@MainActor
final class OnboardingViewModel: ObservableObject {

    // Step 1 — required
    @Published var name = ""
    @Published var cohort = "AM"

    // Step 2 — optional
    @Published var quote = ""
    @Published var birthday: Date?

    // Step 3 — optional
    @Published var domain = ""
    @Published var linkedIn = ""
    @Published var instagram = ""

    // Flow state
    @Published var step: Int = 0          // 0, 1, 2
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let userService = UserService()

    /// Step 1 is the only one with required fields.
    var canAdvanceFromStep1: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Move to the next step. Step 0 -> 1, 1 -> 2.
    func next() {
        if step < 2 { step += 1 }
    }

    /// Skip the current step. Same as next() but conveys intent.
    func skip() {
        next()
    }

    /// Final save: write everything to Firestore and mark onboarding
    /// complete. The auth state listener picks up the flag flip and
    /// the app routes into the tabs automatically.
    func finish(auth: AuthService) async {
        guard let uid = auth.user?.uid else { return }
        isSaving = true
        errorMessage = nil
        do {
            // Load the existing User (created at signUp with just
            // id + email) and fill in the onboarding fields.
            guard var user = try await userService.fetchUser(id: uid) else {
                throw NSError(domain: "Onboarding", code: 404)
            }
            user.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            user.cohort = cohort
            user.quote = quote
            user.birthday = birthday
            user.domain = domain
            user.linkedIn = linkedIn
            user.instagram = instagram
            user.hasCompletedOnboarding = true

            try await userService.saveUser(user)
            await auth.reloadCurrentUser()
        } catch {
            errorMessage = "Couldn't save your profile. Try again."
        }
        isSaving = false
    }
}

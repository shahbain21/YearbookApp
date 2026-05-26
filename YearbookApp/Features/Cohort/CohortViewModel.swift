//
//  CohortViewModel.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/23/26.
//


import SwiftUI
import Combine

// Drives the Cohort grid: loads all cohort members from Firestore.
@MainActor
final class CohortViewModel: ObservableObject {

    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userService = UserService()

    /// Load all members. Called on appear and on pull-to-refresh.
    /// Filters out users who haven't completed onboarding (no name yet)
    /// so the grid doesn't show half-empty rows.
    func loadUsers() async {
            isLoading = true
            errorMessage = nil
            do {
                let all = try await userService.fetchAllUsers()
                users = all
                    .filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    .sorted { $0.name < $1.name }
            } catch {
                errorMessage = "Couldn't load cohort: \(error.localizedDescription)"
                print("Cohort load error: \(error)")        
            }
            isLoading = false
        }
}

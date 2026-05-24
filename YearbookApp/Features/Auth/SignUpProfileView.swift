//
//  SignUpProfileView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/23/26.
//


import SwiftUI

/// Step 2 of sign-up: the profile fields matching the hi-fi. Submit
/// creates the actual Firebase account + Firestore profile, then the
/// flow routes into email verification (handled by YearbookApp).
struct SignUpProfileView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var flow: SignUpFlowViewModel

    private let userService = UserService()
    private let roles = ["Project Manager", "Designer", "Coder"]
    private let cohorts = ["AM", "PM"]

    var body: some View {
        Form {
            // Photo placeholder — wired to Cloudinary later
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: YBSpace.xs) {
                        Circle()
                            .fill(YBColor.icyAqua.opacity(0.5))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "photo.badge.plus")
                                    .font(.title)
                                    .foregroundColor(YBColor.forest)
                            )
                        Text("Upload Photo")
                            .font(YBFont.caption)
                            .foregroundColor(YBColor.forest)
                    }
                    Spacer()
                }
                .padding(.vertical, YBSpace.sm)
            }

            Section("Full Name") {
                TextField("Required", text: $flow.name)
                    .textInputAutocapitalization(.words)
            }

            Section("Favorite Quote") {
                TextField("Optional", text: $flow.quote, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("Birthday") {
                Toggle("Add a birthday",
                       isOn: Binding(
                            get: { flow.birthday != nil },
                            set: { flow.birthday = $0 ? Date() : nil }
                       ))
                    .tint(YBColor.forest)
                if let date = flow.birthday {
                    DatePicker("Birthday",
                        selection: Binding(
                            get: { date },
                            set: { flow.birthday = $0 }
                        ),
                        in: ...Date(),
                        displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
            }

            Section("Role") {
                Picker("Role", selection: $flow.role) {
                    ForEach(roles, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
            }

            Section("Cohort") {
                Picker("Cohort", selection: $flow.cohort) {
                    ForEach(cohorts, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
            }

            Section("LinkedIn") {
                TextField("Optional", text: $flow.linkedIn)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section("Instagram") {
                TextField("Optional", text: $flow.instagram)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if let errorMessage = flow.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(YBFont.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        let success = await flow.submit(
                            auth: auth, userService: userService)
                        // On success, YearbookApp routing takes over
                        // and pushes us into VerifyEmailView.
                        if success { dismiss() }
                    }
                } label: {
                    Text("Create Profile")
                        .fontWeight(.bold)
                }
                .disabled(!flow.canSubmitProfile || flow.isWorking)
            }
        }
        .overlay {
            if flow.isWorking { ProgressView().tint(YBColor.forest) }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpProfileView(flow: SignUpFlowViewModel())
            .environmentObject(AuthService())
    }
}
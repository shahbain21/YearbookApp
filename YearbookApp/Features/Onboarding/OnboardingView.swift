//
//  OnboardingView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import SwiftUI

/// Interim onboarding flow. Three steps after registration:
///   0 - name + cohort (required)
///   1 - quote + birthday (skippable)
///   2 - domain + socials (skippable, finish)
///
/// Plain SwiftUI Form for now — design team will restyle later.
struct OnboardingView: View {
    @EnvironmentObject private var auth: AuthService
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                ProgressView(value: Double(viewModel.step + 1), total: 3)
                    .tint(YBColor.forest)
                    .padding()

                stepContent
                    .animation(.easeInOut, value: viewModel.step)

                Spacer()
                footerButtons
                    .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if viewModel.isSaving { ProgressView().tint(YBColor.forest) }
            }
        }
    }

    private var title: String {
        switch viewModel.step {
        case 0: "Welcome"
        case 1: "Tell us about you"
        case 2: "Your links"
        default: ""
        }
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case 0: step1
        case 1: step2
        default: step3
        }
    }

    /// Step 1 — name + cohort (required to proceed).
    private var step1: some View {
        Form {
            Section("Your name") {
                TextField("Full name", text: $viewModel.name)
                    .textInputAutocapitalization(.words)
            }
            Section("Cohort") {
                Picker("Cohort", selection: $viewModel.cohort) {
                    Text("AM").tag("AM")
                    Text("PM").tag("PM")
                }
                .pickerStyle(.segmented)
            }
        }
    }

    /// Step 2 — quote + birthday (both optional).
    private var step2: some View {
        Form {
            Section("Yearbook quote") {
                TextField("Optional", text: $viewModel.quote, axis: .vertical)
                    .lineLimit(2...4)
            }
            Section("Birthday") {
                Toggle("Add a birthday",
                       isOn: Binding(
                            get: { viewModel.birthday != nil },
                            set: { viewModel.birthday = $0 ? Date() : nil }
                       ))
                    .tint(YBColor.forest)

                if let date = viewModel.birthday {
                    DatePicker("Birthday",
                        selection: Binding(
                            get: { date },
                            set: { viewModel.birthday = $0 }
                        ),
                        in: ...Date(),
                        displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
            }
        }
    }

    /// Step 3 — domain + socials (all optional).
    private var step3: some View {
        Form {
            Section("Domain or focus area") {
                TextField("e.g. App Design, Engineering", text: $viewModel.domain)
            }
            Section("Socials") {
                TextField("LinkedIn username", text: $viewModel.linkedIn)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Instagram handle", text: $viewModel.instagram)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(YBFont.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private var footerButtons: some View {
        HStack {
            // Skip — only on optional steps.
            if viewModel.step > 0 {
                Button("Skip") { viewModel.skip() }
                    .foregroundColor(.secondary)
            }
            Spacer()

            // Primary action — Next on steps 0/1, Finish on step 2.
            Button {
                if viewModel.step < 2 {
                    viewModel.next()
                } else {
                    Task { await viewModel.finish(auth: auth) }
                }
            } label: {
                Text(viewModel.step < 2 ? "Next" : "Finish")
                    .font(YBFont.label)
                    .foregroundColor(.white)
                    .padding(.horizontal, YBSpace.lg)
                    .padding(.vertical, YBSpace.sm)
                    .background(Capsule().fill(YBColor.forest))
            }
            .disabled(viewModel.step == 0 && !viewModel.canAdvanceFromStep1)
            .opacity(
                (viewModel.step == 0 && !viewModel.canAdvanceFromStep1)
                ? 0.5 : 1.0
            )
        }
    }
}

#Preview {
    OnboardingView().environmentObject(AuthService())
}
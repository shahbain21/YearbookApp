//
//  SignUpCredentialsView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/23/26.
//


import SwiftUI

/// Step 1 of sign-up: email + password + confirm password. On Continue,
/// navigates to the profile step. The actual Firebase account isn't
/// created until the profile step is submitted.
struct SignUpCredentialsView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @StateObject private var flow = SignUpFlowViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                YBColor.forest.ignoresSafeArea()

                VStack(spacing: YBSpace.lg) {
                    Spacer()

                    Text("Create Account")
                        .font(YBFont.heading)
                        .foregroundColor(YBColor.white)

                    Text("Use your academy email to get started.")
                        .font(YBFont.caption)
                        .foregroundColor(YBColor.white.opacity(0.8))
                        .multilineTextAlignment(.center)

                    Spacer()

                    VStack(spacing: YBSpace.sm) {
                        TextField("Email", text: $flow.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .environment(\.colorScheme, .light)
                            .foregroundStyle(.black)
                            .tint(.black)

                        SecureField("Password (min 6 characters)", text: $flow.password)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .environment(\.colorScheme, .light)
                            .foregroundStyle(.black)
                            .tint(.black)

                        SecureField("Confirm Password", text: $flow.confirmPassword)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .environment(\.colorScheme, .light)
                            .foregroundStyle(.black)
                            .tint(.black)
                    }

                    NavigationLink {
                        SignUpProfileView(flow: flow)
                    } label: {
                        Text("Continue")
                            .font(YBFont.label)
                            .foregroundColor(YBColor.forest)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Capsule().fill(YBColor.white))
                    }
                    .disabled(!flow.canAdvanceFromCredentials)
                    .opacity(flow.canAdvanceFromCredentials ? 1 : 0.5)

                    Spacer()
                }
                .padding(YBSpace.lg)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(YBColor.white)
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpCredentialsView().environmentObject(AuthService())
}
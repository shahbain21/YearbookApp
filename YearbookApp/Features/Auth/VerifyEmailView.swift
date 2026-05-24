//
//  VerifyEmailView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/22/26.
//


import SwiftUI
import FirebaseAuth

/// Shown after signup, before the rest of the app. The user must
/// verify their email (link sent to their inbox) and tap the button
/// to refresh. Includes a Resend button in case the email got lost.
struct VerifyEmailView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var isChecking = false
    @State private var didResend = false

    var body: some View {
        ZStack {
            YBColor.forest.ignoresSafeArea()

            VStack(spacing: YBSpace.lg) {
                Spacer()

                Image(systemName: "envelope.badge")
                    .font(.system(size: 60))
                    .foregroundColor(YBColor.white)

                Text("Verify Your Email")
                    .font(YBFont.heading)
                    .foregroundColor(YBColor.white)

                Text("We sent a link to \(auth.user?.email ?? "your email"). Open it, then tap below.")
                    .font(YBFont.body)
                    .foregroundColor(YBColor.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, YBSpace.lg)

                Spacer()

                Button {
                    Task {
                        isChecking = true
                        await auth.reloadVerificationStatus()
                        isChecking = false
                    }
                } label: {
                    Text(isChecking ? "Checking…" : "I've Verified — Continue")
                        .font(YBFont.label)
                        .foregroundColor(YBColor.forest)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(YBColor.white))
                }
                .disabled(isChecking)

                Button {
                    Task {
                        await auth.resendVerificationEmail()
                        didResend = true
                    }
                } label: {
                    Text(didResend ? "Email Resent" : "Resend Email")
                        .font(YBFont.caption)
                        .foregroundColor(YBColor.white.opacity(0.9))
                }

                Button("Sign Out") {
                    auth.signOut()
                }
                .font(YBFont.caption)
                .foregroundColor(YBColor.white.opacity(0.7))

                if let error = auth.errorMessage {
                    Text(error)
                        .font(YBFont.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, YBSpace.lg)
                }

                Spacer()
            }
            .padding(YBSpace.lg)
        }
    }
}

#Preview {
    VerifyEmailView().environmentObject(AuthService())
}

import SwiftUI

/// The sign-in screen. Shown when no user is signed in. Handles both
/// signing in and creating an account via the isSigningUp toggle.
struct SignInView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false   // toggles sign-in vs create-account
    @State private var isWorking = false

    var body: some View {
        ZStack {
            YBColor.forest.ignoresSafeArea()

            VStack(spacing: YBSpace.lg) {
                Spacer()

                Text("Yearbook")
                    .font(YBFont.heading)
                    .foregroundColor(YBColor.white)

                Text("Apple Developer Academy")
                    .font(YBFont.caption)
                    .foregroundColor(YBColor.white.opacity(0.8))

                Spacer()

                // Email + password fields. The whole group is forced to
                // light mode AND given an explicit dark text color, so
                // the typed text is readable regardless of device theme.
                VStack(spacing: YBSpace.sm) {
                                    TextField("Email", text: $email)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .autocorrectionDisabled()
                                        .padding()
                                        .background(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .environment(\.colorScheme, .light)
                                        .foregroundStyle(.black)
                                        .tint(.black)

                                    SecureField("Password", text: $password)
                                        .padding()
                                        .background(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .environment(\.colorScheme, .light)
                                        .foregroundStyle(.black)
                                        .tint(.black)
                                }
                .environment(\.colorScheme, .light)
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.1))
                .tint(YBColor.forest)

                // Primary button — label and action depend on the mode.
                Button {
                    Task { await submitEmail() }
                } label: {
                    Text(isSigningUp ? "Create Account" : "Sign In")
                        .font(YBFont.label)
                        .foregroundColor(YBColor.forest)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(YBColor.white)
                        .clipShape(Capsule())
                }
                .disabled(isWorking || email.isEmpty || password.isEmpty)

                // Toggle between sign-in and sign-up, with a transition
                // so the change is actually noticeable.
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        auth.errorMessage = nil       // clear stale errors
                        isSigningUp.toggle()
                    }
                } label: {
                    Text(isSigningUp ? "Have an account? Sign in"
                                     : "New here? Create an account")
                        .font(YBFont.caption)
                        .foregroundColor(YBColor.white.opacity(0.9))
                        // id + transition makes SwiftUI animate the swap
                        .id(isSigningUp)
                        .transition(.push(from: .bottom).combined(with: .opacity))
                }

                // Error message — red, only shown when present.
                if let error = auth.errorMessage {
                    Text(error)
                        .font(YBFont.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(YBSpace.lg)

            if isWorking {
                ProgressView()
                    .tint(YBColor.white)
            }
        }
        // Animate the whole screen when sign-in/sign-up mode changes.
        .animation(.easeInOut(duration: 0.25), value: isSigningUp)
    }

    private func submitEmail() async {
        isWorking = true
        if isSigningUp {
            await auth.signUp(email: email, password: password)
        } else {
            await auth.signIn(email: email, password: password)
        }
        isWorking = false
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthService())
}

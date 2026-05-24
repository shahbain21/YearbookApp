import SwiftUI

/// Sign in to an existing account. Sign-up moved to its own flow
/// (SignUpCredentialsView -> SignUpProfileView).
struct SignInView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var isWorking = false
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            YBColor.forest.ignoresSafeArea()

            VStack(spacing: YBSpace.lg) {
                Spacer()

                Text("MainMemories")
                    .font(YBFont.heading)
                    .foregroundColor(YBColor.white)

                Text("Apple Developer Academy")
                    .font(YBFont.caption)
                    .foregroundColor(YBColor.white.opacity(0.8))

                Spacer()

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

                Button {
                    Task {
                        isWorking = true
                        await auth.signIn(email: email, password: password)
                        isWorking = false
                    }
                } label: {
                    Text("Sign In")
                        .font(YBFont.label)
                        .foregroundColor(YBColor.forest)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(YBColor.white))
                }
                .disabled(isWorking || email.isEmpty || password.isEmpty)

                Button("New here? Create an account") {
                    showSignUp = true
                }
                .font(YBFont.caption)
                .foregroundColor(YBColor.white.opacity(0.9))

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
                ProgressView().tint(YBColor.white)
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpCredentialsView().environmentObject(auth)
        }
    }
}

#Preview {
    SignInView().environmentObject(AuthService())
}

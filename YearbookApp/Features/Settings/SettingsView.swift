import SwiftUI

/// Settings — presented as a sheet from Profile. Uses semantic
/// system colors so it adapts to light and dark mode like the
/// native sheets it sits alongside.
struct SettingsView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsOn = true

    /// The signed-in user, or a blank placeholder while loading.
    private var user: User {
        auth.currentUser ?? User(id: "", name: "", email: "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: YBSpace.lg) {

                    // Photo + upload
                    VStack(spacing: YBSpace.sm) {
                        YBImage(source: user.photoName)
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                        Button("Upload Photo") { /* TODO: photo picker */ }
                            .font(YBFont.caption)
                            .foregroundColor(YBColor.forest)
                        Text(user.name.isEmpty ? user.email : user.name)
                            .font(YBFont.label)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, YBSpace.md)

                    // Change rows
                    VStack(spacing: 0) {
                        editRow("Change Name",      keyPath: \.name,
                                value: user.name)
                        editRow("Change Quote",     keyPath: \.quote,
                                value: user.quote)
                        editRow("Change Domain",    keyPath: \.domain,
                                value: user.domain)
                        editRow("Change LinkedIn",  keyPath: \.linkedIn,
                                value: user.linkedIn)
                        editRow("Change Instagram", keyPath: \.instagram,
                                value: user.instagram)
                    }
                    .padding(.horizontal, YBSpace.md)

                    // Notifications toggle
                    Toggle("Notifications", isOn: $notificationsOn)
                        .font(YBFont.body)
                        .tint(YBColor.forest)
                        .padding(.horizontal, YBSpace.md)

                    // Sign out
                    Button("Sign Out") {
                        auth.signOut()
                        dismiss()
                    }
                    .font(YBFont.label)
                    .foregroundColor(YBColor.forest)

                    // Deactivate
                    Button("Deactivate Account") { /* TODO */ }
                        .font(YBFont.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, YBSpace.lg)
                        .padding(.vertical, YBSpace.sm)
                        .overlay(
                            Capsule().stroke(.red, lineWidth: 1)
                        )

                    // Done
                    Button { dismiss() } label: {
                        Text("Done")
                            .font(YBFont.label)
                            .foregroundColor(.white)
                            .padding(.horizontal, YBSpace.xl)
                            .padding(.vertical, YBSpace.sm)
                            .background(Capsule().fill(YBColor.forest))
                    }
                    .padding(.bottom, YBSpace.xl)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }

    /// Builds one navigation row that pushes the generic editor.
    @ViewBuilder
    private func editRow(_ title: String,
                         keyPath: WritableKeyPath<User, String>,
                         value: String) -> some View {
        NavigationLink {
            EditFieldView(title: title, keyPath: keyPath, initialValue: value)
        } label: {
            HStack {
                Text(title)
                    .font(YBFont.body)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, YBSpace.md)
            .contentShape(Rectangle())
        }
        Divider()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService())
}

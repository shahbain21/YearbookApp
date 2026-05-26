import SwiftUI

/// User settings sheet — edit profile fields, manage notifications,
/// sign out, deactivate. Uses system semantic colors so the sheet
/// renders correctly in light AND dark mode.
struct SettingsView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    private let userService = UserService()

    @State private var notificationsOn = true

    var body: some View {
        NavigationStack {
            ScrollView {
                if let user = auth.currentUser {
                    VStack(spacing: YBSpace.lg) {

                        // Photo + name
                        VStack(spacing: YBSpace.xs) {
                            Circle()
                                .fill(YBColor.icyAqua.opacity(0.5))
                                .frame(width: 110, height: 110)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.title)
                                        .foregroundColor(YBColor.forest)
                                )
                            // brandText so it's readable in both modes.
                            Text("Upload Photo")
                                .font(YBFont.caption)
                                .foregroundColor(YBColor.brandText)

                            Text(user.name)
                                .font(YBFont.label)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, YBSpace.lg)

                        // Edit rows
                        VStack(spacing: 0) {
                            editRow("Change Name",      keyPath: \.name,
                                    value: user.name)
                            dateRow("Change Birthday",  keyPath: \.birthday,
                                    value: user.birthday)
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
                            .tint(YBColor.forest)
                            .padding(.horizontal, YBSpace.md)
                            .padding(.top, YBSpace.md)

                        // Sign out — brandText so it adapts.
                        Button {
                            auth.signOut()
                            dismiss()
                        } label: {
                            Text("Sign Out")
                                .font(YBFont.label)
                                .foregroundColor(YBColor.brandText)
                        }
                        .padding(.top, YBSpace.lg)

                        // Deactivate — destructive, stays red in both modes.
                        Button {
                            // TODO: deactivation flow
                        } label: {
                            Text("Deactivate Account")
                                .font(YBFont.label)
                                .foregroundColor(.red)
                                .padding(.horizontal, YBSpace.lg)
                                .padding(.vertical, YBSpace.sm)
                                .overlay(
                                    Capsule().stroke(Color.red, lineWidth: 1)
                                )
                        }

                        // Done — brand button, stays forest in both modes.
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(YBFont.label)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Capsule().fill(YBColor.forest))
                        }
                        .padding(.horizontal, YBSpace.lg)
                        .padding(.top, YBSpace.md)
                        .padding(.bottom, YBSpace.xl)
                    }
                } else {
                    ProgressView().padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Row builders

    /// Builds one navigation row that pushes a text editor.
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

    /// Builds one navigation row that pushes the date editor.
    @ViewBuilder
    private func dateRow(_ title: String,
                        keyPath: WritableKeyPath<User, Date?>,
                        value: Date?) -> some View {
        NavigationLink {
            EditDateView(title: title, keyPath: keyPath, initialValue: value)
        } label: {
            HStack {
                Text(title)
                    .font(YBFont.body)
                    .foregroundColor(.primary)
                Spacer()
                if let value {
                    Text(value.formatted(.dateTime.month().day().year()))
                        .font(YBFont.caption)
                        .foregroundColor(.secondary)
                }
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
    SettingsView().environmentObject(AuthService())
}

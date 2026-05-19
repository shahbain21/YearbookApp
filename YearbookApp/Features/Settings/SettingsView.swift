//
//  SettingsView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI

/// Settings — presented as a sheet from Profile. The hi-fi's X-to-close
/// confirms it's modal, not a tab.
struct SettingsView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsOn = true

    private let user = MockData.currentUser

    private let changeRows = ["Change Name", "Change Quote", "Change Birthday",
                              "Change Domain", "Change LinkedIn", "Change Instagram"]

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
                        Text(user.name)
                            .font(YBFont.label)
                            .foregroundColor(YBColor.ink)
                    }
                    .padding(.top, YBSpace.md)

                    // Change rows
                    VStack(spacing: 0) {
                        ForEach(changeRows, id: \.self) { row in
                            Button { /* TODO: edit screen */ } label: {
                                HStack {
                                    Text(row)
                                        .font(YBFont.body)
                                        .foregroundColor(YBColor.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(YBColor.inkSoft)
                                }
                                .padding(.vertical, YBSpace.md)
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal, YBSpace.md)

                    // Notifications toggle
                    Toggle("Notifications", isOn: $notificationsOn)
                        .font(YBFont.body)
                        .tint(YBColor.forest)
                        .padding(.horizontal, YBSpace.md)

                    // Deactivate
                    Button("Deactivate Account") { /* TODO: confirm + delete */ }
                        .font(YBFont.caption)
                        .foregroundColor(YBColor.heart)
                        .padding(.horizontal, YBSpace.lg)
                        .padding(.vertical, YBSpace.sm)
                        .overlay(
                            Capsule().stroke(YBColor.heart, lineWidth: 1)
                        )

                    // Sign out
                    Button("Sign Out") {
                        auth.signOut()
                        dismiss()
                    }
                    .font(YBFont.label)
                    .foregroundColor(YBColor.forest)

                    // Save
                    Button { dismiss() } label: {
                        Text("Save")
                            .font(YBFont.label)
                            .foregroundColor(YBColor.white)
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
                            .foregroundColor(YBColor.ink)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

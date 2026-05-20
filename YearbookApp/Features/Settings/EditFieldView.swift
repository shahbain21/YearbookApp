//
//  EditFieldView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import SwiftUI
import FirebaseAuth

/// Generic field editor for a single User property. Used for Name,
/// Quote, Domain, LinkedIn, Instagram, etc. Takes a title, the
/// current value, and a keyPath into User; saves and dismisses.
struct EditFieldView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    let title: String
    let keyPath: WritableKeyPath<User, String>

    @State private var value: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(title: String, keyPath: WritableKeyPath<User, String>, initialValue: String) {
        self.title = title
        self.keyPath = keyPath
        _value = State(initialValue: initialValue)
    }

    var body: some View {
        Form {
            Section {
                TextField(title, text: $value, axis: .vertical)
                    .lineLimit(1...4)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .font(YBFont.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { Task { await save() } }
                    .fontWeight(.bold)
                    .disabled(isSaving)
            }
        }
        .overlay {
            if isSaving { ProgressView().tint(YBColor.forest) }
        }
    }

    private func save() async {
        guard let uid = auth.user?.uid else { return }
        isSaving = true
        errorMessage = nil
        do {
            let service = UserService()
            try await service.updateField(userID: uid, keyPath: keyPath, value: value)
            await auth.reloadCurrentUser()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}

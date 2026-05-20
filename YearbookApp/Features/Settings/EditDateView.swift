//
//  EditDateView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import SwiftUI
import FirebaseAuth

/// Generic date editor for an optional Date field on User. Used for
/// birthday today; could be reused if you add other date fields.
struct EditDateView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    let title: String
    let keyPath: WritableKeyPath<User, Date?>

    @State private var date: Date
    @State private var hasValue: Bool      // toggle for "no birthday set"
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(title: String, keyPath: WritableKeyPath<User, Date?>,
         initialValue: Date?) {
        self.title = title
        self.keyPath = keyPath
        _date = State(initialValue: initialValue ?? Date())
        _hasValue = State(initialValue: initialValue != nil)
    }

    var body: some View {
        Form {
            Section {
                Toggle("Set a date", isOn: $hasValue)
                    .tint(YBColor.forest)

                if hasValue {
                    DatePicker(title, selection: $date,
                               in: ...Date(),                 // no future dates
                               displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
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
            let newValue: Date? = hasValue ? date : nil
            try await service.updateField(
                userID: uid, keyPath: keyPath, value: newValue)
            await auth.reloadCurrentUser()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}

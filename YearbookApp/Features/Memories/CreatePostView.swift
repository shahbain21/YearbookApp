//
//  CreatePostView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/23/26.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

/// Sheet to create a new memory post. Pick a photo, write a caption,
/// hit Post. The sheet is forced to a warm off-white background so
/// brand colors stay readable in both system modes.
struct CreatePostView: View {
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var caption = ""
    @State private var isPosting = false
    @State private var errorMessage: String?

    let onPosted: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: YBSpace.md) {
                    photoPicker
                    captionField
                    if let errorMessage {
                        Text(errorMessage)
                            .font(YBFont.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
            .background(YBColor.sheetBackground)
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(YBColor.forest)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Post") { Task { await submit() } }
                        .fontWeight(.bold)
                        .foregroundColor(YBColor.forest)
                        .disabled(photoData == nil || isPosting)
                }
            }
            .overlay {
                if isPosting {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView("Posting…").tint(YBColor.forest)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    // MARK: - Photo picker

    private var photoPicker: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            if let photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    YBColor.icyAqua.opacity(0.7)
                    VStack(spacing: YBSpace.xs) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 36))
                            .foregroundColor(YBColor.forest)
                        Text("Choose a photo")
                            .font(YBFont.caption)
                            .foregroundColor(YBColor.forest)
                    }
                }
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .onChange(of: photoItem) { _, item in
            Task { await loadPhoto(from: item) }
        }
    }

    /// Caption field. Custom placeholder so we control its color in
    /// both system modes; typed text always dark on the aqua tile.
    private var captionField: some View {
        ZStack(alignment: .topLeading) {
            if caption.isEmpty {
                Text("Write a caption…")
                    .font(.body)
                    .foregroundColor(YBColor.ink.opacity(0.4))
                    .padding(.horizontal, YBSpace.md + 4)
                    .padding(.vertical, YBSpace.md + 8)
                    .allowsHitTesting(false)
            }
            TextField("", text: $caption, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .foregroundColor(YBColor.ink)
                .tint(YBColor.ink)
                .environment(\.colorScheme, .light)
        }
        .background(YBColor.icyAqua.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Submit

    private func submit() async {
        guard let photoData, let uid = auth.user?.uid else { return }
        isPosting = true
        errorMessage = nil

        do {
            let imageService = ImageStorageService()
            let postService  = PostService()

            let imageURL = try await imageService.uploadPostImage(data: photoData)

            try await postService.createPost(
                authorID: uid,
                authorName: auth.currentUser?.name ?? "Cohort Member",
                imageName: imageURL,
                caption: caption.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            onPosted()
            dismiss()
        } catch {
            errorMessage = "Couldn't post: \(error.localizedDescription)"
        }
        isPosting = false
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        photoData = try? await item?.loadTransferable(type: Data.self)
    }
}

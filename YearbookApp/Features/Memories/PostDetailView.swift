//
//  PostDetailView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/27/26.
//


import SwiftUI
import FirebaseAuth

/// Detail view for a single post. Pushed onto the navigation stack
/// when a user taps a post card in the feed. For the author, edit
/// caption and delete post show as visible buttons at the bottom —
/// no menu, no swipe, no per-row sheet recycling. Just one view with
/// its own state, so SwiftUI can't fight us.
struct PostDetailView: View {
    let post: Post
    @ObservedObject var viewModel: MemoriesViewModel

    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showComments = false
    @State private var saveToast: String?
    @State private var savedFlash = false

    /// Look up the freshest version of this post from the view model.
    /// If the user edits the caption, the local post in the feed
    /// updates; this computed property keeps the detail in sync.
    private var currentPost: Post {
        viewModel.posts.first(where: { $0.id == post.id }) ?? post
    }

    private var isAuthor: Bool {
        currentPost.authorID == auth.user?.uid
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: YBSpace.md) {
                authorRow
                postImage
                actionRow
                if !currentPost.caption.isEmpty {
                    Text(currentPost.caption)
                        .font(YBFont.body)
                        .foregroundColor(YBColor.ink)
                        .padding(.top, YBSpace.sm)
                }
                if isAuthor {
                    Divider().padding(.vertical, YBSpace.md)
                    authorActions
                }
            }
            .padding()
        }
        .background(YBColor.sheetBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Post")
                    .font(YBFont.label)
                    .foregroundColor(YBColor.ink)
            }
        }
        .sheet(isPresented: $showComments) {
            CommentsView(post: currentPost)
        }
        .sheet(isPresented: $showEditSheet) {
            EditCaptionSheet(initialCaption: currentPost.caption) { newCaption in
                Task { await viewModel.updateCaption(of: currentPost, to: newCaption) }
            }
        }
        .alert("Delete this post?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deletePost(currentPost)
                    dismiss()       // back to feed after delete
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will also delete all comments. This can't be undone.")
        }
        .overlay(alignment: .top) {
            if let saveToast {
                Text(saveToast)
                    .font(YBFont.caption)
                    .padding(.horizontal, YBSpace.md)
                    .padding(.vertical, YBSpace.sm)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    .padding(.top, YBSpace.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Author row

    private var authorRow: some View {
        HStack(spacing: YBSpace.sm) {
            Circle()
                .fill(YBColor.icyAqua)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 1) {
                Text(currentPost.authorName)
                    .font(YBFont.label)
                    .foregroundColor(YBColor.ink)
                Text("Posted \(currentPost.date.formatted(.dateTime.month().day().year()))")
                    .font(YBFont.caption)
                    .foregroundColor(YBColor.inkSoft)
            }
            Spacer()
        }
    }

    // MARK: - Image

    private var postImage: some View {
        YBImage(source: currentPost.imageName)
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Action row (like / comment / save)

    private var actionRow: some View {
        HStack(spacing: YBSpace.lg) {
            Button {
                Task {
                    await viewModel.toggleLike(
                        on: currentPost,
                        currentUserID: auth.user?.uid ?? "")
                }
            } label: {
                HStack(spacing: YBSpace.xs) {
                    Image(systemName:
                        currentPost.likedBy.contains(auth.user?.uid ?? "")
                            ? "heart.fill" : "heart")
                        .foregroundColor(
                            currentPost.likedBy.contains(auth.user?.uid ?? "")
                                ? YBColor.heart : YBColor.forest)
                    Text("\(currentPost.likeCount)")
                        .foregroundColor(YBColor.ink)
                }
            }
            .buttonStyle(.borderless)

            Button { showComments = true } label: {
                Image(systemName: "bubble.right")
                    .foregroundColor(YBColor.forest)
            }
            .buttonStyle(.borderless)

            Button { Task { await saveImage() } } label: {
                Image(systemName: savedFlash ? "checkmark.circle.fill" : "square.and.arrow.down")
                    .foregroundColor(YBColor.forest)
                    .scaleEffect(savedFlash ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: savedFlash)
            }
            .buttonStyle(.borderless)

            Spacer()
        }
        .font(.title3)
    }

    // MARK: - Author actions (only visible for own posts)

    private var authorActions: some View {
        VStack(spacing: YBSpace.md) {
            Button { showEditSheet = true } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit caption")
                        .fontWeight(.medium)
                    Spacer()
                }
                .foregroundColor(YBColor.forest)
                .padding()
                .background(YBColor.icyAqua.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.borderless)

            Button { showDeleteAlert = true } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete post")
                        .fontWeight(.medium)
                    Spacer()
                }
                .foregroundColor(.red)
                .padding()
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.borderless)
        }
    }

    // MARK: - Save image to camera roll

    private func saveImage() async {
        do {
            try await PhotoSaver.save(remoteURL: currentPost.imageName)
            savedFlash = true
            showToast("Saved to Photos")
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            savedFlash = false
        } catch {
            showToast(error.localizedDescription)
        }
    }

    private func showToast(_ text: String) {
        withAnimation { saveToast = text }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { saveToast = nil }
        }
    }
}

// MARK: - Edit caption sheet

struct EditCaptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var caption: String

    let onSave: (String) -> Void

    init(initialCaption: String, onSave: @escaping (String) -> Void) {
        _caption = State(initialValue: initialCaption)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Caption") {
                    TextField("Write a caption…", text: $caption, axis: .vertical)
                        .lineLimit(3...8)
                        .foregroundColor(YBColor.ink)
                        .tint(YBColor.ink)
                }
                .listRowBackground(YBColor.paper)
            }
            .scrollContentBackground(.hidden)
            .background(YBColor.sheetBackground)
            .environment(\.colorScheme, .light)
            .navigationTitle("Edit Caption")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(YBColor.sheetBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(YBColor.forest)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(caption)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(YBColor.forest)
                }
            }
        }
    }
}

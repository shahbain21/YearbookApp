import SwiftUI

/// A single post in the feed. Uses a native SwiftUI Menu for the
/// edit/delete actions. The Menu's popover is system-controlled and
/// stays dark in dark mode, so the icons inside use brandText to
/// remain readable. The Edit Caption sheet uses the sheetBackground
/// pattern like all our other sheets.
struct PostCardView: View {
    let post: Post
    var isLiked: Bool = false
    var onLike: () -> Void = {}

    var isAuthor: Bool = false
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}

    @State private var showComments = false
    @State private var saveToast: String?
    @State private var savedFlash = false
    @StateObject private var commentsVM = CommentsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: YBSpace.sm) {
            authorRow
            postImage
            actionRow
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(YBFont.caption)
                    .foregroundColor(YBColor.ink)
            }
        }
        .padding(.vertical, YBSpace.sm)
        .task { await commentsVM.loadCount(postID: post.id) }
        .sheet(isPresented: $showComments) {
            CommentsView(post: post)
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
                .frame(width: 38, height: 38)
            VStack(alignment: .leading, spacing: 1) {
                Text(post.authorName)
                    .font(YBFont.label)
                    .foregroundColor(YBColor.ink)
                Text("Posted \(post.date.formatted(.dateTime.month().day().year(.twoDigits)))")
                    .font(YBFont.caption)
                    .foregroundColor(YBColor.inkSoft)
            }
            Spacer()
            if isAuthor {
                authorMenu
            }
        }
    }

    /// Native Menu — the system controls its popover background (dark
    /// in dark mode). Edit's pencil uses brandText so it stays visible
    /// against the dark popup; trash gets its destructive red tint.
    private var authorMenu: some View {
            Menu {
                Button("Edit caption") { onEdit() }
                Button("Delete post", role: .destructive) { onDelete() }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundColor(YBColor.ink)
                    .padding(YBSpace.md)
                    .contentShape(Rectangle())
            }
    }

    // MARK: - Image

    private var postImage: some View {
        YBImage(source: post.imageName)
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Action row (like / comment / save)

    private var actionRow: some View {
        HStack(spacing: YBSpace.md) {
            HStack(spacing: YBSpace.xs) {
                Button(action: onLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? YBColor.heart : YBColor.forest)
                }
                .buttonStyle(.plain)
                Text("\(post.likeCount)")
                    .font(YBFont.caption)
                    .foregroundColor(YBColor.ink)
            }

            HStack(spacing: YBSpace.xs) {
                Button { showComments = true } label: {
                    Image(systemName: "bubble.right")
                        .foregroundColor(YBColor.forest)
                }
                .buttonStyle(.plain)
                if commentsVM.commentCount > 0 {
                    Text("\(commentsVM.commentCount)")
                        .font(YBFont.caption)
                        .foregroundColor(YBColor.ink)
                }
            }

            Button { Task { await saveImage() } } label: {
                Image(systemName: savedFlash ? "checkmark.circle.fill" : "square.and.arrow.down")
                    .foregroundColor(YBColor.forest)
                    .scaleEffect(savedFlash ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: savedFlash)
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    // MARK: - Save image to camera roll

    private func saveImage() async {
        do {
            try await PhotoSaver.save(remoteURL: post.imageName)
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

/// Sheet for editing a post's caption. File-scope (not private) so
/// MemoriesView can present it. Soft off-white background like all
/// other sheets so it reads in both system modes.
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

#Preview {
    PostCardView(post: MockData.posts[0])
        .environmentObject(AuthService())
        .padding()
}

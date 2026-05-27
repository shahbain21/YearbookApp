import SwiftUI

/// A single post card in the feed. Simplified — no menu, no sheets,
/// no per-card state for actions. Tap target is the whole card
/// (handled by the parent's NavigationLink). The action row buttons
/// (like, comment, save) live here as proper Buttons.
struct PostCardView: View {
    let post: Post
    var isLiked: Bool = false
    var onLike: () -> Void = {}

    @State private var showComments = false
    @State private var saveToast: String?
    @State private var savedFlash = false

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
    // .buttonStyle(.borderless) on each so they don't trigger the
    // parent NavigationLink when tapped — a known SwiftUI pattern.

    private var actionRow: some View {
        HStack(spacing: YBSpace.md) {
            Button(action: onLike) {
                HStack(spacing: YBSpace.xs) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? YBColor.heart : YBColor.forest)
                    Text("\(post.likeCount)")
                        .font(YBFont.caption)
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

#Preview {
    PostCardView(post: MockData.posts[0])
        .environmentObject(AuthService())
        .padding()
}

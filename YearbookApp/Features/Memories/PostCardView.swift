import SwiftUI

struct PostCardView: View {
    let post: Post
    var isLiked: Bool = false
    var onLike: () -> Void = {}

    @State private var showComments = false
    @StateObject private var commentsVM = CommentsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: YBSpace.sm) {
            // Author row
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

            // Image
            YBImage(source: post.imageName)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Like + comment row
            HStack(spacing: YBSpace.md) {
                // Like
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

                // Comment
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

                Spacer()
            }

            // Caption
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
    }
}

#Preview {
    PostCardView(post: MockData.posts[0])
        .environmentObject(AuthService())
        .padding()
}

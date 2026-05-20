import SwiftUI

/// A single post in the feed: author, image, like count, caption.
/// No background — posts sit directly on the notebook-paper background.
struct PostCardView: View {
    let post: Post
    var isLiked: Bool = false
    var onLike: () -> Void = {}

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

            // Like count
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

            // Caption
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(YBFont.caption)
                    .foregroundColor(YBColor.ink)
            }
        }
        .padding(.vertical, YBSpace.sm)
    }
}

#Preview {
    PostCardView(post: MockData.posts[0])
        .padding()
}

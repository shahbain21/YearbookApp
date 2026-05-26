import SwiftUI
import FirebaseAuth

/// Sheet of comments for one post. Soft off-white background so the
/// composer's airplane icon and brand-tinted text stay readable in
/// both system modes.
struct CommentsView: View {
    let post: Post

    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CommentsViewModel()
    @State private var newComment = ""
    @State private var commentToDelete: Comment?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                commentList
                composer
            }
            .background(YBColor.sheetBackground)
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(YBColor.sheetBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(YBColor.ink)
                    }
                }
            }
            .alert(
                "Delete this comment?",
                isPresented: Binding(
                    get: { commentToDelete != nil },
                    set: { if !$0 { commentToDelete = nil } }
                )
            ) {
                Button("Delete", role: .destructive) {
                    if let comment = commentToDelete {
                        Task {
                            await viewModel.delete(
                                comment: comment,
                                currentUserID: auth.user?.uid ?? "",
                                postAuthorID: post.authorID)
                        }
                    }
                    commentToDelete = nil
                }
                Button("Cancel", role: .cancel) { commentToDelete = nil }
            } message: {
                Text("This can't be undone.")
            }
        }
        .task { await viewModel.loadComments(postID: post.id) }
    }

    // MARK: - List

    @ViewBuilder
    private var commentList: some View {
        if viewModel.isLoading && viewModel.comments.isEmpty {
            Spacer()
            ProgressView().tint(YBColor.forest)
            Spacer()
        } else if viewModel.comments.isEmpty {
            Spacer()
            Text("Be the first to comment.")
                .font(YBFont.caption)
                .foregroundColor(YBColor.inkSoft)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: YBSpace.md) {
                    ForEach(viewModel.comments) { comment in
                        commentRow(comment)
                        Divider()
                    }
                }
                .padding()
            }
        }
    }

    private func commentRow(_ comment: Comment) -> some View {
        let currentUID = auth.user?.uid ?? ""
        let canDelete = viewModel.canDelete(
            comment: comment,
            currentUserID: currentUID,
            postAuthorID: post.authorID
        )

        return HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: YBSpace.xs) {
                HStack {
                    Text(comment.authorName)
                        .font(YBFont.label)
                        .foregroundColor(YBColor.ink)
                    Text(comment.createdAt.formatted(.relative(presentation: .named)))
                        .font(YBFont.metadata)
                        .foregroundColor(YBColor.inkSoft)
                    Spacer()
                }
                Text(comment.text)
                    .font(YBFont.body)
                    .foregroundColor(YBColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()

            if canDelete {
                Menu {
                    Button("Delete", role: .destructive) {
                        commentToDelete = comment
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(YBColor.inkSoft)
                        .padding(YBSpace.sm)
                }
            }
        }
    }

    // MARK: - Composer

    private var composer: some View {
        HStack(spacing: YBSpace.sm) {
            TextField("Add a comment…", text: $newComment, axis: .vertical)
                .lineLimit(1...4)
                .padding(YBSpace.sm)
                .foregroundColor(YBColor.ink)
                .tint(YBColor.ink)
                .background(YBColor.icyAqua.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .environment(\.colorScheme, .light)

            Button {
                Task {
                    let text = newComment
                    newComment = ""
                    await viewModel.post(
                        text: text,
                        on: post.id,
                        authorID: auth.user?.uid ?? "",
                        authorName: auth.currentUser?.name ?? "Cohort Member"
                    )
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(YBColor.forest)
            }
            .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(YBColor.sheetBackground)
    }
}

#Preview {
    CommentsView(post: MockData.posts[0])
        .environmentObject(AuthService())
}

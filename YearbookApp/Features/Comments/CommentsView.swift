//
//  CommentsView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import SwiftUI
import FirebaseAuth

/// Sheet of comments for one post. Slides up from a post card.
struct CommentsView: View {
    let post: Post

    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CommentsViewModel()
    @State private var newComment = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                commentList
                composer
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundColor(.primary)
                    }
                }
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
                .foregroundColor(.secondary)
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

        return VStack(alignment: .leading, spacing: YBSpace.xs) {
            HStack {
                Text(comment.authorName)
                    .font(YBFont.label)
                    .foregroundColor(.primary)
                Text(comment.createdAt.formatted(.relative(presentation: .named)))
                    .font(YBFont.metadata)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Text(comment.text)
                .font(YBFont.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .swipeActions(edge: .trailing) {
            if canDelete {
                Button(role: .destructive) {
                    Task {
                        await viewModel.delete(
                            comment: comment,
                            currentUserID: currentUID,
                            postAuthorID: post.authorID)
                    }
                } label: { Label("Delete", systemImage: "trash") }
            }
        }
    }

    // MARK: - Composer

    private var composer: some View {
        HStack(spacing: YBSpace.sm) {
            TextField("Add a comment…", text: $newComment, axis: .vertical)
                .lineLimit(1...4)
                .padding(YBSpace.sm)
                .background(YBColor.icyAqua.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))

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
        .background(.ultraThinMaterial)
    }
}

#Preview {
    CommentsView(post: MockData.posts[0])
        .environmentObject(AuthService())
}

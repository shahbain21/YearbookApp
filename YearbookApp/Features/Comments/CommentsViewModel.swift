//
//  CommentsViewModel.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import SwiftUI
import Combine

@MainActor
final class CommentsViewModel: ObservableObject {

    @Published var comments: [Comment] = []
    @Published var commentCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = CommentService()

    /// Load the comment list for one post.
    func loadComments(postID: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await service.fetchComments(for: postID)
            comments = fetched
            commentCount = fetched.count
        } catch {
            errorMessage = "Couldn't load comments."
        }
        isLoading = false
    }

    /// Just the count — used by the post card badge without loading
    /// every comment.
    func loadCount(postID: String) async {
        do {
            commentCount = try await service.fetchComments(for: postID).count
        } catch {
            commentCount = 0
        }
    }

    /// Post a new comment, then append it locally.
    func post(text: String, on postID: String,
              authorID: String, authorName: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            let new = try await service.addComment(
                postID: postID, authorID: authorID,
                authorName: authorName, text: trimmed)
            comments.append(new)
            commentCount += 1
        } catch {
            errorMessage = "Couldn't post comment."
        }
    }

    /// Delete a comment locally + remotely.
    func delete(comment: Comment, currentUserID: String, postAuthorID: String) async {
        guard canDelete(comment: comment,
                        currentUserID: currentUserID,
                        postAuthorID: postAuthorID) else { return }
        do {
            try await service.deleteComment(postID: comment.postID,
                                            commentID: comment.id)
            comments.removeAll { $0.id == comment.id }
            commentCount = max(0, commentCount - 1)
        } catch {
            errorMessage = "Couldn't delete comment."
        }
    }

    /// True if currentUser is allowed to delete this comment.
    /// Either: they wrote it, or they own the post it's on.
    func canDelete(comment: Comment, currentUserID: String,
                   postAuthorID: String) -> Bool {
        comment.authorID == currentUserID || postAuthorID == currentUserID
    }
}
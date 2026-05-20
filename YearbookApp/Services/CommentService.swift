//
//  CommentService.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import Foundation
import FirebaseFirestore

/// Reads, writes, and deletes Comment documents in Firestore.
///
/// Storage layout: comments live in a SUBCOLLECTION under each post,
/// so the path is posts/{postID}/comments/{commentID}. This makes
/// "fetch comments for this post" a single bounded query, and
/// deleting a post would clean up its comments naturally.
final class CommentService {

    private let db = Firestore.firestore()

    private func collection(for postID: String) -> CollectionReference {
        db.collection("posts").document(postID).collection("comments")
    }

    /// All comments on a post, oldest first.
    func fetchComments(for postID: String) async throws -> [Comment] {
        let snapshot = try await collection(for: postID)
            .order(by: "createdAt")
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: Comment.self) }
    }

    /// Add a new comment.
    func addComment(postID: String, authorID: String, authorName: String,
                    text: String) async throws -> Comment {
        let docRef = collection(for: postID).document()
        let comment = Comment(
            id: docRef.documentID,
            postID: postID,
            authorID: authorID,
            authorName: authorName,
            text: text,
            createdAt: Date()
        )
        try docRef.setData(from: comment)
        return comment
    }

    /// Delete a comment.
    func deleteComment(postID: String, commentID: String) async throws {
        try await collection(for: postID).document(commentID).delete()
    }
}
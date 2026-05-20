//
//  PostService.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import Foundation
import FirebaseFirestore

/// Reads and writes Post documents in Firestore.
final class PostService {

    private let db = Firestore.firestore()
    private var postsCollection: CollectionReference {
        db.collection("posts")
    }

    /// All posts, newest first. Backs the Memories feed.
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await postsCollection
            .order(by: "date", descending: true)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: Post.self) }
    }

    /// Create a new post. Firestore assigns the document ID, which we
    /// also use as the post's `id`.
    func createPost(authorID: String, authorName: String,
                    imageName: String, caption: String) async throws {
        let docRef = postsCollection.document()
        let post = Post(
            id: docRef.documentID,
            authorID: authorID,
            authorName: authorName,
            imageName: imageName,
            caption: caption,
            date: Date(),
            likeCount: 0,
            likedBy: []
        )
        try docRef.setData(from: post)
    }

    /// Toggle a like. Uses a Firestore transaction so the count and
    /// the likedBy array stay consistent even with concurrent edits.
    func toggleLike(postID: String, userID: String) async throws {
        let docRef = postsCollection.document(postID)
        _ = try await db.runTransaction { transaction, errorPointer in
            do {
                let snapshot = try transaction.getDocument(docRef)
                var post = try snapshot.data(as: Post.self)
                if post.likedBy.contains(userID) {
                    post.likedBy.removeAll { $0 == userID }
                    post.likeCount = max(0, post.likeCount - 1)
                } else {
                    post.likedBy.append(userID)
                    post.likeCount += 1
                }
                try transaction.setData(from: post, forDocument: docRef)
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
}
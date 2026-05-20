//
//  Comment.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import Foundation

/// A comment on a Post. Stored in Firestore under
/// posts/{postID}/comments/{commentID}.
struct Comment: Identifiable, Codable {
    let id: String
    let postID: String
    let authorID: String
    let authorName: String      // denormalized, same reasoning as Post
    var text: String
    var createdAt: Date
}
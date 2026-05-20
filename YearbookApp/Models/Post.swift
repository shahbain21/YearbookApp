//
//  Post.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//

import Foundation

/// A memory post. Stored in Firestore. The `id` matches the
/// Firestore document ID.
struct Post: Identifiable, Codable {
    let id: String
    let authorID: String       // matches User.id / Firebase uid
    let authorName: String     // denormalized so the feed doesn't need a lookup
    var imageName: String      // asset name or Storage URL later
    var caption: String
    var date: Date
    var likeCount: Int
    var likedBy: [String]      // user IDs who liked it
}

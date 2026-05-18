//
//  Post.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//

import Foundation

// A single memory post in the feed.
struct Post: Identifiable {
    let id: String
    let authorName: String
    var imageName: String   
    var caption: String
    var date: Date
    var likeCount: Int
}

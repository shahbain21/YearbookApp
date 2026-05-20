//
//  User.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import Foundation

/// A cohort member. Stored in Firestore under the user's Firebase
/// Auth uid as the document ID.
struct User: Identifiable, Codable {
    let id: String          // matches the Firebase Auth uid
    var name: String
    var email: String
    var photoName: String?  // asset name or a Storage URL later
    var quote: String = ""
    var role: String?
    var linkedIn: String?
    var instagram: String?
    var cohort: String = "" // "AM", "PM", etc. — flagged earlier
}

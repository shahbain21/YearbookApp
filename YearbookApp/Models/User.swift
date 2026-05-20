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
    let id: String
    var name: String
    var email: String
    var photoName: String?
    var quote: String = ""
    var role: String?
    var linkedIn: String = ""
    var instagram: String = ""
    var domain: String = ""
    var cohort: String = ""
}

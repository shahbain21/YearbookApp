//
//  User.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import Foundation

/// A cohort member.
struct User: Identifiable {
    let id: String
    var name: String
    var photoName: String?    // asset name now; a URL later
    var quote: String = ""
    var role: String?         // e.g. "Project Manager" — nil for most
    var linkedIn: String?
    var instagram: String?
}

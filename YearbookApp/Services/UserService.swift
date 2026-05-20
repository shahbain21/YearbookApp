//
//  UserService.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import Foundation
import FirebaseFirestore

// Reads and writes User profiles in Firestore.
final class UserService {

    private let db = Firestore.firestore()
    private var usersCollection: CollectionReference {
        db.collection("users")
    }

    // Create or overwrite a user's profile document.
    func saveUser(_ user: User) async throws {
        try usersCollection.document(user.id).setData(from: user)
    }

    // Fetch one user by their uid. Returns nil if no profile exists.
    func fetchUser(id: String) async throws -> User? {
        let snapshot = try await usersCollection.document(id).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: User.self)
    }

    // Fetch all users — backs the Cohort screen.
    func fetchAllUsers() async throws -> [User] {
        let snapshot = try await usersCollection.getDocuments()
        return try snapshot.documents.map { try $0.data(as: User.self) }
    }
}

//
//  MemoriesViewModel.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//


import SwiftUI
import Combine

/// Drives the Memories feed: loads posts from Firestore and handles
/// like toggling with an optimistic UI update.
@MainActor
final class MemoriesViewModel: ObservableObject {

    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let postService = PostService()

    /// Load the feed. Called on appear and on pull-to-refresh.
    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        do {
            posts = try await postService.fetchPosts()
        } catch {
            errorMessage = "Couldn't load memories."
        }
        isLoading = false
    }

    /// Optimistic like: update the UI immediately, then confirm with
    /// the service. If the call fails, revert.
    func toggleLike(on post: Post, currentUserID: String) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let original = posts[index]

        var optimistic = original
        if optimistic.likedBy.contains(currentUserID) {
            optimistic.likedBy.removeAll { $0 == currentUserID }
            optimistic.likeCount = max(0, optimistic.likeCount - 1)
        } else {
            optimistic.likedBy.append(currentUserID)
            optimistic.likeCount += 1
        }
        posts[index] = optimistic

        do {
            try await postService.toggleLike(
                postID: post.id, userID: currentUserID)
        } catch {
            posts[index] = original          // revert
            errorMessage = "Couldn't update like."
        }
    }
}
//
//  MemoriesViewModel.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/20/26.
//

import SwiftUI
import Combine

/// Drives the Memories feed. Optimistic updates for delete and edit
/// so we don't reload the entire feed after every action — full
/// reloads break SwiftUI view identity.
@MainActor
final class MemoriesViewModel: ObservableObject {

    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let postService = PostService()

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

    func deletePost(_ post: Post) async {
        posts.removeAll { $0.id == post.id }
        do {
            try await postService.deletePost(postID: post.id)
        } catch {
            errorMessage = "Couldn't delete post."
            await loadPosts()
        }
    }

    func updateCaption(of post: Post, to newCaption: String) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let trimmed = newCaption.trimmingCharacters(in: .whitespacesAndNewlines)
        let original = posts[index].caption
        posts[index].caption = trimmed
        do {
            try await postService.updateCaption(postID: post.id, caption: trimmed)
        } catch {
            posts[index].caption = original
            errorMessage = "Couldn't update caption."
        }
    }

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
            posts[index] = original
            errorMessage = "Couldn't update like."
        }
    }
}

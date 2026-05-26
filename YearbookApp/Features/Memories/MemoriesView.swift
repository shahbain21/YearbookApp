import SwiftUI
import FirebaseAuth

/// The Memories feed. Edit and delete actions are triggered by closures
/// from PostCardView's Menu — when a closure fires, we set state here
/// which presents the appropriate sheet/alert. The Menu itself opens
/// in a popover attached to the card's ... button.
struct MemoriesView: View {
    @EnvironmentObject private var auth: AuthService
    @StateObject private var viewModel = MemoriesViewModel()

    @State private var showCreate = false
    @State private var editPost: Post?      // post whose caption is being edited
    @State private var deletePost: Post?    // post being deleted

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("bg_memories")
                    .resizable()
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: YBSpace.lg) {
                        ForEach(viewModel.posts) { post in
                            PostCardView(
                                post: post,
                                isLiked: post.likedBy.contains(auth.user?.uid ?? ""),
                                onLike: {
                                    Task {
                                        await viewModel.toggleLike(
                                            on: post,
                                            currentUserID: auth.user?.uid ?? "")
                                    }
                                },
                                isAuthor: post.authorID == auth.user?.uid,
                                onEdit: { editPost = post },
                                onDelete: { deletePost = post }
                            )
                        }
                    }
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
                .refreshable { await viewModel.loadPosts() }
                .padding(.top,      geo.size.height * 0.19)
                .padding(.bottom,   geo.size.height * 0.13)
                .padding(.leading,  geo.size.width  * 0.20)
                .padding(.trailing, geo.size.width  * 0.06)
            }
            // Floating "+" as an overlay so positioning doesn't make
            // the Button's hit area fill the screen.
            .overlay(alignment: .bottomTrailing) {
                Button { showCreate = true } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(YBColor.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(YBColor.forest))
                        .shadow(radius: 4)
                }
                .padding(.trailing, YBSpace.lg)
                .padding(.bottom, geo.size.height * 0.15)
            }
        }
        .task { await viewModel.loadPosts() }
        .sheet(isPresented: $showCreate) {
            CreatePostView { Task { await viewModel.loadPosts() } }
                .environmentObject(auth)
        }
        // Edit caption sheet — opens for whichever post the menu picked.
        .sheet(item: $editPost) { post in
            EditCaptionSheet(initialCaption: post.caption) { newCaption in
                Task { await viewModel.updateCaption(of: post, to: newCaption) }
            }
        }
        // Delete confirmation alert.
        .alert(
            "Delete this post?",
            isPresented: Binding(
                get: { deletePost != nil },
                set: { if !$0 { deletePost = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                if let post = deletePost {
                    Task { await viewModel.deletePost(post) }
                }
                deletePost = nil
            }
            Button("Cancel", role: .cancel) { deletePost = nil }
        } message: {
            Text("This will also delete all comments. This can't be undone.")
        }
    }
}

#Preview {
    MemoriesView().environmentObject(AuthService())
}

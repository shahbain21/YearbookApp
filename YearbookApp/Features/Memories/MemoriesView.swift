import SwiftUI
import FirebaseAuth

/// The Memories feed. Uses NavigationStack + List + NavigationLink
/// instead of ScrollView + custom menus — native iOS pattern that
/// fixes the gesture/menu instability we hit with the previous
/// approach. Tap a post to push PostDetailView where edit/delete
/// live as proper buttons.
struct MemoriesView: View {
    @EnvironmentObject private var auth: AuthService
    @StateObject private var viewModel = MemoriesViewModel()

    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    Image("bg_memories")
                        .resizable()
                        .ignoresSafeArea()

                    List {
                        ForEach(viewModel.posts) { post in
                            NavigationLink {
                                PostDetailView(post: post, viewModel: viewModel)
                                    .environmentObject(auth)
                            } label: {
                                PostCardView(
                                    post: post,
                                    isLiked: post.likedBy.contains(auth.user?.uid ?? ""),
                                    onLike: {
                                        Task {
                                            await viewModel.toggleLike(
                                                on: post,
                                                currentUserID: auth.user?.uid ?? "")
                                        }
                                    }
                                )
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: YBSpace.sm,
                                                     leading: 0,
                                                     bottom: YBSpace.sm,
                                                     trailing: 0))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .refreshable { await viewModel.loadPosts() }
                    .padding(.top,      geo.size.height * 0.19)
                    .padding(.bottom,   geo.size.height * 0.13)
                    .padding(.leading,  geo.size.width  * 0.20)
                    .padding(.trailing, geo.size.width  * 0.06)
                }
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
            .navigationBarHidden(true)
        }
        .task { await viewModel.loadPosts() }
        .sheet(isPresented: $showCreate) {
            CreatePostView { Task { await viewModel.loadPosts() } }
                .environmentObject(auth)
        }
    }
}

#Preview {
    MemoriesView().environmentObject(AuthService())
}

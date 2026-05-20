import SwiftUI
import FirebaseAuth

struct MemoriesView: View {
    @EnvironmentObject private var auth: AuthService
    @StateObject private var viewModel = MemoriesViewModel()
    @State private var showCreate = false

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
                                }
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

                // Floating "+" to create a post.
                // Sheet is commented out until image storage is sorted.
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
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
            }
        }
        .task { await viewModel.loadPosts() }
//        .sheet(isPresented: $showCreate) {
//            CreatePostView { Task { await viewModel.loadPosts() } }
//        }
    }
}

#Preview {
    MemoriesView().environmentObject(AuthService())
}

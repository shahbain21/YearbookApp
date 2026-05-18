import SwiftUI

// The Memories feed
struct MemoriesView: View {
    private let posts = MockData.posts

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("bg_memories")
                    .resizable()
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: YBSpace.lg) {
                        ForEach(posts) { post in
                            PostCardView(post: post)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
                .padding(.top,      geo.size.height * 0.19)
                .padding(.bottom,   geo.size.height * 0.13)
                .padding(.leading,  geo.size.width  * 0.20)
                .padding(.trailing, geo.size.width  * 0.06)
            }
        }
    }
}

#Preview {
    MemoriesView()
}

import SwiftUI

/// First-launch intro carousel. Designer-baked full-bleed images for
/// all four pages. The TabView is used only to capture the swipe and
/// show the page dots — the actual image renders behind it edge-to-edge
/// and cross-fades between pages.
struct IntroCarouselView: View {
    /// Called when the user taps Get Started — moves to SignInView.
    let onFinished: () -> Void

    @State private var page = 0

    /// All four pages. Asset names must match what's added to
    /// Assets.xcassets. Until each asset ships, a title-on-green
    /// fallback renders so the carousel still works.
    private let pages: [IntroPage] = [
        IntroPage(asset: "intro_welcome", title: "Welcome"),
        IntroPage(asset: "intro_share",   title: "Share"),
        IntroPage(asset: "intro_post",    title: "Post"),
        IntroPage(asset: "intro_connect", title: "Connect")
    ]

    var body: some View {
        ZStack {
            // The current page's image, full-bleed behind everything.
            // `.id(page)` makes SwiftUI treat each page's image as a
            // new view, so .transition(.opacity) animates between them.
            background(for: pages[page])
                .id(page)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.4), value: page)

            // TabView captures the swipe and renders the page dots,
            // but its actual pages are transparent — the image behind
            // it is what the user sees.
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    Color.clear.tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Get Started button — only on the last page.
            if page == pages.count - 1 {
                VStack {
                    Spacer()
                    Button(action: onFinished) {
                        Text("Get Started")
                            .font(YBFont.label)
                            .foregroundColor(YBColor.forest)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Capsule().fill(YBColor.white))
                    }
                    .padding(.horizontal, YBSpace.xl)
                    .padding(.bottom, 60)   // above the page dots
                    .transition(.opacity)
                }
            }
        }
    }

    // MARK: - Background

    /// Designer image if present; styled fallback text otherwise.
    @ViewBuilder
    private func background(for intro: IntroPage) -> some View {
        if UIImage(named: intro.asset) != nil {
            Image(intro.asset)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        } else {
            ZStack {
                YBColor.forest.ignoresSafeArea()
                Text(intro.title)
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .italic()
                    .foregroundColor(YBColor.white)
            }
        }
    }
}

/// Configuration for one carousel page.
private struct IntroPage {
    let asset: String   // expected asset name in Assets.xcassets
    let title: String   // fallback text if the asset isn't there yet
}

#Preview {
    IntroCarouselView(onFinished: {})
}

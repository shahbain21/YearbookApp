import SwiftUI

/// The Profile screen — shows the signed-in user. The gear button
/// opens Settings as a sheet (Settings is modal, not a tab).
struct ProfileView: View {
    private let user = MockData.currentUser
    @State private var showSettings = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("bg_profile")
                    .resizable()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: YBSpace.md) {
                        // Polaroid-style photo
                        YBImage(source: user.photoName)
                            .frame(width: 180, height: 200)
                            .clipped()
                            .padding(YBSpace.sm)
                            .background(YBColor.white)
                            .shadow(color: .black.opacity(0.15), radius: 5, y: 3)

                        Text(user.name)
                            .font(YBFont.heading)
                            .foregroundColor(YBColor.ink)

                        if !user.quote.isEmpty {
                            Text("\"\(user.quote)\"")
                                .font(YBFont.caption)
                                .italic()
                                .foregroundColor(YBColor.inkSoft)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, YBSpace.md)
                        }

                        if let role = user.role {
                            Text(role.uppercased())
                                .font(YBFont.label)
                                .foregroundColor(YBColor.forest)
                        }

                        socialLinks
                    }
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
                .padding(.top,      geo.size.height * 0.19)
                .padding(.bottom,   geo.size.height * 0.13)
                .padding(.leading,  geo.size.width  * 0.20)
                .padding(.trailing, geo.size.width  * 0.06)

                // Gear button, top-right
                settingsButton
            }
        }
        .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
    }

    @ViewBuilder
    private var socialLinks: some View {
        HStack(spacing: YBSpace.lg) {
            if user.linkedIn != nil {
                Image(systemName: "link")
                    .font(.title2)
                    .foregroundColor(YBColor.forest)
            }
            if user.instagram != nil {
                Image(systemName: "camera")
                    .font(.title2)
                    .foregroundColor(YBColor.forest)
            }
        }
    }

    private var settingsButton: some View {
        VStack {
            HStack {
                Spacer()
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(YBColor.forest)
                }
            }
            Spacer()
        }
        .padding(.top, 60)
        .padding(.trailing, 30)
    }
}

#Preview {
    ProfileView()
}

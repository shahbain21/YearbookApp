//
//  YearbookAppApp.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct YearbookApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var auth = AuthService()
    @State private var showSplash = true

    /// Persisted to UserDefaults so the intro only shows on first launch.
    @AppStorage("hasSeenIntro") private var hasSeenIntro: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView(onFinished: { showSplash = false })
                } else if !hasSeenIntro {
                    IntroCarouselView(onFinished: { hasSeenIntro = true })
                } else if auth.user == nil {
                    SignInView()
                } else if auth.currentUser == nil {
                    loadingState
                } else if auth.currentUser?.hasCompletedOnboarding == false {
                    OnboardingView()
                } else {
                    RootTabView()
                }
            }
            .environmentObject(auth)
            .animation(.easeInOut, value: showSplash)
            .animation(.easeInOut, value: hasSeenIntro)
            .animation(.easeInOut, value: auth.user == nil)
            .animation(.easeInOut, value: auth.currentUser?.hasCompletedOnboarding)
        }
    }

    @ViewBuilder
    private var loadingState: some View {
        ZStack {
            YBColor.forest.ignoresSafeArea()
            VStack(spacing: YBSpace.md) {
                ProgressView().tint(YBColor.white)
                Text("Loading your profile…")
                    .font(YBFont.caption)
                    .foregroundColor(YBColor.white.opacity(0.8))
                Button("Sign Out") { auth.signOut() }
                    .padding(.top, YBSpace.lg)
                    .foregroundColor(YBColor.white)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await auth.reloadCurrentUser()
        }
    }
}

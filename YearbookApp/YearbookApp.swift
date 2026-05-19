//
//  YearbookAppApp.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//

import SwiftUI
import FirebaseCore

/// Connects Firebase at launch.
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

    /// One AuthService for the whole app, shared via the environment.
    @StateObject private var auth = AuthService()

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView(onFinished: { showSplash = false })
                } else if auth.user == nil {
                    SignInView()             // signed out
                } else {
                    RootTabView()            // signed in
                }
            }
            .environmentObject(auth)
            // Smooth fade between splash / sign-in / app.
            .animation(.easeInOut, value: showSplash)
            .animation(.easeInOut, value: auth.user == nil)
        }
    }
}

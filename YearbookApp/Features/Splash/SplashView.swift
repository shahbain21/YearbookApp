//
//  SplashView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//


import SwiftUI

// Splash screen shown briefly on launch, then hands off to the app.
struct SplashView: View {
    // Called when the splash finishes so the parent can advance.
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            if UIImage(named: "splash_background") != nil {
                Image("splash_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                // Fallback so the app still runs if the asset is missing.
                YBColor.forest.ignoresSafeArea()
                Text("APPLE DEVELOPER ACADEMY\nAM COHORT")
                    .font(YBFont.label)
                    .foregroundColor(YBColor.white)
                    .multilineTextAlignment(.center)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)  // 1.8s
            onFinished()
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}

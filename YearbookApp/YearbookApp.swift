//
//  YearbookAppApp.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//

import SwiftUI

@main
struct YearbookApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView(onFinished: { showSplash = false })
            } else {
                MemoriesView() 
            }
        }
    }
}

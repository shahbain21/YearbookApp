//
//  ProfileView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            YBColor.forest.opacity(0.1).ignoresSafeArea()
            Text("Profile — coming soon")
                .font(YBFont.label)
                .foregroundColor(YBColor.forest)
        }
    }
}

#Preview { ProfileView() }
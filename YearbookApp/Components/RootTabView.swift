//
//  RootTabView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI

/// Root navigation. Four tabs; Settings is a sheet from Profile (not a
/// tab), Collage is reached from Memories — both added later.
struct RootTabView: View {
    var body: some View {
        TabView {
            MemoriesView()
                .tabItem { Label("Memories", systemImage: "square.on.square.badge.person.crop.fill") }

            EventsView()
                .tabItem { Label("Events", systemImage: "calendar") }

            CohortView()
                .tabItem { Label("Cohort", systemImage: "circle.hexagonpath") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(YBColor.forest)
    }
}

#Preview {
    RootTabView()
}

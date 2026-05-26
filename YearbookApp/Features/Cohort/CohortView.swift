//
//  CohortView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//

import SwiftUI

/// The Cohort screen — a 2-column grid of all academy members,
/// loaded from Firestore.
struct CohortView: View {
    @StateObject private var viewModel = CohortViewModel()
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("bg_cohort")
                    .resizable()
                    .ignoresSafeArea()

                content(geo: geo)
            }
        }
        .task { await viewModel.loadUsers() }
    }

    @ViewBuilder
    private func content(geo: GeometryProxy) -> some View {
        if viewModel.isLoading && viewModel.users.isEmpty {
            ProgressView().tint(YBColor.forest)
        } else if let error = viewModel.errorMessage, viewModel.users.isEmpty {
            errorState(error)
        } else if viewModel.users.isEmpty {
            emptyState
        } else {
            grid
                .padding(.top,      geo.size.height * 0.19)
                .padding(.bottom,   geo.size.height * 0.13)
                .padding(.leading,  geo.size.width  * 0.20)
                .padding(.trailing, geo.size.width  * 0.06)
        }
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: YBSpace.lg) {
                ForEach(viewModel.users) { user in
                    memberCell(user)
                }
            }
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .refreshable { await viewModel.loadUsers() }
    }

    private func memberCell(_ user: User) -> some View {
        VStack(spacing: YBSpace.xs) {
            YBImage(source: user.photoName)
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(user.name)
                .font(YBFont.label)
                .foregroundColor(YBColor.ink)
        }
    }

    private var emptyState: some View {
        VStack(spacing: YBSpace.sm) {
            Image(systemName: "person.3")
                .font(.system(size: 40))
                .foregroundColor(YBColor.forest)
            Text("No members yet")
                .font(YBFont.label)
                .foregroundColor(YBColor.ink)
            Text("As cohort members sign up, they'll appear here.")
                .font(YBFont.caption)
                .foregroundColor(YBColor.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, YBSpace.xl)
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: YBSpace.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(YBColor.heart)
            Text(message)
                .font(YBFont.caption)
                .foregroundColor(YBColor.inkSoft)
            Button("Retry") {
                Task { await viewModel.loadUsers() }
            }
            .foregroundColor(YBColor.forest)
        }
    }
}

#Preview { CohortView() }

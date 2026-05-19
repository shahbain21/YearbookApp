//
//  CohortView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI

//  The Cohort screen: a grid of all academy members.
struct CohortView: View {
    private let users = MockData.users
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("bg_cohort")
                    .resizable()
                    .ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: YBSpace.lg) {
                        ForEach(users) { user in
                            memberCell(user)
                        }
                    }
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
                .padding(.top,      geo.size.height * 0.19)
                .padding(.bottom,   geo.size.height * 0.13)
                .padding(.leading,  geo.size.width  * 0.20)
                .padding(.trailing, geo.size.width  * 0.06)
            }
        }
    }

    /// One member: photo above their name.
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
}

#Preview {
    CohortView()
}

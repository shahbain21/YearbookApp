//
//  SpiralFrame.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI

/// The spiral-bound notebook frame that wraps content on the main
/// screens. Build once, reuse everywhere.
///
/// Uses a "spiral_binding" transparent PNG if you've added one;
/// otherwise draws simple rings so the app still looks intentional.
struct SpiralFrame<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.leading, 18)        // room for the binding
            .background(YBColor.paper)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(alignment: .leading) { binding }
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    @ViewBuilder
    private var binding: some View {
        if UIImage(named: "spiral_binding") != nil {
            Image("spiral_binding")
                .resizable()
                .scaledToFit()
                .padding(.vertical, 6)
        } else {
            GeometryReader { geo in
                let count = max(8, Int(geo.size.height / 26))
                VStack(spacing: 14) {
                    ForEach(0..<count, id: \.self) { _ in
                        Circle()
                            .stroke(YBColor.ink.opacity(0.55), lineWidth: 2.5)
                            .frame(width: 14, height: 14)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: 22)
        }
    }
}

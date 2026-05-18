//
//  YBImage.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI

/// One image view for the whole app. Handles a local asset name now,
/// a remote URL later (Firebase), and shows a placeholder if missing.
struct YBImage: View {
    let source: String?

    var body: some View {
        if let source, source.hasPrefix("http") {
            AsyncImage(url: URL(string: source)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                placeholder
            }
        } else if let source, UIImage(named: source) != nil {
            Image(source).resizable().scaledToFill()
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            YBColor.icyAqua.opacity(0.5)
            Image(systemName: "photo")
                .font(.system(size: 28))
                .foregroundColor(YBColor.forest)
        }
    }
}
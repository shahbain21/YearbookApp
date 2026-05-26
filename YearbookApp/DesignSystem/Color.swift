//
//  Color.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//

import SwiftUI

/// Color palette from the official Year Book Style Guide.
/// Brand colors stay fixed (they're identity). Sheets share a soft
/// off-white background so brand colors stay readable in both system
/// modes — no per-icon dark-mode handling required.
enum YBColor {

    // MARK: - Brand colors (fixed in both modes)

    static let black      = Color(hex: 0x000000)
    static let forest     = Color(hex: 0x0A400C)
    static let icyAqua    = Color(hex: 0xBFF3F5)
    static let deepPurple = Color(hex: 0x651062)
    static let white      = Color(hex: 0xFFFFFF)
    static let heart      = Color(hex: 0xB23A3F)

    // MARK: - Surface / text colors

    /// Card-tile/screen "paper" background. Always white — pairs with
    /// the designer-baked light backgrounds in the main tabs.
    static let paper   = white
    /// Primary text on paper. Always dark.
    static let ink     = black
    /// Secondary text — captions, metadata.
    static let inkSoft = Color(hex: 0x2F0720, alpha: 0.65)

    /// Sheet / popup background. A warm off-white that renders the
    /// same in light and dark mode so brand colors (forest green text,
    /// forest icons) stay readable without per-icon overrides.
    static let sheetBackground = Color(hex: 0xE5E4E0)

    // MARK: - Adaptive accent (used for system-controlled popovers
    // where we can't override the background, e.g. SwiftUI Menu).

    static let brandText = Color(
        light: forest,
        dark:  Color(hex: 0x6BBF5E)
    )

    // MARK: - Gradients

    static let screenGradient = LinearGradient(
        colors: [white, white, forest],
        startPoint: .top, endPoint: .bottom
    )
}

extension Color {
    /// Build a Color from a 0xRRGGBB literal.
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8)  & 0xFF) / 255.0,
            blue:  Double( hex        & 0xFF) / 255.0,
            opacity: alpha)
    }

    /// Adaptive Color that switches based on system color scheme.
    /// Backed by a UIColor so SwiftUI re-resolves it on theme change.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

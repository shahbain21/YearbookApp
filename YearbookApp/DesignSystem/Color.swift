//
//  Color.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//

import SwiftUI

// Color palette from the official Year Book Style Guide
enum YBColor {
    static let black      = Color(hex: 0x000000)   // Black
    static let forest     = Color(hex: 0x0A400C)   // Black Forest
    static let icyAqua    = Color(hex: 0xBFF3F5)   // Icy Aqua
    static let deepPurple = Color(hex: 0x651062)   // Deep Purple
    static let white      = Color(hex: 0xFFFFFF)   // White
    static let heart      = Color(hex: 0xB23A3F)

    static let paper   = white
    static let ink     = black
    static let inkSoft = Color(hex: 0x2F0720, alpha: 0.65)

    static let screenGradient = LinearGradient(
        colors: [white, white, forest],
        startPoint: .top, endPoint: .bottom
    )
}

extension Color {
    // Build a Color from a 0xRRGGBB literal.
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8)  & 0xFF) / 255.0,
            blue:  Double( hex        & 0xFF) / 255.0,
            opacity: alpha)
    }
}

//
//  Typography.swift.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//

import SwiftUI

// Fonts from the style guide: three SF Pro styles.
enum YBFont {
    static let heading = Font.system(size: 30, weight: .bold)    // headings
    static let body    = Font.system(size: 20, weight: .regular) // body text
    static let label   = Font.system(size: 17, weight: .bold)    // labels
    static let caption = Font.system(size: 13, weight: .regular) // captions
    static let metadata = Font.system(size: 12, weight: .regular)
}

// Consistent spacing scale.
enum YBSpace {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

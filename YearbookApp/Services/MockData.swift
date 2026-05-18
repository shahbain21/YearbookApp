//
//  MockData.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//


import Foundation

// Hard-coded sample data so the app runs before any backend exists.
enum MockData {
    static let posts: [Post] = [
        Post(id: "p1",
             authorName: "Tracie Trey",
             imageName: "mock_post_1",
             caption: "Demo day with the whole crew.",
             date: makeDate(2026, 5, 29),
             likeCount: 4),
        Post(id: "p2",
             authorName: "Tracie Trey",
             imageName: "mock_post_2",
             caption: "Late nights, good people.",
             date: makeDate(2026, 6, 1),
             likeCount: 7)
    ]

    /// Helper to build a date without DateComponents noise at call sites.
    static func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        return Calendar.current.date(from: c) ?? Date()
    }
}

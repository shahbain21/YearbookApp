//
//  MockData.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/17/26.
//


import Foundation

/// Hard-coded sample data so the app runs before any backend exists.
/// Increasingly being replaced by real Firestore data — kept around
/// for previews and as a fallback during development.
enum MockData {

    static let posts: [Post] = [
        Post(id: "p1",
             authorID: "u4",
             authorName: "Tracie Trey",
             imageName: "mock_post_1",
             caption: "Demo day with the whole crew.",
             date: makeDate(2026, 5, 29),
             likeCount: 4,
             likedBy: []),
        Post(id: "p2",
             authorID: "u4",
             authorName: "Tracie Trey",
             imageName: "mock_post_2",
             caption: "Late nights, good people.",
             date: makeDate(2026, 6, 1),
             likeCount: 7,
             likedBy: [])
    ]

    static let users: [User] = [
        User(id: "u1",
             name: "Irmani Chears",
             email: "irmani@msu.idserve.net",
             photoName: "member_irmani",
             cohort: "AM",
             hasCompletedOnboarding: true),
        User(id: "u2",
             name: "Jazmine Martin",
             email: "jazmine@msu.idserve.net",
             photoName: "member_jazmine",
             cohort: "AM",
             hasCompletedOnboarding: true),
        User(id: "u3",
             name: "Jahnell Roberson",
             email: "jahnell@msu.idserve.net",
             photoName: "member_jahnell",
             cohort: "AM",
             hasCompletedOnboarding: true),
        User(id: "u4",
             name: "Tracie Webster",
             email: "tracie@msu.idserve.net",
             photoName: "member_tracie",
             quote: "If you are not living on the edge, you are taking up too much space.",
             role: "Project Manager",
             linkedIn: "tracie-webster",
             instagram: "@traciew",
             domain: "Project Management",
             cohort: "AM",
             hasCompletedOnboarding: true)
    ]

    static let events: [Event] = [
        Event(id: "e1",
              title: "AM Cohort Chicago Trip",
              date: makeDate(2026, 6, 6),
              details: "Cohort trip to Chicago. Meet at the academy at 8am."),
        Event(id: "e2",
              title: "Final Project Showcase",
              date: makeDate(2026, 6, 1),
              details: "Present your capstone apps to mentors."),
        Event(id: "e3",
              title: "Demo Day",
              date: makeDate(2026, 6, 5),
              details: "Open house — show your work to the community.")
    ]

    /// Helper to build a date without DateComponents noise at call sites.
    static func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        return Calendar.current.date(from: c) ?? Date()
    }
}

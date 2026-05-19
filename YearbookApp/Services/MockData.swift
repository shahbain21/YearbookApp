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
    
    static let users: [User] = [
            User(id: "u1", name: "Irmani Chears",   photoName: "member_irmani"),
            User(id: "u2", name: "Jazmine Martin",  photoName: "member_jazmine"),
            User(id: "u3", name: "Jahnell Roberson", photoName: "member_jahnell"),
            User(id: "u4", name: "Tracie Webster",  photoName: "member_tracie",
                 quote: "If you are not living on the edge, you are taking up too much space.",
                 role: "Project Manager",
                 linkedIn: "tracie-webster",
                 instagram: "@traciew")
        ]

        /// The signed-in user. Hard-coded for now; set on login later.
        static let currentUser = users[3]   // Tracie

    // Helper to build a date without DateComponents noise at call sites.
    static func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        return Calendar.current.date(from: c) ?? Date()
    }
}

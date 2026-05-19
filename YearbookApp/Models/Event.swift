//
//  Event.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import Foundation

/// A calendar event shown on the Events screen.
struct Event: Identifiable {
    let id: String
    var title: String
    var date: Date
    var details: String?
}
//
//  EventsViewModel.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI
import Combine
// Drives the Events screen: owns the displayed month, the events,
// and which day (if any) the user has tapped to filter by.
@MainActor
final class EventsViewModel: ObservableObject {

    // All events. From MockData now; a backend later.
    @Published private(set) var events: [Event] = MockData.events

    // The day the user tapped, or nil = show all upcoming.
    @Published var selectedDate: Date?

    //The month currently shown in the grid.
    @Published var displayedMonth: Date

    private let calendar = Calendar.current

    init() {
        displayedMonth = MockData.events.first?.date ?? Date()
    }

    // MARK: - Calendar helpers

    /// Every day to render in the grid, including leading blanks so the
    /// 1st lands under the right weekday. nil = an empty leading cell.
    var daysInGrid: [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else { return [] }

        let leadingBlanks = firstWeekday - 1   // Sunday = 1
        let dayCount = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 0

        var cells: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in 0..<dayCount {
            cells.append(calendar.date(byAdding: .day, value: day, to: monthInterval.start))
        }
        return cells
    }

    // Title like "June 2026" for the header.
    var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    // MARK: - Event lookups

    // True if any event falls on this day — used to highlight it.
    func hasEvent(on day: Date) -> Bool {
        events.contains { calendar.isDate($0.date, inSameDayAs: day) }
    }

    // Events to show in the list
    var visibleEvents: [Event] {
        if let selectedDate {
            return events
                .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
                .sorted { $0.date < $1.date }
        }
        return events.sorted { $0.date < $1.date }
    }

    // MARK: - Actions

    // Tap a day: select it, or deselect if it was already selected.
        func tap(day: Date) {
            if let current = selectedDate, calendar.isDate(current, inSameDayAs: day) {
                selectedDate = nil
            } else {
                selectedDate = day
            }
        }

    func isSelected(_ day: Date) -> Bool {
        guard let selectedDate else { return false }
        return calendar.isDate(selectedDate, inSameDayAs: day)
    }
}

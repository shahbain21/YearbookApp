//
//  CalendarGridView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI

/// A month calendar grid. Highlights days that have events and lets
/// the user tap a day to select it. Driven by EventsViewModel.
struct CalendarGridView: View {
    @ObservedObject var viewModel: EventsViewModel

    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: YBSpace.sm) {
            // Month title
            Text(viewModel.monthTitle)
                .font(YBFont.label)
                .foregroundColor(YBColor.ink)

            // Weekday header row
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(YBFont.caption)
                        .foregroundColor(YBColor.inkSoft)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
            LazyVGrid(columns: columns, spacing: YBSpace.sm) {
                ForEach(Array(viewModel.daysInGrid.enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 34)   // leading blank
                    }
                }
            }
        }
    }

    /// A single tappable day cell.
    private func dayCell(_ day: Date) -> some View {
        let dayNumber = Calendar.current.component(.day, from: day)
        let hasEvent  = viewModel.hasEvent(on: day)
        let selected  = viewModel.isSelected(day)

        return Text("\(dayNumber)")
            .font(YBFont.caption)
            .foregroundColor(selected ? YBColor.white : YBColor.ink)
            .frame(width: 34, height: 34)
            .background(
                Circle().fill(
                    selected   ? YBColor.forest :          // tapped day
                    hasEvent   ? YBColor.icyAqua :         // has an event
                                 Color.clear               // normal day
                )
            )
            .frame(maxWidth: .infinity)
            .contentShape(Circle())
            .onTapGesture { viewModel.tap(day: day) }
    }
}

#Preview {
    CalendarGridView(viewModel: EventsViewModel())
        .padding()
}
//
//  EventsView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI

// The Events screen: a month calendar over a list of events.
struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("bg_events")
                    .resizable()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: YBSpace.lg) {
                        CalendarGridView(viewModel: viewModel)

                        // List header changes with selection.
                        HStack {
                            Text(viewModel.selectedDate == nil
                                 ? "Upcoming Events"
                                 : "Events on \(viewModel.selectedDate!.formatted(.dateTime.month().day()))")
                                .font(YBFont.label)
                                .foregroundColor(YBColor.ink)
                            Spacer()
                            if viewModel.selectedDate != nil {
                                Button("Show all") { viewModel.selectedDate = nil }
                                    .font(YBFont.caption)
                                    .foregroundColor(YBColor.forest)
                            }
                        }

                        eventList
                    }
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
                // Same fractional-inset pattern as Memories.
                .padding(.top,      geo.size.height * 0.19)
                .padding(.bottom,   geo.size.height * 0.13)
                .padding(.leading,  geo.size.width  * 0.20)
                .padding(.trailing, geo.size.width  * 0.06)
            }
        }
    }

    @ViewBuilder
    private var eventList: some View {
        if viewModel.visibleEvents.isEmpty {
            Text("No events for this day.")
                .font(YBFont.caption)
                .foregroundColor(YBColor.inkSoft)
                .padding(.vertical, YBSpace.lg)
        } else {
            VStack(spacing: YBSpace.sm) {
                ForEach(viewModel.visibleEvents) { event in
                    EventRowView(event: event)
                }
            }
        }
    }
}

#Preview {
    EventsView()
}

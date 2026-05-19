//
//  EventRowView.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/18/26.
//


import SwiftUI

/// A single event in the Events list.
struct EventRowView: View {
    let event: Event

    var body: some View {
        HStack(spacing: YBSpace.sm) {
            Image(systemName: "calendar")
                .foregroundColor(YBColor.forest)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(YBFont.label)
                    .foregroundColor(YBColor.ink)
                Text(event.date.formatted(.dateTime.month().day().year()))
                    .font(YBFont.caption)
                    .foregroundColor(YBColor.inkSoft)
                if let details = event.details {
                    Text(details)
                        .font(YBFont.caption)
                        .foregroundColor(YBColor.inkSoft)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(.vertical, YBSpace.sm)
    }
}

#Preview {
    EventRowView(event: MockData.events[0])
        .padding()
}
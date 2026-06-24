//
//  DayearnsWidget.swift
//  DayearnsWidget
//
//  Created by Jubi on 5/26/25.
//

import WidgetKit
import SwiftUI

private enum DayEarnsAppGroup {
    static let identifier = "group.Quang.DayEarns"
    static let widgetSnapshotKey = "widgetSnapshot"
}

private struct WidgetSnapshot: Codable {
    var todayEarnings: Int
    var todayTips: Int
    var upcomingAppointments: Int
    var nextAppointmentName: String?
    var nextAppointmentDate: Date?
    var updatedAt: Date

    static let empty = WidgetSnapshot(
        todayEarnings: 0,
        todayTips: 0,
        upcomingAppointments: 0,
        nextAppointmentName: nil,
        nextAppointmentDate: nil,
        updatedAt: .now
    )

    static func read() -> WidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: DayEarnsAppGroup.identifier),
              let data = defaults.data(forKey: DayEarnsAppGroup.widgetSnapshotKey),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else {
            return .empty
        }
        return snapshot
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(snapshot: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(snapshot: WidgetSnapshot.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(snapshot: WidgetSnapshot.read())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date = .now
    let snapshot: WidgetSnapshot
}

struct DayearnsWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("$\(entry.snapshot.todayEarnings)", systemImage: "dollarsign.circle.fill")
                .font(.headline)
            if entry.snapshot.todayTips > 0 {
                Text("Tips $\(entry.snapshot.todayTips)")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            if let name = entry.snapshot.nextAppointmentName,
               let date = entry.snapshot.nextAppointmentDate {
                Text("Next: \(name)")
                    .font(.caption2)
                    .lineLimit(1)
                Text(date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(entry.snapshot.upcomingAppointments) upcoming")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DayearnsWidget: Widget {
    let kind: String = "Quang.DayEarns.DayearnsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DayearnsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DayearnsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Dayearns")
        .description("Today's earnings and next appointment.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DayearnsWidget()
} timeline: {
    SimpleEntry(snapshot: WidgetSnapshot(
        todayEarnings: 240,
        todayTips: 35,
        upcomingAppointments: 2,
        nextAppointmentName: "Jubi",
        nextAppointmentDate: .now.addingTimeInterval(3600),
        updatedAt: .now
    ))
}
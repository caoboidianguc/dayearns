//
//  WidgetSnapshot.swift
//  DayEarns
//

import Foundation

enum DayEarnsAppGroup {
    static let identifier = "group.Quang.DayEarns"
    static let widgetSnapshotKey = "widgetSnapshot"
}

struct WidgetSnapshot: Codable {
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
}

extension WidgetSnapshot {
    static func make(from worker: Technician) -> WidgetSnapshot {
        let scheduled = worker.khach.filter(\.schedule).sorted { $0.ngay < $1.ngay }
        let next = scheduled.first
        return WidgetSnapshot(
            todayEarnings: worker.tongNgay(),
            todayTips: worker.tinhTip(),
            upcomingAppointments: scheduled.count,
            nextAppointmentName: next?.name,
            nextAppointmentDate: next?.ngay,
            updatedAt: .now
        )
    }

    func write() {
        guard let defaults = UserDefaults(suiteName: DayEarnsAppGroup.identifier),
              let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: DayEarnsAppGroup.widgetSnapshotKey)
    }

    static func read() -> WidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: DayEarnsAppGroup.identifier),
              let data = defaults.data(forKey: DayEarnsAppGroup.widgetSnapshotKey),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else {
            return .empty
        }
        return snapshot
    }
}
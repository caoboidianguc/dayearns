//
//  ReminderUser.swift
//  DayEarns
//
//  Created by Jubi on 11/17/24.
//

import SwiftUI
import UserNotifications

/// Stable notification IDs so each client gets at most one appointment + one birthday reminder.
/// (Older builds used a random UUID per schedule call, which stacked duplicates on every save.)
enum DayEarnsNotificationID {
    static func appointment(_ clientID: UUID) -> String { "appointment-\(clientID.uuidString)" }
    static func birthday(_ clientID: UUID) -> String { "birthday-\(clientID.uuidString)" }
}

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Notification permission granted.")
        } else if let error {
            print("Notification permission denied with error: \(error.localizedDescription)")
        }
    }
}

func clearAppBadge() {
    UNUserNotificationCenter.current().setBadgeCount(0)
}

/// Wipe pending DayEarns reminders and rebuild from current client list.
/// Always clears *all* pending requests first so leftovers from the old random-UUID
/// scheduling (and any orphaned IDs) cannot pile up and fire 15 times at once.
func rescheduleAllNotifications(clients: [Khach]) {
    let center = UNUserNotificationCenter.current()

    // Critical: remove everything pending. Matching only known IDs would miss
    // old `UUID().uuidString` identifiers still queued on the device.
    center.removeAllPendingNotificationRequests()

    clients.filter(\.schedule).forEach { scheduleAppointmentReminder(for: $0) }
    clients.filter { $0.birthDay != nil }.forEach { scheduleBirthdayNotification(for: $0) }
}

private func scheduleAppointmentReminder(for client: Khach) {
    // Only future appointments, and only if the 15‑minute warning is still ahead.
    guard client.ngay > Date.now else { return }
    guard let reminderDate = Calendar.current.date(byAdding: .minute, value: -15, to: client.ngay),
          reminderDate > Date.now else { return }

    let dateCompo = Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute],
        from: reminderDate
    )
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompo, repeats: false)

    let content = UNMutableNotificationContent()
    content.title = "Appointment Reminder"
    content.sound = .default
    content.badge = NSNumber(value: 1)
    content.body = "With \(client.name) in 15 minutes."
    content.threadIdentifier = "dayearns-appointments"
    content.userInfo = [
        "type": "appointment",
        "clientId": client.id.uuidString
    ]

    let request = UNNotificationRequest(
        identifier: DayEarnsNotificationID.appointment(client.id),
        content: content,
        trigger: trigger
    )
    UNUserNotificationCenter.current().add(request) { error in
        if let error {
            print("Failed to schedule appointment for \(client.name): \(error.localizedDescription)")
        }
    }
}

private func scheduleBirthdayNotification(for client: Khach) {
    guard let birthDay = client.birthDay else { return }

    var dateComponents = Calendar.current.dateComponents([.month, .day], from: birthDay)
    dateComponents.hour = 8
    dateComponents.minute = 0

    let content = UNMutableNotificationContent()
    content.title = "Happy Birthday!"
    content.body = "\(client.name)'s birthday is today!"
    content.sound = .default
    content.threadIdentifier = "dayearns-birthdays"
    content.userInfo = [
        "type": "birthday",
        "clientId": client.id.uuidString
    ]

    // Repeats yearly on that month/day — one pending request per client, stable ID.
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(
        identifier: DayEarnsNotificationID.birthday(client.id),
        content: content,
        trigger: trigger
    )
    UNUserNotificationCenter.current().add(request) { error in
        if let error {
            print("Failed to schedule birthday for \(client.name): \(error.localizedDescription)")
        }
    }
}

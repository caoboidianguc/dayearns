//
//  ReminderUser.swift
//  DayEarns
//
//  Created by Jubi on 11/17/24.
//

import SwiftUI
import UserNotifications

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

func rescheduleAllNotifications(clients: [Khach]) {
    let center = UNUserNotificationCenter.current()
    let identifiers = clients.flatMap { client in
        [
            DayEarnsNotificationID.appointment(client.id),
            DayEarnsNotificationID.birthday(client.id)
        ]
    }
    center.removePendingNotificationRequests(withIdentifiers: identifiers)

    clients.filter(\.schedule).forEach { scheduleAppointmentReminder(for: $0) }
    clients.filter(\.isBirthday).forEach { scheduleBirthdayNotification(for: $0) }
}

private func scheduleAppointmentReminder(for client: Khach) {
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
    content.badge = 1
    content.body = "With \(client.name) in 15 minutes."

    let request = UNNotificationRequest(
        identifier: DayEarnsNotificationID.appointment(client.id),
        content: content,
        trigger: trigger
    )
    UNUserNotificationCenter.current().add(request)
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

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(
        identifier: DayEarnsNotificationID.birthday(client.id),
        content: content,
        trigger: trigger
    )
    UNUserNotificationCenter.current().add(request)
}
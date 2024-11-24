//
//  ReminderUser.swift
//  DayEarns
//
//  Created by Jubi on 11/17/24.
//

import SwiftUI
import UserNotifications
//import UserNotificationsUI //what is this one

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Notification permission granted.")
        } else if let error = error {
            print("Notification permission denied with error: \(error.localizedDescription)")
        }
    }
}

//https://developer.apple.com/documentation/usernotifications/unnotificationrequest

func khachHenComingUp(client: Khach) {
    let identifier = UUID()
    let thoiGianBao = Calendar.current.date(byAdding: .minute, value: -15, to: client.ngay)!
    let dateCompo = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: thoiGianBao)
    let batDau = UNCalendarNotificationTrigger(dateMatching: dateCompo, repeats: false)
    
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    content.title = "Appointment Reminder"
    content.sound = .default
    content.badge = 1
    content.body = "With \(client.name) in 15 minutes."
    let request = UNNotificationRequest(identifier: "\(identifier)", content: content, trigger: batDau)
    do {
        center.add(request){(error: Error?) in
            if let erro = error {
                print("Error: \(erro.localizedDescription)")
            }
        }
    }

}

func clientBirthdayNotification(client: Khach){
    guard let birthDay = client.birthDay else {return}
    var dateComponents = Calendar.current.dateComponents([.month, .day], from: birthDay)
    dateComponents.hour = 8
    dateComponents.minute = 0
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    content.title = "Happy Birthday!"
    content.body = "\(client.name)'s birthday is Today!"
    content.sound = .default
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let request = UNNotificationRequest(identifier: "\(client.id)", content: content, trigger: trigger)
    center.add(request){(error: Error?) in
        if let erro = error {
            print("Error: \(erro.localizedDescription)")
        }
    }
}

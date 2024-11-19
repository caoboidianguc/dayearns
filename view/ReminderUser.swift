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
func scheduleBirthdayNotification(for khach: Khach) {
    guard let birthday = khach.birthDay else { return }
    
    let center = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = "Birthday Reminder"
    content.body = "\(khach.name)'s birthday is tomorrow!"
    content.sound = .default
    
    // Create DateComponent for tomorrow
    let birthdayComponents = Calendar.current.dateComponents([.month, .day], from: birthday)
    
    let today = Date()
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    var tomorrowComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
    tomorrowComponents.month = birthdayComponents.month
    tomorrowComponents.day = birthdayComponents.day

    let triggerDate = Calendar.current.date(from: tomorrowComponents)
    
    if let triggerDate = triggerDate, Calendar.current.isDate(triggerDate, inSameDayAs: tomorrow) {
        // Notification should appear at 9 AM
        let triggerDateComponent = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponent, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(khach.id)", content: content, trigger: trigger)
        
        center.add(request)
    }
}
func clientBirthdayNotification(client: Khach){
    guard let birthDay = client.birthDay else {return}
    var dateComponents = Calendar.current.dateComponents([.month, .day], from: birthDay)
    dateComponents.hour = 7
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

func khachHenComingUp(client: Khach){
    let thoiGianBao = Calendar.current.date(byAdding: .minute, value: -20, to: client.ngay)!
    let dateCompo = Calendar.current.dateComponents([.year,.month,.day, .hour, .minute, .second], from: thoiGianBao)
  
    let batDau = UNCalendarNotificationTrigger(dateMatching: dateCompo, repeats: false)
    
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    content.title = "Appointment Reminder"
    content.sound = .default
    content.body = "Appointment with \(client.name) in 20 minutes."
    let request = UNNotificationRequest(identifier: "AppointmentReminder", content: content, trigger: batDau)
    center.add(request)
}





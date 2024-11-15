//
//  HistoryVisit.swift
//  DayEarns
//
//  Created by Jubi on 11/22/23.
//

import Foundation


struct HistoryVisit: Codable, Identifiable {
    var id: UUID = UUID()
    var ngay: Date
    var note: String = ""
    var dvDone: [Service]
}

let mau = HistoryVisit(ngay: Date.from(year: 2023, month: 11, day:21), dvDone: [Service(dichVu: "Lish su", gia: 60)])

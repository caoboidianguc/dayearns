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
    var dvDone: [Service] = []
    var tip: Int?
    
    var tongTien: Int {
        dvDone.reduce(0) { $0 + $1.gia }
    }
    var schedule: Bool {
        ngay > Date.now
    }
    var honTuan: Bool {
        ngay.qua7Ngay < Date.now
    }
    var trongTuan: Bool {
        !schedule && !honTuan
    }
    var thang: Bool {
        !schedule && ngay > Date().thang
    }
    var nam: Bool {
        !schedule && ngay > Date().nam
    }
}

let mau = HistoryVisit(ngay: Date.from(year: 2023, month: 11, day:21), dvDone: [Service(dichVu: "Lish su", gia: 60)])


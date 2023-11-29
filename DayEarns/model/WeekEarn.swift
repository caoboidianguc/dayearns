//
//  WeekEarn.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import Foundation

struct WeekEarn: Codable, Identifiable {
    var id: UUID
    var ngay: Date
    var earn: Int
    var tip: Int?
    
    init(id: UUID = UUID(), ngay: Date, earn: Int) {
        self.id = id
        self.ngay = ngay
        self.earn = earn
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
    var earn3Ngay: Bool {
        !schedule && ngay > Date().qua3Ngay
    }
}

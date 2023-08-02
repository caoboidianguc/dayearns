//
//  LatVat.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import Foundation


enum Chon {
    case schedule
    case khach
    case dv
    case xep
}

extension Date {
    var quaNgay: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .day, value: 2, to: self) ?? self
    }
    var qua7Ngay: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .day, value: 7, to: self) ?? self
    }
    var thang: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .month, value: -1, to: self) ?? self
    }
    var nam: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .year, value: -1, to: self) ?? self
    }
    static func from(year: Int, month: Int, day: Int) -> Date {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        var dateCompo = DateComponents()
        dateCompo.year = year
        dateCompo.month = month
        dateCompo.day = day
        let date = gregorianCalendar.date(from: dateCompo)!
        return date
    }
}

enum QuaTuan: String, CaseIterable, Identifiable {
    case tuan = "Comming up"
    case nuaThang = "Within 7 days"
    case xaxoi = "Over week"
    
    var id: String {self.rawValue}
    var name: String {self.rawValue}
}


//
//  LatVat.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//
import Foundation
import SwiftUI

enum Chon {
    case schedule
    case khach
    case dv
    case xep
}

enum BiLoi: Error {
    case khongDuDiem
}

enum NhapThongTin: Hashable {
    case name
    case phone
    case note
}

extension Date {
    var quaNgay: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .day, value: 2, to: self) ?? self
    }
    var qua3Ngay: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .day, value: -3, to: self) ?? self
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
    case tuan = "Coming up"
    case nuaThang = "Within 7 days"
    case xaxoi = "Over week"
    
    var id: String {self.rawValue}
    var name: String {self.rawValue}
}

enum DSServices: LocalizedStringResource , CaseIterable {
    case sort = "Sort"
    case byName = "By Name"
    case byGia = "By Price"
    
}

extension Technician {
    
    func xapxep(ds: DSServices) -> [Service] {
        switch ds {
        case .sort:
            return services
        case .byName:
            return services.sorted(by: {$0.dichVu < $1.dichVu})
        case .byGia:
            return services.sorted(by: {$0.gia > $1.gia})
        
        }
    }
}

extension Khach {
    func layTen() -> String {
        var tendau = name
        if let doanCuoi = name.firstIndex(of: " "){
            let dau = name[...doanCuoi]
            tendau = String(dau)
            return tendau
        } else {
            return tendau}
    }
    
      mutating func redeemPoints(points: Int) throws {
          guard diem >= points else {
              throw BiLoi.khongDuDiem
          }
          diem = diem - points
      }
    
    var mauNgauNhien: Color {
        let red = CGFloat.random(in: 0...1)
        let xanh = CGFloat.random(in: 0...1)
        let luc = CGFloat.random(in: 0...1)
        return Color(red: red, green: xanh, blue: luc)
    }
}


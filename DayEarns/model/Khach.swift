//
//  Khach.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import Foundation
import SwiftUI

struct Khach: Codable, Identifiable, Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Khach, rhs: Khach) -> Bool {
        lhs.id == rhs.id
    }

    func isDuplicate(of other: Khach) -> Bool {
        let lhsPhone = sdt.trimmingCharacters(in: .whitespacesAndNewlines)
        let rhsPhone = other.sdt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lhsPhone.isEmpty, lhsPhone == rhsPhone else { return false }
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
            .caseInsensitiveCompare(other.name.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
    }
    
    var id: UUID
    var name: String
    var sdt: String
    var desc: String
    var diem: Int  = 0
    var dvDone: [Service] = []
    var ngay: Date
    var danhGia: Int
    var email: String = ""
    var firstCome: Date
    var isNew: Bool = true
    var tip: Int?
    var tag: String?
    var birthDay: Date?
    var histories: [HistoryVisit]
    var address: Address?
    
    init(id: UUID = UUID(),name: String, sdt: String, desc: String = "", dvDone: [Service] = [], ngay: Date = Date(), danhGia: Int = 0, diem: Int, firstCome: Date = .now, histories:[HistoryVisit] = []){
        self.id = id
        self.name = name
        self.sdt = sdt
        self.desc = desc
        self.dvDone = dvDone
        self.ngay = ngay
        self.danhGia = danhGia
        self.diem = diem
        self.firstCome = firstCome
        self.histories = histories
    }
    
    func khachTip() -> Int{
        var tong = 0
        if let bonus = self.tip {
            tong += bonus
        }
        return tong
    }
   var totalService: Int {
       dvDone.reduce(0) {$0 + $1.gia}
    }
    func khachTra() -> Int {
        var tongChi = 0
        for dvu in self.dvDone {
            tongChi += dvu.gia
        }
        tongChi += khachTip()
        return tongChi
    }
    var schedule: Bool {
        ngay > Date.now
    }
    var haiNgay: Bool {
        schedule && ngay < Date.now.quaNgay
    }
    var overTuan: Bool {
        schedule && !haiNgay && ngay < Date.now.qua7Ngay
    }
    var xahon: Bool {
        ngay >= Date().qua7Ngay
    }
    var today: Bool {
        let lich = Calendar.current
        return lich.isDateInToday(ngay)
    }
    var honTuan: Bool {
        ngay.qua7Ngay < Date.now
    }
    var trongTuan: Bool {
        !honTuan && !schedule
    }
    var thang: Bool {
        !schedule && ngay > Date().thang
    }
    var nam: Bool {
        !schedule && ngay > Date().nam
    }
    var isBirthday: Bool {
        let hnay = Date.now.formatted(Date.FormatStyle().month().day())
        var sinh = false
        if let ngay = self.birthDay {
            if hnay == ngay.formatted(Date.FormatStyle().month().day()) {
                sinh = true
            }
        }
        return sinh
    }
}

let khachmau = [Khach(name: "Jubi", sdt: "7373", dvDone:[Service(dichVu: "talk", gia: 60)], ngay: Date.from(year: 2022, month: 11, day:21), diem: 42)]

extension Khach {
    struct ThemKhach {
        var name: String = ""
        var sdt: String = ""
        var email: String = ""
        var desc: String = ""
        var dvDone: [Service] = []
        var diem: Int = 0
        var ngay: Date = Date()
        func pointsKhach() -> Int {
            var tongChi = 0
            for dvu in self.dvDone {
                tongChi += dvu.gia
            }
            return tongChi
        }
    }
    //mau: ThemKhach la de khi update custommer, load this
    var mau: ThemKhach {
        return ThemKhach(name: name, sdt: sdt, email: email, desc: desc, dvDone: dvDone, diem: diem, ngay: ngay)
    }
    
    static var dvmau = [Service(dichVu: "Full set", gia: 60)]
    
    mutating func update(tu data: ThemKhach) {
        name = data.name
        sdt = data.sdt
        desc = data.desc
        dvDone = data.dvDone
        diem = data.diem + data.pointsKhach()
        ngay = data.ngay
        isNew = false
        email = data.email
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
    
    var avatarColor: Color {
        var hash = id.hashValue
        let red = CGFloat((hash & 0xFF)) / 255
        hash >>= 8
        let green = CGFloat((hash & 0xFF)) / 255
        hash >>= 8
        let blue = CGFloat((hash & 0xFF)) / 255
        return Color(red: red, green: green, blue: blue)
    }

    func correctPhone(laySo: String) -> String {
        let digits = laySo.filter(\.isNumber)
        guard !digits.isEmpty else { return "" }
        if digits.count > 10 { return digits }
        guard digits.count == 10 else { return digits }
        let area = digits.prefix(3)
        let middle = digits.dropFirst(3).prefix(3)
        let last = digits.suffix(4)
        return "(\(area)) \(middle)-\(last)"
    }
}

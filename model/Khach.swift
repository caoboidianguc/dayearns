//
//  Khach.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import Foundation
import SwiftUI
//if change struct to class, data will slowly update at View.
struct Khach: Codable, Identifiable, Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(sdt)
    }
     static func == (lhs: Khach, rhs: Khach) -> Bool {
        if lhs.name == rhs.name && lhs.sdt == rhs.sdt {
            return true
        }
        return false
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
//    for migration-->
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case sdt
//        case desc
//        case diem
//        case dvDone
//        case ngay
//        case danhGia
//        case email
//        case firstCome
//        case histories
//        case tip
//        case tag
//        case birthDay
//    }
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(UUID.self, forKey: .id)
//        name = try container.decode(String.self, forKey: .name)
//        sdt = try container.decode(String.self, forKey: .sdt)
//        desc = try container.decode(String.self, forKey: .desc)
//        diem = try container.decode(Int.self, forKey: .diem)
//        dvDone = try container.decodeIfPresent([Service].self, forKey: .dvDone) ?? []
//        ngay = try container.decode(Date.self, forKey: .ngay)
//        danhGia = try container.decode(Int.self, forKey: .danhGia)
//        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
//        firstCome = try container.decode(Date.self, forKey: .firstCome)
//        histories = try container.decodeIfPresent([HistoryVisit].self, forKey: .histories) ?? []
//        tip = try container.decodeIfPresent(Int.self, forKey: .tip)
//        tag = try container.decodeIfPresent(String.self, forKey: .tag)
//        birthDay = try container.decodeIfPresent(Date.self, forKey: .birthDay)
//    }
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(name, forKey: .name)
//        try container.encode(sdt, forKey: .sdt)
//        try container.encode(desc, forKey: .desc)
//        try container.encode(diem, forKey: .diem)
//        try container.encode(dvDone, forKey: .dvDone)
//        try container.encode(ngay, forKey: .ngay)
//        try container.encode(danhGia, forKey: .danhGia)
//        try container.encode(email, forKey: .email)
//        try container.encode(firstCome, forKey: .firstCome)
//        try container.encodeIfPresent(histories, forKey: .histories)
//        try container.encodeIfPresent(tip, forKey: .tip)
//        try container.encodeIfPresent(tag, forKey: .tag)
//        try container.encodeIfPresent(birthDay, forKey: .birthDay)
//    }//<--
    
    func khachTip() -> Int{
        var tong = 0
        if let bonus = self.tip {
            tong += bonus
        }
        return tong
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
    
    mutating func update(tu data: ThemKhach){
        name = data.name
        sdt = data.sdt
        desc = data.desc
        dvDone = data.dvDone
        diem = data.diem + self.khachTra()
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
    
    var mauNgauNhien: Color {
        let red = CGFloat.random(in: 0...1)
        let xanh = CGFloat.random(in: 0...1)
        let luc = CGFloat.random(in: 0...1)
        return Color(red: red, green: xanh, blue: luc)
    }
}

//extension Khach {
//    var allproducts: [Product] {
//        var allProduct: [Product] = []
//        if let product = self.products {
//            allProduct += product
//        }
//        return allProduct
//    }
//    
//    var historiesVisit: [HistoryVisit] {
//        var daden : [HistoryVisit] = []
//        if let history = self.histories {
//            daden += history
//        }
//        return daden
//    }
//}

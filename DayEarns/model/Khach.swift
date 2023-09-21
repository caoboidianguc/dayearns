//
//  Khach.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import Foundation

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
    
    init(id: UUID = UUID(),name: String, sdt: String, desc: String = "", dvDone: [Service] = [], ngay: Date = Date(), danhGia: Int = 0, diem: Int, firstCome: Date = .now){
        self.id = id
        self.name = name
        self.sdt = sdt
        self.desc = desc
        self.dvDone = dvDone
        self.ngay = ngay
        self.danhGia = danhGia
        self.diem = diem
        self.firstCome = firstCome
    }
    
    func khachTra() -> Int {
        var tongChi = 0
        for dvu in self.dvDone {
            tongChi += dvu.gia
        }
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
        ngay.formatted(date: .numeric, time: .omitted) == Date().formatted(date: .numeric, time: .omitted)
    }
    var honTuan: Bool {
        ngay.qua7Ngay < Date.now
    }
    var trongTuan: Bool {
        !honTuan && !schedule
    }
//    var thang: Bool {
//        !schedule && ngay.thang < Date.now
//    }
//    var nam: Bool {
//        !schedule && ngay.nam < Date.now
//    }
    
}

let khachmau = [Khach(name: "Jubi", sdt: "7373", dvDone:[Service(dichVu: "talk", gia: 60)], ngay: Date.from(year: 2022, month: 11, day:21), diem: 42)]

extension Khach {
    struct ThemKhach {
        var name: String = ""
        var sdt: String = ""
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
        return ThemKhach(name: name, sdt: sdt, desc: desc, dvDone: dvDone, diem: diem, ngay: ngay)
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
    }
  
}

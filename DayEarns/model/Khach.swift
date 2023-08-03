//
//  Khach.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import Foundation

struct Khach: Codable, Identifiable, Equatable {
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
    var diem: Int = 1
    var dvDone: [Service] = []
    var ngay: Date
    var danhGia: Int
    var email: String?
    
    init(id: UUID = UUID(),name: String, sdt: String, desc: String = "", dvDone: [Service] = [], ngay: Date = Date(), danhGia: Int = 0){
        self.id = id
        self.name = name
        self.sdt = sdt
        self.desc = desc
        self.dvDone = dvDone
        self.ngay = ngay
        self.danhGia = danhGia
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
    var thang: Bool {
        !schedule && ngay.thang < Date.now
    }
    var nam: Bool {
        !schedule && ngay.nam < Date.now
    }
}

let khachmau = [Khach(name: "Jubi", sdt: "8775", dvDone:[Service(dichVu: "talk", gia: 60)], ngay: Date.from(year: 2022, month: 11, day:21))]

extension Khach {
    struct ThemKhach {
        var name: String = ""
        var sdt: String = ""
        var desc: String = "Take note here\n \n"
        var dvDone: [Service] = []
        var diem: Int = 1
        var ngay: Date = Date()
        var email: String = ""
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
        diem = data.diem
        ngay = data.ngay
        email = data.email
    }
    mutating func updateDiem(tu data: ThemKhach){
        update(tu: data)
        diem = data.diem + 1
    }
    
  
}

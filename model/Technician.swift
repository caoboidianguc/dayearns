//
//  Technician.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import Foundation


struct Technician: Codable {
    let id: UUID
    let name: String
    var phone: String
    var email: String = ""
    var services: [Service]
    var khach: [Khach]
    var weekEarn: [WeekEarn] = []
    init(id: UUID = UUID(), name: String, phone: String,services:[Service] = [] , khach:[Khach] = []){
        self.id = id
        self.name = name
        self.phone = phone
        self.services = services
        self.khach = khach
    }
}
var quang = Technician(name: "Linh", phone: "803")

extension Technician {
    static var dvTech: [Service] = [Service(dichVu: "Full set", gia: 60),
                                    Service(dichVu: "Hair cut", gia: 35)]
    
    
    mutating func delete(_ client: Khach){
        self.khach.removeAll(where: {$0.id == client.id })
    }
    
    func clientExisted(_ client: Khach) -> Bool {
        self.khach.contains(client)
    }
    
    func tinhTip() -> Int {
        var tong = 0
        for khack in khach {
            if khack.today {
                if let bonus = khack.tip {
                    tong += bonus
                }
            }
        }
        return tong
    }
    
    func tongNgay() -> Int {
        var tong = 0
        for lan in khach {
            if lan.today {
                tong += lan.khachTra()
            }
        }
        return tong
    }
    
    func tinhTheoNgay() -> Int {
        var tong = 0
        for ngay in weekEarn {
            if ngay.trongTuan {
                tong += ngay.earn
            }
        }
        return tong
    }
    
    func tuan(quaTuan: QuaTuan) -> [Khach] {
        self.khach.filter {
            switch quaTuan {
            case .tuan:
                return $0.haiNgay
            case .nuaThang:
                return $0.overTuan
            case .xaxoi:
                return $0.xahon
            }
        }.sorted(by: {$0.ngay < $1.ngay})
        
    }
    
    func listDaTim(ten: String) -> [Khach] {
        self.khach.filter { $0.name.contains(ten) || $0.sdt.contains(ten) }
    }
}

extension Technician {
    var tuan: [Khach] {
        self.khach.filter {$0.trongTuan}.sorted(by: {$0.ngay > $1.ngay})
    }
    var motTuan: [WeekEarn] {
        self.weekEarn.filter {$0.trongTuan}.sorted(by: {$0.ngay > $1.ngay})
    }
    var thangTech: [WeekEarn] {
        self.weekEarn.filter {$0.thang}
    }
    var namTech: [WeekEarn] {
        self.weekEarn.filter {$0.nam}
    }
    
}


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
    var weekEarn: [WeekEarn]
    
    init(id: UUID = UUID(), name: String, phone: String,services:[Service] = [] , khach:[Khach] = [], weekEarn:[WeekEarn] = []){
        self.id = id
        self.name = name
        self.phone = phone
        self.services = services
        self.khach = khach
        self.weekEarn = weekEarn
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
        
    func tuan(quaTuan: QuaTuan) -> [Khach] {
        self.khach.filter {
            switch quaTuan {
            case .birthday:
                return $0.isBirthday
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
        self.khach.filter { $0.name.contains(ten) || $0.sdt.contains(ten) || ($0.tag ?? "").contains(ten) }
    }
    
    func timService(ten: String) -> [Service]{
        self.services.filter {
            $0.dichVu.contains(ten)
        }
    }
}

extension Technician {
    var tuan: [Khach] {
        self.khach.filter {$0.trongTuan}.sorted(by: {$0.ngay > $1.ngay})
    }
//    chart
//    var motTuan: [WeekEarn] {
//        self.weekEarn.filter {$0.trongTuan}.sorted(by: {$0.ngay > $1.ngay})
//    }
//    
//    var thangTech: [WeekEarn] {
//        self.weekEarn.filter {$0.thang}
//    }
//    
//    var namTech: [WeekEarn] {
//        self.weekEarn.filter {$0.nam}
//    }
 
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
    var motTuanHistory: [HistoryVisit] {
        var allHistory: [HistoryVisit] = []
        let allKhach = self.khach.filter {$0.nam} //maybe customer have one time visit and never come back?
        for khach in allKhach {
            for historyV in khach.histories {
                allHistory.append(historyV)
            }
        }
        return allHistory.filter{$0.trongTuan}
    }
    
    var thangHistory: [HistoryVisit] {
        var allHistory: [HistoryVisit] = []
        for khach in self.khach {
            for historyV in khach.histories {
                allHistory.append(historyV)
            }
        }
        return allHistory.filter{$0.thang}
    }
    var namHistory: [HistoryVisit] {
        var allHistory: [HistoryVisit] = []
        for khach in self.khach {
            for historyV in khach.histories {
                allHistory.append(historyV)
            }
        }
        return allHistory.filter{$0.nam}
    }
}


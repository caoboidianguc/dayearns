//
//  Service.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//
import Foundation

struct Service: Codable, Identifiable {
    var id: UUID
    var dichVu: String
    var gia: Int
    
    init(id: UUID = UUID(), dichVu: String, gia: Int){
        self.id = id
        self.dichVu = dichVu
        self.gia = gia
    }
}

extension Service {
    struct themDv {
        var dichVu: String = ""
        var gia: Int = 0
    }
}

//
//  Loi.swift
//  DayEarns
//
//  Created by Jubi on 9/7/23.
//

import Foundation


struct Loi: Identifiable {
    let id: UUID
    let error: Error
    let chiTiet: String
    init(id: UUID = UUID(), error: Error, chiTiet: String) {
        self.id = id
        self.error = error
        self.chiTiet = chiTiet
    }
}

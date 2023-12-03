//
//  HistoryVisit.swift
//  DayEarns
//
//  Created by Jubi on 11/22/23.
//

import Foundation


struct HistoryVisit: Codable, Identifiable {
    var id: UUID
    var ngay: Date
    var dvDone: [Service]
}

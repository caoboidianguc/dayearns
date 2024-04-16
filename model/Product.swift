//
//  Product.swift
//  DayEarns
//
//  Created by Jubi on 3/29/24.
//

import Foundation

struct Product: Codable, Identifiable {
    var id: UUID = UUID()
    var branchName: Branch
    var name: String
    var number: String = ""
    
    enum Branch: Codable {
        case OPI
        case DND
        case Wave
        case Shellac
    }
    
    
}

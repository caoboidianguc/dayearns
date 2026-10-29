//
//  Address.swift
//  DayEarns
//
//  Created by Jubi on 11/20/24.
//

import Foundation

struct Address: Codable {
    var street: String
    var alternateStreet: String
    var city: String
    var state: String
    var zip: String
    
    init(street: String, alternateStreet: String = "",city: String, state: String, zip: String) {
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
        self.alternateStreet = alternateStreet
    }
}

extension Address {
    var formattedMultiline: String {
        let line1 = [street, alternateStreet]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        let line2 = [city, "\(state) \(zip)"]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        return [line1, line2].filter { !$0.isEmpty }.joined(separator: "\n")
    }
}

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

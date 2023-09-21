//
//  Button.swift
//  DayEarns
//
//  Created by Jubi on 9/19/23.
//

import SwiftUI


struct PhoneButton: View {
    var action: () -> Void = {}
    var body: some View {
        Button(action: action, label: {
            Image(systemName: "phone.badge.plus")
                .foregroundStyle(.red)
            .font(.title)})
    }
}

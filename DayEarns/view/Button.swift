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



struct AddServiceButton: View {
    var action: () -> Void = {}
    var body: some View {
        Button(action: action, label: {
            RoundedRectangle(cornerRadius: 15)
                .frame(width:100, height: 35)
                .overlay{
                    Text("Add Service")
                        .font(.system(size: 14))
                        .foregroundStyle(.background)
                }
        })
    }
}
#Preview {
    AddClientButton()
}

struct AddClientButton: View {
    var action: () -> Void = {}
    var body: some View {
        Button(action: action, label: {
            RoundedRectangle(cornerRadius: 15)
                .frame(width:75, height: 35)
                .overlay{
                    Text("Add")
                        .font(.system(size: 25))
                        .foregroundStyle(.background)
                }
        })
    }
}

//
//  LinkPhone.swift
//  DayEarns
//
//  Created by Jubi on 8/2/23.
//

import SwiftUI

struct LinkPhone: View {
    var khach: Khach
    
    var body: some View {
        if khach.sdt.isEmpty {
            Button(action: {updatesdt = true
            }, label: {
                Image(systemName: "phone.badge.plus")
                    .foregroundStyle(.red)
                    .font(.title)
                    .alert("\(khach.name)'s Number", isPresented: $updatesdt, actions: {
                        TextField("phone", text: $sdt)
                            .keyboardType(.numberPad)
                        Button("Xong"){khach.sdt = sdt}
                    })
            })
            
        } else {
            Link(destination: URL(string: "tel:\(khach.sdt)")!, label: {Text(khach.sdt)})
        }
    }
}

//#Preview {
//    LinkPhone()
//}

//
//  Button.swift
//  DayEarns
//
//  Created by Jubi on 9/19/23.
//

import SwiftUI

struct ClaimPointButton: View {
    var claim: ()->Void = {}
    var body: some View {
        Button(action: claim, label: {
            Text("Claim", comment: "Client claimed their point here")
                .help("Client claimed their point here")
                .shadow(color: .black,radius: 10)
        }).foregroundStyle(.blue)
    }
}

struct PhoneButton: View {
    @State private var sdt = ""
    @State private var updateSdt = false
    @State private var incorrect = false
    @Binding var khach: Khach
    var body: some View {
        Button(action: {updateSdt = true}, label: {
            Image(systemName: "phone.badge.plus")
                .foregroundStyle(.red)
            .font(.title)})
        .alert("\(khach.name)'s Number", isPresented: $updateSdt, actions: {
            TextField("Phone", text: $sdt)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
            Button("Done"){
                if !sdt.isEmpty && sdt.count < 10 {
                    incorrect = true
                } else {
                    khach.sdt = sdt
                }
            }
        })
        .alert("Phone is incorrect!", isPresented: $incorrect, actions: {
            Button("Done"){
                updateSdt = false
            }
        })
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



struct AddTag: View {
    @Binding var khach: Khach
    @State private var name = ""
    @State private var theTag = false
    
    var body: some View {
        ZStack {
            Button(action: {
                theTag = true
            }, label: {
                Label("Tag", systemImage: "tag")
                    .alert("Add Tag", isPresented: $theTag, actions: {
                        TextField("Tag name", text: $name)
                            .textInputAutocapitalization(.words)
                        Button("Dismiss"){
                            theTag = false
                        }
                        Button("Done"){
                            khach.tag = name
                        }
                    })
            })
        }
        }
}

struct AddTip: View {
    @Binding var khach: Khach
    @State private var tip: Int?
    @State private var addTip = false
    
    var body: some View {
        Button(action: {addTip = true}, label: {
            Label("Tip", systemImage: "dollarsign.arrow.circlepath")
                .alert("Tipping", isPresented: $addTip, actions: {
                    TextField("Tip Amount", value: $tip, format: .number)
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                    Button("Done"){
                        if let bonus = tip {
                            khach.tip = bonus
                        }
                    }
                })
        })
            
    }
}


struct BirthdayButton: View {
    @Binding var khach: Khach
    @State private var ngaySinh: Date = Date.now
    
    var body: some View {
        VStack {
            DatePicker("Birthday", selection: $ngaySinh, in: Date.distantPast...Date.now, displayedComponents: .date)
            Spacer()
            Button("Save") {
                khach.birthDay = ngaySinh
            }.foregroundStyle(.blue)
                .disabled(Calendar.current.isDateInToday(ngaySinh))
        }
    }
}

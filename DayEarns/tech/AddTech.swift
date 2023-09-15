//
//  AddTech.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI


struct AddTech: View {
    @State private var ten = ""
    @State private var phone = ""
    @State private var email = ""
    @Binding var tech: Technician
    @FocusState private var focusNhap: NhapThongTin?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("Welcome to DayEarn")
                    .font(.title)
                Form(content: {
                    TextField("Your Name", text: $ten)
                        .textInputAutocapitalization(.words)
                        .focused($focusNhap, equals: .name)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("someOne @vidu.com", text: $email)
                        .keyboardType(.emailAddress)
                })
                
            }.padding(10)
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .primaryAction){
                    Button("Done"){
                        let newTech = Technician(name: ten, phone: phone)
                        tech = newTech
                        tech.email = email

                    }.disabled(ten.isEmpty)
                }
            }
            .onAppear{
                focusNhap = .name
            }
        }
    }
}

//struct AddTech_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTech()
//    }
//}

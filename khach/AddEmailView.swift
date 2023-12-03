//
//  AddEmailView.swift
//  DayEarns
//
//  Created by Jubi on 9/29/23.
//

import SwiftUI

struct AddEmailView: View {
    @Binding var khach: Khach
    @State private var email: String = ""
    @State private var checkEmail = true
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        HStack {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .onChange(of: email, perform: { chu in
                    checkEmail = checkEmail(email: chu)
                })
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading){
                Button("Dismiss"){
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing){
                Button("Done"){
                    khach.email = email
                }.disabled(checkEmail)
            }
        })
        .frame(idealWidth: 500, idealHeight: 300)
    }//body
    
    
     private func checkEmail(email: String) -> Bool {
         guard let doan = try? Regex(".+@.+") else {return true}
         if email.contains(doan){
             return false
         } else {return true}
     }
    
    
    
}

#Preview {
    NavigationStack{
        AddEmailView(khach: .constant(khachmau[0]))
    }
}

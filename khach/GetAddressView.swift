//
//  GetAddressView.swift
//  DayEarns
//
//  Created by Jubi on 11/20/24.
//

import SwiftUI

struct GetAddressView: View {
    @Binding var khach: Khach
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var zip: String = ""
    @State private var state: String = ""
    @State private var altStreet: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Form {
                TextField("Street:", text: $street)
                TextField("Street optionally:", text: $altStreet)
                TextField("City:", text: $city)
                TextField("State:", text: $state)
                TextField("Zip Code:", text: $zip)
                    .keyboardType(.numberPad)
            }//form
            .frame(maxWidth: .infinity, maxHeight: 300)
                HStack {
                    Button("Cancel"){
                        street = ""; city = ""; state = ""; zip = ""; altStreet = ""
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button(action: {
                        let diaChi = Address(street: street, alternateStreet: altStreet, city: city, state: state, zip: zip)
                        khach.address = diaChi
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                    }.disabled(ktra)
                }//hstack
                .padding(.horizontal)
                .font(.title)
        }
        
    }//body
    var ktra: Bool {
        state.isEmpty || city.isEmpty || street.isEmpty
    }
}

#Preview {
    GetAddressView(khach: .constant(khachmau[0]))
//        .frame(width: 400, height:400)
}

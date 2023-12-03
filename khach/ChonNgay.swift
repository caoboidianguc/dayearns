//
//  ChonNgay.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct ChonNgay: View {
    @Binding var client: Khach.ThemKhach
    var body: some View {
        NavigationView {
            ScrollView {
                Section(header: Text("Your Client !") ){
                    VStack {
                        TextField("Name:", text: $client.name).textInputAutocapitalization(.words)
                        TextField("Phone - opt", text: $client.sdt).keyboardType(.numberPad)
                        DatePicker("iPick:", selection: $client.ngay)
                            .datePickerStyle(.automatic)
                            .padding(20)
                    }.padding()
                }
                
                ChonDichVu(client: $client)
            }.navigationTitle("Get Appointment")
        }
    }
}

struct ChonNgay_Previews: PreviewProvider {
    static var previews: some View {
        ChonNgay(client: .constant(khachmau[0].mau))
            .environmentObject(KhachData())
    }
}

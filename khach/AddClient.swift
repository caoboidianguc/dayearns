//
//  AddClient.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct AddClient: View {
    @Binding var client: Khach.ThemKhach
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Name:", text: $client.name)
                    .textInputAutocapitalization(.words)
                TextField("Phone Option", text: $client.sdt)
                    .keyboardType(.phonePad)
                TextField("Note:", text: $client.desc)
            }.padding()
            
            ChonDichVu(client: $client)
           
        }//list
        .onAppear{
            client.dvDone.removeAll()
        }
        
        
    }//body
    
}

//struct AddClient_Previews: PreviewProvider {
//    static var previews: some View {
//        AddClient(worker: .constant(quang),client: .constant(khachmau[0].mau))
//            .environmentObject(KhachData())
//    }
//}

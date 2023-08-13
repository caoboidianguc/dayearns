//
//  ClientEdit.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI


struct ClientEdit: View {
    @Binding var worker: Technician
    @Binding var client: Khach.ThemKhach
    @State var newSer = Service.themDv()

    var body: some View {
        ScrollView {
            VStack {
                TextField("Name:", text: $client.name).textInputAutocapitalization(.words)
                TextField("Phone Option", text: $client.sdt).keyboardType(.numberPad)
//                TextField("Note :", text: $client.desc)
                Label("Notes", systemImage: "hand.point.down")
                TextEditor(text: $client.desc)
                    .frame(width: 350, height: 150, alignment: .leading)
                DatePicker("IPick", selection: $client.ngay)
                    .datePickerStyle(.compact)
            }.padding()
            
            ChonDichVu(client: $client)
            HStack {
                NewService(newSer: $newSer)
                Button("Add Service", action: {
                    themDichVu()
                }).disabled(newSer.dichVu.isEmpty)
            }
        }//list
        .onAppear{
            client.dvDone.removeAll()
        }
        .listStyle(.automatic)
    }//body
    private func themDichVu(){
        let new = Service(dichVu: newSer.dichVu, gia: newSer.gia)
        worker.services.append(new)
        client.dvDone.append(new)
    }
}

//struct ClientEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        ClientEdit(worker: .constant(quang),client: .constant(khachmau[0].mau))
//            .environmentObject(KhachData())
//
//    }
//}

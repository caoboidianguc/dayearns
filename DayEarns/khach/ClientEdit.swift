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
    @FocusState private var focusNhap: NhapThongTin?

    var body: some View {
        ScrollView {
            VStack {
                TextField("Name:", text: $client.name).textInputAutocapitalization(.words)
                    .focused($focusNhap, equals: .name)
                TextField("Phone Option", text: $client.sdt).keyboardType(.numberPad)
                    .focused($focusNhap, equals: .phone)
//                TextField("Note :", text: $client.desc)
                Label("Notes", systemImage: "hand.point.down")
                    .help("Any note to know about custommer?")
                    
                TextEditor(text: $client.desc)
                    .frame(width: 350, height: 150, alignment: .leading)
                    .focused($focusNhap, equals: .note)
                DatePicker("IPick", selection: $client.ngay)
                    .datePickerStyle(.compact)
            }.padding()
            
            ChonDichVu(client: $client)
            HStack {
                NewService(newSer: $newSer)
                AddServiceButton(action: themDichVu)
                    .disabled(newSer.dichVu.isEmpty)
            }
        }//list
        .onAppear{
            client.dvDone.removeAll()
            if client.name.isEmpty {
                focusNhap = .name
            } else if client.sdt.isEmpty {
                focusNhap = .phone
            } else {
                focusNhap = .note
            }
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


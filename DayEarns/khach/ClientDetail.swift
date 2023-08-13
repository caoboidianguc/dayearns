//
//  ClientDetail.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct ClientDetail: View {
    @Binding var worker: Technician
    @Binding var khach: Khach
    @State private var updateKhach: Khach.ThemKhach = Khach.ThemKhach()
    @State private var suadoi = false
    @State private var xoa = false
    @State private var updatesdt = false
    @State private var sdt = ""
    @State private var hinhTrong = false
    @State private var updateEmail = false
    @State private var email = ""
    
    var body: some View {
        List {
            Section(header: Text("Client:")) {
                HStack {
                    Text(khach.name)
                    Spacer()
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
                
                if let email = khach.email {
                    Link(destination: URL(string: "mailto:\(email)")!, label: {Text(email)})
                }
                
                HStack{
                    DanhGiaView(danhGia: $khach.danhGia)
                    Spacer()
                    Button(action: {updateEmail = true} , label: {
                        Label("", systemImage: "mail.fill")
                            .alert("\(khach.name)'s Email", isPresented: $updateEmail, actions: {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                Button("Dismiss", role: .cancel){updateEmail = false}
                            Button("Done"){khach.email = email}
                        })
                    })
                }
                
                
            }.padding(8)
            Section(header: Text("Service:")) {
                ForEach(khach.dvDone){dv in
                    HStack {
                        Text(dv.dichVu)
                        Spacer()
                        Text("$\(dv.gia)")
                    }
                }
            }
           
            Section(header: Text("Detail")){
                Text("Latest Visit: \(khach.ngay.formatted(.dateTime))")
                Text("Note: \(khach.desc)")
                Text("Time visited: \(khach.diem)")
                Text("Total: $\(khach.khachTra())")
                
            }.padding(5)
            
            Button("Delete This Client"){
                xoa = true
            }.foregroundColor(.red)
                .alert("You can't undo this!", isPresented: $xoa, actions: {
                    Button{worker.delete(khach)
                        hinhTrong = true
                    } label: {
                        Text("Delete")
                    }
                    Button("Cancel", role: .cancel) { xoa = false}
                }, message: {Text("\(khach.name) will be remove")})
            
        }
        .overlay {
            if hinhTrong {
                EmptyView()
            }
        }
        .navigationTitle(Text("\(khach.layTen()) visited"))
            .navigationBarItems(trailing: Button("Edit"){
                suadoi = true
                updateKhach = khach.mau
            })
            .fullScreenCover(isPresented: $suadoi) {
                NavigationView {
                    ClientEdit(worker: $worker, client: $updateKhach)
                        .navigationBarItems(leading: Button("Cancel"){
                            suadoi = false
                        }, trailing: Button("Update"){
                            suaDoi()
                        })
                }
            }
    }//body
    private func suaDoi(){
        if khach.dvDone.isEmpty {
            khach.update(tu: updateKhach)
        } else {
            khach.updateDiem(tu: updateKhach)
        }
        suadoi = false
    }
}

//struct ClientDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ClientDetail(worker: .constant(quang),khach: .constant(khachmau[0]))
//        }
//    }
//}


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
    @State private var updatesdt = false
    @State private var sdt = ""
    @State private var updateEmail = false
    @State private var email: String = ""
    @State private var checkEmail = true
    @State private var claim = false
    @State private var loiRedeem: Loi?
    @State private var redeem = ""
    
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
                                    TextField("Phone", text: $sdt)
                                        .keyboardType(.numberPad)
                                    Button("Done"){khach.sdt = sdt}
                                })
                        })
                        
                    } else {
                        Link(destination: URL(string: "tel:\(khach.sdt)")!, label: {Text(khach.sdt)})
                    }
                }
//                replace tel to sms for message
                if !khach.email.isEmpty {
                    Link(destination: URL(string: "mailto:\(khach.email)")!, label: {Text(khach.email)})
                }
                
                HStack{
                    DanhGiaView(danhGia: $khach.danhGia)
                    Spacer()
                    if khach.email.isEmpty {
                        Button(action: {updateEmail = true} , label: {
                            Label("", systemImage: "mail.fill")
                                .alert("\(khach.name)'s Email", isPresented: $updateEmail, actions: {
                                TextField("Email", text: $email)
                                        .onChange(of: email, perform: { chu in
                                            checkEmail = checkEmail(email: chu)
                                        })
                                        
                                    .keyboardType(.emailAddress)
                                    Button("Dismiss", role: .cancel){updateEmail = false}
                                    Button("Done"){khach.email = email}.disabled(checkEmail)
                            })
                        })
                    }
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
                Text("First Visits: \(khach.firstCome.formatted(.dateTime))")
                Text("Note: \(khach.desc)")
                HStack {
                    Text("Points Earn: \(khach.diem)")
                    Spacer()
                    Button(action: {
                        claim = true
                    }, label: {
                        Text("Claim")
                    })
                }
                Text("Total: $\(khach.khachTra())")
                if !khach.isNew {
                    Text("Latest Visits: \(khach.ngay.formatted(.dateTime))")
                }
                
            }.padding(5)
            
        }
        .alert("Redeem points", isPresented: $claim, actions: {
            TextField("Points", text: $redeem)
            Button("Dismiss", role: .cancel){ claim = false }
            Button("Redeem"){
                redeemPoint()
            }
        })
        
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
                            khach.update(tu: updateKhach)
                            suadoi = false
                        })
                }
            }
            .sheet(item: $loiRedeem){ coloi in
                LoiView(loi: coloi)
            }
    }//body
   
    private func checkEmail(email: String) -> Bool {
        guard let doan = try? Regex(".+@.+") else {return true}
        if email.contains(doan){
            return false
        } else {return true}
    }
    
    private func redeemPoint(){
        do {
            if let diem = Int(redeem){
            try khach.redeemPoints(points: diem)}
        } catch {
            loiRedeem = Loi(error: BiLoi.khongDuDiem, chiTiet: "The amounts enter larger than \(khach.name) earn")
        }
        claim = false
    }
    
}

struct ClientDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClientDetail(worker: .constant(quang),khach: .constant(khachmau[0]))
        }
    }
}


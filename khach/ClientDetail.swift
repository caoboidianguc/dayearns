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
    @State private var loiRedeem: Loi?
    
    
    var body: some View {
        List {
            HeadDetailSection(khach: $khach)
            
            ServiceDetailSection(khach: $khach)
            
            DetailSection(khach: $khach)
            
            NavigationLink("Receipt", destination: {
                HoaDon(worker: worker, khach: khach)
            })
        }
        
        .navigationTitle(Text("\(khach.layTen()) visited"))
            .navigationBarItems(trailing: Button("Edit"){
                suadoi = true
                updateKhach = khach.mau
            }
                .accessibilityLabel("Edit \(khach.name)"))
        
            .fullScreenCover(isPresented: $suadoi) {
                NavigationView {
                    ClientEdit(worker: $worker, client: $updateKhach)
                        .navigationBarItems(leading: Button("Cancel"){
                            suadoi = false
                        }, trailing: Button("Update"){
                            khach.update(tu: updateKhach)
                            khach.tip = nil
                            suadoi = false
                        })
                }
            }
            .sheet(item: $loiRedeem){ coloi in
                LoiView(loi: coloi)
            }
               
    }//body
    
    var renderURL = URL.documentsDirectory.appending(path: "hoadon.pdf")
}

struct ClientDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClientDetail(worker: .constant(quang),khach: .constant(khachmau[0]))
                .environmentObject(KhachData())
        }
    }
}


struct DetailSection: View {
    @State private var loiRedeem: Loi?
    @Binding var khach: Khach
    @State private var claim = false
    @State private var redeem = ""
    var body: some View {
        Section(content: {
            if !khach.isNew {
                Text("Latest Visits: \(khach.ngay.formatted(.dateTime))")
            }
            Text("Note: \(khach.desc)")
            HStack {
                Text("Points Earn: \(khach.diem)")
                Spacer()
                Button(action: {
                    claim = true
                }, label: {
                    Text("Claim", comment: "Client claimed their point here")
                        .help("Client claimed their point here")
                })
            }
            Text("Total: $\(khach.khachTra())")
            Text("First Visits: \(khach.firstCome.formatted(.dateTime))")
        }, header: {
            Text("Detail:")
        }, footer: {
            if let tag = khach.tag?.name {
                Text(tag)
            }
            
        })
            .alert("Redeem points", isPresented: $claim, actions: {
                TextField("Points", text: $redeem)
                Button("Dismiss", role: .cancel){ claim = false }
                Button("Redeem"){
                    redeemPoint()
                }
            })
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



struct HeadDetailSection: View {
    @Binding var khach: Khach
    var body: some View {
        Section(header: Text("Client:")) {
            HStack {
                Text(khach.name)
                Spacer()
                if khach.sdt.isEmpty {
                    PhoneButton(khach: $khach)
                } else {
                    Link(destination: URL(string: "sms:\(khach.sdt)")!, label: {Text(khach.sdt)})
                }
            }
//                replace "tel" to "sms" for message
            if !khach.email.isEmpty {
                Link(destination: URL(string: "mailto:\(khach.email)")!, label: {Text(khach.email)})
            }
            HStack{
                DanhGiaView(danhGia: $khach.danhGia)
            }
        }
    }
}

struct ServiceDetailSection: View {
    @Binding var khach: Khach
    var body: some View {
        Section(content: {
            if let bonus = khach.tip {
                HStack {
                    Text("Tip:").foregroundStyle(.green)
                    Spacer()
                    Text("$ \(bonus)")
                }
            }
            ForEach(khach.dvDone){dv in
                HStack {
                    Text(dv.dichVu)
                    Spacer()
                    Text("$\(dv.gia)")
                }
            }
        }, header: {Text("Services:")}, footer: {
            AddTip(khach: $khach)
        })
    }
}

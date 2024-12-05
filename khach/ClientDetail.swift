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
    @State private var detail = false
    @State private var history = false
    
    var denTham: String {
        return khach.schedule ? "Next Visit" : "Last Visit"
    }
    var body: some View {
        List {
            HeadDetailSection(khach: $khach)
            ServiceDetailSection(khach: $khach)
            Section(content: {
                HStack {
                    Text("\(denTham) -> \(khach.ngay.formatted(date: .omitted, time: .shortened))")
                    Spacer()
                    Toggle(isOn: $detail, label: {
                        Image(systemName: "exclamationmark.bubble.circle.fill")
                    })
                        .toggleStyle(.button)
                }.font(.title2)
            })
//            Section(content: {
//                if let diaChi = khach.address {
//                    Text("\(diaChi.street) \(diaChi.alternateStreet),\n\(diaChi.city), \(diaChi.state)  \(diaChi.zip).")
//                        .textSelection(.enabled)
//                }else {
//                    NavigationLink(destination: {
//                        GetAddressView(khach: $khach)
//                    }, label: {
//                        Text("Add Shipping Address")
//                    })
//                }
//            })
            NavigationLink("Receipt", destination: {
                HoaDon(worker: worker, khach: khach)
            })
        }//list
        
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
                                let hitory = HistoryVisit(ngay: updateKhach.ngay,note: updateKhach.desc, dvDone: updateKhach.dvDone)
                                khach.update(tu: updateKhach)
                                khach.histories.append(hitory)
                                khach.tip = nil
                                suadoi = false
                        })
                }
            }
            .sheet(item: $loiRedeem){ coloi in
                LoiView(loi: coloi)
            }
            .sheet(isPresented: $detail){
                NavigationView {
                    DetailSection(khach: $khach)
                        .navigationTitle("\(khach.name)'s detail")
                        .toolbar{
                            ToolbarItem(placement: .navigationBarTrailing){
                                Button("Done"){
                                    detail = false
                                }
                            }
                        }
                }
            }
    }//body
    func printAddress(){
        if let diaChi = khach.address {
            print("\(diaChi.street), \(diaChi.state), \(diaChi.zip)")
        }
    }
    

    private func historyView() -> some View {
        Section(content: {
            HStack {
                Text("Histories")
                Spacer()
                Toggle(isOn: $history, label: {
                    Image(systemName: "clock.arrow.circlepath")
                })
                    .toggleStyle(.button)
            }
        })
    }
}

//struct ClientDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ClientDetail(worker: .constant(quang), khach: .constant(khachmau[0]))
//                .environmentObject(KhachData())
//        }
//    }
//}



struct DetailSection: View {
    @State private var loiRedeem: Loi?
    @Binding var khach: Khach
    @State private var claim = false
    @State private var redeem = ""
    var body: some View {
        List {
            Section(content: {
                if !khach.isNew {
                    Text("\(visit) \(khach.ngay.formatted(.dateTime))")
                }
                Text("Note: \(khach.desc)")
                HStack {
                    Text("Points Earn: \(khach.diem)")
                    Spacer()
                    ClaimPointButton(){
                        claim = true
                    }
                }
                Text("First Visits: \(khach.firstCome.formatted(.dateTime))")
                
                if let birthDay = khach.birthDay {
                    HStack {
                        Label(khach.isBirthday ? "It's Today" : "Birthday", systemImage: khach.isBirthday ? "birthday.cake.fill" : "")
                            .font(khach.isBirthday ? .headline : .callout)
                            .foregroundStyle(khach.isBirthday ? .green : .primary)
                        Spacer()
                        Text(birthDay, style: .date)
                            .opacity(khach.isBirthday ? 0.1 : 0.9)
                    }
                }else {
                    BirthdayButton(khach: $khach)
                }
            }, header: {Text("Info")})
          
            NavigationLink("Histories visited", destination: {
                HistoriesView(histories: khach.histories)
            })
          
        }
//        .listStyle(.plain)
            .alert("Redeem points", isPresented: $claim, actions: {
                TextField("Points", text: $redeem)
                    .keyboardType(.numberPad)
                Button("Dismiss", role: .cancel){ claim = false }
                Button("Redeem"){
                    redeemPoint()
                    claim = false
                }
            })
    }//body
    private func redeemPoint(){
        do {
            if let diem = Int(redeem){
            try khach.redeemPoints(points: diem)}
        } catch {
            loiRedeem = Loi(error: BiLoi.khongDuDiem, chiTiet: "The amounts enter larger than \(khach.name) earn")
        }
    }
    var visit: String {
        khach.ngay > Date.now ? "Next Visit:" : "Latest Visit:"
    }
}



struct HeadDetailSection: View {
    @Binding var khach: Khach
    var phone: String{
        khach.correctPhone(laySo: khach.sdt)
    }
    var body: some View {
        Section(content: {
            HStack {
                Text(khach.name)
                Spacer()
                if khach.sdt.isEmpty {
                    PhoneButton(khach: $khach)
                } else {
                    Link(destination: URL(string: "sms:\(phone)")!, label: {Text(phone)})
                }
            }
//                replace "tel" to "sms" for message
            if !khach.email.isEmpty {
                Link(destination: URL(string: "mailto:\(khach.email)")!, label: {Text(khach.email)})
            }
            HStack{
                DanhGiaView(danhGia: $khach.danhGia)
            }
        },header: {
            Text("Client:")
        } , footer: {
            if let theTag = khach.tag {
                Label(theTag, systemImage: "tag")
            } else {
                AddTag(khach: $khach)
            }
        }).padding(5)
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
            HStack {
                Text("Total:")
                Spacer()
                Text("$ \(khach.khachTra())")
            }.font(.title2)
        }, header: {
            HStack {
                Text("Services:")
                Spacer()
                AddTip(khach: $khach)
            }
        }).padding(5)
    }
}

//struct DeleteButton: View {
//    @Binding var worker: Technician
//    var khach: Khach
//    @State private var xoa = false
//    
//    var body: some View {
//        Button(action: {
//            xoa = true
//        }, label: {
//            
//            Text("Delete this Client")
//                .foregroundStyle(.red)
//                .font(.headline)
//        })
//        .alert("Sure ee!", isPresented: $xoa, actions: {
//            Button("Nooo!"){
//                xoa = false
//            }
//            Button("Delete", action: {
//                worker.delete(khach)
//            })
//        })
//    }
//}

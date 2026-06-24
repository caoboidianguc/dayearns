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
    @State private var removeAddress = false

    var denTham: String {
        khach.schedule ? "Next Visit" : "Last Visit"
    }
    
    var body: some View {
        List {
            // Client Header Section
            HeadDetailSection(khach: $khach)
            
            // Services Section
            ServiceDetailSection(khach: $khach)
            
            // Visit Date Section
            Section {
                HStack {
                    Text("\(denTham): \(khach.ngay, format: .dateTime.month().day().hour().minute())")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Toggle(isOn: $detail) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    .toggleStyle(.button)
                    .accessibilityLabel("Show client details")
                }
            }
            
            // Visit Histories Section
            Section {
                NavigationLink(destination: HistoriesView(histories: khach.histories)) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.gray)
                        Text("Visit Histories")
                    }
                }
            }
            
            // Address Section
            Section(footer:
                HStack {
                    Text("")
                    Spacer()
                    Button(action: {
                        removeAddress = true
                }, label: {
                    Image(systemName: "trash")
                }).opacity(khach.address ?? nil == nil ? 0 : 1)
                    }
            ) {
                if let diaChi = khach.address {
                    let addressComponents = [
                        diaChi.street,
                        diaChi.alternateStreet,
                        diaChi.city,
                        "\(diaChi.state) \(diaChi.zip)"
                    ].compactMap {$0?.trimmingCharacters(in: .whitespacesAndNewlines)}
                        .filter { !$0.isEmpty}
                        .joined(separator: ", ")
                    let encodeAddress = addressComponents.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(.red)
                        let urlString = "https://maps.apple.com/?q=\(encodeAddress)"
                        let url = URL(string: urlString)
                        Link(destination: url!, label: {
                            Text("\(diaChi.street) \(diaChi.alternateStreet),\n\(diaChi.city), \(diaChi.state) \(diaChi.zip)")
                        })
                        }
                } else {
                    NavigationLink(destination: GetAddressView(khach: $khach)) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.green)
                            Text("Add Shipping Address")
                        }
                    }
                }
            }.alert("Remove Address?",isPresented: $removeAddress, actions: {
                Button("Cancel",role: .cancel, action: {removeAddress = false})
                Button("Remove") {
                    khach.address = nil
                }
            })
            
            // Receipt Section
            Section {
                NavigationLink(destination: HoaDon(worker: worker, khach: khach)) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(.gray)
                        Text("Receipt")
                    }
                }
            }
        }
        .listStyle(.grouped) // Better section separation
        .navigationTitle("\(khach.layTen())'s Visit")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    suadoi = true
                    updateKhach = khach.mau
                }) {
                    Image(systemName: "pencil")
                        .foregroundStyle(.blue)
                }
                .accessibilityLabel("Edit \(khach.name)")
            }
        }
        .fullScreenCover(isPresented: $suadoi) {
            NavigationStack {
                ClientEdit(worker: $worker, client: $updateKhach)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { suadoi = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Update") {
                                let history = HistoryVisit(
                                    ngay: updateKhach.ngay,
                                    note: updateKhach.desc,
                                    dvDone: updateKhach.dvDone,
                                    tip: khach.tip
                                )
                                khach.update(tu: updateKhach)
                                khach.histories.append(history)
                                khach.tip = nil
                                suadoi = false
                            }
                        }
                    }
            }
        }
        .sheet(item: $loiRedeem) { coloi in
            LoiView(loi: coloi)
        }
        .sheet(isPresented: $detail) {
            NavigationStack {
                DetailSection(khach: $khach)
                    .navigationTitle("\(khach.name)'s Details")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { detail = false }
                        }
                    }
            }
        }
    }
}

// Detail Section
struct DetailSection: View {
    @State private var loiRedeem: Loi?
    @Binding var khach: Khach
    @State private var claim = false
    @State private var redeem = ""
    
    var visit: String {
        khach.ngay > Date.now ? "Next Visit:" : "Latest Visit:"
    }
    
    var body: some View {
        List {
            Section(header: Text("Visit Info")) {
                if !khach.isNew {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.purple)
                        Text("\(visit) \(khach.ngay, format: .dateTime)")
                    }
                }
                HStack {
                    Image(systemName: "note.text")
                        .foregroundStyle(.gray)
                    Text("Note: \(khach.desc)")
                }
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Points Earned: \(khach.diem)")
                    Spacer()
                    ClaimPointButton { claim = true }
                }
            }
            
            Section(header: Text("Personal Info")) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(.gray)
                    Text("First Visit: \(khach.firstCome, format: .dateTime)")
                }
                if let birthDay = khach.birthDay {
                    HStack {
                        Label(khach.isBirthday ? "It's Today!" : "Birthday", systemImage: khach.isBirthday ? "birthday.cake.fill" : "calendar")
                            .font(khach.isBirthday ? .headline : .callout)
                            .foregroundStyle(khach.isBirthday ? .green : .primary)
                        Spacer()
                        Text(birthDay, style: .date)
                            .opacity(khach.isBirthday ? 0.1 : 0.9)
                    }
                } else {
                    BirthdayButton(khach: $khach)
                }
            }
        }
        .listStyle(.grouped)
        .alert("Redeem Points", isPresented: $claim) {
            TextField("Enter points", text: $redeem)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) { claim = false }
            Button("Redeem") {
                redeemPoint()
                claim = false
            }
        } message: {
            Text("Enter the number of points to redeem.")
        }
    }
    
    private func redeemPoint() {
        if let diem = Int(redeem), diem > 0 {
            do {
                try khach.redeemPoints(points: diem)
            } catch {
                loiRedeem = Loi(error: BiLoi.khongDuDiem, chiTiet: "Not enough points for \(khach.name).")
            }
        } else {
            loiRedeem = Loi(error: BiLoi.khongDuDiem, chiTiet: "Please enter a valid number of points.")
        }
    }
}

// Head Detail Section
struct HeadDetailSection: View {
    @Binding var khach: Khach
    var phone: String{
        khach.correctPhone(laySo: khach.sdt)
    }
    var body: some View {
        Section(content: {
            HStack {
                Text(khach.name)
                    .font(.title3)
                Spacer()
                if khach.sdt.isEmpty {
                    PhoneButton(khach: $khach)
                } else if let smsURL = URL(string: "sms:\(phone)") {
                    Link(destination: smsURL) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(.green)
                            Text(phone)
                        }
                    }
                } else {
                    Text(phone)
                        .foregroundStyle(.gray)
                        .italic()
                }
            }
//                replace "tel" to "sms" for message
            if !khach.email.isEmpty {
                Link(destination: URL(string: "mailto:\(khach.email)")!, label: {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.purple)
                        Text(khach.email)
                    }
                })
            }
            HStack{
                DanhGiaView(danhGia: $khach.danhGia)
            }
        },header: {
            Text("Client:")
        } , footer: {
            if let theTag = khach.tag {
                Label(theTag, systemImage: "tag.fill")
                    .foregroundStyle(.orange)
            } else {
                AddTag(khach: $khach)
            }
        }).padding(.vertical, 5)
    }
}

// Service Detail Section
struct ServiceDetailSection: View {
    @Binding var khach: Khach
    
    var body: some View {
        Section(header: HStack {
            Text("Services")
            Spacer()
            AddTip(khach: $khach)
        }) {
            if let bonus = khach.tip {
                HStack {
                    Text("Tip:")
                        .foregroundStyle(.green)
                    Spacer()
                    Text("$ \(bonus)")
                        .foregroundStyle(.green)
                }
            }
            ForEach(khach.dvDone) { dv in
                HStack {
                    Text(dv.dichVu)
                    Spacer()
                    Text("$\(dv.gia)")
                }
            }
            HStack {
                Text("Total:")
                    .font(.title2.bold())
                Spacer()
                Text("$ \(khach.khachTra())")
                    .font(.title2.bold())
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 5)
    }
}


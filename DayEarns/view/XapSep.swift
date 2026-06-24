//
//  XapSep.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct XapSep: View {
    @EnvironmentObject var tech: KhachData
    @State private var khong: Bool = false
    @State private var hienProfile = false
    var ngayEarn: [WeekEarn] {
        tech.worker.weekEarn.filter(\.trongTuan)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TotalWorkingRange(tech: tech)
                } header: {
                    Text("Review timeline:")
                        .font(.headline)
                }
                NavigationLink {
                    BieuDoChung(worker: tech.worker)
                } label: {
                    BieuDoView(worker: tech.worker)
                        .frame(height: 250)
                }
                .overlay {
                    if tech.worker.motTuanHistory.isEmpty {
                        VStack(alignment: .center, spacing: 10) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(.yellow)
                                .shadow(radius: 2)
                            Text("Your daily chart show here!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section(header: Text("Today")) {
                    HStack {
                        Label("\(tech.worker.tongNgay())", systemImage: "dollarsign")
                            .font(.title2)

                        Spacer()
                        Button {
                            withAnimation(.easeInOut) {
                                luuNgayLam()
                            }
                        } label: {
                            Image(systemName: "tray.and.arrow.down")
                                .opacity(khong ? 0 : 1)
                                .font(.title2)
                                .padding(5)
                        }
                    }
                    .alert("Today have saved", isPresented: $khong) {}
                }

                Section(header: Text("DAYS WERE SAVED")) {
                    ForEach(ngayEarn) { tuan in
                        HStack {
                            Text(tuan.ngay.formatted(.dateTime.month().day()))
                            Spacer()
                            VStack {
                                Text("$ \(tuan.earn)")
                                    .font(.title2)
                                Text("$ \(tuan.tip ?? 0)")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .onDelete { tuan in
                        tech.worker.weekEarn.remove(atOffsets: tuan)
                    }
                }
            }
            .navigationTitle("Summary!")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { hienProfile = true } label: {
                        Image(systemName: "person.crop.rectangle.fill")
                    }
                }
            }
            .sheet(isPresented: $hienProfile) {
                NavigationStack {
                    TechView(tech: tech.worker)
                        .navigationTitle("Info")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { hienProfile = false }
                            }
                        }
                }
            }
        }
    }

    private func luuNgayLam() {
        let tienTip: Int = tech.worker.tinhTip()
        let tienLam: Int = tech.worker.tongNgay() - tienTip
        var newWeek = WeekEarn(ngay: .now, earn: tienLam)
        newWeek.tip = tienTip
        tech.worker.weekEarn.insert(newWeek, at: 0)
        khong = true
    }
}

struct XapSep_Previews: PreviewProvider {
    static var previews: some View {
        XapSep()
            .environmentObject(KhachData())
    }
}

struct TotalWorkingRange: View {
    @State var fromDate: Date = Date()
    @State var toDate: Date = Date()
    var tech: KhachData
    @State private var tongTien: Int = 0
    @State private var tongTip: Int = 0

    var body: some View {
        VStack {
            DatePicker("From", selection: $fromDate, displayedComponents: .date)
            DatePicker("To", selection: $toDate, displayedComponents: .date)
                .onChange(of: toDate) { ngay in
                    recalculate(to: ngay)
                }
            HStack {
                Text("Total Earnings: \(tongTien)").foregroundStyle(.yellow)
                Text("Total tip: \(tongTip)").foregroundStyle(.green)
            }
        }
        .onChange(of: fromDate) { ngay in
            tongTien = tech.tongTienTrongKhoangThoiGian(fromDate: ngay, toDate: toDate)
            tongTip = tech.tongTipTrongKhoangThoiGian(fromDate: ngay, toDate: toDate)
        }
        .onAppear {
            fromDate = Date()
            toDate = Date()
            recalculate(to: toDate)
        }
    }

    private func recalculate(to ngay: Date) {
        tongTien = tech.tongTienTrongKhoangThoiGian(fromDate: fromDate, toDate: ngay)
        tongTip = tech.tongTipTrongKhoangThoiGian(fromDate: fromDate, toDate: ngay)
    }
}
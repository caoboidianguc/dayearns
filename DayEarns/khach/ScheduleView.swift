//
//  ScheduleView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var tech: KhachData
    @State private var addClient = false
    @State private var khachHen = Khach.ThemKhach()
    @State private var daCo = false
    @State private var thongbao = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(QuaTuan.allCases) { quatuan in
                    if !tech.worker.tuan(quaTuan: quatuan).isEmpty {
                        Section {
                            ForEach(tech.worker.tuan(quaTuan: quatuan)) { khach in
                                NavigationLink {
                                    ClientDetail(worker: $tech.worker, khach: tech.binding(for: khach))
                                } label: {
                                    KhachRow(khach: tech.binding(for: khach))
                                }
                            }
                        } header: {
                            Text(LocalizedStringKey(quatuan.name))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(tuaDe())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") { addClient = true }
                        .help(Text("add schedule for a client"))
                        .accessibilityLabel("add schedule for a client")
                }
            }
            .sheet(isPresented: $addClient) {
                NavigationStack {
                    ChonNgay(client: $khachHen)
                        .alert(thongbao, isPresented: $daCo) {}
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { addClient = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add") { layHen() }
                                    .disabled(khachHen.ngay < Date.now)
                            }
                        }
                        .onAppear {
                            khachHen.dvDone.removeAll()
                            khachHen.name.removeAll()
                            khachHen.sdt.removeAll()
                        }
                }
            }
        }
    }

    private func tuaDe() -> LocalizedStringKey {
        let count = tech.worker.khach.filter(\.schedule).count
        return count == 0 ? "No Schedules" : "\(count) Up Coming"
    }

    private func layHen() {
        let history = HistoryVisit(ngay: khachHen.ngay, note: khachHen.desc, dvDone: khachHen.dvDone)
        if !khachHen.sdt.isEmpty && khachHen.sdt.count < 10 {
            thongbao = "Phone number is incorrect!"
            daCo = true
            return
        }

        var newClient = Khach(
            name: khachHen.name,
            sdt: khachHen.sdt,
            dvDone: khachHen.dvDone,
            ngay: khachHen.ngay,
            diem: khachHen.pointsKhach()
        )

        if let index = tech.worker.indexOfDuplicate(for: newClient) {
            tech.worker.khach[index].ngay = khachHen.ngay
            tech.worker.khach[index].dvDone = khachHen.dvDone
            tech.worker.khach[index].desc = khachHen.desc
            tech.worker.khach[index].histories.insert(history, at: 0)
            addClient = false
        } else {
            newClient.histories.insert(history, at: 0)
            tech.worker.khach.append(newClient)
            addClient = false
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(KhachData())
    }
}
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
                ForEach(QuaTuan.allCases){ quatuan in
                    if !tech.worker.tuan(quaTuan: quatuan).isEmpty {
                        Section(content: {
                            ForEach(tech.worker.tuan(quaTuan: quatuan)) { khach in
                                NavigationLink(destination: ClientDetail(worker: $tech.worker, khach: binding(for: khach)) ){
                                    KhachRow(khach: binding(for: khach))
                                }
                            }
                        }, header: {Text(LocalizedStringKey(quatuan.name))})
                    }
                }
            }
            
            .listStyle(.plain)
            .navigationTitle(tuaDe())
                .navigationBarItems(trailing:
                    Button("Add"){ addClient = true }
                    .help(Text("add schedule for a client"))
                    .accessibilityLabel("add schedule for a client"))
                .sheet(isPresented: $addClient){
                    NavigationView {
                        ChonNgay(client: $khachHen)
                            .alert(thongbao, isPresented: $daCo, actions: {})
                            .navigationBarItems(leading: Button("Cancel") {
                                addClient = false
                            }, trailing: Button("Add"){
                                layHen()
                            }.disabled(khachHen.ngay < Date.now))
                            .onAppear {
                                khachHen.dvDone.removeAll()
                                khachHen.name.removeAll()
                                khachHen.sdt.removeAll()
                            }
                    }
                }
                
            
        }//navi
        
    }
    private func tuaDe() -> LocalizedStringKey {
        var tua: LocalizedStringKey = ""
        let khach = tech.worker.khach.filter {$0.schedule}.count
        if khach == 0 {
            tua = "No Schedules"
        } else {
            tua = "\(khach) Up Coming"
        }
        return tua
    }
    private func binding(for khachIndex: Khach) -> Binding<Khach> {
        guard let clientIndex = tech.worker.khach.firstIndex(where: {$0.id == khachIndex.id}) else {fatalError("khong the lay khach index")}
        return $tech.worker.khach[clientIndex]
    }
    private func layHen(){
        let hitory = HistoryVisit(ngay: khachHen.ngay, note: khachHen.desc, dvDone: khachHen.dvDone)
        if !khachHen.sdt.isEmpty && khachHen.sdt.count < 10 {
            thongbao = "Phone number is incorrect!"
            daCo = true
        } else {
            var newClient = Khach(name: khachHen.name, sdt: khachHen.sdt, dvDone: khachHen.dvDone, ngay: khachHen.ngay, diem: khachHen.pointsKhach())
            if tech.worker.clientExisted(newClient){
                thongbao = "Client existed\nUpdate client for future appointment."
                daCo = true
            } else {
                newClient.histories.insert(hitory, at: 0)
                tech.worker.khach.append(newClient)
                addClient = false
            }
                                    
        }
    }
    
}
struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(KhachData())
    }
}


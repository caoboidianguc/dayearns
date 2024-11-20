//
//  ContentView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI
struct ContentView: View {
    @EnvironmentObject var tech: KhachData
    let luuThayDoi: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @State private var manhinh: Chon = .khach
    
    var body: some View {
        if tech.worker.name.isEmpty {
            AddTech(tech: $tech.worker)
        } else {
            TabView(selection: $manhinh) {
                ScheduleView(worker: $tech.worker)
                    .tabItem {
                        sinhNhatLabel()
                    }
                    .tag(Chon.schedule)
                
                ClientList(tech: $tech.worker)
                    .tabItem {
                        Label("Clients", systemImage: "person.text.rectangle")
                    }
                    .tag(Chon.khach)
                
                ServiceView(worker: $tech.worker)
                    .tabItem {
                        Label("Services", systemImage: "list.dash")
                    }
                    .tag(Chon.dv)
                
                XapSep(worker: $tech.worker)
                    .tabItem{
                        Label("Earns", systemImage: "scroll")
                    }
                    .tag(Chon.xep)
                
            }
            .onChange(of: scenePhase){ phase in
                if phase == .background {
                    luuThayDoi()
                }
            }
            .onAppear {
                if !tech.worker.khach.filter({$0.haiNgay}).isEmpty || !tech.worker.khach.filter({$0.isBirthday}).isEmpty {
                    manhinh = .schedule
                }
//                tech.khach.filter{$0.isBirthday}.forEach{ client in clientBirthdayNotification(client: client) }
//                
//                tech.khach.filter{$0.schedule}.forEach{ client in
//                    khachHenComingUp(client: client)
//                    print(client.name)
//                }
            }
        }
    }//body
    var sinhNhat : Bool {
        if tech.worker.khach.contains(where: {$0.isBirthday}){
            return true
        } else { return false }
    }
    private func sinhNhatLabel() -> some View {
        Label(sinhNhat ? "Party" : "Schedule", systemImage: sinhNhat ? "birthday.cake" : "calendar.badge.clock")
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(luuThayDoi: {})
                .environmentObject(KhachData())
    }
}

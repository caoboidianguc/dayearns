//
//  ContentView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI
struct ContentView: View {
    @Binding var tech: Technician
    let luuThayDoi: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @State private var manhinh: Chon = .khach
    
    var body: some View {
        if tech.name.isEmpty {
            AddTech(tech: $tech)
        } else {
            TabView(selection: $manhinh) {
                ScheduleView(worker: $tech)
                    .tabItem {
                        sinhNhatLabel()
                    }
                    .tag(Chon.schedule)
                
                ClientList(tech: $tech)
                    .tabItem {
                        Label("Clients", systemImage: "person.text.rectangle")
                    }
                    .tag(Chon.khach)
                
                ServiceView(worker: $tech)
                    .tabItem {
                        Label("Services", systemImage: "list.dash")
                    }
                    .tag(Chon.dv)
                
                XapSep(worker: $tech)
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
                if !tech.khach.filter({$0.haiNgay}).isEmpty || !tech.khach.filter({$0.isBirthday}).isEmpty {
                    manhinh = .schedule
                }
            }
        }
    }//body
    var sinhNhat : Bool {
        if tech.khach.contains(where: {$0.isBirthday}){
            return true
        } else { return false }
    }
    private func sinhNhatLabel() -> some View {
        Label(sinhNhat ? "Party" : "Schedule", systemImage: sinhNhat ? "birthday.cake" : "calendar.badge.clock")
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tech: .constant(quang), luuThayDoi: {})
                .environmentObject(KhachData())
    }
}

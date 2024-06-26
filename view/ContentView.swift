//
//  ContentView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI
//@available(iOS 17.0, *)
struct ContentView: View {
    @Binding var worker: Technician
    let luuThayDoi: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @State private var manhinh: Chon = .khach
    
    var body: some View {
        if worker.name.isEmpty {
            AddTech(tech: $worker)
        } else {
            TabView(selection: $manhinh) {
                ScheduleView(worker: $worker)
                    .tabItem {
                        Label("Schedule", systemImage: "calendar.badge.clock")
                    }
                    .tag(Chon.schedule)
                
                ClientList(worker: $worker)
                    .tabItem {
                        Label("Clients", systemImage: "person.text.rectangle")
                    }
                    .tag(Chon.khach)
                
                ServiceView(worker: $worker)
                    .tabItem {
                        Label("Services", systemImage: "list.dash")
                    }
                    .tag(Chon.dv)
                
                XapSep(worker: $worker)
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
                if !worker.khach.filter({$0.haiNgay}).isEmpty {
                    manhinh = .schedule
                }
            }
        }
    }
    
}
//@available(iOS 17.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView(worker: .constant(quang), luuThayDoi: {})
                .environmentObject(KhachData())
    }
}

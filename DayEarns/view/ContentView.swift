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
        TabView(selection: $manhinh) {
            ScheduleView()
                .tabItem { sinhNhatLabel() }
                .tag(Chon.schedule)

            ClientList()
                .tabItem {
                    Label("Clients", systemImage: "person.text.rectangle")
                }
                .tag(Chon.khach)

            ServiceView()
                .tabItem {
                    Label("Services", systemImage: "list.dash")
                }
                .tag(Chon.dv)

            XapSep()
                .tabItem {
                    Label("Earns", systemImage: "scroll")
                }
                .tag(Chon.xep)
        }
        .overlay {
            if tech.worker.name.isEmpty {
                AddTech(tech: $tech.worker)
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background || phase == .inactive {
                luuThayDoi()
            }
            if phase == .active {
                clearAppBadge()
            }
        }
        .onAppear {
            if !tech.worker.khach.filter(\.haiNgay).isEmpty || !tech.worker.khach.filter(\.isBirthday).isEmpty {
                manhinh = .schedule
            }
        }
    }

    var sinhNhat: Bool {
        tech.worker.khach.contains(where: \.isBirthday)
    }

    private func sinhNhatLabel() -> some View {
        Label(
            sinhNhat ? "Party" : "Schedule",
            systemImage: sinhNhat ? "birthday.cake" : "calendar.badge.clock"
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(luuThayDoi: {})
            .environmentObject(KhachData())
    }
}
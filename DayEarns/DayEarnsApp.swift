//
//  DayEarnsApp.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

@main
struct DayEarnsApp: App {
    @StateObject var ledger = KhachData()
    var body: some Scene {
        WindowGroup {
                ContentView(worker: $ledger.worker) {
                    ledger.save()
                }.environmentObject(ledger)
                .onAppear {
                    ledger.load()
                }
                .refreshable {
                    ledger.load()
                }
        }
    }
}

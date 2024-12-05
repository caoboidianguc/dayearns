//
//  DayEarnsApp.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

@main
//@available(iOS 17.0, *)
struct DayEarnsApp: App {
    @StateObject var ledger = KhachData()
    var body: some Scene {
        WindowGroup {
            ContentView() {
                    Task {
                        do{
                            try await ledger.save(tech: ledger.worker)
                        } catch {
                            fatalError("Can't save")
                        }
                        ledger.checkForSchedule()
                    }
                }
                .environmentObject(ledger)
               
                .onAppear{
                    requestNotificationPermission()
                    Task {
                    do {
                        try await ledger.load()
                    } catch {
                        print("Loading or migration failed: \(error)")
                        }
                    }
                }
                .refreshable {
                    Task {
                        do{
                            try await ledger.load()
                        } catch {
                            fatalError("Can't load")
                        }
                    }
                }
        }
    }
}


    

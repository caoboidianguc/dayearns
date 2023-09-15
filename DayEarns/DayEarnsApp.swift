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
                    Task {
                        do{
                            try await ledger.save(tech: ledger.worker)
                        } catch {
                            fatalError("Can't save")
                        }
                    }
                }
                .environmentObject(ledger)
                .onAppear {
                    Task {
                        do{
                            try await ledger.load()
                        } catch {
                            fatalError("Can't load")
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

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
            ContentView(tech: $ledger.worker) {
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
                            await ledger.loadAppAndBirthday()
                        } catch {
                            print("Loading or migration failed: \(error)")
                        }
                        requestNotificationPermission()
                        ledger.clientBirthday.forEach{ client in clientBirthdayNotification(client: client) }
                        
                        ledger.clientAppointment.forEach{ client in
                            khachHenComingUp(client: client)
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


    

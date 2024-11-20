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
                    }
                }
            .environmentObject(ledger)
           
            .task {
                    do{
                        try await ledger.load()
                        await ledger.layKhach()
                    } catch {
                        print("Loading or migration failed: \(error)")
                    }
                    requestNotificationPermission()
                ledger.sinhNhat.forEach{ client in clientBirthdayNotification(client: client)}
                
                ledger.khachHen.forEach{ client in
                    khachHenComingUp(client: client)
                    print(client.name)
                }
                }//task
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


    

//
//  DayEarnsApp.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

@main
struct DayEarnsApp: App {
    @StateObject private var ledger = KhachData()

    var body: some Scene {
        WindowGroup {
            ContentView {
                Task { await ledger.persist() }
            }
            .environmentObject(ledger)
            .alert(
                "Save Error",
                isPresented: Binding(
                    get: { ledger.persistenceError != nil },
                    set: { if !$0 { ledger.persistenceError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    ledger.persistenceError = nil
                }
            } message: {
                Text(ledger.persistenceError ?? "")
            }
            .task {
                requestNotificationPermission()
                do {
                    try await ledger.load()
                } catch {
                    ledger.persistenceError = "Could not load your saved data."
                    print("Loading failed: \(error)")
                }
            }
            .refreshable {
                do {
                    try await ledger.load()
                } catch {
                    ledger.persistenceError = "Could not reload your data."
                    print("Reload failed: \(error)")
                }
            }
        }
    }
}
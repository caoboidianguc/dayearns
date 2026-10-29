//
//  KhachData.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

@MainActor
class KhachData: ObservableObject {

    @Published var worker: Technician = Technician(name: "", phone: "")
    @Published var persistenceError: String?

    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("khach.data")
    }

    func save(tech: Technician) async throws {
        let url = try Self.fileURL()
        let data = try JSONEncoder().encode(tech)
        try data.write(to: url, options: .atomic)
        WidgetSnapshot.make(from: tech).write()
    }

    func load() async throws {
        let fileURL = try Self.fileURL()
        guard let data = try? Data(contentsOf: fileURL) else {
            rescheduleNotifications()
            return
        }
        worker = try JSONDecoder().decode(Technician.self, from: data)
        WidgetSnapshot.make(from: worker).write()
        // Rebuild reminders from saved data; also clears any duplicate leftovers.
        rescheduleNotifications()
    }

    func persist() async {
        do {
            try await save(tech: worker)
            persistenceError = nil
            rescheduleNotifications()
        } catch {
            persistenceError = "Could not save your data. Please try again."
            print("Save failed: \(error)")
        }
    }

    func delete(_ client: Khach) {
        worker.delete(client)
    }

    /// Reads a client spreadsheet and saves full name plus phone.
    /// People already in the app are left untouched.
    func importClients(from csv: String) async throws -> ClientImportResult {
        let result = try ClientCSVImporter.importCSV(csv, into: &worker)
        if result.added > 0 {
            await persist()
        }
        return result
    }

    func clientExisted(_ client: Khach) -> Bool {
        worker.khach.contains { $0.isDuplicate(of: client) }
    }

    func findDuplicateIndex(for client: Khach) -> Int? {
        worker.khach.firstIndex { $0.isDuplicate(of: client) }
    }

    func binding(for client: Khach) -> Binding<Khach> {
        guard let index = worker.khach.firstIndex(where: { $0.id == client.id }) else {
            return .constant(client)
        }
        return Binding(
            get: { self.worker.khach[index] },
            set: { self.worker.khach[index] = $0 }
        )
    }

    func checkForSchedule() {
        rescheduleNotifications()
    }

    private func rescheduleNotifications() {
        rescheduleAllNotifications(clients: worker.khach)
    }

    func calculateDateWorked(fromDate: Date, toDate: Date) -> [HistoryVisit] {
        let lich = Calendar.current
        let from = lich.startOfDay(for: fromDate)
        let to = lich.startOfDay(for: toDate)
        return worker.khach.flatMap { khach in
            khach.histories.filter { his in
                let visitDate = lich.startOfDay(for: his.ngay)
                return visitDate >= from && visitDate <= to
            }
        }
    }

    func tongTienTrongKhoangThoiGian(fromDate: Date, toDate: Date) -> Int {
        calculateDateWorked(fromDate: fromDate, toDate: toDate).reduce(0) { $0 + $1.tongTien }
    }

    func tongTipTrongKhoangThoiGian(fromDate: Date, toDate: Date) -> Int {
        calculateDateWorked(fromDate: fromDate, toDate: toDate).reduce(0) { $0 + ($1.tip ?? 0) }
    }
}
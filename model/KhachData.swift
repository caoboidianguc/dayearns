//
//  KhachData.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

//import Foundation
import SwiftUI

@MainActor
class KhachData: ObservableObject {
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("khach.data")
    }
    @Published var worker: Technician = Technician(name: "", phone: "")
    @Published var khachHen: [Khach] = []
    @Published var sinhNhat: [Khach] = []
    
    func layKhach() async {
        do{
            let khachs = worker.khach.filter{$0.schedule}
            let sinhNhats = worker.khach.filter{$0.isBirthday}
            self.khachHen = khachs
            self.sinhNhat = sinhNhats
        }
    }
    
    func load() async throws {
            do {
                let url = try Self.fileURL()
                if FileManager.default.fileExists(atPath: url.path) {
                    let data = try Data(contentsOf: url)
                    let user = try JSONDecoder().decode(Technician.self, from: data)
                    await MainActor.run {  // Ensure UI updates happen on the main thread
                        self.worker = user
                    }
                } else {
                    print("No existing user data found")
                }
            } catch {
                throw error
            }
        }
    
    func save(tech: Technician) async throws {
        let task = Task {
            let url = try Self.fileURL()
            if FileManager.default.fileExists(atPath: url.path()){
                _ = try Data(contentsOf: url)
            }
//            oldline
            let data = try JSONEncoder().encode(tech)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
            print("Data saved successfully")
        }
        _ = try await task.value
    }
    
    func delete(_ client: Khach){
        worker.khach.removeAll(where: { $0.id == client.id})
    }
    
    func clientExisted(_ client: Khach) -> Bool {
        worker.khach.contains(client)
    }
    
}

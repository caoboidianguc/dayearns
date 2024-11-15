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
    
    func load() async throws {
            do {
                let url = try Self.fileURL()
                if FileManager.default.fileExists(atPath: url.path) {
                    let data = try Data(contentsOf: url)
                    let user = try JSONDecoder().decode(Technician.self, from: data)
                    print("Tech loaded: \(user)")
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
    
//    func load() async throws {
//        let task = Task<Technician, Error>{
//            let fileURL = try Self.fileURL()
//            guard let data = try? Data(contentsOf: fileURL) else { return worker}
//            let newTech = try JSONDecoder().decode(Technician.self, from: data)
//            return newTech
//        }
//        let tech = try await task.value
//        self.worker = tech
//    }
    
    
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
    
//    func checkAndMigrateData() async {
//        do {
//            let url = try Self.fileURL()
//            if FileManager.default.fileExists(atPath: url.path) {
//                let oldData = try Data(contentsOf: url)
//                //check if data exist
//                let jsonString = String(data: oldData, encoding: .utf8)
//                print("File contents: \(jsonString ?? "File is empty")")
//                let user = try JSONDecoder().decode(Technician.self, from: oldData)
//                
//                
//                if !UserDefaults.standard.bool(forKey: "hasMigratedToNewKhachModel") {
//                    
//                    user.khach = user.khach.map { oldClient in
//                        let newKhach = Khach(name: oldClient.name, sdt: oldClient.sdt, desc: oldClient.desc, dvDone: oldClient.dvDone, ngay: oldClient.ngay, danhGia: oldClient.danhGia ,diem: oldClient.diem)
//                        return newKhach
//                    }
//                    let newUser = Technician(name: user.name, phone: user.phone, services: user.services, khach: user.khach, weekEarn: user.weekEarn)
//                    // Save the migrated data
//                    let newData = try JSONEncoder().encode(newUser)
//                    try newData.write(to: url)
//                    
//                    UserDefaults.standard.set(true, forKey: "hasMigratedToNewKhachModel")//turn true if migrate
//                }
//            } else {print("File does not exist")}
//        } catch {
//            print("Error during data migration: \(error)")
//        }
//    }
}



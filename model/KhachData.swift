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
    func load() async throws {
            let task = Task<Technician, Error>{
                let fileURL = try Self.fileURL()
                guard let data = try? Data(contentsOf: fileURL) else { return worker}
                let newTech = try JSONDecoder().decode(Technician.self, from: data)
                return newTech
            }
            let tech = try await task.value
            self.worker = tech
        }
    func checkForSchedule(){
        self.worker.khach.filter{$0.isBirthday}.forEach{ client in clientBirthdayNotification(client: client)}
    
        self.worker.khach.filter{$0.schedule}.forEach{ client in
            khachHenComingUp(client: client)
            
        }
    }
}



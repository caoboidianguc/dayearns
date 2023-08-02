//
//  KhachData.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import Foundation
import SwiftUI


class KhachData: ObservableObject {
    private static var documentFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            fatalError("khong thay duong dan thu muc.")
        }
    }
    
    private static var fileURL: URL {
        return documentFolder.appendingPathComponent("khach.data")
    }
    
    @Published var worker: Technician = Technician(name: "", phone: "")
    
    func load(){
        DispatchQueue.global(qos: .background).async {
            [weak self] in
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                #if DEBUG
                DispatchQueue.main.async {
                    self?.worker = quang
                }
                #endif
                return
            }
            guard let nguoiMoi = try? JSONDecoder().decode(Technician.self, from: data) else {
                fatalError("khong the decode")
            }
            DispatchQueue.main.async {
                self?.worker = nguoiMoi
            }
        }
    }
    
    func save() {
        DispatchQueue.global(qos: .background).async {
            [weak self] in
            guard let ngaycong = self?.worker else {fatalError("khong the luu")}
            guard let data = try? JSONEncoder().encode(ngaycong) else {fatalError("khong the encode")}
            
            do {
                let outfile = Self.fileURL
                try data.write(to: outfile)
            } catch {
                fatalError("khong the ghi vao tap tin")
            }
        }
    }
    
    func delete(_ client: Khach){
        worker.khach.removeAll(where: { $0.id == client.id})
    }
    
    func clientExisted(_ client: Khach) -> Bool {
        worker.khach.contains(client)
    }
    
}



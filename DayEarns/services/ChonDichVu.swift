//
//  ChonDichVu.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct ChonDichVu: View {
    @EnvironmentObject var worker: KhachData
    @Binding var client: Khach.ThemKhach
    var cotGrid: [GridItem] = [GridItem(spacing:5, alignment: .center),
                               GridItem(spacing:5, alignment: .center),
                               GridItem(spacing:5, alignment: .center)]
    
    var dichvu: [String] {
        var ds: [String] = []
        for ser in client.dvDone {
            ds.append(ser.dichVu)
        }
        return ds
    }
    var danhmuc: String {
        ListFormatter.localizedString(byJoining: dichvu)
    }
    var chon: LocalizedStringKey {
        dichvu.isEmpty ? "Please Pick" : "UnPick--> "
    }
    var body: some View {
        VStack {
            chonDv()
            LazyVGrid (columns: cotGrid,alignment: .center, spacing: 5, content: {
                ForEach(worker.worker.services){ serv in
                    Button(action: {
                        client.dvDone.append(serv)
                    }, label: {
                        VStack {
                        Text(serv.dichVu)
                        Text("$\(serv.gia)")
                        }.padding()
                                
                    })
                }
            })
        }
    }//body
    private func chonDv() -> some View {
        Button(action: {
            client.dvDone = []
        }, label: {
            Text(chon)
            Text(danhmuc)
        })
    }
}

struct ChonDichVu_Previews: PreviewProvider {
    static var previews: some View {
        ChonDichVu(client: .constant(khachmau[0].mau))
            .environmentObject(KhachData())
    }
}


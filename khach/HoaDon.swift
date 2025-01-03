//
//  HoaDon.swift
//  DayEarns
//
//  Created by Jubi on 9/20/23.
//

import SwiftUI

struct HoaDon: View {
    var worker: Technician
    var khach: Khach
    var phoneKhach: String{
        khach.correctPhone(laySo: khach.sdt)
    }
    var phoneTech: String{
        khach.correctPhone(laySo: worker.phone)
    }
    var body: some View {
        VStack {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(worker.name)
                            .font(.title)
                        Text(phoneTech)
                        Text(worker.email)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(khach.name).font(.title2)
                        Text(phoneKhach)
                        Text("No: \(khach.ngay.formatted(.dateTime.month(.twoDigits).day()))")
                    }
                }
            }//tieu de
            Spacer()
            VStack(alignment: .leading) {
                Text("Services:")
                if let bonus = khach.tip {
                    HStack {
                        Text("Tip:")
                        Spacer()
                        Text("$ \(bonus)")
                    }
                }
                ForEach(khach.dvDone){dv in
                    HStack {
                        Text("\(dv.dichVu)")
                        Spacer()
                        Text("$ \(dv.gia)")
                    }
                }
            }
            VStack(alignment: .leading) {
                if !khach.desc.isEmpty {
                    Text("Detail:\n")
                    Text("Note: \(khach.desc)")
                }
                HStack {
                    Text("Total:")
                    Spacer()
                    Label("", systemImage: "hand.point.right")
                    Text("$ \(khach.khachTra())")
                }.font(.title3)
                                
            }.padding(5)
            Spacer()
            ShareLink("Receipt", item: inHoaDon(ngLam: worker, ngMua: khach))
        }//list
        .listStyle(.grouped)
        .padding(10)
        
    }//body
    
}

#Preview {
    HoaDon(worker: quang, khach: khachmau[0])
}



extension HoaDon {
    @MainActor
    func inHoaDon(ngLam: Technician, ngMua: Khach) -> URL {
        
        let renderURL = URL.documentsDirectory.appending(path: "Receipt.pdf")
        Task {
            let hoadon = HoaDon(worker: ngLam, khach: ngMua)
            let renderer = ImageRenderer(content: hoadon)
            renderer.render { size, renderer in
                var khoGiayMedia = CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height))
                guard let comsumer = CGDataConsumer(url: renderURL as CFURL),
                      let pdfContext = CGContext(consumer: comsumer, mediaBox: &khoGiayMedia, nil)
                else {return}
                pdfContext.beginPDFPage(nil)
                pdfContext.translateBy(x: khoGiayMedia.size.width / 2 - size.width / 2,
                                       y: khoGiayMedia.size.height / 2 - size.height / 2)
                renderer(pdfContext)
                pdfContext.endPDFPage()
                pdfContext.closePDF()
            }
        }
        let layUrl = renderURL
        return layUrl
    }
}

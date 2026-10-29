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
    var phoneKhach: String {
        khach.correctPhone(laySo: khach.sdt)
    }
    var phoneTech: String {
        khach.correctPhone(laySo: worker.phone)
    }

    var body: some View {
        VStack {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(worker.name)
                            .font(.title)
                        if !phoneTech.isEmpty {
                            Text(phoneTech)
                        }
                        if !worker.email.isEmpty {
                            Text(worker.email)
                        }
                        if let diaChi = worker.address {
                            Text(diaChi.formattedMultiline)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(khach.name).font(.title2)
                        if !phoneKhach.isEmpty {
                            Text(phoneKhach)
                        }
                        Text("No: \(khach.ngay.formatted(.dateTime.month(.twoDigits).day()))")
                    }
                }
            }
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
                ForEach(khach.dvDone) { dv in
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
        }
        .listStyle(.grouped)
        .padding(10)

    }

}

#Preview {
    HoaDon(worker: quang, khach: khachmau[0])
}



extension HoaDon {
    private static func receiptFileName(for client: Khach) -> String {
        let rawName = client.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !rawName.isEmpty else { return "Receipt.pdf" }

        let invalid = CharacterSet(charactersIn: "/\\:?%*|\"<>")
        let sanitized = rawName
            .components(separatedBy: invalid)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return sanitized.isEmpty ? "Receipt.pdf" : "\(sanitized).pdf"
    }

    @MainActor
    func inHoaDon(ngLam: Technician, ngMua: Khach) -> URL {

        let renderURL = URL.documentsDirectory.appending(path: Self.receiptFileName(for: ngMua))
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
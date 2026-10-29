//
//  ChonDichVu.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct ChonDichVu: View {
    @EnvironmentObject var worker: KhachData
    @State var newSer = Service.themDv()
    @Binding var client: Khach.ThemKhach
    private let boxSpacing: CGFloat = 3
    private let boxCornerRadius: CGFloat = 10
    private var boxHeight: CGFloat {
        let titleLine = UIFont.preferredFont(forTextStyle: .subheadline).lineHeight
        let priceLine = UIFont.preferredFont(forTextStyle: .caption1).lineHeight
        let titleToPrice: CGFloat = 4
        let verticalPadding: CGFloat = 16
        return ceil(titleLine * 3 + titleToPrice + priceLine + verticalPadding)
    }
    private var cotGrid: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: boxSpacing, alignment: .center), count: 3)
    }
    
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
    @State private var chonnut = ""
    var body: some View {
        VStack {
            chonDv()
            LazyVGrid(columns: cotGrid, alignment: .center, spacing: boxSpacing) {
                ForEach(worker.worker.services){ serv in
                    nutHieuUng(serv: serv)
                }
            }
            HStack {
                NewService(newSer: $newSer)
                AddServiceButton(action: themDichVu)
                    .disabled(newSer.dichVu.isEmpty)
            }
        }
    }//body
    private func nutHieuUng(serv: Service) -> some View {
        Button(action: {
            withAnimation(.bouncy(duration: 0.6)) {
                client.dvDone.append(serv)
                chonnut = serv.dichVu
            }
        }, label: {
            VStack(spacing: 4) {
                Text(serv.dichVu)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity)
                Text("$\(serv.gia)")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: boxHeight, maxHeight: boxHeight, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: boxCornerRadius)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: boxCornerRadius)
                    .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: boxCornerRadius))
            .transition(.scale)
            .opacity(chonnut == serv.dichVu ? 0 : 1)
            .scaleEffect(chonnut == serv.dichVu ? 0.1 : 1)
            .rotationEffect(.degrees(chonnut == serv.dichVu ? 360 : 0))
        })
        .buttonStyle(.plain)
    }
    private func themDichVu(){
        let new = Service(dichVu: newSer.dichVu, gia: newSer.gia)
        worker.worker.services.append(new)
        client.dvDone.append(new)
    }
    
    
    private func chonDv() -> some View {
        Button(action: {
            withAnimation(.bouncy(duration: 0.5)) {
                client.dvDone = []
            }
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

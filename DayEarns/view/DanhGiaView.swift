//
//  DanhGiaView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct DanhGiaView: View {
    @Binding var danhGia: Int
    private let diem = 6
    var body: some View {
        ForEach(1..<diem , id: \.self){ chodiem in
            Image(systemName: "star")
                .symbolVariant(chodiem <= danhGia ? .fill: .none)
                .foregroundStyle(.yellow)
                .onTapGesture {
                    if chodiem != danhGia {
                        danhGia = chodiem
                    } else {
                        danhGia = 0
                    }
                }
        }
    }
}


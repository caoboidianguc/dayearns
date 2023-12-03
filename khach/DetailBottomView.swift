//
//  DetailBottomView.swift
//  DayEarns
//
//  Created by Jubi on 9/7/23.
//

import SwiftUI

struct DetailBottomView: View {
    var khach: Khach
    @State private var claim = false
    
    var body: some View {
        List {
            Text("First Visits: \(khach.firstCome.formatted(.dateTime))")
            if khach.firstCome != khach.ngay {
                Text("Latest Visits: \(khach.ngay.formatted(.dateTime))")
            }
            Text("Note: \(khach.desc)")
            HStack {
                Text("Points Earn: \(khach.diem)")
                Spacer()
                Button(action: {
                    claim = true
                }, label: {
                    Text("Claim")
                })
            }
            Text("Total: $\(khach.khachTra())")
        }
        .listStyle(.plain)
    }
}

#Preview {
    DetailBottomView(khach: khachmau[0])
}

//
//  HistoriesView.swift
//  DayEarns
//
//  Created by Jubi on 4/10/24.
//

import SwiftUI

struct HistoriesView: View {
    var histories: [HistoryVisit]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(histories) { history in
                    VStack {
                        Text(history.ngay.formatted(date: .abbreviated, time: .shortened))
                        dvDone(services: history.dvDone)
                    }
                }
            }.navigationTitle("Histories")
        }
    }//body
    private func dvDone(services: [Service]) -> some View {
        ForEach(services){ dv in
            HStack {
                Text(dv.dichVu)
                Text(dv.gia.description)
            }
        }
    }
}

#Preview {
    HistoriesView(histories: [mau])
}


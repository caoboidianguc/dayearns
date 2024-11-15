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
                        if !history.note.isEmpty {
                            Text(history.note)
                                .font(.subheadline)
                        }
                        ForEach(history.dvDone){ dv in
                            HStack {
                                Text(dv.dichVu)
                                Text(dv.gia.description)
                            }
                        }
                    }
                }
            }.navigationTitle("Histories")
        }
    }//body
    
}

#Preview {
    HistoriesView(histories: [mau])
}


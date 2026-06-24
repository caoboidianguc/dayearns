//
//  HistoriesView.swift
//  DayEarns
//
//  Created by Jubi on 4/10/24.
//

import SwiftUI
struct HistoriesView: View {
    var histories: [HistoryVisit]
    @State private var onePage: [HistoryVisit] = []
    let pageSize: Int = 15
    
    var sortHistories: [HistoryVisit] {
        histories.sorted(by: { $0.ngay > $1.ngay })
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(onePage) { history in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(history.ngay.formatted(date: .numeric, time: .shortened))
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        if !history.note.isEmpty {
                            Text(history.note)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 4)
                        }
                        
                        if let tip = history.tip {
                            HStack {
                                Text("Tip:")
                                Spacer()
                                Text(tip.description)
                            }
                                .font(.subheadline)
                                .foregroundStyle(.green)
                                .padding(.bottom, 4)
                        }
                        
                        ForEach(history.dvDone) { dv in
                            HStack {
                                Text(dv.dichVu)
                                    .font(.body)
                                Spacer()
                                Text(dv.gia.description)
                                    .font(.body)
                                    .foregroundStyle(.blue)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 2, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                
                if onePage.count < sortHistories.count {
                    Button(action: {
                        let nextPart = sortHistories[onePage.count..<min(onePage.count + pageSize, sortHistories.count)]
                        onePage.append(contentsOf: nextPart)
                    }) {
                        Text("Load more")
                            .font(.callout)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Histories")
        .onAppear {
            onePage = Array(sortHistories.prefix(pageSize))
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    HistoriesView(histories: [mau])
}


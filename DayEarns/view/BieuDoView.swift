//
//  BieuDoView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import Charts
import SwiftUI

struct BieuDoView: View {
    @Binding var worker: Technician
//    @State private var tuan: Date = Date.now.addingTimeInterval(-7 * 3600 * 24 * 30)
    
    var body: some View {
        VStack {
            Chart {
                ForEach(worker.motTuan){ kha in
                    BarMark(x: .value("Day", kha.ngay, unit: .day), y: .value("Thu", kha.earn))
                        .foregroundStyle(.yellow)
                    BarMark(x: .value("Day", kha.ngay, unit: .day), y: .value("Tip", kha.tip ?? 0))
                        .foregroundStyle(.green)
                        .cornerRadius(3)
                }
            }
    //        .chartScrollPosition(x: $tuan)
            LabelChart()
        }
    }
}

//#Preview {
//    BieuDoView(worker: .constant(quang))
//}
struct BieuDoThang: View {
    @Binding var worker: Technician
    
    var body: some View {
        VStack {
            Chart {
                ForEach(worker.thangTech){ tuan in
                    BarMark(x: .value("Day", tuan.ngay, unit: .weekOfMonth), y: .value("Get", tuan.earn))
                        .foregroundStyle(.yellow)
                    BarMark(x: .value("Day", tuan.ngay, unit: .day), y: .value("Tip", tuan.tip ?? 0))
                        .foregroundStyle(.green)
                }
            }
//            .chartXAxis(.visible)
//            .chartYAxis(.automatic)
            Label("Weekly Earns", systemImage: "chart.line.uptrend.xyaxis")
                .font(.title)
        }.overlay {
            if worker.thangTech.isEmpty {
                Label("Go by week", systemImage: "chart.line.uptrend.xyaxis.circle.fill")
            }
        }
    }
    
}

struct BieuDoNam: View {
    @Binding var worker: Technician
    
    var body: some View {
        VStack {
            Chart {
                ForEach(worker.namTech){
                    BarMark(x: .value("Month", $0.ngay, unit: .month), y: .value("Get", $0.earn))
                        .foregroundStyle(.yellow)
                    BarMark(x: .value("Day", $0.ngay, unit: .day), y: .value("Tip", $0.tip ?? 0))
                        .foregroundStyle(.green)
                }
            }
            .chartXAxis(.visible)
            .chartYAxis(.automatic)
            Label("Monthly Earns", systemImage: "chart.pie.fill")
                .font(.title)
                
        }.overlay {
            if worker.namTech.isEmpty {
                Label("Go by month", systemImage: "chart.xyaxis.line")
            }
        }
    }
    
}

struct BieuDoChung: View {
    @Binding var worker: Technician
    
    var body: some View {
        ScrollView {
            BieuDoThang(worker: $worker)
                .frame(height: 300)
            BieuDoNam(worker: $worker)
                .frame(height: 300)
        }
        
    }
    
}

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
    
    var body: some View {
        VStack {
            Chart {
                ForEach(worker.motTuan){ kha in
                    BarMark(x: .value("Day", kha.ngay, unit: .day), y: .value("Thu", kha.earn))
                        .foregroundStyle(.yellow)
                        .annotation(position: .overlay, alignment: .centerFirstTextBaseline){
                            Text("\(kha.earn)").foregroundStyle(.white)
                        }
                    BarMark(x: .value("Day", kha.ngay, unit: .day), y: .value("Tip", kha.tip ?? 0))
                        .foregroundStyle(.green)
                        .cornerRadius(3)
                        .annotation(position: .automatic, alignment: .center){
                            Text("\(kha.tip ?? 0)").foregroundStyle(.green)
                        }
                }
                
            }
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
                }
                ForEach(worker.thangTech){ tuan in
                    BarMark(x: .value("Day", tuan.ngay, unit: .weekOfMonth), y: .value("Tip", tuan.tip ?? 0))
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
                    
                }
                ForEach(worker.namTech){
                    BarMark(x: .value("Day", $0.ngay, unit: .month), y: .value("Tip", $0.tip ?? 0))
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


struct BieuDoHangNam: View {
    @Binding var worker: Technician
    
    var body: some View {
        VStack {
            Chart {
                ForEach(worker.namTech){
                    BarMark(x: .value("Year", $0.ngay, unit: .year), y: .value("Get", $0.earn))
                        .foregroundStyle(.yellow)
                    
                }
                ForEach(worker.namTech){
                    BarMark(x: .value("Year", $0.ngay, unit: .year), y: .value("Tip", $0.tip ?? 0))
                        .foregroundStyle(.green)
                }
            }
            .chartXAxis(.visible)
            .chartYAxis(.automatic)
            Label("Yearly", systemImage: "chart.pie.fill")
                .font(.title)
                
        }
    }
    
}

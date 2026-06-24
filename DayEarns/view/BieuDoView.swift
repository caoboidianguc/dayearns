//
//  BieuDoView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//
import Charts
import SwiftUI
struct BieuDoView: View {
    var worker: Technician
    
    var body: some View {
        VStack {
            Chart {
                ForEach(worker.motTuanHistory){ histo in
                    BarMark(x: .value("Day",  histo.ngay, unit: .day), y: .value("Total", histo.tongTien))
                        .foregroundStyle(.yellow)
//                        .annotation(position: .overlay, alignment: .centerFirstTextBaseline){
//                            Text("\(histo.tongTien)").foregroundStyle(.white)
//                        }
                }
                ForEach(worker.motTuanHistory) { kha in
                    BarMark(x: .value("Day", kha.ngay, unit: .day), y: .value("Tip", kha.tip ?? 0))
                        .foregroundStyle(.green)
                        .cornerRadius(3)
//                        .annotation(position: .automatic, alignment: .center){
//                            Text("\(kha.tip ?? 0)").foregroundStyle(.green)
//                        }
                }
                
            }
        }
    }
}

//#Preview {
//    BieuDoView(worker: .constant(quang))
//}
struct BieuDoThang: View {
    var worker: Technician
    
    var body: some View {
        VStack {
            Chart {
                ForEach(worker.thangHistory){tha in
                    BarMark(x: .value("Day", tha.ngay, unit: .weekOfMonth), y: .value("Total", tha.tongTien))
                        .foregroundStyle(.yellow)
                }
                ForEach(worker.thangHistory){ tuan in
                    BarMark(x: .value("Day", tuan.ngay, unit: .weekOfMonth), y: .value("Tip", tuan.tip ?? 0))
                        .foregroundStyle(.green)
                        
                }
            }
            Label("Weekly Earns", systemImage: "chart.line.uptrend.xyaxis")
                .font(.title)
        }.overlay {
            if worker.thangHistory.isEmpty {
                Label("Go by week", systemImage: "chart.line.uptrend.xyaxis.circle.fill")
            }
        }
    }
    
}

struct BieuDoNam: View {
    var worker: Technician
    
    var body: some View {
        VStack {
            Chart {
                ForEach(worker.namHistory){
                    BarMark(x: .value("Year", $0.ngay, unit: .month), y: .value("Total", $0.tongTien))
                        .foregroundStyle(.yellow)
                }
                ForEach(worker.namHistory){
                    BarMark(x: .value("Day", $0.ngay, unit: .month), y: .value("Tip", $0.tip ?? 0))
                        .foregroundStyle(.green)
                }
            }
            .chartXAxis(.visible)
            .chartYAxis(.automatic)
            Label("Monthly Earns", systemImage: "chart.xyaxis.line")
                .font(.title)
                
        }.overlay {
            if worker.namHistory.isEmpty {
                Label("Go by month", systemImage: "chart.xyaxis.line")
            }
        }
    }
    
}

struct BieuDoHangNam: View {
    var worker: Technician
    
    var body: some View {
        VStack {
            Chart {
                ForEach(worker.namHistory){
                    BarMark(x: .value("Year", $0.ngay, unit: .year), y: .value("Get", $0.tongTien))
                        .foregroundStyle(.yellow)
                    
                }
                ForEach(worker.namHistory){
                    BarMark(x: .value("Year", $0.ngay, unit: .year), y: .value("Tip", $0.tip ?? 0))
                        .foregroundStyle(.green)
                }
            }
            .chartXAxis(.visible)
            .chartYAxis(.automatic)
            Label("Yearly", systemImage: "chart.line.uptrend.xyaxis")
                .font(.title)
                
        }
    }
    
}


struct BieuDoChung: View {
    var worker: Technician
    var anNam: Bool {
        worker.namHistory.isEmpty
    }
    var anThang: Bool {
        worker.thangHistory.isEmpty
    }
    var body: some View {
        ScrollView {
            BieuDoThang(worker: worker)
                .frame(height: 300)
            BieuDoNam(worker: worker)
                .frame(height: 300)
                .opacity(anThang ? 0 : 1)
            BieuDoHangNam(worker: worker)
                .frame(height: 300)
                .opacity(anNam ? 0 : 1)
        }
        
    }
    
}


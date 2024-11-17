//
//  XapSep.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct XapSep: View {
    @Binding var worker: Technician
    @State private var khong: Bool = false
    @State private var hienProfile = false
    var ngayEarn: [WeekEarn] {
        worker.weekEarn.filter {$0.earn3Ngay}
    }
    var body: some View {
        NavigationStack {
            List {
                Section(content: {
                    HStack {
                        Text("Total:")
                        Spacer()
                        Text("\(worker.tinhTheoNgay())")
                            .foregroundColor(worker.tinhTheoNgay() > 3000 ? .purple : .primary)
                    }
                }, header: {
                    Text("last 7 days:")
                })
                NavigationLink  {
                    BieuDoChung(worker: worker)
                } label: {
                    BieuDoView(worker: worker)
                        .frame(height: 250)
                }.overlay {
                    if worker.motTuanHistory.isEmpty {
                        VStack (alignment: .center) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(.yellow)
                            Text("Your daily chart show here!")
                        }
                    }
                }
                Section(header: Text("Today")){
                    HStack {
                        Label("\(worker.tongNgay())", systemImage: "dollarsign")
                        Spacer()
                        Button(action: {
                            luuNgayLam()
                        }, label:{
                            Image(systemName: "tray.and.arrow.down")
                                .opacity(khong ? 0 : 1)
                        })
                    }
                    .alert("Today have saved", isPresented: $khong, actions: {})
                }
                
                Section(header: Text("DAYS WERE SAVED")){
                    ForEach(ngayEarn) { tuan in
                        HStack {
                            Text(tuan.ngay.formatted(.dateTime.month().day()))
                            Spacer()
                            VStack{
                                Text("$ \(tuan.earn)")
                                    .font(.title2)
                                Text("$ \(tuan.tip ?? 0)")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                            }
                        }
                    }.onDelete {tuan in
                        worker.weekEarn.remove(atOffsets: tuan)
                    }
                }
                
            }//list
            .navigationTitle("Summary!")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        hienProfile = true
                    }, label: {Image(systemName: "person.crop.rectangle.fill")})
                }
            }
            .sheet(isPresented: $hienProfile){
                NavigationView {
                    TechView(tech: worker)
                        .navigationTitle("Info")
                        .toolbar{
                            ToolbarItem(placement: .navigationBarTrailing){
                                Button("Done"){
                                    hienProfile = false
                                }
                            }
                        }
                }
            }

        }
    }//body
    
    private func luuNgayLam() {
        let tienTip: Int = worker.tinhTip()
        let tienLam: Int = worker.tongNgay() - tienTip
        var newWeek = WeekEarn(ngay: .now, earn: tienLam)
        newWeek.tip = tienTip
        worker.weekEarn.insert(newWeek, at: 0)
        khong = true
    }
}

struct XapSep_Previews: PreviewProvider {
    static var previews: some View {
        XapSep(worker: .constant(quang))
            
    }
}


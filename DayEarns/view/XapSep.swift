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
    @State private var resetWarning = false
    @State private var anNut = "an"
    @State private var hienProfile = false
    
    var body: some View {
        NavigationView {
            List {
                Section(content: {
                    HStack {
                        Text("Total:")
                        Spacer()
                        Text("\(worker.tinhTheoNgay())")
                            .foregroundColor(worker.tinhTheoNgay() > 3000 ? .purple : .primary)
                    }
                }, header: {
                    Text("Earned:")
                })
                NavigationLink  {
                    BieuDoChung(worker: $worker)
                } label: {
                    BieuDoView(worker: $worker)
                        .frame(height: 250)
                }.overlay {
                    if worker.motTuan.isEmpty {
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
                            let newWeek = WeekEarn(tuan: "\(Date.now.formatted(.dateTime.month().day().weekday(.wide)))", earn: worker.tongNgay())
                            worker.weekEarn.insert(newWeek, at: 0)
                            khong = true
                            anNut = ""
                        }, label:{Image(systemName: "tray.and.arrow.down")})
                        .disabled(anNut.isEmpty)
                    }
                    .foregroundColor(anNut.isEmpty ? .gray : .green)
                    .alert("Today have saved", isPresented: $khong, actions: {})
                }
                
                Section(header: Text("DAYS WERE SAVED")){
                    ForEach(worker.weekEarn) { tuan in
                        HStack {
                            Text(tuan.tuan)
                            Spacer()
                            Text("$\(tuan.earn)")
                        }
                    }.onDelete {tuan in
                        worker.weekEarn.remove(atOffsets: tuan)
                    }
                }
                
            }//list
            .navigationTitle("Summary!")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing){
                    Button("Reset"){
                        resetWarning = true
                        anNut = "an"
                    }
                }
                ToolbarItem(placement: .topBarLeading){
                    Button("Profile", systemImage: "person.crop.rectangle.fill", action: {
                        hienProfile = true
                    })
                }
            })
            .confirmationDialog("Delete", isPresented: $resetWarning) {
                Button("Erase All Days Saved!", role: .destructive){ worker.weekEarn.removeAll()}
                Button("Cancel", role: .cancel){ resetWarning = false }}
            .sheet(isPresented: $hienProfile){
                NavigationView {
                    TechView(tech: worker)
                        .navigationTitle("Info")
                }
            }
            
        }
    }//body
    private func binding(for khachIndex: Khach) -> Binding<Khach> {
        guard let clientIndex = worker.khach.firstIndex(where: {$0.id == khachIndex.id}) else {fatalError("khong the lay khach index")}
        return $worker.khach[clientIndex]
    }
    
}

//struct XapSep_Previews: PreviewProvider {
//    static var previews: some View {
//        XapSep(worker: .constant(quang))
//    }
//}


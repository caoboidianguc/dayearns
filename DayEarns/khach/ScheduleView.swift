//
//  ScheduleView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct ScheduleView: View {
    @Binding var worker: Technician
    @State private var addClient = false
    @State private var khachHen = Khach.ThemKhach()
    @State private var daCo = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(QuaTuan.allCases){ quatuan in
                    if !worker.tuan(quaTuan: quatuan).isEmpty {
                        Section(content: {
                            ForEach(worker.tuan(quaTuan: quatuan)) { khach in
                                NavigationLink(destination: ClientDetail(worker: $worker ,khach: binding(for: khach)) ){
                                    KhachRow(khach: khach)
                                }
                            }
                        }, header: {Text(quatuan.name)})
                    }
                }
            }
            
            .listStyle(.plain)
            .navigationTitle("Schedule")
                .navigationBarItems(trailing:
                    Button("Add"){
                        addClient = true
                    }
                )
                .sheet(isPresented: $addClient){
                    NavigationView {
                        ChonNgay(client: $khachHen)
                            .alert("Client in your list", isPresented: $daCo, actions: {})
                            .navigationBarItems(leading: Button("Cancel") {
                                addClient = false
                            }, trailing: Button("Add"){
                                let newApp = Khach(name: khachHen.name, sdt: khachHen.sdt,dvDone: khachHen.dvDone, ngay: khachHen.ngay)
                                if worker.clientExisted(newApp) {
                                    daCo = true
                                } else {
                                    worker.khach.append(newApp)
                                    addClient = false }
                            })
                            .onAppear {
                                khachHen.dvDone.removeAll()
                                khachHen.name.removeAll()
                                khachHen.sdt.removeAll()
                            }
                    }
                }
            
        }//navi
        
    }
    private func binding(for khachIndex: Khach) -> Binding<Khach> {
        guard let clientIndex = worker.khach.firstIndex(where: {$0.id == khachIndex.id}) else {fatalError("khong the lay khach index")}
        return $worker.khach[clientIndex]
    }
}
struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(worker: .constant(quang))
            .environmentObject(KhachData())
    }
}


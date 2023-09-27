//
//  ServiceView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct ServiceView: View {
    @Binding var worker: Technician
    @State private var themdv = Service.themDv()
    @State private var nutThem = false
    @State var hienNutSort = false
    @State private var chonSort: DSServices = .khong
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(xapxep(ds: chonSort)){ dv in
                    HStack {
                        Text(dv.dichVu)
                        Spacer()
                        Text("$\(dv.gia)")
                    }.padding(.bottom)
                }
                .onDelete {xoa in
                    worker.services.remove(atOffsets: xoa)
                }
                .onMove(perform: move)
                .navigationTitle("Services")
                HStack {
                    NewService(newSer: $themdv)
                    AddServiceButton(action: {
                        themService()
                    }).disabled(themdv.dichVu.isEmpty)
                }
                .onSubmit() {
                    themdv.gia = 0
                }
               
            }//list
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Sort", selection: $chonSort){
                        ForEach(DSServices.allCases, id: \.self){ chon in
                            Text(chon.rawValue).tag(chon)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .overlay {
                if worker.services.isEmpty {
                    VStack(alignment: .center){
                        Label("No Service", systemImage: "scissors")
                            .padding(.bottom)
                        Text("Service you add\n will appear here.")
                    }
                    .font(.title)
                    .foregroundStyle(.gray)
                }
            }
        }
        
    }
    private func move(from: IndexSet, to: Int){
        withAnimation(.default){
            worker.services.move(fromOffsets: from, toOffset: to)
        }
    }
    private func themService() {
        let newSer = Service(dichVu: themdv.dichVu, gia: themdv.gia)
        worker.services.append(newSer)
        themdv.dichVu.removeAll()
    }
}

struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceView(worker: .constant(quang))
    }
}

extension ServiceView {
    enum DSServices: String, CaseIterable {
        case khong = "Sort"
        case byName = "By Name"
        case byGia = "By Price"
        
    }
    
    private func xapxep(ds: DSServices) -> [Service] {
        switch ds {
        case .byName:
            return worker.services.sorted(by: {$0.dichVu < $1.dichVu})
        case .byGia:
            return worker.services.sorted(by: {$0.gia > $1.gia})
        case .khong:
            return worker.services
        }
    }
}

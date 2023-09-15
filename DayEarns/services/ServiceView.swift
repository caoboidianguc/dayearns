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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(worker.services) { dv in
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
                    Button("Add", action: {
                        themService()
                    }).disabled(themdv.dichVu.isEmpty)
                }
                .onSubmit() {
                    themdv.gia = 0
                }
               
            }//list
            
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

//struct ServiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceView(worker: .constant(quang))
//    }
//}

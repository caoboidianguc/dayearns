//
//  ServiceView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

//@available(iOS 17.0, *)
struct ServiceView: View {
    @Binding var worker: Technician
    @State private var themdv = Service.themDv()
    @State private var nutThem = false
    @State var hienNutSort = false
    @State private var chonSort: DSServices = .sort
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(worker.xapxep(ds: chonSort)){ dv in
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
            .onAppear(perform: {
                if chonSort != .sort {
                    worker.services = worker.xapxep(ds: chonSort)
                }
            })
            
            .onChange(of: chonSort){ _ in
                worker.services = worker.xapxep(ds: chonSort)
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Sort", selection: $chonSort){
                        ForEach(DSServices.allCases, id: \.self){ chon in
                            Text(chon.rawValue).tag(chon)
                        }
                    }
                }
                ToolbarItem(placement: .keyboard, content: {
                    Button("Done", action: {
                        UIApplication.shared.endKey()
                    })
                })
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
//@available(iOS 17.0, *)
struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceView(worker: .constant(quang))
    }
}


extension UIApplication {
    func endKey() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

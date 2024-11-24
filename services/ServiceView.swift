//
//  ServiceView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI


struct ServiceView: View {
    @EnvironmentObject var tech: KhachData
    @State private var themdv = Service.themDv()
    @State private var nutThem = false
    @State var hienNutSort = false
    @State private var chonSort: DSServices = .sort
    @State private var timService = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(timService == "" ? tech.worker.xapxep(ds: chonSort) : tech.worker.timService(ten: timService)){ dv in
                    HStack {
                        Text(dv.dichVu)
                        Spacer()
                        Text("$\(dv.gia)")
                    }.padding(.bottom)
                }
                .onDelete {xoa in
                    tech.worker.services.remove(atOffsets: xoa)
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
            .searchable(text: $timService, placement: .automatic).textInputAutocapitalization(.words)
            .onChange(of: chonSort){ _ in
                tech.worker.services = tech.worker.xapxep(ds: chonSort)
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
                if tech.worker.services.isEmpty {
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
            tech.worker.services.move(fromOffsets: from, toOffset: to)
        }
    }
    private func themService() {
        let newSer = Service(dichVu: themdv.dichVu, gia: themdv.gia)
        tech.worker.services.append(newSer)
        themdv.dichVu.removeAll()
    }
}
//@available(iOS 17.0, *)
struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceView()
            .environmentObject(KhachData())
    }
}


extension UIApplication {
    func endKey() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

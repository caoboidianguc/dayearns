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
    @State var hienNutSort = false
    @State private var chonSort: DSServices = .sort
    @State private var timService = ""
    @State private var nutService = false
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                   
                }//list
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    if !nutService {
                        Button { nutService = true } label: {
                            Image(systemName: "scissors.circle")
                                .shadow(radius: 3)
                                .font(.largeTitle)
                                .accessibilityLabel("Add Service")
                                .foregroundStyle(.yellow)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 8)
                    }
                }
            }
            .sheet(isPresented: $nutService) {
                themServiceView()
                    .presentationDetents([.medium, .large])
            }
            .searchable(text: $timService, placement: .automatic).textInputAutocapitalization(.words)
            .onChange(of: chonSort) { _ in
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
    private func themServiceView() -> some View {
        HStack {
            NewService(newSer: $themdv)
            AddServiceButton(action: {
                themService()
                nutService = false
            }).disabled(themdv.dichVu.isEmpty)
            
        }
        .offset(x:0, y: 100)
        .onSubmit() {
            themdv.gia = 0
            nutService = false
        }
        
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



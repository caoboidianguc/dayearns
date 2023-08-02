//
//  ClientList.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct ClientList: View {
    @Binding var worker: Technician
    @State var newCus = Khach.ThemKhach()
    @State private var trangMoi = false
    @State private var existed = false
    @State private var warning = ""
    var khachList: [Khach] {
        worker.khach
            .filter{$0.trongTuan}
            .sorted(by: {$0.ngay > $1.ngay})
    }
    @State private var text = ""
//    @State private var listTim: [Khach] = []
    var body: some View {
        NavigationView {
            List {
                ForEach(text == "" ? khachList : worker.listDaTim(ten: text)) { khach in
                    if !khach.schedule {
                        NavigationLink(destination: ClientDetail(worker: $worker, khach: binding(for: khach))){
                            KhachRow(khach: khach)
                        }
                        .swipeActions {
                            Button(role: .destructive, action: {
                                worker.delete(khach)
                            }, label: {
                                Label("Xoa", systemImage: "trash")
                            })
                        }

                    }
                }
                
                
            }//list
            .overlay {
                if worker.khach.isEmpty {
                    VStack(alignment: .leading){
                        Label("No Client", systemImage: "person.fill.questionmark")
                            .padding(.bottom)
                        Text("Client within a week\n will appear here.")
                    }
                    .font(.title)
                    .foregroundStyle(.gray)
                }
            }
            .listStyle(.plain)
            .searchable(text: $text, placement: .automatic, prompt: "Name in \(khachList.count)")
          
            .navigationTitle("Clients")
            
            .navigationBarItems(trailing: Button(action: {trangMoi = true },
                                                 label: {Image(systemName: "person.badge.plus")}))
            .sheet(isPresented: $trangMoi) {
                NavigationView {
                    AddClient(worker: $worker, client: $newCus)
                        .alert("Failed to add.", isPresented: $existed, actions: {}, message: {Text(warning)})
                        .navigationBarItems(leading: Button("Cancel"){
                            trangMoi = false
                        }, trailing: Button("Add"){
                            var newClient = Khach(name: newCus.name, sdt: newCus.sdt, desc: newCus.desc ,dvDone: newCus.dvDone)
                            if worker.clientExisted(newClient) {
                                warning = "Client existed!"
                                existed = true
                            } else {
                                worker.khach.insert(newClient, at: 0)
                                trangMoi = false}
                            }.disabled(newCus.name.isEmpty)
                        )
                        
                        
                        .onAppear{
                            newCus.name.removeAll()
                            newCus.sdt.removeAll()
                            newCus.desc.removeAll()
                        }
                }
        }
        }
        
    }//body
    private func binding(for khachIndex: Khach) -> Binding<Khach> {
        guard let clientIndex = worker.khach.firstIndex(where: {$0.id == khachIndex.id}) else {fatalError("khong the lay khach index")}
        return $worker.khach[clientIndex]
    }
}

struct ClientList_Previews: PreviewProvider {
    static var previews: some View {
        ClientList(worker: .constant(quang))
    }
}

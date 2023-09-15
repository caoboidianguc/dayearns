//  ClientList.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
import SwiftUI

struct ClientList: View {
    @Binding var worker: Technician
    @State var newCus = Khach.ThemKhach()
    @State private var trangMoi = false
    @State private var existed = false
    @State private var warning = ""
    @State private var text = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(text == "" ? worker.tuan : worker.listDaTim(ten: text)) { khach in
                    if !khach.schedule {
                        NavigationLink(destination: ClientDetail(worker: $worker, khach: binding(for: khach))){
                            KhachRow(khach: khach) }
                        .swipeActions {
                            Button(role: .destructive, action: {
                                worker.delete(khach)
                            }, label: {
                                Label("Xoa", systemImage: "trash")
                            })
                        }
                    }
                }
                .listRowSeparator(.hidden)
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
            .searchable(text: $text, placement: .automatic, prompt: "Name or Phone")
          
            .navigationTitle(title.formatted(.dateTime.day().weekday()))
            
            .navigationBarItems(trailing: Button(action: {trangMoi = true },
                                                 label: {Image(systemName: "person.badge.plus")}))
            .sheet(isPresented: $trangMoi) {
                NavigationView {
                    AddClient(worker: $worker, client: $newCus)
                        .alert("Failed to add.", isPresented: $existed, actions: {}, message: {Text(warning)})
                        .navigationBarItems(leading: Button("Cancel"){
                            trangMoi = false
                        }, trailing: Button("Add"){
                            themKhach()
                            }.disabled(newCus.name.isEmpty))
                        .onAppear{
                            newCus.name.removeAll()
                            newCus.sdt.removeAll()
                            newCus.desc.removeAll()
                        }
                }
            }
            
        }
        
    }//body
    var title: Date {
        get {
            return Date.now
        }
        set (newValue){
            if newValue < Date.now {
                self.title = newValue
            }
        }
    }
    private func binding(for khachIndex: Khach) -> Binding<Khach> {
        guard let clientIndex = worker.khach.firstIndex(where: {$0.id == khachIndex.id}) else {fatalError("khong the lay khach index")}
        return $worker.khach[clientIndex]
    }
    private func themKhach() {
        let newClient = Khach(name: newCus.name, sdt: newCus.sdt, desc: newCus.desc ,dvDone: newCus.dvDone, diem: newCus.pointsKhach())
        if worker.clientExisted(newClient) {
            warning = "Client existed!"
            existed = true
        } else {
            worker.khach.insert(newClient, at: 0)
            trangMoi = false}
    }
}

struct ClientList_Previews: PreviewProvider {
    static var previews: some View {
        ClientList(worker: .constant(quang))
    }
}

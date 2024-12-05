//  ClientList.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
import SwiftUI

struct ClientList: View {
    @EnvironmentObject var tech: KhachData
    @State var newCus = Khach.ThemKhach()
    @State private var trangMoi = false
    @State private var existed = false
    @State private var warning = ""
    @State private var text = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(text == "" ? tech.worker.tuan : tech.worker.listDaTim(ten: text)) { khach in
//                        only Clients from past to today
                        if !khach.schedule {
                            NavigationLink{ClientDetail(worker: $tech.worker, khach: binding(for: khach))} label: {
                                KhachRow(khach: binding(for: khach))
                            }
                            .swipeActions {
                                Button(role: .destructive, action: {
                                    tech.worker.delete(khach)
                                }, label: {
                                    Label("Delete", systemImage: "trash")
                                })
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }//list
                nutThemKhach()            
            }
            .overlay {
                if tech.worker.khach.isEmpty {
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
            .searchable(text: $text, placement: .automatic, prompt: "Name or Phone").textInputAutocapitalization(.words)
          
            .navigationTitle(title.formatted(.dateTime.day().weekday()))
            
            .sheet(isPresented: $trangMoi) {
                NavigationView {
                    AddClient(client: $newCus)
                        .alert("Failed to add.", isPresented: $existed, actions: {}, message: {Text(warning)})
                        .navigationBarItems(leading: Button("Cancel"){
                            trangMoi = false
                        }, trailing: AddClientButton {
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
    private func nutThemKhach() -> some View{
        Button(action: {trangMoi = true }, label: {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.largeTitle)
                .accessibilityLabel("Add Client")
                .foregroundStyle(.yellow)
        }).offset(x: 160, y: 230)
    }
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
        guard let clientIndex = tech.worker.khach.firstIndex(where: {$0.id == khachIndex.id}) else {fatalError("khong the lay khach index")}
        return $tech.worker.khach[clientIndex]
    }
    private func themKhach() {
        let hitory = HistoryVisit(ngay: Date.now, note: newCus.desc, dvDone: newCus.dvDone)
        if !newCus.sdt.isEmpty && newCus.sdt.count < 10 {
            warning = "Phone number is incorrect!"
            existed = true
        } else {
            var newClient = Khach(name: newCus.name, sdt: newCus.sdt, desc: newCus.desc ,dvDone: newCus.dvDone, diem: newCus.pointsKhach())
            if tech.clientExisted(newClient){
                warning = "Client existed!"
                existed = true
            } else {
                newClient.histories.insert(hitory, at: 0)
                tech.worker.khach.insert(newClient, at: 0)
                    trangMoi = false
                }
        }
    }
}

struct ClientList_Previews: PreviewProvider {
    static var previews: some View {
        ClientList()
            .environmentObject(KhachData())
    }
}

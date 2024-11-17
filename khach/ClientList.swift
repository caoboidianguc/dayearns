//  ClientList.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
import SwiftUI

struct ClientList: View {
    @Binding var tech: Technician
    @State var newCus = Khach.ThemKhach()
    @State private var trangMoi = false
    @State private var existed = false
    @State private var warning = ""
    @State private var text = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(text == "" ? tech.tuan : tech.listDaTim(ten: text)) { khach in
                        if !khach.schedule {
                            NavigationLink{ClientDetail(worker: $tech, khach: binding(for: khach))} label: {
                                KhachRow(khach: khach)
                            }
                            .swipeActions {
                                Button(role: .destructive, action: {
                                    tech.delete(khach)
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
                if tech.khach.isEmpty {
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
        guard let clientIndex = tech.khach.firstIndex(where: {$0.id == khachIndex.id}) else {fatalError("khong the lay khach index")}
        return $tech.khach[clientIndex]
    }
    private func themKhach() {
        let hitory = HistoryVisit(ngay: Date.now, note: newCus.desc, dvDone: newCus.dvDone)
        var newClient = Khach(name: newCus.name, sdt: newCus.sdt, desc: newCus.desc ,dvDone: newCus.dvDone, diem: newCus.pointsKhach())
        newClient.histories.append(hitory)
        if tech.clientExisted(newClient) {
            warning = "Client existed!"
            existed = true
        } else if !newCus.sdt.isEmpty && newCus.sdt.count < 10 {
            warning = "Phone number is incorrect!"
            existed = true
        } else {
            tech.khach.insert(newClient, at: 0)
            trangMoi = false
        }
    }
}

struct ClientList_Previews: PreviewProvider {
    static var previews: some View {
        ClientList(tech: .constant(quang))
    }
}

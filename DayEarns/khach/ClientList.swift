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
            List {
                ForEach(text == "" ? tech.worker.tuan : tech.worker.listDaTim(ten: text)) { khach in
                    if !khach.schedule {
                        NavigationLink {
                            ClientDetail(worker: $tech.worker, khach: tech.binding(for: khach))
                        } label: {
                            KhachRow(khach: tech.binding(for: khach))
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                tech.worker.delete(khach)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .overlay {
                if tech.worker.khach.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("No Client", systemImage: "person.fill.questionmark")
                            .font(.title)
                            .foregroundStyle(.gray)
                            .padding(.bottom)
                        Text("Client within a week\n will appear here.")
                            .font(.title3)
                            .dynamicTypeSize(.large)
                            .foregroundStyle(.gray)
                    }
                    .padding()
                }
            }
            .listStyle(.plain)
            .searchable(text: $text, placement: .automatic, prompt: "Name or Phone")
            .textInputAutocapitalization(.words)
            .navigationTitle(Date.now.formatted(.dateTime.day().weekday()))
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button { trangMoi = true } label: {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .shadow(radius: 4)
                            .font(.largeTitle)
                            .accessibilityLabel("Add Client")
                            .foregroundStyle(.yellow)
                    }
                    .padding(.trailing)
                    .padding(.bottom, 8)
                }
            }
            .sheet(isPresented: $trangMoi) {
                NavigationStack {
                    AddClient(client: $newCus)
                        .alert("Failed to add.", isPresented: $existed) {} message: {
                            Text(warning)
                        }
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { trangMoi = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                AddClientButton { themKhach() }
                                    .disabled(newCus.name.isEmpty)
                            }
                        }
                        .onAppear {
                            newCus.name.removeAll()
                            newCus.sdt.removeAll()
                            newCus.desc.removeAll()
                        }
                }
            }
        }
    }

    private func themKhach() {
        let hitory = HistoryVisit(ngay: Date.now, note: newCus.desc, dvDone: newCus.dvDone)
        if !newCus.sdt.isEmpty && newCus.sdt.count < 10 {
            warning = "Phone number is incorrect!"
            existed = true
        } else {
            var newClient = Khach(
                name: newCus.name,
                sdt: newCus.sdt,
                desc: newCus.desc,
                dvDone: newCus.dvDone,
                diem: newCus.pointsKhach()
            )
            if tech.clientExisted(newClient) {
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
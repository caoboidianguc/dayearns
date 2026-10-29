//  ClientList.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
import SwiftUI
import UniformTypeIdentifiers

struct ClientList: View {
    @EnvironmentObject var tech: KhachData
    @State var newCus = Khach.ThemKhach()
    @State private var trangMoi = false
    @State private var existed = false
    @State private var warning = ""
    @State private var text = ""
    @State private var showImporter = false
    @State private var importMessage = ""
    @State private var showImportResult = false
    @State private var displayedClients: [Khach] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(displayedClients) { khach in
                    NavigationLink(value: khach.id) {
                        KhachRow(khach: khach)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            tech.worker.delete(khach)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .navigationDestination(for: UUID.self) { id in
                if let index = tech.worker.khach.firstIndex(where: { $0.id == id }) {
                    ClientDetail(worker: $tech.worker, khach: $tech.worker.khach[index])
                }
            }
            .task(id: text) {
                if text.isEmpty {
                    displayedClients = tech.worker.tuan.filter { !$0.schedule }
                    return
                }
                try? await Task.sleep(for: .milliseconds(150))
                guard !Task.isCancelled else { return }
                displayedClients = tech.worker.listDaTim(ten: text)
            }
            .onChange(of: tech.worker.khach) { _, _ in
                displayedClients = text.isEmpty
                    ? tech.worker.tuan.filter { !$0.schedule }
                    : tech.worker.listDaTim(ten: text)
            }
            .overlay {
                if text.isEmpty && tech.worker.tuan.isEmpty {
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
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("No clients this week", systemImage: "person.crop.circle")
                                .font(.title3)
                                .foregroundStyle(.gray)
                            Text("Search by name or phone to find saved clients.")
                                .font(.body)
                                .foregroundStyle(.gray)
                        }
                        .padding()
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $text, placement: .automatic, prompt: "Name or Phone")
            .textInputAutocapitalization(.words)
            .navigationTitle(Date.now.formatted(.dateTime.day().weekday()))
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        showImporter = true
//                    } label: {
//                        Image(systemName: "square.and.arrow.down")
//                    }
//                    .accessibilityLabel("Import Clients")
//                }
//            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    Task { await importCSV(from: url) }
                case .failure(let error):
                    importMessage = error.localizedDescription
                    showImportResult = true
                }
            }
            .alert("Import Clients", isPresented: $showImportResult) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importMessage)
            }
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

    private func importCSV(from url: URL) async {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed { url.stopAccessingSecurityScopedResource() }
        }
        do {
            let csv = try String(contentsOf: url, encoding: .utf8)
            let result = try await tech.importClients(from: csv)
            importMessage = importSummary(result)
        } catch {
            importMessage = error.localizedDescription
        }
        showImportResult = true
    }

    private func importSummary(_ result: ClientImportResult) -> String {
        var parts = ["Added \(result.added) clients."]
        if result.alreadySaved > 0 {
            parts.append("\(result.alreadySaved) were already saved and were left as they are.")
        }
        if result.skipped > 0 {
            parts.append("\(result.skipped) rows had no name or phone and were skipped.")
        }
        parts.append("Search by name or phone to find them.")
        return parts.joined(separator: " ")
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

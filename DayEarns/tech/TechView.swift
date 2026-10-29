//
//  TechView.swift
//  DayEarns
//
//  Created by Jubi on 8/1/23.
//

import SwiftUI

struct TechView: View {
    @Binding var tech: Technician
    @State private var editing = false

    private var phoneDisplay: String {
        Khach(name: "", sdt: tech.phone, diem: 0).correctPhone(laySo: tech.phone)
    }

    var body: some View {
        List {
            Section {
                Text(tech.name)
                    .font(.title3)
                if !tech.phone.isEmpty {
                    Text(phoneDisplay)
                }
                if !tech.email.isEmpty {
                    Text(tech.email)
                }
                if let diaChi = tech.address {
                    Text(diaChi.formattedMultiline)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("profile")
            }

            Section {
                Text("\(tech.khach.count)  Clients")
            } header: {
                Text("you gained")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    editing = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel("Edit profile")
            }
        }
        .sheet(isPresented: $editing) {
            NavigationStack {
                EditTech(tech: $tech)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TechView(tech: .constant(quang))
            .navigationTitle("Info")
    }
}
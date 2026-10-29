//
//  EditTech.swift
//  DayEarns
//
//  Created by Jubi on 7/3/26.
//

import SwiftUI

struct EditTech: View {
    @Binding var tech: Technician
    @Environment(\.dismiss) private var dismiss

    @State private var phone = ""
    @State private var email = ""
    @State private var street = ""
    @State private var altStreet = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    @State private var checkEmailType = ""
    @FocusState private var focusNhap: NhapThongTin?

    var body: some View {
        Form {
            Section("Profile") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(tech.name)
                        .foregroundStyle(.secondary)
                }
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                    .focused($focusNhap, equals: .phone)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .onChange(of: email) { chu in
                        validateEmail(chu)
                    }
                if !checkEmailType.isEmpty {
                    Text(checkEmailType)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }

            Section("Business Address") {
                TextField("Street", text: $street)
                TextField("Street optionally", text: $altStreet)
                TextField("City", text: $city)
                TextField("State", text: $state)
                TextField("Zip Code", text: $zip)
                    .keyboardType(.numberPad)

                if tech.address != nil || hasAddressInput {
                    Button("Remove Address", role: .destructive) {
                        clearAddress()
                    }
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadFromTech()
            focusNhap = .phone
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    applyChanges()
                    dismiss()
                }
                .disabled(!canSave)
            }
        }
    }

    private var hasAddressInput: Bool {
        [street, altStreet, city, state, zip]
            .contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private var canSave: Bool {
        checkEmailType.isEmpty && (addressIsComplete || !hasAddressInput)
    }

    private var addressIsComplete: Bool {
        !street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func loadFromTech() {
        phone = tech.phone
        email = tech.email
        if let diaChi = tech.address {
            street = diaChi.street
            altStreet = diaChi.alternateStreet
            city = diaChi.city
            state = diaChi.state
            zip = diaChi.zip
        }
    }

    private func clearAddress() {
        street = ""
        altStreet = ""
        city = ""
        state = ""
        zip = ""
    }

    private func applyChanges() {
        tech.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        tech.email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if addressIsComplete {
            tech.address = Address(
                street: street.trimmingCharacters(in: .whitespacesAndNewlines),
                alternateStreet: altStreet.trimmingCharacters(in: .whitespacesAndNewlines),
                city: city.trimmingCharacters(in: .whitespacesAndNewlines),
                state: state.trimmingCharacters(in: .whitespacesAndNewlines),
                zip: zip.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } else {
            tech.address = nil
        }
    }

    private func validateEmail(_ email: String) {
        guard !email.isEmpty else {
            checkEmailType = ""
            return
        }
        guard let pattern = try? Regex(".+@.+") else { return }
        checkEmailType = email.contains(pattern) ? "" : "Email incompleted!"
    }
}

#Preview {
    NavigationStack {
        EditTech(tech: .constant(quang))
    }
}
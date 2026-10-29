//
//  ClientCSVImporter.swift
//  DayEarns
//

import Foundation

struct ClientImportResult: Equatable {
    var added: Int
    var alreadySaved: Int
    var skipped: Int
}

enum ClientCSVError: LocalizedError {
    case emptyFile
    case missingNameOrPhone

    var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "That file is empty."
        case .missingNameOrPhone:
            return "The file needs a name column and a phone column."
        }
    }
}

enum ClientCSVImporter {
    /// Adds name and phone from a client spreadsheet.
    /// Clients already saved on this phone stay as they are, including their visits and points.
    static func importCSV(_ csv: String, into worker: inout Technician) throws -> ClientImportResult {
        let records = parseRecords(csv)
        guard let header = records.first else { throw ClientCSVError.emptyFile }

        let columns = header.map(normalizeHeader)
        let fullNameIndex = columns.firstIndex(where: nameHeaders.contains)
        let firstIndex = columns.firstIndex(where: firstNameHeaders.contains)
        let lastIndex = columns.firstIndex(where: lastNameHeaders.contains)
        guard let phoneIndex = columns.firstIndex(where: phoneHeaders.contains) else {
            throw ClientCSVError.missingNameOrPhone
        }
        guard fullNameIndex != nil || firstIndex != nil || lastIndex != nil else {
            throw ClientCSVError.missingNameOrPhone
        }

        var saved = Set(worker.khach.map { identity(name: $0.name, phone: $0.sdt) })
        var added = 0
        var alreadySaved = 0
        var skipped = 0
        var newcomers: [Khach] = []
        let placeholderVisit = Calendar.current.date(byAdding: .day, value: -30, to: Date())
            ?? Date(timeIntervalSinceNow: -30 * 24 * 60 * 60)

        for record in records.dropFirst() {
            let name = fullName(
                record: record,
                fullNameIndex: fullNameIndex,
                firstIndex: firstIndex,
                lastIndex: lastIndex
            )
            let phone = field(record, phoneIndex).filter(\.isNumber)
            guard !name.isEmpty, !phone.isEmpty else {
                skipped += 1
                continue
            }

            let key = identity(name: name, phone: phone)
            guard saved.insert(key).inserted else {
                alreadySaved += 1
                continue
            }

            newcomers.append(Khach(
                name: name,
                sdt: phone,
                ngay: placeholderVisit,
                diem: 0,
                firstCome: placeholderVisit
            ))
            added += 1
        }

        worker.khach.append(contentsOf: newcomers)
        return ClientImportResult(added: added, alreadySaved: alreadySaved, skipped: skipped)
    }

    private static let nameHeaders: Set<String> = ["name", "full name", "fullname", "client", "client name"]
    private static let firstNameHeaders: Set<String> = ["first name", "firstname", "first"]
    private static let lastNameHeaders: Set<String> = ["last name", "lastname", "last"]
    private static let phoneHeaders: Set<String> = [
        "phone", "phone number", "phonenumber", "mobile", "mobile phone", "cell", "cell phone", "sdt", "tel", "telephone"
    ]

    private static func identity(name: String, phone: String) -> String {
        let cleanName = name.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased()
        let digits = phone.filter(\.isNumber)
        return cleanName + "\u{1}" + digits
    }

    private static func normalizeHeader(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\u{feff}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private static func field(_ record: [String], _ index: Int?) -> String {
        guard let index, record.indices.contains(index) else { return "" }
        return record[index].trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func fullName(
        record: [String],
        fullNameIndex: Int?,
        firstIndex: Int?,
        lastIndex: Int?
    ) -> String {
        let combined = field(record, fullNameIndex)
        if !combined.isEmpty { return collapseSpaces(combined) }
        let parts = [field(record, firstIndex), field(record, lastIndex)].filter { !$0.isEmpty }
        return collapseSpaces(parts.joined(separator: " "))
    }

    private static func collapseSpaces(_ value: String) -> String {
        value.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    private static func isLineBreak(_ character: Character) -> Bool {
        character == "\n" || character == "\r" || character == "\r\n"
            || character == "\u{2028}" || character == "\u{2029}"
    }

    private static func parseRecords(_ csv: String) -> [[String]] {
        var records: [[String]] = []
        var field = ""
        var record: [String] = []
        var inQuotes = false
        let chars = Array(csv)
        var index = 0

        func finishRecord() {
            record.append(field)
            field = ""
            if record.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                records.append(record)
            }
            record = []
        }

        while index < chars.count {
            let character = chars[index]
            if inQuotes {
                if character == "\"" {
                    if index + 1 < chars.count, chars[index + 1] == "\"" {
                        field.append("\"")
                        index += 1
                    } else {
                        inQuotes = false
                    }
                } else {
                    field.append(character)
                }
            } else if character == "\"" {
                inQuotes = true
            } else if character == "," {
                record.append(field)
                field = ""
            } else if isLineBreak(character) {
                // Swift treats a Windows "\r\n" pair as one Character.
                if character == "\r", index + 1 < chars.count, chars[index + 1] == "\n" {
                    index += 1
                }
                finishRecord()
            } else {
                field.append(character)
            }
            index += 1
        }

        if inQuotes || !field.isEmpty || !record.isEmpty {
            finishRecord()
        }
        return records
    }
}

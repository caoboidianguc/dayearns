//
//  ClientCSVImportTests.swift
//  DayEarnsTests
//

import XCTest
@testable import DayEarns

final class ClientCSVImportTests: XCTestCase {
    func testImportsFullNameAndPhoneAndIgnoresEmail() throws {
        let csv = """
        First Name,Last Name,Email,Phone
        Linda,Smith,landonlayla@gmail.com,"(803) 553-2292"
        Mary Jo,Cole,mjc@scb-cpa.com,(803) 960-9941
        """
        var worker = Technician(name: "Linh", phone: "803")
        let result = try ClientCSVImporter.importCSV(csv, into: &worker)

        XCTAssertEqual(result.added, 2)
        XCTAssertEqual(worker.khach.map(\.name), ["Linda Smith", "Mary Jo Cole"])
        XCTAssertEqual(worker.khach.map(\.sdt), ["8035532292", "8039609941"])
        XCTAssertTrue(worker.khach.allSatisfy { $0.email.isEmpty })
        XCTAssertTrue(worker.khach.allSatisfy { $0.diem == 0 && $0.histories.isEmpty })
        XCTAssertTrue(worker.khach.allSatisfy { !$0.today && !$0.trongTuan && !$0.schedule })
    }

    func testKeepsExistingClientData() throws {
        var worker = Technician(name: "Linh", phone: "803")
        let visit = HistoryVisit(ngay: Date(), note: "gel", dvDone: [Service(dichVu: "Full set", gia: 60)])
        worker.khach = [
            Khach(name: "Linda Smith", sdt: "(803) 553-2292", desc: "prefers mornings", diem: 40, histories: [visit])
        ]

        let csv = """
        First Name,Last Name,Email,Phone
        Linda,Smith,landonlayla@gmail.com,(803) 553-2292
        Jennifer,Testing,jgay14@yahoo.com,(803) 386-4800
        """
        let result = try ClientCSVImporter.importCSV(csv, into: &worker)

        XCTAssertEqual(result.added, 1)
        XCTAssertEqual(result.alreadySaved, 1)
        XCTAssertEqual(worker.khach.count, 2)
        XCTAssertEqual(worker.khach[0].name, "Linda Smith")
        XCTAssertEqual(worker.khach[0].diem, 40)
        XCTAssertEqual(worker.khach[0].desc, "prefers mornings")
        XCTAssertEqual(worker.khach[0].histories.count, 1)
        XCTAssertEqual(worker.khach[0].sdt, "(803) 553-2292")
        XCTAssertEqual(worker.khach[1].name, "Jennifer Testing")
        XCTAssertEqual(worker.khach[1].sdt, "8033864800")
    }

    func testSamePhoneWithDifferentNamesAreBothSaved() throws {
        let csv = """
        First Name,Last Name,Email,Phone
        Donna,Owens,donna67@bellsouth.net,(803) 603-0465
        Hannah,Owens,donnao67@bellsouth.net,(803) 603-0465
        Donna,Owens,donna67@bellsouth.net,(803) 603-0465
        ,,,(803) 603-0465
        """
        var worker = Technician(name: "Linh", phone: "803")
        let result = try ClientCSVImporter.importCSV(csv, into: &worker)

        XCTAssertEqual(result.added, 2)
        XCTAssertEqual(result.alreadySaved, 1)
        XCTAssertEqual(result.skipped, 1)
        XCTAssertEqual(worker.khach.map(\.name), ["Donna Owens", "Hannah Owens"])
    }

    func testWindowsLineEndings() throws {
        let csv = "First Name,Last Name,Email,Phone\r\nLinda,Smith,a@b.com,(803) 553-2292\r\n"
        var worker = Technician(name: "Linh", phone: "803")
        let result = try ClientCSVImporter.importCSV(csv, into: &worker)
        XCTAssertEqual(result.added, 1)
        XCTAssertEqual(worker.khach.first?.name, "Linda Smith")
        XCTAssertEqual(worker.khach.first?.sdt, "8035532292")
    }

    func testQuotedCommaInName() throws {
        let csv = """
        First Name,Last Name,Phone
        "Elise","Bidwell, CFP",(803) 609-2984
        """
        var worker = Technician(name: "Linh", phone: "803")
        _ = try ClientCSVImporter.importCSV(csv, into: &worker)
        XCTAssertEqual(worker.khach.first?.name, "Elise Bidwell, CFP")
        XCTAssertEqual(worker.khach.first?.sdt, "8036092984")
    }

    func testMissingColumnsThrows() {
        var worker = Technician(name: "Linh", phone: "803")
        XCTAssertThrowsError(try ClientCSVImporter.importCSV("Email\nonly@mail.com\n", into: &worker))
        XCTAssertTrue(worker.khach.isEmpty)
    }

    func testSiteExportFile() throws {
        let url = URL(fileURLWithPath: "/Users/jubi/Downloads/clients.csv")
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        let csv = try String(contentsOf: url, encoding: .utf8)
        var worker = Technician(name: "Linh", phone: "803")
        worker.khach = [Khach(name: "Linda Smith", sdt: "8035532292", diem: 42)]
        let result = try ClientCSVImporter.importCSV(csv, into: &worker)

        XCTAssertEqual(worker.khach[0].diem, 42)
        XCTAssertEqual(worker.khach[0].name, "Linda Smith")
        XCTAssertEqual(worker.khach.filter { $0.name == "Linda Smith" && $0.sdt.filter(\.isNumber) == "8035532292" }.count, 1)
        XCTAssertEqual(result.added, 8995)
        XCTAssertEqual(result.alreadySaved, 281)
        XCTAssertEqual(result.skipped, 160)
        XCTAssertTrue(worker.khach.allSatisfy { $0.email.isEmpty && !$0.today })
    }
}

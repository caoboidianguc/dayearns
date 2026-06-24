//
//  KhachLogicTests.swift
//  DayEarnsTests
//

import XCTest
@testable import DayEarns

final class KhachLogicTests: XCTestCase {
    func testPointsOnlyIncreaseByNewServicesOnUpdate() {
        var client = Khach(name: "Test", sdt: "5551234567", dvDone: [], diem: 100)
        var draft = client.mau
        draft.dvDone = [Service(dichVu: "Full set", gia: 60)]
        client.update(tu: draft)
        XCTAssertEqual(client.diem, 160)
    }

    func testDuplicateDetectionUsesPhoneAndName() {
        let first = Khach(name: "Jubi", sdt: "5551234567", diem: 0)
        let second = Khach(name: "Jubi", sdt: "5551234567", diem: 0)
        let different = Khach(name: "Other", sdt: "5551234567", diem: 0)
        XCTAssertTrue(first.isDuplicate(of: second))
        XCTAssertFalse(first.isDuplicate(of: different))
        XCTAssertNotEqual(first, second)
    }

    func testCorrectPhoneFormatsTenDigits() {
        let client = Khach(name: "Test", sdt: "", diem: 0)
        XCTAssertEqual(client.correctPhone(laySo: "5551234567"), "(555) 123-4567")
        XCTAssertEqual(client.correctPhone(laySo: ""), "")
    }
}
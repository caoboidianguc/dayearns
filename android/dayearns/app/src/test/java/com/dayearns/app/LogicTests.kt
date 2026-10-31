package com.dayearns.app

import com.dayearns.app.model.*
import com.dayearns.app.ui.applyEdit
import com.dayearns.app.ui.applyTip
import com.dayearns.app.ui.receiptFileName
import org.junit.Assert.*
import org.junit.Test

class CsvImportTests {
    private fun tech() = Technician(name = "Linh", phone = "803")

    @Test fun importsFullNameAndPhoneAndIgnoresEmail() {
        val csv = "First Name,Last Name,Email,Phone\nLinda,Smith,l@g.com,\"(803) 553-2292\"\nMary Jo,Cole,m@s.com,(803) 960-9941\n"
        val (w, r) = ClientCsvImporter.importCsv(csv, tech())
        assertEquals(2, r.added)
        assertEquals(listOf("Linda Smith", "Mary Jo Cole"), w.khach.map { it.name })
        assertEquals(listOf("8035532292", "8039609941"), w.khach.map { it.sdt })
        assertTrue(w.khach.all { it.email.isEmpty() && it.diem == 0 && it.histories.isEmpty() && !it.today && !it.trongTuan && !it.schedule })
    }

    @Test fun keepsExistingClientData() {
        val existing = Khach(name = "Linda Smith", sdt = "(803) 553-2292", desc = "prefers mornings", diem = 40,
            histories = listOf(HistoryVisit(ngay = Clock.now(), note = "gel")))
        val csv = "First Name,Last Name,Email,Phone\nLinda,Smith,x,(803) 553-2292\nJennifer,Testing,y,(803) 386-4800"
        val (w, r) = ClientCsvImporter.importCsv(csv, tech().copy(khach = listOf(existing)))
        assertEquals(ClientImportResult(1, 1, 0), r)
        assertEquals(40, w.khach[0].diem); assertEquals("(803) 553-2292", w.khach[0].sdt)
        assertEquals("8033864800", w.khach[1].sdt)
    }

    @Test fun samePhoneDifferentNamesDuplicatesAndBadRows() {
        val csv = "First Name,Last Name,Email,Phone\nDonna,Owens,a,(803) 603-0465\nHannah,Owens,b,(803) 603-0465\nDonna,Owens,a,(803) 603-0465\n,,,(803) 603-0465\nNo,Phone,c,\n"
        val (w, r) = ClientCsvImporter.importCsv(csv, tech())
        assertEquals(ClientImportResult(2, 1, 2), r)
        assertEquals(2, w.khach.size)
    }

    @Test fun fullNameColumnBomCrlfQuotesAndCaseInsensitiveDup() {
        val csv = "\uFEFFName,Mobile\r\n\"Smith, \"\"Jo\"\"\",803-111-2222\r\n  smith,  \"\"jo\"\"  ,8031112222\r\n"
        val recs = ClientCsvImporter.parseRecords(csv)
        assertEquals(listOf("Smith, \"Jo\"", "803-111-2222"), recs[1])
        val (_, r) = ClientCsvImporter.importCsv(csv, tech())
        assertEquals(1, r.added)
    }

    @Test fun missingColumnsAndEmptyFile() {
        assertEquals("That file is empty.", runCatching { ClientCsvImporter.importCsv("", tech()) }.exceptionOrNull()?.message)
        assertEquals("The file needs a name column and a phone column.", runCatching { ClientCsvImporter.importCsv("Name,Email\nA,b", tech()) }.exceptionOrNull()?.message)
    }

    @Test fun exportRoundTrips() {
        val w = tech().copy(khach = listOf(Khach(name = "A, B", sdt = "8031234567", diem = 0)))
        val (back, r) = ClientCsvImporter.importCsv(ClientCsvImporter.export(w), tech())
        assertEquals(1, r.added); assertEquals("A, B", back.khach[0].name)
    }

    @Test fun summaryText() {
        assertEquals("Added 2 clients. 1 were already saved and were left as they are. 3 rows had no name or phone and were skipped. Search by name or phone to find them.",
            ClientCsvImporter.summary(ClientImportResult(2, 1, 3)))
    }
}

class LogicTests {
    @Test fun phoneFormatting() {
        assertEquals("(803) 553-2292", correctPhone("803.553.2292"))
        assertEquals("80355", correctPhone("80355")); assertEquals("", correctPhone("abc"))
    }

    @Test fun totalsAndToday() {
        val now = Clock.now()
        val k1 = Khach(name = "A", sdt = "", dvDone = listOf(Service(dichVu = "Full set", gia = 60)), ngay = now - 1000, diem = 0, tip = 10)
        val k2 = Khach(name = "B", sdt = "", dvDone = listOf(Service(dichVu = "x", gia = 35)), ngay = now.plusDays(-3), diem = 0, tip = 5)
        val t = Technician(name = "L", phone = "", khach = listOf(k1, k2))
        assertEquals(70, k1.khachTra()); assertEquals(70, t.tongNgay()); assertEquals(10, t.tinhTip())
        val saved = t.saveToday().weekEarn.first(); assertEquals(60, saved.earn); assertEquals(10, saved.tip)
    }

    @Test fun scheduleBuckets() {
        val now = Clock.now()
        val soon = Khach(name = "S", sdt = "", ngay = now.plusDays(1), diem = 0)
        val mid = Khach(name = "M", sdt = "", ngay = now.plusDays(4), diem = 0)
        val far = Khach(name = "F", sdt = "", ngay = now.plusDays(10), diem = 0)
        val t = Technician(name = "L", phone = "", khach = listOf(far, mid, soon))
        assertEquals(listOf("S"), t.tuan(QuaTuan.TUAN).map { it.name })
        assertEquals(listOf("M"), t.tuan(QuaTuan.NUA_THANG).map { it.name })
        assertEquals(listOf("F"), t.tuan(QuaTuan.XAXOI).map { it.name })
        assertTrue(t.listDaTim("S").isEmpty()) // scheduled clients are excluded from search
    }

    @Test fun duplicateAndRedeem() {
        val a = Khach(name = " linda ", sdt = "803", diem = 30); val b = Khach(name = "Linda", sdt = "803", diem = 0)
        assertTrue(a.isDuplicate(b)); assertFalse(a.copy(sdt = "").isDuplicate(b.copy(sdt = "")))
        assertEquals(10, a.redeemPoints(20).diem)
        assertTrue(runCatching { a.redeemPoints(31) }.isFailure)
    }

    @Test fun editAddsPointsAndHistoryAndClearsTip() {
        val k = Khach(name = "A", sdt = "", diem = 5, tip = 7)
        val e = applyEdit(k, k.mau.copy(dvDone = listOf(Service(dichVu = "x", gia = 40))))
        assertEquals(45, e.diem); assertNull(e.tip); assertEquals(7, e.histories.last().tip); assertFalse(e.isNew)
    }

    @Test fun tipReplacesSameDayHistory() {
        val now = Clock.now()
        val k = Khach(name = "A", sdt = "", ngay = now, diem = 0, histories = listOf(HistoryVisit(ngay = now)))
        val t = applyTip(k, 12)
        assertEquals(1, t.histories.size); assertEquals(12, t.histories[0].tip); assertEquals(12, t.tip)
    }

    @Test fun rangeTotalsAndMisc() {
        val now = Clock.now()
        val k = Khach(name = "A", sdt = "", diem = 0, histories = listOf(
            HistoryVisit(ngay = now, dvDone = listOf(Service(dichVu = "x", gia = 50)), tip = 5),
            HistoryVisit(ngay = now.plusDays(-10), dvDone = listOf(Service(dichVu = "y", gia = 20)))))
        val t = Technician(name = "L", phone = "", khach = listOf(k))
        assertEquals(50, t.tongTien(now, now)); assertEquals(5, t.tongTip(now, now)); assertEquals(70, t.tongTien(now.plusDays(-30), now))
        assertEquals("Receipt.pdf", receiptFileName(" /:")); assertEquals("Ann B.pdf", receiptFileName("Ann/ B"))
        assertTrue(phoneLooksWrong("123")); assertFalse(phoneLooksWrong(""))
        assertEquals("Mary ", Khach(name = "Mary Jo", sdt = "", diem = 0).layTen())
    }
}

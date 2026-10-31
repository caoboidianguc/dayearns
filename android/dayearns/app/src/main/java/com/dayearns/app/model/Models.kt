package com.dayearns.app.model

import kotlinx.serialization.Serializable
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId
import java.util.UUID

/** Clock used by all date logic; tests may override. */
object Clock { var now: () -> Long = { System.currentTimeMillis() } }

private val zone: ZoneId get() = ZoneId.systemDefault()
fun Long.toLdt(): LocalDateTime = LocalDateTime.ofInstant(Instant.ofEpochMilli(this), zone)
fun Long.toLocalDate(): LocalDate = toLdt().toLocalDate()
fun LocalDateTime.millis(): Long = atZone(zone).toInstant().toEpochMilli()
fun Long.plusDays(d: Long) = toLdt().plusDays(d).millis()
fun Long.plusMonths(m: Long) = toLdt().plusMonths(m).millis()
fun Long.plusYears(y: Long) = toLdt().plusYears(y).millis()

@Serializable
data class Service(val id: String = UUID.randomUUID().toString(), val dichVu: String, val gia: Int)

@Serializable
data class Address(val street: String, val alternateStreet: String = "", val city: String, val state: String, val zip: String) {
    val formattedMultiline: String get() {
        val l1 = listOf(street, alternateStreet).map { it.trim() }.filter { it.isNotEmpty() }.joinToString(" ")
        val l2 = listOf(city, "$state $zip").map { it.trim() }.filter { it.isNotEmpty() }.joinToString(", ")
        return listOf(l1, l2).filter { it.isNotEmpty() }.joinToString("\n")
    }
    val oneLine: String get() = listOf(street, alternateStreet, city, "$state $zip").map { it.trim() }.filter { it.isNotEmpty() }.joinToString(", ")
}

/** Shared time-window logic (same as iOS schedule/honTuan/trongTuan/thang/nam). */
interface Dated {
    val ngay: Long
    val schedule: Boolean get() = ngay > Clock.now()
    val honTuan: Boolean get() = ngay.plusDays(7) < Clock.now()
    val trongTuan: Boolean get() = !schedule && !honTuan
    val thang: Boolean get() = !schedule && ngay > Clock.now().plusMonths(-1)
    val nam: Boolean get() = !schedule && ngay > Clock.now().plusYears(-1)
}

@Serializable
data class HistoryVisit(
    val id: String = UUID.randomUUID().toString(),
    override val ngay: Long,
    val note: String = "",
    val dvDone: List<Service> = emptyList(),
    val tip: Int? = null,
) : Dated {
    val tongTien: Int get() = dvDone.sumOf { it.gia }
}

@Serializable
data class WeekEarn(
    val id: String = UUID.randomUUID().toString(),
    override val ngay: Long,
    val earn: Int,
    val tip: Int? = null,
) : Dated

@Serializable
data class Khach(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val sdt: String,
    val desc: String = "",
    val diem: Int = 0,
    val dvDone: List<Service> = emptyList(),
    override val ngay: Long = Clock.now(),
    val danhGia: Int = 0,
    val email: String = "",
    val firstCome: Long = Clock.now(),
    val isNew: Boolean = true,
    val tip: Int? = null,
    val tag: String? = null,
    val birthDay: Long? = null,
    val histories: List<HistoryVisit> = emptyList(),
    val address: Address? = null,
) : Dated {
    fun isDuplicate(other: Khach): Boolean {
        val a = sdt.trim(); val b = other.sdt.trim()
        if (a.isEmpty() || a != b) return false
        return name.trim().equals(other.name.trim(), ignoreCase = true)
    }
    fun khachTip(): Int = tip ?: 0
    val totalService: Int get() = dvDone.sumOf { it.gia }
    fun khachTra(): Int = totalService + khachTip()
    val haiNgay: Boolean get() = schedule && ngay < Clock.now().plusDays(2)
    val overTuan: Boolean get() = schedule && !haiNgay && ngay < Clock.now().plusDays(7)
    val xahon: Boolean get() = ngay >= Clock.now().plusDays(7)
    val today: Boolean get() = ngay.toLocalDate() == Clock.now().toLocalDate()
    val isBirthday: Boolean get() {
        val b = birthDay ?: return false
        val t = Clock.now().toLocalDate(); val d = b.toLocalDate()
        return t.monthValue == d.monthValue && t.dayOfMonth == d.dayOfMonth
    }
    fun layTen(): String = name.indexOf(' ').let { if (it >= 0) name.substring(0, it + 1) else name }
    fun redeemPoints(points: Int): Khach {
        if (diem < points) throw IllegalStateException("Not enough points")
        return copy(diem = diem - points)
    }
    val mau: ThemKhach get() = ThemKhach(name, sdt, email, desc, dvDone, diem, ngay)
    fun update(data: ThemKhach): Khach = copy(
        name = data.name, sdt = data.sdt, desc = data.desc, dvDone = data.dvDone,
        diem = data.diem + data.pointsKhach(), ngay = data.ngay, isNew = false, email = data.email,
    )
    val avatarColor: Long get() {
        var h = id.hashCode()
        val r = h and 0xFF; h = h shr 8; val g = h and 0xFF; h = h shr 8; val b = h and 0xFF
        return 0xFF000000 or (r.toLong() shl 16) or (g.toLong() shl 8) or b.toLong()
    }
}

data class ThemKhach(
    val name: String = "", val sdt: String = "", val email: String = "", val desc: String = "",
    val dvDone: List<Service> = emptyList(), val diem: Int = 0, val ngay: Long = Clock.now(),
) { fun pointsKhach(): Int = dvDone.sumOf { it.gia } }

fun correctPhone(laySo: String): String {
    val digits = laySo.filter { it.isDigit() }
    if (digits.isEmpty()) return ""
    if (digits.length != 10) return digits
    return "(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}"
}

enum class QuaTuan(val title: String) { BIRTHDAY("Happy Birthday"), TUAN("Coming up"), NUA_THANG("Within 7 days"), XAXOI("Over week") }
enum class DSServices(val title: String) { SORT("Sort"), BY_NAME("By Name"), BY_GIA("By Price") }

@Serializable
data class Technician(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val phone: String,
    val email: String = "",
    val services: List<Service> = emptyList(),
    val khach: List<Khach> = emptyList(),
    val weekEarn: List<WeekEarn> = emptyList(),
    val address: Address? = null,
) {
    fun clientExisted(c: Khach) = khach.any { it.isDuplicate(c) }
    fun indexOfDuplicate(c: Khach) = khach.indexOfFirst { it.isDuplicate(c) }.takeIf { it >= 0 }
    fun tinhTip(): Int = khach.filter { it.today }.sumOf { it.tip ?: 0 }
    fun tongNgay(): Int = khach.filter { it.today }.sumOf { it.khachTra() }
    fun tuan(q: QuaTuan): List<Khach> = khach.filter {
        when (q) { QuaTuan.BIRTHDAY -> it.isBirthday; QuaTuan.TUAN -> it.haiNgay; QuaTuan.NUA_THANG -> it.overTuan; QuaTuan.XAXOI -> it.xahon }
    }.sortedBy { it.ngay }
    fun listDaTim(ten: String, limit: Int = 50): List<Khach> = khach.asSequence().filter { !it.schedule }.filter {
        it.name.contains(ten, true) || it.sdt.contains(ten) || (it.tag?.contains(ten, true) ?: false)
    }.take(limit).toList()
    fun timService(ten: String) = services.filter { it.dichVu.contains(ten, true) }
    val tuan: List<Khach> get() = khach.filter { it.trongTuan }.sortedByDescending { it.ngay }
    fun xapxep(ds: DSServices) = when (ds) {
        DSServices.SORT -> services; DSServices.BY_NAME -> services.sortedBy { it.dichVu }; DSServices.BY_GIA -> services.sortedByDescending { it.gia }
    }
    val motTuanHistory get() = khach.flatMap { it.histories }.filter { it.trongTuan }
    val thangHistory get() = khach.flatMap { it.histories }.filter { it.thang }
    val namHistory get() = khach.flatMap { it.histories }.filter { it.nam }

    fun calculateDateWorked(from: Long, to: Long): List<HistoryVisit> {
        val f = from.toLocalDate(); val t = to.toLocalDate()
        return khach.flatMap { k -> k.histories.filter { val d = it.ngay.toLocalDate(); !d.isBefore(f) && !d.isAfter(t) } }
    }
    fun tongTien(from: Long, to: Long) = calculateDateWorked(from, to).sumOf { it.tongTien }
    fun tongTip(from: Long, to: Long) = calculateDateWorked(from, to).sumOf { it.tip ?: 0 }

    /** Save today's totals (iOS luuNgayLam). */
    fun saveToday(): Technician {
        val tip = tinhTip(); val earn = tongNgay() - tip
        return copy(weekEarn = listOf(WeekEarn(ngay = Clock.now(), earn = earn, tip = tip)) + weekEarn)
    }
}

/** Validation shared by add/schedule flows: phone may be empty or have >= 10 chars. */
fun phoneLooksWrong(sdt: String) = sdt.isNotEmpty() && sdt.length < 10
fun emailIncomplete(email: String) = email.isNotEmpty() && !Regex(".+@.+").containsMatchIn(email)

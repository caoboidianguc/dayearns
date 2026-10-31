package com.dayearns.app.model

data class ClientImportResult(val added: Int, val alreadySaved: Int, val skipped: Int)
class ClientCsvException(message: String) : Exception(message)

/** Port of iOS ClientCSVImporter: adds name + phone; existing clients are left as they are. */
object ClientCsvImporter {
    private val nameHeaders = setOf("name", "full name", "fullname", "client", "client name")
    private val firstNameHeaders = setOf("first name", "firstname", "first")
    private val lastNameHeaders = setOf("last name", "lastname", "last")
    private val phoneHeaders = setOf("phone", "phone number", "phonenumber", "mobile", "mobile phone", "cell", "cell phone", "sdt", "tel", "telephone")

    fun importCsv(csv: String, worker: Technician): Pair<Technician, ClientImportResult> {
        val records = parseRecords(csv)
        val header = records.firstOrNull() ?: throw ClientCsvException("That file is empty.")
        val cols = header.map { it.replace("\uFEFF", "").trim().lowercase() }
        val fullIdx = cols.indexOfFirst { it in nameHeaders }.takeIf { it >= 0 }
        val firstIdx = cols.indexOfFirst { it in firstNameHeaders }.takeIf { it >= 0 }
        val lastIdx = cols.indexOfFirst { it in lastNameHeaders }.takeIf { it >= 0 }
        val phoneIdx = cols.indexOfFirst { it in phoneHeaders }.takeIf { it >= 0 }
        if (phoneIdx == null || (fullIdx == null && firstIdx == null && lastIdx == null))
            throw ClientCsvException("The file needs a name column and a phone column.")

        val saved = worker.khach.map { identity(it.name, it.sdt) }.toMutableSet()
        var added = 0; var already = 0; var skipped = 0
        val newcomers = mutableListOf<Khach>()
        val placeholder = Clock.now().plusDays(-30)
        for (rec in records.drop(1)) {
            val combined = field(rec, fullIdx)
            val name = collapse(if (combined.isNotEmpty()) combined else listOf(field(rec, firstIdx), field(rec, lastIdx)).filter { it.isNotEmpty() }.joinToString(" "))
            val phone = field(rec, phoneIdx).filter { it.isDigit() }
            if (name.isEmpty() || phone.isEmpty()) { skipped++; continue }
            if (!saved.add(identity(name, phone))) { already++; continue }
            newcomers += Khach(name = name, sdt = phone, ngay = placeholder, diem = 0, firstCome = placeholder)
            added++
        }
        return worker.copy(khach = worker.khach + newcomers) to ClientImportResult(added, already, skipped)
    }

    fun summary(r: ClientImportResult): String {
        val parts = mutableListOf("Added ${r.added} clients.")
        if (r.alreadySaved > 0) parts += "${r.alreadySaved} were already saved and were left as they are."
        if (r.skipped > 0) parts += "${r.skipped} rows had no name or phone and were skipped."
        parts += "Search by name or phone to find them."
        return parts.joinToString(" ")
    }

    private fun identity(name: String, phone: String) = collapse(name).lowercase() + "\u0001" + phone.filter { it.isDigit() }
    private fun collapse(v: String) = v.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }.joinToString(" ")
    private fun field(r: List<String>, i: Int?) = if (i != null && i in r.indices) r[i].trim() else ""

    fun parseRecords(csv: String): List<List<String>> {
        val records = mutableListOf<List<String>>()
        val field = StringBuilder(); var record = mutableListOf<String>(); var inQuotes = false
        fun finish() {
            record.add(field.toString()); field.clear()
            if (record.any { it.isNotBlank() }) records.add(record)
            record = mutableListOf()
        }
        var i = 0
        while (i < csv.length) {
            val c = csv[i]
            if (inQuotes) {
                if (c == '"') { if (i + 1 < csv.length && csv[i + 1] == '"') { field.append('"'); i++ } else inQuotes = false }
                else field.append(c)
            } else when (c) {
                '"' -> inQuotes = true
                ',' -> { record.add(field.toString()); field.clear() }
                '\n', '\r', '\u2028', '\u2029' -> { if (c == '\r' && i + 1 < csv.length && csv[i + 1] == '\n') i++; finish() }
                else -> field.append(c)
            }
            i++
        }
        if (inQuotes || field.isNotEmpty() || record.isNotEmpty()) finish()
        return records
    }

    /** CSV export (Android addition): same columns the importer reads. */
    fun export(worker: Technician): String {
        fun q(s: String) = if (s.any { it == ',' || it == '"' || it == '\n' }) "\"" + s.replace("\"", "\"\"") + "\"" else s
        return buildString {
            append("Name,Phone,Email\n")
            worker.khach.forEach { append(q(it.name)).append(',').append(q(it.sdt)).append(',').append(q(it.email)).append('\n') }
        }
    }
}

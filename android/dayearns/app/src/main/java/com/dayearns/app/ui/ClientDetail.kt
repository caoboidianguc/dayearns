package com.dayearns.app.ui

import android.content.Context
import android.content.Intent
import android.graphics.Paint
import android.graphics.pdf.PdfDocument
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import com.dayearns.app.LedgerViewModel
import com.dayearns.app.model.*
import java.io.File

/** iOS AddTip: set tip, replace same-day history with one carrying the tip. */
fun applyTip(k: Khach, bonus: Int): Khach {
    val day = k.ngay.toLdt().dayOfMonth
    val visit = HistoryVisit(ngay = k.ngay, note = k.desc, dvDone = k.dvDone, tip = bonus)
    return k.copy(tip = bonus, histories = k.histories.filter { it.ngay.toLdt().dayOfMonth != day } + visit)
}

/** iOS ClientDetail "Update". */
fun applyEdit(k: Khach, f: ThemKhach): Khach {
    val h = HistoryVisit(ngay = f.ngay, note = f.desc, dvDone = f.dvDone, tip = k.tip)
    val u = k.update(f)
    return u.copy(histories = u.histories + h, tip = null)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ClientDetailScreen(vm: LedgerViewModel, w: Technician, id: String, back: () -> Unit, go: (String) -> Unit) {
    val k = w.khach.firstOrNull { it.id == id } ?: run { LaunchedEffect(Unit) { back() }; return }
    val ctx = LocalContext.current
    var dialog by remember { mutableStateOf("") }
    var msg by remember { mutableStateOf<String?>(null) }
    var editing by remember { mutableStateOf(false) }
    val up: ((Khach) -> Khach) -> Unit = { f -> vm.updateClient(id, f) }
    Scaffold(topBar = { TopAppBar(title = { Text("${k.layTen()}'s Visit") }, navigationIcon = { IconButton(onClick = back) { Icon(Icons.Filled.ArrowBack, "Back") } },
        actions = { IconButton(onClick = { editing = true }) { Icon(Icons.Filled.Edit, "Edit ${k.name}") } }) }) { pad ->
        Column(Modifier.padding(pad).verticalScroll(rememberScrollState()).padding(12.dp)) {
            Text("CLIENT:", color = Color.Gray)
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(k.name, fontSize = 20.sp, modifier = Modifier.weight(1f))
                if (k.sdt.isEmpty()) IconButton(onClick = { dialog = "phone" }) { Icon(Icons.Filled.AddIcCall, "Add phone", tint = Color.Red) }
                else TextButton(onClick = { ctx.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("sms:${k.sdt.filter(Char::isDigit)}"))) }) {
                    Icon(Icons.Filled.Phone, null, tint = TipGreen); Text(" " + correctPhone(k.sdt)) }
            }
            if (k.email.isNotEmpty()) TextButton(onClick = { ctx.startActivity(Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:${k.email}"))) }) {
                Icon(Icons.Filled.Email, null, tint = Purple); Text(" " + k.email) }
            Stars(k.danhGia) { r -> up { it.copy(danhGia = r) } }
            if (k.tag != null) AssistChip(onClick = { dialog = "tag" }, label = { Text(k.tag) }, leadingIcon = { Icon(Icons.Filled.Sell, null, tint = Color(0xFFFF9800)) })
            else TextButton(onClick = { dialog = "tag" }) { Icon(Icons.Filled.Sell, null); Text(" Tag") }
            HorizontalDivider()
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("SERVICES", color = Color.Gray, modifier = Modifier.weight(1f))
                TextButton(onClick = { dialog = "tip" }) { Icon(Icons.Filled.AttachMoney, null); Text("Tip") }
            }
            k.tip?.let { Row { Text("Tip:", color = TipGreen, modifier = Modifier.weight(1f)); Text("$ $it", color = TipGreen) } }
            k.dvDone.forEach { Row { Text(it.dichVu, Modifier.weight(1f)); Text("$${it.gia}") } }
            Row { Text("Total:", fontSize = 22.sp, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f)); Text("$ ${k.khachTra()}", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1E6FD9)) }
            HorizontalDivider(Modifier.padding(vertical = 8.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("${if (k.schedule) "Next Visit" else "Last Visit"}: ${k.ngay.fmt("MMM d, h:mm a")}", color = Color.Gray, modifier = Modifier.weight(1f))
                IconButton(onClick = { dialog = "details" }) { Icon(Icons.Filled.Info, "Show client details", tint = Color(0xFF1E6FD9)) }
            }
            ListItem(headlineContent = { Text("Visit Histories") }, leadingContent = { Icon(Icons.Filled.History, null) }, modifier = Modifier.clickableRow { go("history/$id") })
            val a = k.address
            if (a != null) Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.Place, null, tint = Color.Red)
                TextButton(onClick = { ctx.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("geo:0,0?q=" + Uri.encode(a.oneLine)))) }, Modifier.weight(1f)) { Text(a.formattedMultiline) }
                IconButton(onClick = { dialog = "rmaddr" }) { Icon(Icons.Filled.Delete, "Remove address") }
            } else ListItem(headlineContent = { Text("Add Shipping Address") }, leadingContent = { Icon(Icons.Filled.AddCircle, null, tint = TipGreen) }, modifier = Modifier.clickableRow { dialog = "addr" })
            ListItem(headlineContent = { Text("Receipt") }, leadingContent = { Icon(Icons.Filled.Description, null) }, modifier = Modifier.clickableRow { go("receipt/$id") })
        }
    }
    when (dialog) {
        "phone" -> InputDialog("${k.name}'s Number", "Phone", onDismiss = { dialog = "" }) { s -> if (phoneLooksWrong(s)) msg = "Phone is incorrect!" else up { it.copy(sdt = s) } }
        "tag" -> InputDialog("Add Tag", "Tag name", initial = k.tag ?: "", onDismiss = { dialog = "" }) { s -> up { it.copy(tag = s.ifBlank { null }) } }
        "tip" -> InputDialog("Tipping", "Tip Amount", number = true, onDismiss = { dialog = "" }) { s -> s.toIntOrNull()?.let { b -> up { applyTip(it, b) } } }
        "rmaddr" -> AlertDialog(onDismissRequest = { dialog = "" }, title = { Text("Remove Address?") },
            confirmButton = { TextButton(onClick = { up { it.copy(address = null) }; dialog = "" }) { Text("Remove") } }, dismissButton = { TextButton(onClick = { dialog = "" }) { Text("Cancel") } })
        "addr" -> AddressDialog({ dialog = "" }) { a -> up { it.copy(address = a) } }
        "details" -> DetailsDialog(k, up, { dialog = "" }) { msg = it }
    }
    if (editing) EditClientDialog(vm, w, k, { editing = false }) { f -> up { applyEdit(it, f) }; editing = false }
    MessageDialog(msg) { msg = null }
}

fun Modifier.clickableRow(f: () -> Unit) = this.clickable(onClick = f)

@Composable
fun AddressDialog(dismiss: () -> Unit, save: (Address) -> Unit) {
    var s by remember { mutableStateOf("") }; var alt by remember { mutableStateOf("") }; var c by remember { mutableStateOf("") }
    var st by remember { mutableStateOf("") }; var z by remember { mutableStateOf("") }
    AlertDialog(onDismissRequest = dismiss, title = { Text("Shipping Address") }, text = { Column {
        OutlinedTextField(s, { s = it }, label = { Text("Street:") }); OutlinedTextField(alt, { alt = it }, label = { Text("Street optionally:") })
        OutlinedTextField(c, { c = it }, label = { Text("City:") }); OutlinedTextField(st, { st = it }, label = { Text("State:") })
        OutlinedTextField(z, { z = it }, label = { Text("Zip Code:") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)) } },
        confirmButton = { TextButton(enabled = s.isNotEmpty() && c.isNotEmpty() && st.isNotEmpty(), onClick = { save(Address(s, alt, c, st, z)); dismiss() }) { Text("Save") } },
        dismissButton = { TextButton(onClick = dismiss) { Text("Cancel") } })
}

@Composable
fun DetailsDialog(k: Khach, up: ((Khach) -> Khach) -> Unit, dismiss: () -> Unit, err: (String) -> Unit) {
    var claim by remember { mutableStateOf(false) }
    var bday by remember { mutableStateOf(Clock.now()) }
    AlertDialog(onDismissRequest = dismiss, title = { Text("${k.name}'s Details") }, text = { Column {
        Text("VISIT INFO", color = Color.Gray)
        if (!k.isNew) Text("${if (k.schedule) "Next Visit:" else "Latest Visit:"} ${k.ngay.full()}")
        Text("Note: ${k.desc}")
        Row(verticalAlignment = Alignment.CenterVertically) { Icon(Icons.Filled.Star, null, tint = Yellow); Text(" Points Earned: ${k.diem}", Modifier.weight(1f)); TextButton(onClick = { claim = true }) { Text("Claim") } }
        Text("PERSONAL INFO", color = Color.Gray)
        Text("First Visit: ${k.firstCome.full()}")
        val b = k.birthDay
        if (b != null) Text(if (k.isBirthday) "🎂 It's Today! ${b.fmt("MMM d, yyyy")}" else "Birthday: ${b.fmt("MMM d, yyyy")}", color = if (k.isBirthday) TipGreen else Color.Unspecified)
        else { DateTimeField("Birthday", bday, withTime = false) { if (it <= Clock.now()) bday = it }
            TextButton(enabled = bday.toLocalDate() != Clock.now().toLocalDate(), onClick = { up { it.copy(birthDay = bday) } }) { Text("Save") } }
    } }, confirmButton = { TextButton(onClick = dismiss) { Text("Done") } })
    if (claim) InputDialog("Redeem Points", "Enter points", number = true, onDismiss = { claim = false }) { s ->
        val p = s.toIntOrNull()
        if (p == null || p <= 0) err("Please enter a valid number of points.")
        else if (k.diem < p) err("Not enough points for ${k.name}.") else up { it.redeemPoints(p) }
    }
}

@Composable
fun EditClientDialog(vm: LedgerViewModel, w: Technician, k: Khach, dismiss: () -> Unit, save: (ThemKhach) -> Unit) {
    var f by remember { mutableStateOf(k.mau.copy(dvDone = emptyList())) }
    androidx.compose.ui.window.Dialog(onDismissRequest = dismiss, properties = androidx.compose.ui.window.DialogProperties(usePlatformDefaultWidth = false)) {
        Surface(Modifier.fillMaxSize()) { Column(Modifier.verticalScroll(rememberScrollState()).padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) { TextButton(onClick = dismiss) { Text("Cancel") }; Spacer(Modifier.weight(1f)); Button(onClick = { save(f) }) { Text("Update") } }
            OutlinedTextField(f.name, { f = f.copy(name = it) }, label = { Text("Name:") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(f.sdt, { f = f.copy(sdt = it) }, label = { Text("Phone Option") }, modifier = Modifier.fillMaxWidth(), keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone))
            if (f.email.length >= 4 && emailIncomplete(f.email)) Text("Email incompleted!", color = Color.Red)
            OutlinedTextField(f.email, { f = f.copy(email = it) }, label = { Text("Email:") }, modifier = Modifier.fillMaxWidth(), keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email))
            OutlinedTextField(f.desc, { f = f.copy(desc = it) }, label = { Text("Notes") }, modifier = Modifier.fillMaxWidth().height(150.dp))
            DateTimeField("IPick", f.ngay) { f = f.copy(ngay = it) }
            ChonDichVu(w.services, f.dvDone, { f = f.copy(dvDone = it) }) { s -> vm.update { t -> t.copy(services = t.services + s) } }
        } }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HistoriesScreen(k: Khach?, back: () -> Unit) {
    var shown by remember { mutableIntStateOf(15) }
    val sorted = k?.histories?.sortedByDescending { it.ngay } ?: emptyList()
    Scaffold(topBar = { TopAppBar(title = { Text("Histories") }, navigationIcon = { IconButton(onClick = back) { Icon(Icons.Filled.ArrowBack, "Back") } }) }) { pad ->
        LazyColumn(Modifier.padding(pad), contentPadding = PaddingValues(12.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            items(sorted.take(shown), key = { it.id }) { h -> Card(Modifier.fillMaxWidth()) { Column(Modifier.padding(12.dp)) {
                Text(h.ngay.fmt("M/d/yyyy, h:mm a"), fontWeight = FontWeight.Bold)
                if (h.note.isNotEmpty()) Text(h.note, color = Color.Gray)
                h.tip?.let { Row { Text("Tip:", Modifier.weight(1f), color = TipGreen); Text("$it", color = TipGreen) } }
                h.dvDone.forEach { Row { Text(it.dichVu, Modifier.weight(1f)); Text("${it.gia}", color = Color(0xFF1E6FD9)) } }
            } } }
            if (shown < sorted.size) item { OutlinedButton(onClick = { shown += 15 }, Modifier.fillMaxWidth()) { Text("Load more") } }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReceiptScreen(w: Technician, k: Khach?, back: () -> Unit) {
    val ctx = LocalContext.current
    Scaffold(topBar = { TopAppBar(title = { Text("Receipt") }, navigationIcon = { IconButton(onClick = back) { Icon(Icons.Filled.ArrowBack, "Back") } }) }) { pad ->
        if (k == null) return@Scaffold
        Column(Modifier.padding(pad).padding(16.dp).fillMaxSize()) {
            receiptLines(w, k).forEach { (l, r) -> Row { Text(l, Modifier.weight(1f)); Text(r) } }
            Spacer(Modifier.weight(1f))
            Button(onClick = { shareReceipt(ctx, w, k) }, Modifier.fillMaxWidth()) { Icon(Icons.Filled.Share, null); Text(" Receipt") }
        }
    }
}

fun receiptLines(w: Technician, k: Khach): List<Pair<String, String>> = buildList {
    add(w.name to k.name)
    add(correctPhone(w.phone) to correctPhone(k.sdt))
    add(w.email to "No: ${k.ngay.fmt("MM/dd")}")
    w.address?.formattedMultiline?.lines()?.forEach { add(it to "") }
    add("" to ""); add("Services:" to "")
    k.tip?.let { add("Tip:" to "$ $it") }
    k.dvDone.forEach { add(it.dichVu to "$ ${it.gia}") }
    if (k.desc.isNotEmpty()) add("Note: ${k.desc}" to "")
    add("Total:" to "$ ${k.khachTra()}")
}

fun receiptFileName(name: String): String {
    val s = name.trim().filter { it !in "/\\:?%*|\"<>" }.trim()
    return if (s.isEmpty()) "Receipt.pdf" else "$s.pdf"
}

fun shareReceipt(ctx: Context, w: Technician, k: Khach) {
    val doc = PdfDocument(); val page = doc.startPage(PdfDocument.PageInfo.Builder(400, 600, 1).create())
    val p = Paint().apply { textSize = 13f; isAntiAlias = true }
    var y = 40f
    receiptLines(w, k).forEachIndexed { i, (l, r) ->
        p.textSize = if (i == 0) 20f else 13f
        page.canvas.drawText(l, 20f, y, p); page.canvas.drawText(r, 380f - p.measureText(r), y, p); y += if (i == 0) 28f else 20f
    }
    doc.finishPage(page)
    val dir = File(ctx.cacheDir, "receipts").apply { mkdirs() }
    val f = File(dir, receiptFileName(k.name)); f.outputStream().use { doc.writeTo(it) }; doc.close()
    val uri = FileProvider.getUriForFile(ctx, ctx.packageName + ".files", f)
    ctx.startActivity(Intent.createChooser(Intent(Intent.ACTION_SEND).setType("application/pdf").putExtra(Intent.EXTRA_STREAM, uri).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION), "Receipt"))
}

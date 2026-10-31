package com.dayearns.app.ui

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
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
import com.dayearns.app.LedgerViewModel
import com.dayearns.app.model.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScheduleScreen(vm: LedgerViewModel, w: Technician, open: (String) -> Unit) {
    var adding by remember { mutableStateOf(false) }
    val count = w.khach.count { it.schedule }
    Scaffold(topBar = { TopAppBar(title = { Text(if (count == 0) "No Schedules" else "$count Up Coming") },
        actions = { TextButton(onClick = { adding = true }) { Text("Add") } }) }) { pad ->
        LazyColumn(Modifier.padding(pad)) {
            QuaTuan.entries.forEach { q ->
                val list = w.tuan(q)
                if (list.isNotEmpty()) {
                    item { Text(q.title, Modifier.padding(12.dp, 8.dp), fontWeight = FontWeight.Bold, color = Purple) }
                    items(list, key = { q.name + it.id }) { k -> KhachRow(k) { open(k.id) } }
                }
            }
        }
    }
    if (adding) ClientFormDialog(vm, w, title = "Get Appointment", schedule = true, onDismiss = { adding = false })
}

/** Add client (ClientList +) or schedule appointment (ScheduleView Add). */
@Composable
fun ClientFormDialog(vm: LedgerViewModel, w: Technician, title: String, schedule: Boolean, onDismiss: () -> Unit) {
    var f by remember { mutableStateOf(ThemKhach(ngay = if (schedule) Clock.now().plusDays(1) else Clock.now())) }
    var warn by remember { mutableStateOf<String?>(null) }
    androidx.compose.ui.window.Dialog(onDismissRequest = onDismiss, properties = androidx.compose.ui.window.DialogProperties(usePlatformDefaultWidth = false)) {
        Surface(Modifier.fillMaxSize()) {
            Column(Modifier.verticalScroll(rememberScrollState()).padding(16.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    TextButton(onClick = onDismiss) { Text("Cancel") }
                    Text(title, Modifier.weight(1f), fontWeight = FontWeight.Bold)
                    Button(enabled = if (schedule) f.ngay >= Clock.now() && f.name.isNotBlank() else f.name.isNotBlank(), onClick = {
                        if (phoneLooksWrong(f.sdt)) { warn = "Phone number is incorrect!"; return@Button }
                        val history = HistoryVisit(ngay = f.ngay, note = f.desc, dvDone = f.dvDone)
                        val nk = Khach(name = f.name, sdt = f.sdt, desc = f.desc, dvDone = f.dvDone, ngay = if (schedule) f.ngay else Clock.now(), diem = f.pointsKhach())
                        if (schedule) {
                            val idx = w.indexOfDuplicate(nk)
                            vm.update { t -> if (idx != null) t.copy(khach = t.khach.mapIndexed { i, k -> if (i == idx) k.copy(ngay = f.ngay, dvDone = f.dvDone, desc = f.desc, histories = listOf(history) + k.histories) else k })
                                else t.copy(khach = t.khach + nk.copy(histories = listOf(history))) }
                        } else {
                            if (w.clientExisted(nk)) { warn = "Client existed!"; return@Button }
                            vm.update { t -> t.copy(khach = listOf(nk.copy(histories = listOf(history.copy(ngay = Clock.now())))) + t.khach) }
                        }
                        onDismiss()
                    }) { Text("Add") }
                }
                OutlinedTextField(f.name, { f = f.copy(name = it) }, label = { Text("Name:") }, modifier = Modifier.fillMaxWidth())
                OutlinedTextField(f.sdt, { f = f.copy(sdt = it) }, label = { Text(if (schedule) "Phone - opt" else "Phone Option") }, modifier = Modifier.fillMaxWidth(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone))
                if (!schedule) OutlinedTextField(f.desc, { f = f.copy(desc = it) }, label = { Text("Note:") }, modifier = Modifier.fillMaxWidth())
                if (schedule) DateTimeField("iPick:", f.ngay) { f = f.copy(ngay = it) }
                Spacer(Modifier.height(8.dp))
                ChonDichVu(w.services, f.dvDone, { f = f.copy(dvDone = it) }) { s -> vm.update { t -> t.copy(services = t.services + s) } }
            }
        }
    }
    MessageDialog(warn, "Failed to add.") { warn = null }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ClientListScreen(vm: LedgerViewModel, w: Technician, open: (String) -> Unit) {
    var text by remember { mutableStateOf("") }
    var adding by remember { mutableStateOf(false) }
    var importMsg by remember { mutableStateOf<String?>(null) }
    var menu by remember { mutableStateOf(false) }
    val ctx = LocalContext.current
    val picker = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri != null) importMsg = try {
            val csv = ctx.contentResolver.openInputStream(uri)!!.use { it.readBytes().toString(Charsets.UTF_8) }
            vm.importClients(csv)
        } catch (e: Exception) { "Could not read that file." }
    }
    val exporter = rememberLauncherForActivityResult(ActivityResultContracts.CreateDocument("text/csv")) { uri ->
        if (uri != null) importMsg = try {
            ctx.contentResolver.openOutputStream(uri)!!.use { it.write(ClientCsvImporter.export(w).toByteArray()) }
            "Exported ${w.khach.size} clients."
        } catch (e: Exception) { "Could not write that file." }
    }
    val shown = if (text.isEmpty()) w.tuan.filter { !it.schedule } else w.listDaTim(text)
    Scaffold(
        topBar = { TopAppBar(title = { Text(Clock.now().fmt("EEE d")) }, actions = {
            IconButton(onClick = { menu = true }) { Icon(Icons.Filled.MoreVert, "More") }
            DropdownMenu(menu, { menu = false }) {
                DropdownMenuItem(text = { Text("Import clients (CSV)") }, leadingIcon = { Icon(Icons.Filled.FileUpload, null) },
                    onClick = { menu = false; picker.launch(arrayOf("text/*", "text/csv", "text/comma-separated-values", "application/csv", "application/vnd.ms-excel", "application/octet-stream")) })
                DropdownMenuItem(text = { Text("Export clients (CSV)") }, leadingIcon = { Icon(Icons.Filled.FileDownload, null) },
                    onClick = { menu = false; exporter.launch("dayearns_clients.csv") })
            }
        }) },
        floatingActionButton = { FloatingActionButton(onClick = { adding = true }, containerColor = Yellow) { Icon(Icons.Filled.PersonAdd, "Add Client") } },
    ) { pad ->
        Column(Modifier.padding(pad)) {
            OutlinedTextField(text, { text = it }, Modifier.fillMaxWidth().padding(horizontal = 12.dp), placeholder = { Text("Name or Phone") },
                leadingIcon = { Icon(Icons.Filled.Search, null) }, singleLine = true)
            if (text.isEmpty() && w.tuan.isEmpty()) {
                Column(Modifier.padding(24.dp)) {
                    if (w.khach.isEmpty()) { Text("No Client", fontSize = 26.sp, color = Color.Gray); Text("Client within a week\nwill appear here.", color = Color.Gray) }
                    else { Text("No clients this week", fontSize = 20.sp, color = Color.Gray); Text("Search by name or phone to find saved clients.", color = Color.Gray) }
                }
            }
            LazyColumn {
                items(shown, key = { it.id }) { k ->
                    val state = rememberSwipeToDismissBoxState(confirmValueChange = {
                        if (it == SwipeToDismissBoxValue.EndToStart) { vm.update { t -> t.copy(khach = t.khach.filter { c -> c.id != k.id }) }; true } else false })
                    SwipeToDismissBox(state, enableDismissFromStartToEnd = false, backgroundContent = {
                        Box(Modifier.fillMaxSize().padding(8.dp), contentAlignment = Alignment.CenterEnd) { Icon(Icons.Filled.Delete, "Delete", tint = Color.Red) } }) {
                        Surface { KhachRow(k) { open(k.id) } }
                    }
                }
            }
        }
    }
    if (adding) ClientFormDialog(vm, w, title = "New Client", schedule = false, onDismiss = { adding = false })
    MessageDialog(importMsg, "Clients") { importMsg = null }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ServicesScreen(vm: LedgerViewModel, w: Technician) {
    var search by remember { mutableStateOf("") }
    var sort by remember { mutableStateOf(DSServices.SORT) }
    var sortMenu by remember { mutableStateOf(false) }
    var adding by remember { mutableStateOf(false) }
    var name by remember { mutableStateOf("") }
    var price by remember { mutableStateOf("") }
    Scaffold(topBar = { TopAppBar(title = { Text("Services") }, actions = {
        TextButton(onClick = { sortMenu = true }) { Text(sort.title) }
        DropdownMenu(sortMenu, { sortMenu = false }) { DSServices.entries.forEach { d ->
            DropdownMenuItem(text = { Text(d.title) }, onClick = { sort = d; sortMenu = false; vm.update { t -> t.copy(services = t.xapxep(d)) } }) } }
    }) }, floatingActionButton = { FloatingActionButton(onClick = { adding = true }, containerColor = Yellow) { Icon(Icons.Filled.ContentCut, "Add Service") } }) { pad ->
        Column(Modifier.padding(pad)) {
            OutlinedTextField(search, { search = it }, Modifier.fillMaxWidth().padding(horizontal = 12.dp), placeholder = { Text("Search") }, singleLine = true,
                leadingIcon = { Icon(Icons.Filled.Search, null) })
            if (w.services.isEmpty()) Column(Modifier.fillMaxWidth().padding(32.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                Text("No Service", fontSize = 26.sp, color = Color.Gray); Text("Service you add\nwill appear here.", color = Color.Gray) }
            val list = if (search.isEmpty()) w.services else w.timService(search)
            LazyColumn {
                items(list, key = { it.id }) { s ->
                    val i = w.services.indexOfFirst { it.id == s.id }
                    ListItem(headlineContent = { Text(s.dichVu) }, trailingContent = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text("$${s.gia}")
                            IconButton(enabled = search.isEmpty() && i > 0, onClick = { vm.update { t -> t.copy(services = t.services.toMutableList().apply { add(i - 1, removeAt(i)) }) } }) { Icon(Icons.Filled.KeyboardArrowUp, "Move up") }
                            IconButton(onClick = { vm.update { t -> t.copy(services = t.services.filter { it.id != s.id }) } }) { Icon(Icons.Filled.Delete, "Delete", tint = Color.Gray) }
                        } })
                }
            }
        }
    }
    if (adding) AlertDialog(onDismissRequest = { adding = false }, title = { Text("New Service") }, text = { Column {
        OutlinedTextField(name, { name = it }, label = { Text("Service") }, singleLine = true)
        OutlinedTextField(price, { price = it.filter(Char::isDigit) }, label = { Text("Price") }, singleLine = true, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)) } },
        confirmButton = { Button(enabled = name.isNotBlank(), onClick = { vm.update { t -> t.copy(services = t.services + Service(dichVu = name.trim(), gia = price.toIntOrNull() ?: 0)) }; name = ""; price = ""; adding = false }) { Text("Add Service") } },
        dismissButton = { TextButton(onClick = { adding = false }) { Text("Cancel") } })
}

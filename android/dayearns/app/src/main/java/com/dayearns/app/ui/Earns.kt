package com.dayearns.app.ui

import androidx.compose.foundation.Canvas
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.dayearns.app.LedgerViewModel
import com.dayearns.app.model.*
import java.time.temporal.IsoFields

/** Bars grouped by key: yellow = services total, green = tips (overlaid like iOS). */
@Composable
fun BarChart(groups: List<Pair<String, Pair<Int, Int>>>, modifier: Modifier = Modifier) {
    val max = (groups.maxOfOrNull { maxOf(it.second.first, it.second.second) } ?: 0).coerceAtLeast(1)
    Column(modifier) {
        Canvas(Modifier.fillMaxWidth().weight(1f)) {
            if (groups.isEmpty()) return@Canvas
            val slot = size.width / groups.size; val bw = slot * 0.6f
            groups.forEachIndexed { i, (_, v) ->
                val x = i * slot + (slot - bw) / 2
                val h1 = size.height * v.first / max; val h2 = size.height * v.second / max
                drawRect(Yellow, Offset(x, size.height - h1), Size(bw, h1))
                drawRect(TipGreen, Offset(x + bw * .2f, size.height - h2), Size(bw * .6f, h2))
            }
        }
        Row(Modifier.fillMaxWidth()) { groups.forEach { Text(it.first, Modifier.weight(1f), fontSize = 10.sp, maxLines = 1) } }
    }
}

fun group(h: List<HistoryVisit>, key: (HistoryVisit) -> Pair<Long, String>) =
    h.groupBy { key(it) }.toSortedMap(compareBy { it.first }).map { (k, v) -> k.second to (v.sumOf { it.tongTien } to v.sumOf { it.tip ?: 0 }) }

fun dailyGroups(w: Technician) = group(w.motTuanHistory) { val d = it.ngay.toLocalDate(); d.toEpochDay() to it.ngay.fmt("EEE") }
fun weeklyGroups(w: Technician) = group(w.thangHistory) { val d = it.ngay.toLocalDate(); (d.year * 100L + d.get(IsoFields.WEEK_OF_WEEK_BASED_YEAR)) to "W" + d.get(IsoFields.WEEK_OF_WEEK_BASED_YEAR) }
fun monthlyGroups(w: Technician) = group(w.namHistory) { val d = it.ngay.toLocalDate(); (d.year * 100L + d.monthValue) to it.ngay.fmt("MMM") }
fun yearlyGroups(w: Technician) = group(w.namHistory) { val d = it.ngay.toLocalDate(); d.year.toLong() to "${d.year}" }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EarnsScreen(vm: LedgerViewModel, w: Technician, openCharts: () -> Unit, openProfile: () -> Unit) {
    var from by remember { mutableStateOf(Clock.now()) }
    var to by remember { mutableStateOf(Clock.now()) }
    var saved by remember { mutableStateOf(false) }
    Scaffold(topBar = { TopAppBar(title = { Text("Summary!") }, actions = { IconButton(onClick = openProfile) { Icon(Icons.Filled.AccountBox, "Profile") } }) }) { pad ->
        LazyColumn(Modifier.padding(pad).padding(horizontal = 12.dp)) {
            item {
                Text("Review timeline:", fontWeight = FontWeight.Bold)
                DateTimeField("From", from, withTime = false) { from = it }
                DateTimeField("To", to, withTime = false) { to = it }
                Row { Text("Total Earnings: ${w.tongTien(from, to)}", color = Color(0xFFB8860B)); Spacer(Modifier.width(12.dp)); Text("Total tip: ${w.tongTip(from, to)}", color = TipGreen) }
                Spacer(Modifier.height(12.dp))
                Card(Modifier.fillMaxWidth().height(250.dp).clickable(onClick = openCharts)) {
                    if (w.motTuanHistory.isEmpty()) Column(Modifier.fillMaxSize(), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Filled.PieChart, null, tint = Yellow, modifier = Modifier.size(70.dp)); Text("Your daily chart show here!", color = Color.Gray) }
                    else BarChart(dailyGroups(w), Modifier.fillMaxSize().padding(12.dp))
                }
                Text("TODAY", Modifier.padding(top = 16.dp), color = Color.Gray)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("$ ${w.tongNgay()}", fontSize = 24.sp, modifier = Modifier.weight(1f))
                    IconButton(onClick = { vm.update { it.saveToday() }; saved = true }) { Icon(Icons.Filled.SaveAlt, "Save today") }
                }
                Text("DAYS WERE SAVED", Modifier.padding(top = 16.dp), color = Color.Gray)
            }
            items(w.weekEarn.filter { it.trongTuan }, key = { it.id }) { e ->
                ListItem(headlineContent = { Text(e.ngay.fmt("MMM d")) }, trailingContent = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Column(horizontalAlignment = Alignment.End) { Text("$ ${e.earn}", fontSize = 20.sp); Text("$ ${e.tip ?: 0}", color = TipGreen) }
                        IconButton(onClick = { vm.update { t -> t.copy(weekEarn = t.weekEarn.filter { it.id != e.id }) } }) { Icon(Icons.Filled.Delete, "Delete", tint = Color.Gray) }
                    } })
            }
        }
    }
    if (saved) AlertDialog(onDismissRequest = { saved = false }, title = { Text("Today have saved") }, confirmButton = { TextButton(onClick = { saved = false }) { Text("OK") } })
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChartsScreen(w: Technician, back: () -> Unit) {
    Scaffold(topBar = { TopAppBar(title = { Text("Charts") }, navigationIcon = { IconButton(onClick = back) { Icon(Icons.Filled.ArrowBack, "Back") } }) }) { pad ->
        Column(Modifier.padding(pad).verticalScroll(rememberScrollState()).padding(12.dp)) {
            listOf("Weekly Earns" to weeklyGroups(w), "Monthly Earns" to monthlyGroups(w), "Yearly" to yearlyGroups(w)).forEach { (t, g) ->
                Text(t, fontSize = 22.sp)
                if (g.isEmpty()) Text("No data yet", color = Color.Gray) else BarChart(g, Modifier.fillMaxWidth().height(260.dp))
                Spacer(Modifier.height(16.dp))
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(vm: LedgerViewModel, w: Technician, back: () -> Unit) {
    var editing by remember { mutableStateOf(false) }
    Scaffold(topBar = { TopAppBar(title = { Text("Info") }, navigationIcon = { IconButton(onClick = back) { Icon(Icons.Filled.ArrowBack, "Back") } },
        actions = { IconButton(onClick = { editing = true }) { Icon(Icons.Filled.Edit, "Edit profile") } }) }) { pad ->
        Column(Modifier.padding(pad).padding(16.dp)) {
            Text("PROFILE", color = Color.Gray)
            Text(w.name, fontSize = 22.sp)
            if (w.phone.isNotEmpty()) Text(correctPhone(w.phone))
            if (w.email.isNotEmpty()) Text(w.email)
            w.address?.let { Text(it.formattedMultiline, color = Color.Gray) }
            Spacer(Modifier.height(16.dp)); Text("YOU GAINED", color = Color.Gray); Text("${w.khach.size}  Clients")
        }
    }
    if (editing) {
        var phone by remember { mutableStateOf(w.phone) }; var email by remember { mutableStateOf(w.email) }
        var street by remember { mutableStateOf(w.address?.street ?: "") }; var alt by remember { mutableStateOf(w.address?.alternateStreet ?: "") }
        var city by remember { mutableStateOf(w.address?.city ?: "") }; var state by remember { mutableStateOf(w.address?.state ?: "") }
        var zip by remember { mutableStateOf(w.address?.zip ?: "") }
        val hasAddr = listOf(street, alt, city, state, zip).any { it.isNotBlank() }
        val complete = street.isNotBlank() && city.isNotBlank() && state.isNotBlank()
        val canSave = !emailIncomplete(email) && (complete || !hasAddr)
        AlertDialog(onDismissRequest = { editing = false }, title = { Text("Edit Profile") }, text = {
            Column(Modifier.verticalScroll(rememberScrollState())) {
                OutlinedTextField(phone, { phone = it }, label = { Text("Phone") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone))
                OutlinedTextField(email, { email = it }, label = { Text("Email") }, isError = emailIncomplete(email))
                if (emailIncomplete(email)) Text("Email incompleted!", color = Color.Red)
                OutlinedTextField(street, { street = it }, label = { Text("Street") }); OutlinedTextField(alt, { alt = it }, label = { Text("Street optionally") })
                OutlinedTextField(city, { city = it }, label = { Text("City") }); OutlinedTextField(state, { state = it }, label = { Text("State") })
                OutlinedTextField(zip, { zip = it }, label = { Text("Zip Code") })
                TextButton(onClick = { street = ""; alt = ""; city = ""; state = ""; zip = "" }) { Text("Clear address") }
            } },
            confirmButton = { Button(enabled = canSave, onClick = {
                vm.update { it.copy(phone = phone.trim(), email = email.trim(), address = if (complete) Address(street.trim(), alt.trim(), city.trim(), state.trim(), zip.trim()) else null) }
                editing = false }) { Text("Save") } },
            dismissButton = { TextButton(onClick = { editing = false }) { Text("Cancel") } })
    }
}

@Composable
fun WelcomeScreen(onDone: (String, String, String) -> Unit) {
    var n by remember { mutableStateOf("") }; var p by remember { mutableStateOf("") }; var e by remember { mutableStateOf("") }
    Column(Modifier.fillMaxSize().padding(24.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
        Text("Welcome to DayEarn", fontSize = 28.sp)
        OutlinedTextField(n, { n = it }, label = { Text("Your Name") })
        OutlinedTextField(p, { p = it }, label = { Text("Phone") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone))
        OutlinedTextField(e, { e = it }, label = { Text("someOne@vidu.com") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email))
        Spacer(Modifier.height(16.dp))
        Button(enabled = n.isNotBlank(), onClick = { onDone(n.trim(), p.trim(), e.trim()) }) { Text("Done") }
    }
}

package com.dayearns.app.ui

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.dayearns.app.model.*
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

val Yellow = Color(0xFFF4C430)
val Purple = Color(0xFF7B3FA0)
val TipGreen = Color(0xFF2E9E4F)

fun Long.fmt(p: String): String = toLdt().format(DateTimeFormatter.ofPattern(p))
fun Long.dayWeekday() = fmt("EEE d")
fun Long.full() = fmt("M/d/yyyy, h:mm a")

@Composable
fun DateTimeField(label: String, value: Long, withTime: Boolean = true, onChange: (Long) -> Unit) {
    val ctx = LocalContext.current
    val d = value.toLdt()
    Row(Modifier.fillMaxWidth().padding(vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(label, Modifier.weight(1f))
        AssistChip(onClick = {
            DatePickerDialog(ctx, { _, y, m, day -> onChange(LocalDateTime.of(y, m + 1, day, d.hour, d.minute).millis()) }, d.year, d.monthValue - 1, d.dayOfMonth).show()
        }, label = { Text(value.fmt("MMM d, yyyy")) })
        if (withTime) {
            Spacer(Modifier.width(6.dp))
            AssistChip(onClick = {
                TimePickerDialog(ctx, { _, h, min -> onChange(d.withHour(h).withMinute(min).withSecond(0).millis()) }, d.hour, d.minute, false).show()
            }, label = { Text(value.fmt("h:mm a")) })
        }
    }
}

@Composable
fun Stars(rating: Int, onChange: (Int) -> Unit) {
    Row {
        for (i in 1..5) Icon(if (i <= rating) Icons.Filled.Star else Icons.Outlined.StarOutline, null, tint = Yellow,
            modifier = Modifier.size(28.dp).clickable { onChange(if (i != rating) i else 0) })
    }
}

/** iOS ChonDichVu: grid of services to tap-add, tap header to clear, add new service inline. */
@Composable
fun ChonDichVu(services: List<Service>, picked: List<Service>, onPicked: (List<Service>) -> Unit, onNewService: (Service) -> Unit) {
    var name by remember { mutableStateOf("") }
    var price by remember { mutableStateOf("") }
    Column(Modifier.fillMaxWidth()) {
        TextButton(onClick = { onPicked(emptyList()) }) {
            Text(if (picked.isEmpty()) "Please Pick" else "UnPick--> " + picked.joinToString(", ") { it.dichVu })
        }
        // fixed-height grid inside a scrolling column
        val rows = (services.size + 2) / 3
        LazyVerticalGrid(GridCells.Fixed(3), Modifier.fillMaxWidth().height((rows * 84).dp), userScrollEnabled = false,
            horizontalArrangement = Arrangement.spacedBy(4.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            items(services, key = { it.id }) { s ->
                OutlinedCard(onClick = { onPicked(picked + s) }, Modifier.height(80.dp), border = BorderStroke(1.dp, Purple.copy(alpha = .25f))) {
                    Column(Modifier.fillMaxSize().padding(6.dp), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(s.dichVu, textAlign = TextAlign.Center, maxLines = 3, fontSize = 14.sp)
                        Text("$${s.gia}", fontWeight = FontWeight.SemiBold, fontSize = 12.sp)
                    }
                }
            }
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f).padding(end = 8.dp)) {
                OutlinedTextField(name, { name = it }, label = { Text("Service") }, singleLine = true)
                OutlinedTextField(price, { price = it.filter(Char::isDigit) }, label = { Text("Price") }, singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number))
            }
            Button(onClick = { val s = Service(dichVu = name.trim(), gia = price.toIntOrNull() ?: 0); onNewService(s); onPicked(picked + s); name = ""; price = "" },
                enabled = name.isNotBlank()) { Text("Add Service") }
        }
    }
}

@Composable
fun KhachRow(k: Khach, onClick: () -> Unit) {
    val highlight = k.today || k.isBirthday
    val color = if (highlight) Color(k.avatarColor) else Color.Gray
    Row(Modifier.fillMaxWidth().padding(horizontal = 8.dp, vertical = 4.dp).clip(RoundedCornerShape(10.dp))
        .background(color.copy(alpha = if (highlight) .1f else .05f)).clickable(onClick = onClick).padding(8.dp),
        verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(42.dp).clip(RoundedCornerShape(5.dp)).background(color), contentAlignment = Alignment.Center) {
            if (k.isBirthday) Icon(Icons.Filled.Cake, null, tint = Color.Green, modifier = Modifier.size(34.dp))
            else Text(k.name.take(1), color = Color.White, fontSize = 28.sp)
        }
        Spacer(Modifier.width(10.dp))
        Column(Modifier.weight(1f)) {
            Text(k.name, fontWeight = FontWeight.SemiBold, maxLines = 1, color = color)
            Text(correctPhone(k.sdt), style = MaterialTheme.typography.bodySmall, color = Color.Gray, maxLines = 1)
        }
        if (k.schedule) Icon(Icons.Filled.EventAvailable, null, tint = Purple, modifier = Modifier.size(16.dp))
        Text(if (k.today) k.ngay.fmt("h:mm a") else k.ngay.dayWeekday(),
            color = if (k.schedule) Purple else Color.Gray, fontSize = if (k.schedule) 20.sp else 12.sp)
    }
}

@Composable
fun InputDialog(title: String, label: String, number: Boolean = false, initial: String = "", onDismiss: () -> Unit, onDone: (String) -> Unit) {
    var t by remember { mutableStateOf(initial) }
    AlertDialog(onDismissRequest = onDismiss, title = { Text(title) },
        text = { OutlinedTextField(t, { t = if (number) it.filter(Char::isDigit) else it }, label = { Text(label) }, singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = if (number) KeyboardType.Number else KeyboardType.Text)) },
        confirmButton = { TextButton(onClick = { onDone(t); onDismiss() }) { Text("Done") } },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Cancel") } })
}

@Composable
fun MessageDialog(msg: String?, title: String = "", onDismiss: () -> Unit) {
    if (msg != null) AlertDialog(onDismissRequest = onDismiss, title = { if (title.isNotEmpty()) Text(title) }, text = { Text(msg) },
        confirmButton = { TextButton(onClick = onDismiss) { Text("OK") } })
}

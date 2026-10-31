package com.dayearns.app

import android.Manifest
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.dayearns.app.model.Technician
import com.dayearns.app.ui.*

class MainActivity : ComponentActivity() {
    private val vm: LedgerViewModel by viewModels()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Reminders.ensureChannel(this)
        setContent {
            val dark = isSystemInDarkTheme()
            MaterialTheme(colorScheme = if (dark) darkColorScheme(primary = Yellow, secondary = Purple) else lightColorScheme(primary = Purple, secondary = Yellow)) {
                Surface { App(vm) }
            }
        }
    }
    override fun onStop() { super.onStop(); vm.persistNow() }
}

@Composable
fun App(vm: LedgerViewModel) {
    val w by vm.worker.collectAsStateWithLifecycle()
    val loaded by vm.loaded.collectAsStateWithLifecycle()
    val err by vm.error.collectAsStateWithLifecycle()
    val perm = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) {}
    LaunchedEffect(Unit) { if (Build.VERSION.SDK_INT >= 33) perm.launch(Manifest.permission.POST_NOTIFICATIONS) }
    if (!loaded) return
    if (w.name.isEmpty()) { WelcomeScreen { n, p, e -> vm.update { Technician(name = n, phone = p, email = e) } }; return }
    val nav = rememberNavController()
    var tab by rememberSaveable { mutableIntStateOf(if (w.khach.any { it.haiNgay || it.isBirthday }) 0 else 1) }
    NavHost(nav, "tabs") {
        composable("tabs") {
            val party = w.khach.any { it.isBirthday }
            Scaffold(bottomBar = { NavigationBar {
                NavigationBarItem(tab == 0, { tab = 0 }, { Icon(if (party) Icons.Filled.Cake else Icons.Filled.Schedule, null) }, label = { Text(if (party) "Party" else "Schedule") })
                NavigationBarItem(tab == 1, { tab = 1 }, { Icon(Icons.Filled.Contacts, null) }, label = { Text("Clients") })
                NavigationBarItem(tab == 2, { tab = 2 }, { Icon(Icons.Filled.List, null) }, label = { Text("Services") })
                NavigationBarItem(tab == 3, { tab = 3 }, { Icon(Icons.Filled.Receipt, null) }, label = { Text("Earns") })
            } }) { pad ->
                androidx.compose.foundation.layout.Box(Modifier.padding(pad)) {
                    val open: (String) -> Unit = { nav.navigate("client/$it") }
                    when (tab) {
                        0 -> ScheduleScreen(vm, w, open)
                        1 -> ClientListScreen(vm, w, open)
                        2 -> ServicesScreen(vm, w)
                        else -> EarnsScreen(vm, w, { nav.navigate("charts") }, { nav.navigate("profile") })
                    }
                }
            }
        }
        composable("client/{id}") { ClientDetailScreen(vm, w, it.arguments!!.getString("id")!!, { nav.popBackStack() }) { r -> nav.navigate(r) } }
        composable("history/{id}") { b -> HistoriesScreen(w.khach.firstOrNull { it.id == b.arguments!!.getString("id") }) { nav.popBackStack() } }
        composable("receipt/{id}") { b -> ReceiptScreen(w, w.khach.firstOrNull { it.id == b.arguments!!.getString("id") }) { nav.popBackStack() } }
        composable("charts") { ChartsScreen(w) { nav.popBackStack() } }
        composable("profile") { ProfileScreen(vm, w) { nav.popBackStack() } }
    }
    MessageDialog(err, "Save Error") { vm.error.value = null }
}

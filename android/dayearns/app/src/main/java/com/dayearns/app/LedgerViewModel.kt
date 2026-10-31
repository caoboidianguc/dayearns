package com.dayearns.app

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.dayearns.app.data.LedgerDb
import com.dayearns.app.data.LedgerRepository
import com.dayearns.app.model.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class LedgerViewModel(app: Application) : AndroidViewModel(app) {
    private val repo = LedgerRepository(LedgerDb.get(app).dao())
    private val _worker = MutableStateFlow(Technician(name = "", phone = ""))
    val worker = _worker.asStateFlow()
    val loaded = MutableStateFlow(false)
    val error = MutableStateFlow<String?>(null)
    private var saveJob: Job? = null

    init {
        viewModelScope.launch(Dispatchers.IO) {
            try { repo.load()?.let { _worker.value = it } } catch (e: Exception) { error.value = "Could not load your saved data." }
            loaded.value = true
            Reminders.reschedule(getApplication(), _worker.value.khach)
        }
    }

    /** Apply a change and auto-save to Room (debounced). */
    fun update(f: (Technician) -> Technician) {
        _worker.value = f(_worker.value)
        saveJob?.cancel()
        saveJob = viewModelScope.launch(Dispatchers.IO) { delay(300); persist() }
    }

    fun updateClient(id: String, f: (Khach) -> Khach) = update { w -> w.copy(khach = w.khach.map { if (it.id == id) f(it) else it }) }

    suspend fun persist() {
        try { repo.save(_worker.value); Reminders.reschedule(getApplication(), _worker.value.khach) }
        catch (e: Exception) { error.value = "Could not save your data. Please try again." }
    }
    fun persistNow() { viewModelScope.launch(Dispatchers.IO) { persist() } }

    fun importClients(csv: String): String = try {
        val (w, r) = ClientCsvImporter.importCsv(csv, _worker.value)
        if (r.added > 0) update { w }
        ClientCsvImporter.summary(r)
    } catch (e: ClientCsvException) { e.message ?: "Import failed." }
}

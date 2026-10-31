package com.dayearns.app

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.dayearns.app.model.*
import java.time.LocalDate
import java.time.LocalTime

/** Appointment reminder 15 min before, and birthday at 8:00 (like iOS). */
object Reminders {
    private const val CHANNEL = "dayearns"
    private const val PREFS = "reminders"

    fun reschedule(ctx: Context, clients: List<Khach>) {
        val am = ctx.getSystemService(AlarmManager::class.java)
        val prefs = ctx.getSharedPreferences(PREFS, 0)
        prefs.getStringSet("codes", emptySet())!!.forEach { am.cancel(pi(ctx, it.toInt(), "", "")) }
        val codes = mutableSetOf<String>()
        val now = Clock.now()
        clients.filter { it.schedule }.forEach { c ->
            val at = c.ngay - 15 * 60_000
            if (at > now) { val code = ("a" + c.id).hashCode(); codes += "$code"
                am.set(AlarmManager.RTC_WAKEUP, at, pi(ctx, code, "Appointment Reminder", "With ${c.name} in 15 minutes.")) }
        }
        clients.forEach { c ->
            val b = c.birthDay ?: return@forEach
            val bd = b.toLocalDate(); val today = LocalDate.now()
            var next = runCatching { bd.withYear(today.year) }.getOrElse { LocalDate.of(today.year, 3, 1) }.atTime(LocalTime.of(8, 0))
            if (next.millis() <= now) next = next.plusYears(1)
            val code = ("b" + c.id).hashCode(); codes += "$code"
            am.set(AlarmManager.RTC_WAKEUP, next.millis(), pi(ctx, code, "Happy Birthday!", "${c.name}'s birthday is today!"))
        }
        prefs.edit().putStringSet("codes", codes).apply()
    }

    private fun pi(ctx: Context, code: Int, title: String, body: String): PendingIntent {
        val i = Intent(ctx, ReminderReceiver::class.java).putExtra("title", title).putExtra("body", body).putExtra("code", code)
        return PendingIntent.getBroadcast(ctx, code, i, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }

    fun ensureChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT >= 26) ctx.getSystemService(NotificationManager::class.java)
            .createNotificationChannel(NotificationChannel(CHANNEL, "Reminders", NotificationManager.IMPORTANCE_HIGH))
    }

    fun show(ctx: Context, code: Int, title: String, body: String) {
        ensureChannel(ctx)
        val open = PendingIntent.getActivity(ctx, 0, Intent(ctx, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE)
        val n = NotificationCompat.Builder(ctx, CHANNEL).setSmallIcon(R.drawable.ic_stat).setContentTitle(title)
            .setContentText(body).setAutoCancel(true).setContentIntent(open).build()
        try { NotificationManagerCompat.from(ctx).notify(code, n) } catch (_: SecurityException) {}
    }
}

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: return
        if (title.isEmpty()) return
        Reminders.show(ctx, intent.getIntExtra("code", 0), title, intent.getStringExtra("body") ?: "")
    }
}

/** Re-arm alarms after reboot by loading the ledger. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        val pending = goAsync()
        Thread {
            kotlinx.coroutines.runBlocking {
                runCatching { com.dayearns.app.data.LedgerRepository(com.dayearns.app.data.LedgerDb.get(ctx).dao()).load() }
                    .getOrNull()?.let { Reminders.reschedule(ctx, it.khach) }
            }
            pending.finish()
        }.start()
    }
}

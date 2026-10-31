package com.dayearns.app.data

import android.content.Context
import androidx.room.*
import com.dayearns.app.model.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

private val json = Json { ignoreUnknownKeys = true }

@Entity(tableName = "technician")
data class TechEntity(@PrimaryKey val id: String, val name: String, val phone: String, val email: String, val addressJson: String?)

@Entity(tableName = "services")
data class ServiceEntity(@PrimaryKey val id: String, val position: Int, val name: String, val price: Int)

@Entity(tableName = "clients")
data class ClientEntity(
    @PrimaryKey val id: String, val position: Int, val name: String, val phone: String, val note: String,
    val points: Int, val servicesJson: String, val visitAt: Long, val rating: Int, val email: String,
    val firstCome: Long, val isNew: Boolean, val tip: Int?, val tag: String?, val birthDay: Long?,
    val historiesJson: String, val addressJson: String?,
)

@Entity(tableName = "week_earns")
data class WeekEarnEntity(@PrimaryKey val id: String, val position: Int, val ngay: Long, val earn: Int, val tip: Int?)

@Dao
interface LedgerDao {
    @Query("SELECT * FROM technician LIMIT 1") suspend fun tech(): TechEntity?
    @Query("SELECT * FROM services ORDER BY position") suspend fun services(): List<ServiceEntity>
    @Query("SELECT * FROM clients ORDER BY position") suspend fun clients(): List<ClientEntity>
    @Query("SELECT * FROM week_earns ORDER BY position") suspend fun weekEarns(): List<WeekEarnEntity>
    @Query("DELETE FROM technician") suspend fun clearTech()
    @Query("DELETE FROM services") suspend fun clearServices()
    @Query("DELETE FROM clients") suspend fun clearClients()
    @Query("DELETE FROM week_earns") suspend fun clearWeek()
    @Insert suspend fun insertTech(t: TechEntity)
    @Insert suspend fun insertServices(s: List<ServiceEntity>)
    @Insert suspend fun insertClients(c: List<ClientEntity>)
    @Insert suspend fun insertWeek(w: List<WeekEarnEntity>)

    @Transaction
    suspend fun replaceAll(t: TechEntity, s: List<ServiceEntity>, c: List<ClientEntity>, w: List<WeekEarnEntity>) {
        clearTech(); clearServices(); clearClients(); clearWeek()
        insertTech(t); insertServices(s); insertClients(c); insertWeek(w)
    }
}

@Database(entities = [TechEntity::class, ServiceEntity::class, ClientEntity::class, WeekEarnEntity::class], version = 1, exportSchema = false)
abstract class LedgerDb : RoomDatabase() {
    abstract fun dao(): LedgerDao
    companion object {
        @Volatile private var inst: LedgerDb? = null
        fun get(ctx: Context) = inst ?: synchronized(this) {
            inst ?: Room.databaseBuilder(ctx.applicationContext, LedgerDb::class.java, "dayearns.db").build().also { inst = it }
        }
    }
}

/** Saves/loads the whole Technician ledger to the on-device Room database. */
class LedgerRepository(private val dao: LedgerDao) {
    suspend fun load(): Technician? {
        val t = dao.tech() ?: return null
        return Technician(
            id = t.id, name = t.name, phone = t.phone, email = t.email,
            address = t.addressJson?.let { json.decodeFromString<Address>(it) },
            services = dao.services().map { Service(it.id, it.name, it.price) },
            khach = dao.clients().map {
                Khach(it.id, it.name, it.phone, it.note, it.points, json.decodeFromString(it.servicesJson), it.visitAt,
                    it.rating, it.email, it.firstCome, it.isNew, it.tip, it.tag, it.birthDay,
                    json.decodeFromString(it.historiesJson), it.addressJson?.let { a -> json.decodeFromString<Address>(a) })
            },
            weekEarn = dao.weekEarns().map { WeekEarn(it.id, it.ngay, it.earn, it.tip) },
        )
    }
    suspend fun save(w: Technician) {
        dao.replaceAll(
            TechEntity(w.id, w.name, w.phone, w.email, w.address?.let { json.encodeToString(it) }),
            w.services.mapIndexed { i, s -> ServiceEntity(s.id, i, s.dichVu, s.gia) },
            w.khach.mapIndexed { i, k -> ClientEntity(k.id, i, k.name, k.sdt, k.desc, k.diem, json.encodeToString(k.dvDone), k.ngay,
                k.danhGia, k.email, k.firstCome, k.isNew, k.tip, k.tag, k.birthDay, json.encodeToString(k.histories), k.address?.let { json.encodeToString(it) }) },
            w.weekEarn.mapIndexed { i, e -> WeekEarnEntity(e.id, i, e.ngay, e.earn, e.tip) },
        )
    }
}

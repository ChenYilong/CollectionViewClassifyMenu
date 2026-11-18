package com.cyl.classifymenu

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * `CYLTagListCachePolicy`: where `CYLTagListView` keeps the titles of its edited sections (`cachePolicy`), so an order
 * changed in editing mode (a drag), a deleted tag or an added one survives a relaunch.
 */
enum class CYLTagListCachePolicy {
    /** No cache (the default of `CYLTagListView`): edits live as long as the host's data. */
    CYLTagListCachePolicyNone,

    /** A SQLite database of the app (`tags.sqlite`). */
    CYLTagListCachePolicyDatabase,

    /** `NSUserDefaults` on iOS; the app's `SharedPreferences` here. */
    CYLTagListCachePolicyUserDefaults,

    /** A JSON file in the app's sandbox (its files folder). */
    CYLTagListCachePolicySandboxFile,
}

/**
 * `CYLTagListCache`: a store of the ordered titles of a tag list's sections. `CYLTagListView` makes the built-in store
 * of its `cachePolicy`; implement this interface and set `CYLTagListView.cache` to use another store.
 */
interface CYLTagListCache {
    /** `cachedTitlesForSection:`: the titles saved for `section`, in order; null when nothing was saved for it. */
    fun cachedTitlesForSection(section: String): List<String>?

    /** `saveTitles:forSection:`: saves `titles` (in this order) as the contents of `section`, replacing what was saved. */
    fun saveTitles(titles: List<String>, forSection: String)

    /** `removeTitlesForSection:`: removes what was saved for `section`. */
    fun removeTitlesForSection(section: String)

    /** `removeAllTitles`: removes every section of this cache. */
    fun removeAllTitles()
}

/**
 * `CYLTagListStore`: the built-in caches (a database, `SharedPreferences` or a file) behind one class, as iOS.
 * `name` separates the caches of different lists (the database key, the preferences key or the file name).
 * Android needs a `Context` for its storage; iOS uses the app's own folders.
 */
class CYLTagListStore(context: Context, val policy: CYLTagListCachePolicy, name: String) : CYLTagListCache {
    /** Separates the caches of different lists ("CYLTagListView" when empty). */
    val name: String = name.ifEmpty { "CYLTagListView" }

    private val appContext: Context = context.applicationContext ?: context
    private val memory = HashMap<String, List<String>>()
    private val database: SQLiteDatabase? =
        if (policy == CYLTagListCachePolicy.CYLTagListCachePolicyDatabase) openDatabase() else null

    companion object {
        /** `+cacheWithPolicy:name:`: the store for `policy` and `name`; null for `CYLTagListCachePolicyNone`. */
        @JvmStatic
        fun cacheWithPolicy(context: Context, policy: CYLTagListCachePolicy, name: String): CYLTagListStore? =
            if (policy == CYLTagListCachePolicy.CYLTagListCachePolicyNone) null else CYLTagListStore(context, policy, name)

        private const val DATABASE_NAME = "CollectionViewClassifyMenu-tags.sqlite"
        private const val PREFERENCES_NAME = "CYLTagListCache"
    }

    // MARK: - CYLTagListCache

    override fun cachedTitlesForSection(section: String): List<String>? = when (policy) {
        CYLTagListCachePolicy.CYLTagListCachePolicyNone -> null
        CYLTagListCachePolicy.CYLTagListCachePolicyDatabase -> if (database == null) memory[section] else databaseTitles(section)
        CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults -> preferencesContents()[section]
        CYLTagListCachePolicy.CYLTagListCachePolicySandboxFile -> fileContents()[section]
    }

    override fun saveTitles(titles: List<String>, forSection: String) {
        when (policy) {
            CYLTagListCachePolicy.CYLTagListCachePolicyNone -> return
            CYLTagListCachePolicy.CYLTagListCachePolicyDatabase -> {
                val db = database ?: run { memory[forSection] = titles.toList(); return }
                db.beginTransaction()
                try {
                    db.delete("tags", "list = ? AND section = ?", arrayOf(name, forSection))
                    // An empty section is a row with a NULL title, so "saved, empty" differs from "never saved".
                    if (titles.isEmpty()) db.insert("tags", null, row(forSection, 0, null))
                    titles.forEachIndexed { position, title -> db.insert("tags", null, row(forSection, position, title)) }
                    db.setTransactionSuccessful()
                } finally {
                    db.endTransaction()
                }
            }
            CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults ->
                writePreferences(preferencesContents().toMutableMap().apply { put(forSection, titles.toList()) })
            CYLTagListCachePolicy.CYLTagListCachePolicySandboxFile ->
                writeFile(fileContents().toMutableMap().apply { put(forSection, titles.toList()) })
        }
    }

    override fun removeTitlesForSection(section: String) {
        when (policy) {
            CYLTagListCachePolicy.CYLTagListCachePolicyNone -> return
            CYLTagListCachePolicy.CYLTagListCachePolicyDatabase ->
                database?.delete("tags", "list = ? AND section = ?", arrayOf(name, section)) ?: memory.remove(section)
            CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults ->
                writePreferences(preferencesContents().toMutableMap().apply { remove(section) })
            CYLTagListCachePolicy.CYLTagListCachePolicySandboxFile ->
                writeFile(fileContents().toMutableMap().apply { remove(section) })
        }
    }

    override fun removeAllTitles() {
        when (policy) {
            CYLTagListCachePolicy.CYLTagListCachePolicyNone -> return
            CYLTagListCachePolicy.CYLTagListCachePolicyDatabase -> {
                memory.clear()
                database?.delete("tags", "list = ?", arrayOf(name))
            }
            CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults ->
                appContext.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE).edit().remove(preferencesKey).apply()
            CYLTagListCachePolicy.CYLTagListCachePolicySandboxFile -> fileURL.delete()
        }
    }

    // MARK: - Storage

    private val preferencesKey: String get() = "CYLTagListCache.$name"

    private val fileURL: File
        get() {
            val folder = File(appContext.filesDir, "CollectionViewClassifyMenu").apply { mkdirs() }
            val safe = name.map { if (it.isLetterOrDigit()) it else '_' }.joinToString("")
            return File(folder, "tags-$safe.json")
        }

    private fun decode(text: String?): Map<String, List<String>> {
        if (text.isNullOrEmpty()) return emptyMap()
        return try {
            val json = JSONObject(text)
            json.keys().asSequence().associateWith { key ->
                val array = json.optJSONArray(key) ?: JSONArray()
                (0 until array.length()).map { array.getString(it) }
            }
        } catch (e: Exception) {
            emptyMap()
        }
    }

    private fun encode(contents: Map<String, List<String>>): String =
        JSONObject().apply { contents.forEach { (key, titles) -> put(key, JSONArray(titles)) } }.toString()

    private fun preferencesContents(): Map<String, List<String>> =
        decode(appContext.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE).getString(preferencesKey, null))

    private fun writePreferences(contents: Map<String, List<String>>) {
        appContext.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE).edit().putString(preferencesKey, encode(contents)).apply()
    }

    private fun fileContents(): Map<String, List<String>> = decode(if (fileURL.exists()) fileURL.readText() else null)

    private fun writeFile(contents: Map<String, List<String>>) {
        val file = fileURL
        val temporary = File(file.parentFile, file.name + ".tmp")
        temporary.writeText(encode(contents))
        if (!temporary.renameTo(file)) {
            file.writeText(encode(contents))
            temporary.delete()
        }
    }

    private fun row(section: String, position: Int, title: String?) = ContentValues().apply {
        put("list", name)
        put("section", section)
        put("position", position)
        if (title == null) putNull("title") else put("title", title)
    }

    private fun openDatabase(): SQLiteDatabase? = try {
        object : SQLiteOpenHelper(appContext, DATABASE_NAME, null, 1) {
            override fun onCreate(db: SQLiteDatabase) {
                db.execSQL("CREATE TABLE IF NOT EXISTS tags (list TEXT NOT NULL, section TEXT NOT NULL, position INTEGER NOT NULL, " +
                    "title TEXT, PRIMARY KEY (list, section, position))")
            }

            override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
        }.writableDatabase
    } catch (e: Exception) {
        // Without a database the store keeps the titles in memory, as iOS when sqlite3_open fails.
        null
    }

    private fun databaseTitles(section: String): List<String>? {
        val db = database ?: return memory[section]
        db.rawQuery("SELECT title FROM tags WHERE list = ? AND section = ? ORDER BY position", arrayOf(name, section)).use { cursor ->
            if (cursor.count == 0) return null
            val titles = ArrayList<String>()
            while (cursor.moveToNext()) {
                if (!cursor.isNull(0)) titles.add(cursor.getString(0))
            }
            return titles
        }
    }
}

// MARK: - Network sync

/**
 * `CYLTagListLoadPolicy`: in what order `CYLTagListView.loadSectionsWithKeys` reads the cache and the remote source.
 * Unlike a search suggestion cache, a tag list may be kept on a server and edited on several devices.
 */
enum class CYLTagListLoadPolicy {
    /** The cache at once, then the remote source; a successful download is saved and reported again (the default). */
    CYLTagListLoadPolicyCacheThenNetwork,

    /** The cache when it holds every section asked for; otherwise the remote source (the cache if that fails). */
    CYLTagListLoadPolicyCacheFirst,

    /** The remote source; the cache only when the download fails. */
    CYLTagListLoadPolicyNetworkFirst,
}

/** `CYLTagListDataOrigin`: where the titles reported by `CYLTagListView.loadSectionsWithKeys` come from. */
enum class CYLTagListDataOrigin {
    /** The local cache (`CYLTagListView.cache`). */
    CYLTagListDataOriginCache,

    /** The remote source (`CYLTagListView.remoteSource`). */
    CYLTagListDataOriginNetwork,
}

/**
 * `CYLTagListRemoteSource`: a server that keeps a tag list's sections, shared by the user's devices. The host implements
 * it with its own networking; `CYLTagListView` only asks it for sections (`loadSectionsWithKeys`). Uploading is the
 * host's too: `menuDidFinishEditingWithTitles` / `editingFinishHandler` give it the edited sections.
 */
interface CYLTagListRemoteSource {
    /**
     * `fetchSectionsWithKeys:completion:`: downloads the sections saved under `keys`; calls `completion` once, on any
     * thread, with the titles by key (a missing key: nothing on the server) or an error.
     */
    fun fetchSectionsWithKeys(keys: List<String>, completion: (Map<String, List<String>>?, Throwable?) -> Unit)
}

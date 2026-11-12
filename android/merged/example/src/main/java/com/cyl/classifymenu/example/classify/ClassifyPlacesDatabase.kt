package com.cyl.classifymenu.example.classify

import android.content.Context
import android.database.sqlite.SQLiteDatabase

/**
 * A query and its arguments (`CYLExampleSQLQuery`).
 */
data class ClassifySQLQuery(val sql: String, val arguments: List<String>) {
    /**
     * `-displayString`: the statement with its arguments inlined, quoted, for display.
     */
    fun displayString(): String {
        val parts = sql.split("?")
        return buildString {
            parts.forEachIndexed { index, part ->
                append(part)
                if (index + 1 < parts.size) append("'").append(arguments.getOrElse(index) { "" }.replace("'", "''")).append("'")
            }
        }
    }
}

/**
 * The local SQLite database of the Classify demo: the shared example database of every platform,
 * `Example-Shared/Database/cyl_places.sqlite` (bundled as an asset, made by `scripts/generate-places-db.py` from the
 * demo data), copied once to the app's databases folder and opened read-only. The iOS demo app reads the same file.
 */
class ClassifyPlacesDatabase(context: Context) {
    private val database: SQLiteDatabase

    init {
        val appContext = context.applicationContext
        val file = appContext.getDatabasePath(FILE_NAME)
        // The bundled file wins: it is copied again whenever it differs (a new app version with new data).
        val bundled = appContext.assets.open(FILE_NAME).use { it.readBytes() }
        if (!file.exists() || !file.readBytes().contentEquals(bundled)) {
            file.parentFile?.mkdirs()
            file.writeBytes(bundled)
        }
        database = SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READONLY)
    }

    /**
     * Closes the database.
     */
    fun close() = database.close()

    /**
     * The rows of `query`: name, category, tag, region, rating, price.
     */
    fun rows(query: ClassifySQLQuery): List<Map<String, Any>> = database.rawQuery(query.sql, query.arguments.toTypedArray()).use { cursor ->
        val rows = ArrayList<Map<String, Any>>()
        while (cursor.moveToNext()) {
            rows.add(mapOf(
                "name" to cursor.getString(0), "category" to cursor.getString(1), "tag" to cursor.getString(2),
                "region" to cursor.getString(3), "rating" to cursor.getDouble(4), "price" to cursor.getInt(5),
            ))
        }
        rows
    }

    /**
     * The rows of any statement, as column → value (Long, Double, String or null).
     */
    fun rowsOf(sql: String, arguments: List<String> = emptyList()): List<Map<String, Any?>> = database.rawQuery(sql, arguments.toTypedArray()).use { cursor ->
        val rows = ArrayList<Map<String, Any?>>()
        while (cursor.moveToNext()) {
            rows.add((0 until cursor.columnCount).associate { index ->
                cursor.getColumnName(index) to when (cursor.getType(index)) {
                    android.database.Cursor.FIELD_TYPE_INTEGER -> cursor.getLong(index)
                    android.database.Cursor.FIELD_TYPE_FLOAT -> cursor.getDouble(index)
                    android.database.Cursor.FIELD_TYPE_NULL -> null
                    else -> cursor.getString(index)
                }
            })
        }
        rows
    }

    /**
     * The number of rows of `table`.
     */
    fun countOfTable(table: String): Int = database.rawQuery("SELECT COUNT(*) FROM $table", null).use { if (it.moveToFirst()) it.getInt(0) else 0 }

    companion object {
        /**
         * The shared database file (an asset).
         */
        const val FILE_NAME = "cyl_places.sqlite"

        /**
         * `+queryForTag:regions:dishes:` of the iOS menu linkage: tag = ?, region IN (…), tag IN (…), by rating.
         */
        fun query(tag: String?, regions: List<String>, dishes: List<String>): ClassifySQLQuery {
            val conditions = ArrayList<String>()
            val arguments = ArrayList<String>()
            if (!tag.isNullOrEmpty()) {
                conditions.add("tag = ?")
                arguments.add(tag)
            }
            for ((column, values) in listOf("region" to regions, "tag" to dishes)) {
                if (values.isEmpty()) continue
                conditions.add("$column IN (${values.joinToString(", ") { "?" }})")
                arguments.addAll(values)
            }
            var sql = "SELECT name, category, tag, region, rating, price FROM places"
            if (conditions.isNotEmpty()) sql += " WHERE ${conditions.joinToString(" AND ")}"
            return ClassifySQLQuery("$sql ORDER BY rating DESC, id", arguments)
        }
    }
}

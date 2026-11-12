package com.cyl.classifymenu.example.classify

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import com.cyl.classifymenu.kDataSourceCellTextKey
import com.cyl.classifymenu.kDataSourceSectionKey

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
 * The local SQLite database of the Classify demo: the `places` table of the iOS example's `CYLExampleDatabase`, made
 * the same way from the demo data (every tag in some of the filter's regions, same names, ratings and prices), and
 * the saved selections.
 */
class ClassifyPlacesDatabase(context: Context) : SQLiteOpenHelper(context.applicationContext, "classify_places.sqlite", null, 1) {
    private val appContext = context.applicationContext

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL("CREATE TABLE places (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL, tag TEXT NOT NULL, region TEXT NOT NULL, rating REAL NOT NULL, price INTEGER NOT NULL)")
        db.execSQL("CREATE INDEX places_tag ON places(tag)")
        db.execSQL("CREATE INDEX places_region ON places(region)")
        db.execSQL("CREATE TABLE selections (scenario TEXT NOT NULL, section INTEGER NOT NULL, item INTEGER NOT NULL)")
        db.beginTransaction()
        try {
            val regions = ClassifyDemoDataSource.regions()
            var placeID = 0
            var tagIndex = 0
            for (category in ClassifyDemoDatabase.dataSource(appContext)) {
                val type = category[ClassifyDemoDataSource.SECTION_TITLE_KEY] as? String ?: ""
                @Suppress("UNCHECKED_CAST")
                val items = category[kDataSourceSectionKey] as? List<Map<String, Any?>> ?: emptyList()
                for (item in items) {
                    val tag = item[kDataSourceCellTextKey] as? String ?: ""
                    regions.forEachIndexed { region, regionName ->
                        if ((tagIndex + region) % 3 == 2) return@forEachIndexed
                        val rating = 3.5 + ((tagIndex * 7 + region * 3) % 16) / 10.0
                        val price = 30 + ((tagIndex * 37 + region * 53) % 270)
                        val name = "${ClassifyDemoDataSource.shortTitle(tag)} · ${ClassifyDemoDataSource.shortTitle(regionName)}"
                        db.execSQL("INSERT INTO places VALUES (?, ?, ?, ?, ?, ?, ?)", arrayOf<Any>(placeID, name, type, tag, regionName, rating, price))
                        placeID++
                    }
                    tagIndex++
                }
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS places")
        db.execSQL("DROP TABLE IF EXISTS selections")
        onCreate(db)
    }

    /**
     * The rows of `query`: name, category, tag, region, rating, price.
     */
    fun rows(query: ClassifySQLQuery): List<Map<String, Any>> = readableDatabase.rawQuery(query.sql, query.arguments.toTypedArray()).use { cursor ->
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
     * The number of rows of `table`.
     */
    fun countOfTable(table: String): Int = readableDatabase.rawQuery("SELECT COUNT(*) FROM $table", null).use { if (it.moveToFirst()) it.getInt(0) else 0 }

    companion object {
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

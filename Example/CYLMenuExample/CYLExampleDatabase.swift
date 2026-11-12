//
//  CYLExampleDatabase.swift
//  CYLMenuExample
//
//  The Example's SQLite database (libsqlite3 of the iOS SDK), so that every filter demo runs the
//  whole chain: tags selected → SQL built from them → query → list refreshed. It holds
//  - reviews / review_keywords: the reviews of scenario 1 (CYLReviewStore);
//  - places: shops and venues for the classify menu demo ported from CollectionViewClassifyMenu's
//    original app (its data.json categories and tags, and the regions of its filter);
//  - selections: the conditions each demo last confirmed, restored when it opens again.
//  The tables are filled again at every launch from the in-app data; selections are kept.
//

import Foundation
import SQLite3
import CollectionViewClassifyMenu

let CYLExampleDatabaseErrorDomain = "CYLExampleDatabaseErrorDomain"

/// SQLite's SQLITE_TRANSIENT: the text is copied before sqlite3_bind_text returns.
private let CYLSQLiteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// A statement and the values bound to its "?" placeholders, as shown to the user.
@objcMembers
final class CYLExampleSQLQuery: NSObject {
    let sql: String
    /// NSString / String, NSNumber / numbers, or NSNull.
    let arguments: [Any]

    init(sql: String, arguments: [Any]? = nil) {
        self.sql = sql
        self.arguments = arguments ?? []
        super.init()
    }

    /// The SQL with each "?" replaced by its value ('text', numbers as is), for display only.
    func displayString() -> String {
        let parts = sql.components(separatedBy: "?")
        var result = ""
        for (index, part) in parts.enumerated() {
            result += part
            guard index + 1 < parts.count else { break }
            let value: Any = index < arguments.count ? arguments[index] : NSNull()
            if let text = value as? String {
                result += "'\(text.replacingOccurrences(of: "'", with: "''"))'"
            } else if let number = value as? NSNumber {
                result += number.stringValue
            } else {
                result += "NULL"
            }
        }
        return result
    }
}

@objcMembers
final class CYLExampleDatabase: NSObject {

    private static let sharedInstance: CYLExampleDatabase = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let path = caches.appendingPathComponent("CYLMenuExample.sqlite").path
        do {
            return try CYLExampleDatabase(path: path)
        } catch {
            NSLog("[CYLMenuExample] Cannot open %@ (%@), using an in-memory database.", path, String(describing: error))
            // An in-memory database can always be opened and filled.
            return try! CYLExampleDatabase(path: ":memory:")
        }
    }()

    /// The Example's database, opened and filled on first use.
    static func shared() -> CYLExampleDatabase {
        sharedInstance
    }

    /// The same as shared() (the Objective-C name).
    @nonobjc static var sharedDatabase: CYLExampleDatabase {
        sharedInstance
    }

    let path: String
    private var handle: OpaquePointer?

    /// A database at `path` (":memory:" for an in-memory one), filled with the Example's data.
    init(path: String) throws {
        self.path = path
        super.init()
        if sqlite3_open_v2(path, &handle, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) != SQLITE_OK {
            let error = lastError()
            sqlite3_close(handle)
            handle = nil
            throw error
        }
        try createTables()
        try fillTables()
    }

    deinit {
        if let handle {
            sqlite3_close(handle)
        }
    }

    func lastError() -> NSError {
        let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "cannot open the database"
        let code = handle.map { Int(sqlite3_errcode($0)) } ?? Int(SQLITE_CANTOPEN)
        return NSError(domain: CYLExampleDatabaseErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }

    // MARK: Statements

    private func preparedStatement(_ sql: String, arguments: [Any]?) throws -> OpaquePointer {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK, let prepared = statement else {
            throw lastError()
        }
        for (offset, value) in (arguments ?? []).enumerated() {
            let index = Int32(offset + 1)
            let result: Int32
            if let text = value as? String {
                result = sqlite3_bind_text(prepared, index, text, -1, CYLSQLiteTransient)
            } else if let number = value as? NSNumber {
                let type = String(cString: number.objCType)
                let floating = type == "d" || type == "f"
                result = floating ? sqlite3_bind_double(prepared, index, number.doubleValue)
                                  : sqlite3_bind_int64(prepared, index, number.int64Value)
            } else {
                result = sqlite3_bind_null(prepared, index)
            }
            if result != SQLITE_OK {
                let error = lastError()
                sqlite3_finalize(prepared)
                throw error
            }
        }
        return prepared
    }

    /// Runs a statement that returns no rows. Arguments: String, NSNumber (or numbers) or NSNull.
    func executeSQL(_ sql: String, arguments: [Any]? = nil) throws {
        let statement = try preparedStatement(sql, arguments: arguments)
        let result = sqlite3_step(statement)
        sqlite3_finalize(statement)
        if result != SQLITE_DONE && result != SQLITE_ROW {
            throw lastError()
        }
    }

    /// Rows of a SELECT, one dictionary per row (column name → String, NSNumber or NSNull).
    func rows(forSQL sql: String, arguments: [Any]? = nil) throws -> [[String: Any]] {
        let statement = try preparedStatement(sql, arguments: arguments)
        defer { sqlite3_finalize(statement) }
        var rows: [[String: Any]] = []
        var result = sqlite3_step(statement)
        while result == SQLITE_ROW {
            var row: [String: Any] = [:]
            for column in 0..<sqlite3_column_count(statement) {
                let name = String(cString: sqlite3_column_name(statement, column))
                switch sqlite3_column_type(statement, column) {
                case SQLITE_INTEGER: row[name] = NSNumber(value: sqlite3_column_int64(statement, column))
                case SQLITE_FLOAT: row[name] = NSNumber(value: sqlite3_column_double(statement, column))
                case SQLITE_TEXT: row[name] = sqlite3_column_text(statement, column).map { String(cString: $0) } ?? ""
                default: row[name] = NSNull()
                }
            }
            rows.append(row)
            result = sqlite3_step(statement)
        }
        if result != SQLITE_DONE {
            throw lastError()
        }
        return rows
    }

    /// The same as rows(forSQL:arguments:) (the spelling of the Objective-C selector).
    @nonobjc func rowsForSQL(_ sql: String, arguments: [Any]? = nil) throws -> [[String: Any]] {
        try rows(forSQL: sql, arguments: arguments)
    }

    func rows(for query: CYLExampleSQLQuery) throws -> [[String: Any]] {
        try rows(forSQL: query.sql, arguments: query.arguments)
    }

    /// Runs `block` in one transaction: committed if it returns true, rolled back otherwise.
    @discardableResult
    func inTransaction(_ block: (CYLExampleDatabase) -> Bool) -> Bool {
        guard (try? executeSQL("BEGIN")) != nil else { return false }
        let ok = block(self)
        try? executeSQL(ok ? "COMMIT" : "ROLLBACK")
        return ok
    }

    /// Number of rows of a table.
    func count(ofTable table: String) -> Int {
        let sql = "SELECT COUNT(*) AS n FROM \"\(table.replacingOccurrences(of: "\"", with: ""))\""
        return ((try? rows(forSQL: sql))?.first?["n"] as? NSNumber)?.intValue ?? 0
    }

    /// The same as count(ofTable:) (the spelling of the Objective-C selector).
    @nonobjc func countOfTable(_ table: String) -> Int {
        count(ofTable: table)
    }

    // MARK: Schema and data

    private func createTables() throws {
        let statements = [
            "PRAGMA foreign_keys = ON",
            "DROP TABLE IF EXISTS review_keywords",
            "DROP TABLE IF EXISTS reviews",
            "DROP TABLE IF EXISTS places",
            "CREATE TABLE reviews (id INTEGER PRIMARY KEY, user TEXT NOT NULL, text TEXT NOT NULL, date TEXT NOT NULL, "
                + "sku TEXT NOT NULL, rating INTEGER NOT NULL, has_photo INTEGER NOT NULL, has_follow_up INTEGER NOT NULL)",
            "CREATE TABLE review_keywords (review_id INTEGER NOT NULL REFERENCES reviews(id), keyword TEXT NOT NULL)",
            "CREATE INDEX review_keywords_keyword ON review_keywords(keyword)",
            "CREATE TABLE places (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL, tag TEXT NOT NULL, "
                + "region TEXT NOT NULL, rating REAL NOT NULL, price INTEGER NOT NULL)",
            "CREATE INDEX places_tag ON places(tag)",
            "CREATE INDEX places_region ON places(region)",
            "CREATE TABLE IF NOT EXISTS selections (scenario TEXT NOT NULL, section INTEGER NOT NULL, item INTEGER NOT NULL)",
        ]
        for sql in statements {
            try executeSQL(sql)
        }
    }

    private func fillTables() throws {
        var fillError: Error?
        let ok = inTransaction { database in
            do {
                // Scenario 1: the reviews, with their position in CYLReviewStore as id.
                for (index, review) in CYLReviewStore.shared().reviews.enumerated() {
                    try database.executeSQL("INSERT INTO reviews VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                                            arguments: [NSNumber(value: index), review.user, review.text, review.date, review.sku,
                                                        NSNumber(value: review.rating.rawValue), NSNumber(value: review.hasPhoto),
                                                        NSNumber(value: review.hasFollowUp)])
                    for keyword in review.keywords {
                        try database.executeSQL("INSERT INTO review_keywords VALUES (?, ?)", arguments: [NSNumber(value: index), keyword])
                    }
                }
                // The classify menu demo: every tag of data.json (CYLDBManager, from the original app), in
                // some of the regions of its filter.
                let regions = CYLDemoDataSource.regions()
                var placeID = 0
                var tagIndex = 0
                for category in CYLDBManager.dataSource() {
                    let type = category["Type"] as? String ?? ""
                    let items = category[kDataSourceSectionKey] as? [[String: Any]] ?? []
                    for item in items {
                        let tag = item[kDataSourceCellTextKey] as? String ?? ""
                        for (region, regionName) in regions.enumerated() {
                            if (tagIndex + region) % 3 == 2 {
                                continue
                            }
                            let rating = 3.5 + Double((tagIndex * 7 + region * 3) % 16) / 10.0
                            let price = 30 + ((tagIndex * 37 + region * 53) % 270)
                            let name = "\(CYLDemoDataSource.shortTitle(forTitle: tag)) · \(CYLDemoDataSource.shortTitle(forTitle: regionName))"
                            try database.executeSQL("INSERT INTO places VALUES (?, ?, ?, ?, ?, ?, ?)",
                                                    arguments: [NSNumber(value: placeID), name, type, tag, regionName,
                                                                NSNumber(value: rating), NSNumber(value: price)])
                            placeID += 1
                        }
                        tagIndex += 1
                    }
                }
                return true
            } catch {
                fillError = error
                return false
            }
        }
        if !ok {
            throw fillError ?? lastError()
        }
    }

    // MARK: Selections

    /// The [section, item] pairs a demo saved last, or nil.
    func savedSelection(forScenario scenario: String) -> [IndexPath]? {
        let rows = (try? rows(forSQL: "SELECT section, item FROM selections WHERE scenario = ? ORDER BY section, item",
                              arguments: [scenario])) ?? []
        guard !rows.isEmpty else { return nil }
        return rows.map { row in
            IndexPath(item: (row["item"] as? NSNumber)?.intValue ?? 0, section: (row["section"] as? NSNumber)?.intValue ?? 0)
        }
    }

    /// Saves a demo's selection (replacing the previous one).
    @discardableResult
    func saveSelection(_ indexPaths: [IndexPath], forScenario scenario: String) -> Bool {
        inTransaction { database in
            guard (try? database.executeSQL("DELETE FROM selections WHERE scenario = ?", arguments: [scenario])) != nil else {
                return false
            }
            for indexPath in indexPaths {
                guard (try? database.executeSQL("INSERT INTO selections VALUES (?, ?, ?)",
                                                arguments: [scenario, NSNumber(value: indexPath.section),
                                                            NSNumber(value: indexPath.item)])) != nil else {
                    return false
                }
            }
            return true
        }
    }
}

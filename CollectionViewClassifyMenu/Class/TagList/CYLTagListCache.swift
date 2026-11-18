//
//  CYLTagListCache.swift
//  CollectionViewClassifyMenu
//
//  A cache of a tag list's sections, so an order changed in editing mode (a drag), a deleted tag or an added one
//  survives a relaunch: a SQLite database (the default), NSUserDefaults or a JSON file in the app's sandbox, behind
//  one store, as CYLSearchViewController's suggestion cache (CYLSearchSuggestionStore).
//

import Foundation
import SQLite3

/**
 * Where `CYLTagListView` keeps the titles of its edited sections (`CYLTagListView.cachePolicy`).
 */
@objc public enum CYLTagListCachePolicy: Int {
    /**
     * No cache (the default of `CYLTagListView`): edits live as long as the host's data.
     */
    case none
    /**
     * A SQLite database in the app's Application Support folder.
     */
    case database
    /**
     * `NSUserDefaults`.
     */
    case userDefaults
    /**
     * A JSON file in the app's sandbox (Application Support).
     */
    case sandboxFile
}

/**
 * A store of the ordered titles of a tag list's sections. `CYLTagListView` makes the built-in store of its
 * `cachePolicy`; implement this protocol and set `CYLTagListView.cache` to use another store.
 */
@objc public protocol CYLTagListCache: NSObjectProtocol {
    /**
     * The titles saved for `section`, in order; nil when nothing was saved for it.
     */
    func cachedTitles(forSection section: String) -> [String]?

    /**
     * Saves `titles` (in this order) as the contents of `section`, replacing what was saved.
     */
    func saveTitles(_ titles: [String], forSection section: String)

    /**
     * Removes what was saved for `section`.
     */
    func removeTitles(forSection section: String)

    /**
     * Removes every section of this cache.
     */
    func removeAllTitles()
}

/**
 * The built-in caches: a database, `NSUserDefaults` or a file, behind one class. `name` separates the caches of
 * different lists (the database key, the defaults key or the file name).
 */
@objcMembers
public final class CYLTagListStore: NSObject, CYLTagListCache {

    /**
     * The policy of this store.
     */
    public let policy: CYLTagListCachePolicy

    /**
     * Separates the caches of different lists.
     */
    public let name: String

    private var memory: [String: [String]] = [:]
    private var database: OpaquePointer?

    /**
     * The store for `policy` and `name`; nil for `CYLTagListCachePolicyNone`.
     */
    @objc(cacheWithPolicy:name:)
    public static func cache(policy: CYLTagListCachePolicy, name: String) -> CYLTagListStore? {
        policy == .none ? nil : CYLTagListStore(policy: policy, name: name)
    }

    /**
     * A store for `policy` and `name` ("CYLTagListView" when empty).
     */
    public init(policy: CYLTagListCachePolicy, name: String) {
        self.policy = policy
        self.name = name.isEmpty ? "CYLTagListView" : name
        super.init()
        if policy == .database {
            openDatabase()
        }
    }

    deinit {
        sqlite3_close(database)
    }

    // MARK: - CYLTagListCache

    public func cachedTitles(forSection section: String) -> [String]? {
        switch policy {
        case .none:
            return nil
        case .database:
            return database == nil ? memory[section] : databaseTitles(forSection: section)
        case .userDefaults:
            return (UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: [String]])?[section]
        case .sandboxFile:
            return fileContents()[section]
        }
    }

    public func saveTitles(_ titles: [String], forSection section: String) {
        switch policy {
        case .none:
            return
        case .database:
            guard database != nil else {
                memory[section] = titles
                return
            }
            execute("BEGIN")
            execute("DELETE FROM tags WHERE list = ? AND section = ?", [name, section])
            // An empty section is a row with a NULL title, so "saved, empty" differs from "never saved".
            if titles.isEmpty {
                execute("INSERT INTO tags (list, section, position, title) VALUES (?, ?, 0, NULL)", [name, section])
            }
            for (position, title) in titles.enumerated() {
                execute("INSERT INTO tags (list, section, position, title) VALUES (?, ?, \(position), ?)", [name, section, title])
            }
            execute("COMMIT")
        case .userDefaults:
            var all = (UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: [String]]) ?? [:]
            all[section] = titles
            UserDefaults.standard.set(all, forKey: defaultsKey)
        case .sandboxFile:
            var all = fileContents()
            all[section] = titles
            writeFile(all)
        }
    }

    public func removeTitles(forSection section: String) {
        switch policy {
        case .none:
            return
        case .database:
            if database == nil {
                memory[section] = nil
            } else {
                execute("DELETE FROM tags WHERE list = ? AND section = ?", [name, section])
            }
        case .userDefaults:
            var all = (UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: [String]]) ?? [:]
            all[section] = nil
            UserDefaults.standard.set(all, forKey: defaultsKey)
        case .sandboxFile:
            var all = fileContents()
            all[section] = nil
            writeFile(all)
        }
    }

    public func removeAllTitles() {
        switch policy {
        case .none:
            return
        case .database:
            memory.removeAll()
            execute("DELETE FROM tags WHERE list = ?", [name])
        case .userDefaults:
            UserDefaults.standard.removeObject(forKey: defaultsKey)
        case .sandboxFile:
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    // MARK: - Storage

    private var defaultsKey: String { "CYLTagListCache." + name }

    private static var folder: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("CollectionViewClassifyMenu", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private var fileURL: URL {
        let safe = name.map { $0.isLetter || $0.isNumber ? $0 : "_" }
        return Self.folder.appendingPathComponent("tags-" + String(safe) + ".json")
    }

    private func fileContents() -> [String: [String]] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return [:]
        }
        return (try? JSONDecoder().decode([String: [String]].self, from: data)) ?? [:]
    }

    private func writeFile(_ contents: [String: [String]]) {
        if let data = try? JSONEncoder().encode(contents) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    private func openDatabase() {
        let path = Self.folder.appendingPathComponent("tags.sqlite").path
        guard sqlite3_open(path, &database) == SQLITE_OK else {
            sqlite3_close(database)
            database = nil
            return
        }
        execute("CREATE TABLE IF NOT EXISTS tags (list TEXT NOT NULL, section TEXT NOT NULL, position INTEGER NOT NULL, title TEXT, PRIMARY KEY (list, section, position))")
    }

    private static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    private func execute(_ sql: String, _ texts: [String] = []) {
        guard let database else {
            return
        }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            return
        }
        defer { sqlite3_finalize(statement) }
        for (index, text) in texts.enumerated() {
            sqlite3_bind_text(statement, Int32(index + 1), text, -1, Self.transient)
        }
        sqlite3_step(statement)
    }

    private func databaseTitles(forSection section: String) -> [String]? {
        guard let database else {
            return memory[section]
        }
        var statement: OpaquePointer?
        let sql = "SELECT title FROM tags WHERE list = ? AND section = ? ORDER BY position"
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            return nil
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, name, -1, Self.transient)
        sqlite3_bind_text(statement, 2, section, -1, Self.transient)
        var rows = 0
        var titles: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            rows += 1
            if let text = sqlite3_column_text(statement, 0) {
                titles.append(String(cString: text))
            }
        }
        return rows == 0 ? nil : titles
    }
}

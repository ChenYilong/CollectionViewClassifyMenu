//
//  CYLTagStore.swift
//  CYLTagEditorExample
//
//  The user's tags (like a chat app's contact tags): every tag in the user's order, and the
//  recently used ones. New tags are added here; the editor only reads and asks it to change.
//  The demo tags are read from a local JSON file per language (CYLTagData).
//

import Foundation

final class CYLTagStore {

    /// Every tag, in the user's order ("我的标签").
    private(set) var tags: [String]
    /// Recently used tags, the most recent first ("最近使用").
    private(set) var recentTags: [String]
    /// How many recent tags are kept.
    let recentLimit: Int

    init(tags: [String], recentTags: [String] = [], recentLimit: Int = 8) {
        var seen = Set<String>()
        self.tags = tags.filter { seen.insert($0).inserted }
        self.recentLimit = recentLimit
        self.recentTags = Array(recentTags.filter { seen.contains($0) }.prefix(recentLimit))
    }

    /// The demo tags of the current language, from tags.json in CYLTagEditorExample.bundle's .lproj folder
    /// (see CYLTagData). An empty store if the file is missing or invalid.
    static func bundled() -> CYLTagStore {
        do {
            return try CYLTagStore(data: CYLTagData.bundled())
        } catch {
            assertionFailure("Cannot load tags.json: \(error)")
            return CYLTagStore(tags: [])
        }
    }

    convenience init(data: CYLTagData) {
        self.init(tags: data.tags, recentTags: data.recentTags)
    }

    /// A tag name as stored: without surrounding spaces and new lines.
    static func normalizedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func contains(_ tag: String) -> Bool {
        tags.contains(tag)
    }

    /// Tags containing `query`, ignoring case and width ("ios" finds "iOS"); those starting with it first.
    func tags(matching query: String) -> [String] {
        let query = CYLTagStore.normalizedName(query)
        guard !query.isEmpty else { return [] }
        let options: String.CompareOptions = [.caseInsensitive, .widthInsensitive, .diacriticInsensitive]
        let matches = tags.filter { $0.range(of: query, options: options) != nil }
        let prefixed = matches.filter { $0.range(of: query, options: options.union(.anchored)) != nil }
        return prefixed + matches.filter { !prefixed.contains($0) }
    }

    /// Whether "+ 新建标签：<query>" is offered: a name that is not a tag yet (the exact name; "ios"
    /// may be created next to "iOS", as in the chat app).
    func canCreate(_ name: String) -> Bool {
        let name = CYLTagStore.normalizedName(name)
        return !name.isEmpty && !contains(name)
    }

    /// Adds a tag at the end of "我的标签" and returns it; an existing tag is returned as is. Nil for
    /// an empty name.
    @discardableResult
    func createTag(named name: String) -> String? {
        let name = CYLTagStore.normalizedName(name)
        guard !name.isEmpty else { return nil }
        if !contains(name) {
            tags.append(name)
        }
        return name
    }

    func deleteTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        recentTags.removeAll { $0 == tag }
    }

    /// Moves tags to the front of "最近使用" (when the editor is confirmed).
    func markUsed(_ used: [String]) {
        let used = used.filter(contains)
        recentTags = Array((used + recentTags.filter { !used.contains($0) }).prefix(recentLimit))
    }
}

/// The contents of tags.json: the demo tags, the recently used ones and the tags the remark screen
/// starts with. One file per language in CYLTagEditorExample.bundle/<language>.lproj/.
struct CYLTagData: Codable, Equatable {
    var version: Int
    var tags: [String]
    var recentTags: [String]
    var selectedTags: [String]

    enum LoadingError: Error, Equatable {
        case fileNotFound(String)
    }

    /// Parses tags.json.
    static func decode(_ data: Data) throws -> CYLTagData {
        try JSONDecoder().decode(CYLTagData.self, from: data)
    }

    static func load(from url: URL) throws -> CYLTagData {
        try decode(Data(contentsOf: url))
    }

    /// tags.json of the Example's current language (CYLTagEditorLocalization).
    static func bundled(bundle: Bundle = CYLTagEditorLocalization.resourceBundle) throws -> CYLTagData {
        guard let url = bundle.url(forResource: "tags", withExtension: "json") else {
            throw LoadingError.fileNotFound("tags.json in \(bundle.bundlePath)")
        }
        return try load(from: url)
    }
}

//
//  CYLTagStore.swift
//  CYLTagEditorExample
//
//  The user's tags (like a chat app's contact tags): every tag in the user's order, and the
//  recently used ones. New tags are added here; the editor only reads and asks it to change.
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

    /// The tags of the screenshots this Example reproduces.
    static func demo() -> CYLTagStore {
        let tags = ["nz", "家人", "留学", "iOS", "英语", "公司", "同事", "寝室", "同学", "天蝎座", "巨蟹座", "6666", "猎头",
                    "LeanCloud", "国外", "ChatKit", "澳洲", "whv", "加拿大", "阿里", "VIPABC", "Vipabc", "想移民", "李智维",
                    "龙熠", "微博转发", "xdf", "杨佳", "雅思", "驻马店", "car", "婚礼必来", "婚礼待确认", "4月30",
                    "mem", "ok", "nz 内推", "nz 租房", "nz 不租", "nzcar", "律师", "惠灵顿租房", "nz 兼职", "mz 兼职",
                    "nz 代购", "nz 求代购", "美国代购", "右", "wellington", "nz 河南", "nz 待入群", "motor", "抖音", "中介",
                    "无疑", "nz 中介", "Swift 高手", "wuyi", "拉黑", "租房", "买车", "AUT", "au t", "AUTCIS", "非 AUT",
                    "ricky", "_lanepro", "cita", "创业"]
        return CYLTagStore(tags: tags, recentTags: ["_lanepro", "创业"])
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

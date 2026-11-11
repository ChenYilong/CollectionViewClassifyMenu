//
//  CYLSearchDiscoverData.swift
//  CYLMenuExample
//
//  The data of the search history and discover demo, from CYLMenuExample.bundle/Data/search-discover.json:
//  recent searches, and a pool of discover topics from which the More button picks another random selection.
//

import Foundation

/**
 * One discover topic: a title (sample data, not translated), and an optional icon after it: "hot" for the 热 icon.
 */
struct CYLDiscoverTopic: Codable, Equatable {
    let title: String
    var icon: String?
}

/**
 * The demo's data as stored in the JSON file.
 */
struct CYLSearchDiscoverData: Codable {
    var version: Int
    /**
     * How many topics the discover grid shows at a time.
     */
    var discoverCount: Int
    var recentSearches: [String]
    var discover: [CYLDiscoverTopic]

    enum LoadingError: Error {
        case missingFile
    }

    /**
     * The file in CYLMenuExample.bundle.
     */
    static var fileURL: URL? {
        CYLExampleLocalization.resourceBundle?.url(forResource: "search-discover", withExtension: "json", subdirectory: "Data")
    }

    /**
     * Reads and decodes the bundled file.
     */
    static func bundled() throws -> CYLSearchDiscoverData {
        guard let url = fileURL else { throw LoadingError.missingFile }
        return try JSONDecoder().decode(CYLSearchDiscoverData.self, from: Data(contentsOf: url))
    }

    /**
     * The first selection: the first `discoverCount` topics, so the first screen is always the same.
     */
    var initialTopics: [CYLDiscoverTopic] {
        Array(discover.prefix(max(0, discoverCount)))
    }

    /**
     * Another random selection of `discoverCount` topics; it differs from `current` whenever the pool allows.
     */
    func randomTopics<G: RandomNumberGenerator>(excluding current: [CYLDiscoverTopic], using generator: inout G) -> [CYLDiscoverTopic] {
        let count = min(max(0, discoverCount), discover.count)
        let others = discover.filter { !current.contains($0) }
        // Prefer topics that are not shown now; fill up with the others when the pool is small.
        var picked = Array(others.shuffled(using: &generator).prefix(count))
        if picked.count < count {
            let rest = discover.filter { !picked.contains($0) }.shuffled(using: &generator)
            picked += rest.prefix(count - picked.count)
        }
        return picked
    }
}

/**
 * Any random number generator behind one type, so a screen can keep one and tests can swap in a seeded one.
 */
struct CYLAnyRandomNumberGenerator: RandomNumberGenerator {
    private let nextValue: () -> UInt64

    init<G: RandomNumberGenerator>(_ generator: G) {
        var generator = generator
        nextValue = { generator.next() }
    }

    mutating func next() -> UInt64 {
        nextValue()
    }
}

/**
 * A seeded generator (SplitMix64) for repeatable selections in tests.
 */
struct CYLSeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

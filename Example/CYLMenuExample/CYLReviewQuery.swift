//
//  CYLReviewQuery.swift
//  CYLMenuExample
//
//  Three ways to apply the selected review filters, kept apart on purpose:
//  - CYLMemoryReviewQuery filters the reviews already in memory, synchronously.
//  - CYLNetworkReviewQuery sends the conditions to a server and refreshes when the
//    response arrives; responses to older requests are dropped. The server is
//    simulated (CYLReviewServer) so the Example runs offline.
//  - CYLDatabaseReviewQuery turns the conditions into one SQL statement and runs it on
//    the Example's SQLite database (CYLExampleDatabase).
//

import Foundation

@objc enum CYLReviewFilteringMode: Int {
    case memory = 0
    case network
    case database
}

typealias CYLReviewQueryCompletion = ([CYLReview]) -> Void

@objc protocol CYLReviewQuerying: NSObjectProtocol {
    var mode: CYLReviewFilteringMode { get }
    var isLoading: Bool { get }
    /// Reviews matching every filter (AND). The completion runs on the main queue,
    /// synchronously for memory filtering; it is not called for superseded requests.
    func fetchReviewsMatching(_ filters: [CYLReviewFilter], completion: @escaping CYLReviewQueryCompletion)
}

final class CYLMemoryReviewQuery: NSObject, CYLReviewQuerying {
    var mode: CYLReviewFilteringMode { .memory }
    var isLoading: Bool { false }

    func fetchReviewsMatching(_ filters: [CYLReviewFilter], completion: @escaping CYLReviewQueryCompletion) {
        completion(CYLReviewStore.shared().reviewsMatchingAll(filters))
    }
}

/// A stand-in for a backend: answers a request URL with the matching reviews.
final class CYLReviewServer: NSObject {
    static func reviews(forRequestURL url: URL) -> [CYLReview] {
        let store = CYLReviewStore.shared()
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let filters = items.compactMap { item -> CYLReviewFilter? in
            item.name == "filter" ? item.value.flatMap(store.filter(withIdentifier:)) : nil
        }
        return store.reviewsMatchingAll(filters)
    }

    /// The same as reviews(forRequestURL:).
    static func reviews(forRequest url: URL) -> [CYLReview] {
        reviews(forRequestURL: url)
    }
}

final class CYLNetworkReviewQuery: NSObject, CYLReviewQuerying {
    /// Simulated round trip. Defaults to 0.6 s.
    var latency: TimeInterval = 0.6
    private(set) var isLoading = false
    private(set) var lastRequestURL: URL?
    private(set) var requestCount = 0
    private(set) var droppedResponseCount = 0

    var mode: CYLReviewFilteringMode { .network }

    static func requestURL(for filters: [CYLReviewFilter]) -> URL {
        var components = URLComponents(string: "https://api.example.com/reviews")!
        let items = filters.map { URLQueryItem(name: "filter", value: $0.identifier) }
        components.queryItems = items.isEmpty ? nil : items
        return components.url!
    }

    func fetchReviewsMatching(_ filters: [CYLReviewFilter], completion: @escaping CYLReviewQueryCompletion) {
        let url = Self.requestURL(for: filters)
        lastRequestURL = url
        requestCount += 1
        let request = requestCount
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + latency) { [weak self] in
            guard let self else { return }
            if request != self.requestCount {
                // The user changed the filters again: this response is out of date.
                self.droppedResponseCount += 1
                return
            }
            self.isLoading = false
            completion(CYLReviewServer.reviews(forRequestURL: url))
        }
    }
}

/// Runs the conditions as SQL on CYLExampleDatabase: rating, photo and follow-up are columns of
/// `reviews`, keywords rows of `review_keywords`; every condition is ANDed.
final class CYLDatabaseReviewQuery: NSObject, CYLReviewQuerying {
    let database: CYLExampleDatabase
    /// The statement of the last fetch.
    private(set) var lastQuery: CYLExampleSQLQuery?

    var mode: CYLReviewFilteringMode { .database }
    var isLoading: Bool { false }

    init(database: CYLExampleDatabase) {
        self.database = database
        super.init()
    }

    /// On CYLExampleDatabase.shared().
    override convenience init() {
        self.init(database: CYLExampleDatabase.shared())
    }

    static func query(for filters: [CYLReviewFilter]) -> CYLExampleSQLQuery {
        var conditions: [String] = []
        var arguments: [Any] = []
        let ratings: [String: CYLReviewRating] = ["good": .good, "neutral": .neutral, "bad": .bad]
        for filter in filters {
            let identifier = filter.identifier
            if let rating = ratings[identifier] {
                conditions.append("r.rating = ?")
                arguments.append(NSNumber(value: rating.rawValue))
            } else if identifier == "photo" {
                conditions.append("r.has_photo = 1")
            } else if identifier == "followup" {
                conditions.append("r.has_follow_up = 1")
            } else if filter.isKeyword {
                conditions.append("EXISTS (SELECT 1 FROM review_keywords k WHERE k.review_id = r.id AND k.keyword = ?)")
                arguments.append(filter.name)
            }
        }
        var sql = "SELECT r.id FROM reviews r"
        if !conditions.isEmpty {
            sql += " WHERE " + conditions.joined(separator: " AND ")
        }
        return CYLExampleSQLQuery(sql: sql + " ORDER BY r.id", arguments: arguments)
    }

    func fetchReviewsMatching(_ filters: [CYLReviewFilter], completion: @escaping CYLReviewQueryCompletion) {
        let query = Self.query(for: filters)
        lastQuery = query
        var rows: [[String: Any]] = []
        do {
            rows = try database.rows(for: query)
        } catch {
            NSLog("[CYLMenuExample] %@: %@", query.sql, String(describing: error))
        }
        let reviews = CYLReviewStore.shared().reviews
        let result = rows.compactMap { row -> CYLReview? in
            guard let index = (row["id"] as? NSNumber)?.intValue, index >= 0, index < reviews.count else { return nil }
            return reviews[index]
        }
        completion(result)
    }
}

//
//  CYLReviewStore.swift
//  CYLMenuExample
//
//  Mock reviews and the filters shown above them (场景一：淘宝评价筛选).
//

import UIKit

@objc enum CYLReviewRating: Int {
    case good
    case neutral
    case bad
}

@objcMembers
final class CYLReview: NSObject {
    var user = ""
    var text = ""
    var date = ""
    var sku = ""
    var rating: CYLReviewRating = .good
    var hasPhoto = false
    var hasFollowUp = false
    var keywords: [String] = []
}

/// One filter chip, such as "好评(3)" or the keyword "质量不错(2)".
@objcMembers
final class CYLReviewFilter: NSObject {
    /// Stable identifier sent to the server: all, good, neutral, bad, photo, followup or keyword:<word>.
    var identifier = ""
    var name = ""
    var image: UIImage?
    /// true for keyword chips, which also appear in the product page preview.
    var isKeyword = false
    var matches: (CYLReview) -> Bool = { _ in true }
}

@objcMembers
final class CYLReviewStore: NSObject {
    private(set) var reviews: [CYLReview]
    /// 全部, 好评, 中评, 差评, 有图, 追加, then keywords.
    private(set) var filters: [CYLReviewFilter]

    private static let sharedInstance = CYLReviewStore()

    static func shared() -> CYLReviewStore {
        sharedInstance
    }

    /// The same as shared() (the Objective-C name).
    @nonobjc static var sharedStore: CYLReviewStore {
        sharedInstance
    }

    override init() {
        reviews = Self.mockReviews()
        filters = Self.makeFilters()
        super.init()
    }

    static func review(user: String, text: String, date: String, sku: String, rating: CYLReviewRating, photo: Bool,
                       followUp: Bool, keywords: [String]) -> CYLReview {
        let review = CYLReview()
        review.user = user
        review.text = text
        review.date = date
        review.sku = sku
        review.rating = rating
        review.hasPhoto = photo
        review.hasFollowUp = followUp
        review.keywords = keywords
        return review
    }

    /// Sample data (not localized).
    static func mockReviews() -> [CYLReview] {
        let pink = "颜色分类:苹果6 4.7【镜面粉字】"
        let white = "颜色分类:苹果6plus【白边白字】"
        return [
            review(user: "1**1", text: "这是我买的第二个了，太棒了，酷毙了，又能当化妆镜，又能当手机壳，价格真的很实惠，质量也不错。", date: "2015-06-17", sku: pink, rating: .good, photo: true, followUp: false, keywords: ["手机套不错", "质量不错", "划算"]),
            review(user: "雨**4", text: "刚收到就拆卡看壳，然后手机壳上有一层膜，没看到，找了卖家，卖家非常细心的解说，宝贝不错。", date: "2015-06-16", sku: white, rating: .good, photo: false, followUp: false, keywords: ["态度不错", "手机套不错"]),
            review(user: "j**8", text: "太炫了，闪瞎眼，质量蛮不错的非常超值，好几个朋友看了都说也要买。", date: "2015-06-12", sku: pink, rating: .good, photo: false, followUp: true, keywords: ["质量不错", "划算"]),
            review(user: "杨**6", text: "已经第N次购买了，不管是老板还是客服都非常好，东西更加不用说，超级靓。", date: "2015-06-13", sku: white, rating: .good, photo: true, followUp: false, keywords: ["态度不错", "质量不错"]),
            review(user: "小**猫", text: "颜色很正，和图片一样，镜面效果很好，就是有点容易留指纹。", date: "2015-06-11", sku: pink, rating: .good, photo: true, followUp: true, keywords: ["颜色不错"]),
            review(user: "t**2", text: "背面细节一般，边缘有一点毛刺，不过这个价格可以接受。", date: "2015-06-10", sku: white, rating: .neutral, photo: false, followUp: false, keywords: ["背面细节一般"]),
            review(user: "阿**宝", text: "手机壳很薄，手感好，颜色也漂亮，推荐购买。", date: "2015-06-09", sku: pink, rating: .good, photo: false, followUp: false, keywords: ["手机套不错", "颜色不错"]),
            review(user: "z**9", text: "物流很快，第二天就到了，壳子做工精细，背面细节一般。", date: "2015-06-08", sku: white, rating: .good, photo: true, followUp: false, keywords: ["质量不错", "背面细节一般"]),
            review(user: "大**熊", text: "给女朋友买的，她很喜欢，客服回复也很及时。", date: "2015-06-07", sku: pink, rating: .good, photo: false, followUp: true, keywords: ["态度不错"]),
            review(user: "m**0", text: "性价比高，用了一周没有掉色，会回购。", date: "2015-06-05", sku: white, rating: .good, photo: false, followUp: false, keywords: ["划算", "质量不错"]),
        ]
    }

    /// Identifiers of the rating filters; their names are localization keys looked up in title(for:).
    private static let identifiers = ["全部": "all", "好评": "good", "中评": "neutral", "差评": "bad", "有图": "photo", "追加": "followup"]

    static func filter(named name: String, symbol: String?, color: UIColor, keyword: Bool,
                       matches: @escaping (CYLReview) -> Bool) -> CYLReviewFilter {
        let filter = CYLReviewFilter()
        filter.identifier = keyword ? "keyword:" + name : (identifiers[name] ?? name)
        filter.name = name
        filter.isKeyword = keyword
        filter.matches = matches
        if let symbol {
            filter.image = UIImage(systemName: symbol)?.withTintColor(color, renderingMode: .alwaysOriginal)
        }
        return filter
    }

    static func makeFilters() -> [CYLReviewFilter] {
        let orange = UIColor(red: 1, green: 0.45, blue: 0.1, alpha: 1)
        var filters = [
            filter(named: "全部", symbol: nil, color: orange, keyword: false) { _ in true },
            filter(named: "好评", symbol: "hand.thumbsup.fill", color: orange, keyword: false) { $0.rating == .good },
            filter(named: "中评", symbol: "hand.raised.fill", color: orange, keyword: false) { $0.rating == .neutral },
            filter(named: "差评", symbol: "hand.thumbsdown.fill", color: .gray, keyword: false) { $0.rating == .bad },
            filter(named: "有图", symbol: nil, color: orange, keyword: false) { $0.hasPhoto },
            filter(named: "追加", symbol: nil, color: orange, keyword: false) { $0.hasFollowUp },
        ]
        for keyword in ["手机套不错", "质量不错", "态度不错", "划算", "颜色不错", "背面细节一般"] {
            filters.append(filter(named: keyword, symbol: nil, color: orange, keyword: true) { $0.keywords.contains(keyword) })
        }
        return filters
    }

    func reviewsMatching(_ filter: CYLReviewFilter) -> [CYLReview] {
        reviews.filter(filter.matches)
    }

    /// Reviews that match every filter (AND); "all" adds no condition.
    func reviewsMatchingAll(_ filters: [CYLReviewFilter]) -> [CYLReview] {
        reviews.filter { review in filters.allSatisfy { $0.matches(review) } }
    }

    func filter(withIdentifier identifier: String) -> CYLReviewFilter? {
        filters.first { $0.identifier == identifier }
    }

    /// "好评(3)".
    func title(for filter: CYLReviewFilter) -> String {
        // Rating filters are UI text and localized; keyword filters are sample data.
        let name = filter.isKeyword ? filter.name : CYLExampleLocalizedString(filter.name)
        if filter.name == "全部" {
            return name
        }
        return "\(name)(\(reviewsMatching(filter).count))"
    }
}

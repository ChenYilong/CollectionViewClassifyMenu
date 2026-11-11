//
//  CYLProductViewController.swift
//  CYLMenuExample
//
//  场景一（商品页）：只展示两行评价关键词的预览，点击进入评价页。
//

import UIKit
import CollectionViewClassifyMenu

final class CYLProductViewController: UIViewController {

    private(set) var previewView = CYLTagListView()
    var previewSource: CYLExampleMenuSource?
    /// Maps preview items to indexes in CYLReviewStore.filters.
    var previewFilterIndexes: [Int] = []
    private var previewHeight: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem, not title: a view controller's title would replace its tab's title.
        navigationItem.title = CYLExampleLocalizedString("宝贝详情")
        view.backgroundColor = .systemGroupedBackground
        let store = CYLReviewStore.shared()

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        // Sample data: the product's name and price.
        let name = label(text: "潮牌电镀镜面MLGB字母iphone6手机壳苹果6plus手机壳情侣5S外壳潮", font: .systemFont(ofSize: 16), color: .label)
        let price = label(text: "¥9.90-14.90", font: .boldSystemFont(ofSize: 22), color: UIColor(red: 1, green: 0.31, blue: 0, alpha: 1))
        let reviewTitle = label(text: CYLExampleLocalizedString("宝贝评价(%lu)", UInt(store.reviews.count)),
                                font: .systemFont(ofSize: 15), color: .label)

        // Keyword chips only, two rows, no fold control: a preview of the review page.
        var items: [CYLExampleMenuItem] = []
        var indexes: [Int] = []
        for (index, filter) in store.filters.enumerated() where filter.isKeyword {
            items.append(CYLExampleMenuItem(title: store.title(for: filter)))
            indexes.append(index)
        }
        previewFilterIndexes = indexes
        let source = CYLExampleMenuSource(sections: [CYLExampleMenuSection(title: CYLExampleLocalizedString("关键词"), items: items)])
        previewSource = source
        let style = CYLReviewListViewController.reviewFilterStyle()
        style.sectionInsets = UIEdgeInsets(top: 4, left: 0, bottom: 12, right: 0)
        previewView.style = style
        previewView.selectionMode = .none
        previewView.showsSectionHeaders = false
        previewView.foldStyle = .truncate
        previewView.defaultVisibleRows = 2
        previewView.isScrollEnabled = false
        previewView.menuDelegate = self
        previewView.menuDataSource = source
        previewView.reloadMenuData()
        let height = previewView.heightAnchor.constraint(equalToConstant: previewView.heightThatFitsWidth(view.bounds.width - 32))
        height.isActive = true
        previewHeight = height

        let reviewBlock = UIView()
        reviewBlock.backgroundColor = .systemBackground
        let reviewStack = UIStackView(arrangedSubviews: [reviewTitle, previewView])
        reviewStack.axis = .vertical
        reviewStack.spacing = 6
        reviewStack.isLayoutMarginsRelativeArrangement = true
        reviewStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        reviewStack.translatesAutoresizingMaskIntoConstraints = false
        reviewBlock.addSubview(reviewStack)
        for review in store.reviews.prefix(2) {
            reviewStack.addArrangedSubview(label(text: "\(review.user)\n\(review.text)", font: .systemFont(ofSize: 13), color: .secondaryLabel))
        }
        let more = UIButton(type: .system)
        more.setTitle(CYLExampleLocalizedString("查看更多评价"), for: .normal)
        more.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        more.heightAnchor.constraint(equalToConstant: 44).isActive = true
        reviewStack.addArrangedSubview(more)
        NSLayoutConstraint.activate([
            reviewStack.topAnchor.constraint(equalTo: reviewBlock.topAnchor, constant: 8),
            reviewStack.leadingAnchor.constraint(equalTo: reviewBlock.leadingAnchor),
            reviewStack.trailingAnchor.constraint(equalTo: reviewBlock.trailingAnchor),
            reviewStack.bottomAnchor.constraint(equalTo: reviewBlock.bottomAnchor),
        ])

        for subview in [card(with: [name, price]), reviewBlock] {
            stack.addArrangedSubview(subview)
        }
        let frame = scrollView.frameLayoutGuide
        let content = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: content.topAnchor),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: frame.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: frame.trailingAnchor),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = previewView.bounds.width > 0 ? previewView.bounds.width : view.bounds.width - 32
        let height = previewView.heightThatFitsWidth(width)
        if let constraint = previewHeight, abs(constraint.constant - height) > 0.5 {
            constraint.constant = height
        }
    }

    private func label(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    private func card(with views: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = .systemBackground
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])
        return card
    }

    @objc private func moreTapped() {
        showReviews(withFilterIndex: 0)
    }

    /// Pushes the review page with the given filter selected.
    @objc func showReviews(withFilterIndex index: Int) {
        let reviews = CYLReviewListViewController(selectedFilterIndex: index)
        reviews.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(reviews, animated: true)
    }
}

extension CYLProductViewController: CYLMenuDelegate {

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        showReviews(withFilterIndex: previewFilterIndexes[indexPath.item])
    }
}

//
//  CYLSearchHomeViewController.swift
//  CYLMenuExample
//
//  场景二首页：一个搜索框，点击后 push 进入搜索页（隐藏根 TabBar）。
//

import UIKit

final class CYLSearchHomeViewController: UIViewController {

    private(set) var searchButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem, not title: a view controller's title would replace its tab's title.
        navigationItem.title = CYLExampleLocalizedString("脉脉搜索")
        view.backgroundColor = .systemGroupedBackground

        var configuration = UIButton.Configuration.gray()
        configuration.title = CYLExampleLocalizedString("搜人名,职位,公司...")
        configuration.image = UIImage(systemName: "magnifyingglass")
        configuration.imagePadding = 8
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .secondaryLabel
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        searchButton = UIButton(configuration: configuration, primaryAction: nil)
        searchButton.contentHorizontalAlignment = .leading
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)

        let hint = UILabel()
        hint.text = CYLExampleLocalizedString("按分类浏览热门标签：找人、动态、八卦、职位")
        hint.font = .preferredFont(forTextStyle: .footnote)
        hint.adjustsFontForContentSizeCategory = true
        hint.textColor = .secondaryLabel
        hint.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [searchButton, hint])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
        ])
    }

    @objc private func searchTapped() {
        openSearch()
    }

    /// Pushes the search screen with the root tab bar hidden, and returns it.
    @discardableResult
    @objc func openSearch() -> CYLSearchCategoryViewController {
        let search = CYLSearchCategoryViewController()
        // Tab bars stay at the bottom and are hidden for pushed screens.
        search.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(search, animated: true)
        return search
    }
}

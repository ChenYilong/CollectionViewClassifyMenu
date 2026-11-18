//
//  CYLTagReorderDemoViewController.swift
//  CYLMenuExample
//
//  Drag to reorder: one tag list with `allowsReordering`. A long press picks a tag up, dragging moves it, and the order
//  below the list follows each move (`tagMoveHandler`). The iOS counterpart of the Android example's draggable
//  container (AndroidTagView `setDragEnable(true)`, `LujunTagContainerFragment`); VoiceOver users get 前移 / 后移
//  actions on every tag instead.
//

import UIKit
import CollectionViewClassifyMenu

final class CYLTagReorderDemoViewController: UIViewController {

    /// The tags at launch and after Reset.
    static let initialTitles = ["Swift", "Kotlin", "ArkTS", "Dart", "TypeScript", "Objective-C", "Java", "C++", "Rust", "Go"]

    private(set) var tagListView: CYLTagListView!
    private(set) var orderLabel: UILabel!
    /// The titles in their current order.
    private(set) var titles = CYLTagReorderDemoViewController.initialTitles

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("拖拽排序")
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLExampleLocalizedString("重置"), style: .plain,
                                                            target: self, action: #selector(reset))

        let hint = UILabel()
        hint.text = CYLExampleLocalizedString("长按一个标签，拖到新位置后松手。")
        hint.font = .preferredFont(forTextStyle: .subheadline)
        hint.textColor = .secondaryLabel
        hint.numberOfLines = 0

        let list = CYLTagListView()
        list.accessibilityIdentifier = "reorder.tags"
        list.isScrollEnabled = false
        list.allowsReordering = true
        list.colorTheme = .pureTeal
        list.setTags(withTitles: titles)
        list.reloadMenuData()
        list.tagMoveHandler = { [weak self] from, to in self?.move(from: from, to: to) }
        tagListView = list

        let order = UILabel()
        order.accessibilityIdentifier = "reorder.order"
        order.font = .preferredFont(forTextStyle: .footnote)
        order.numberOfLines = 0
        orderLabel = order

        let stack = UIStackView(arrangedSubviews: [hint, list, order])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            list.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
        ])
        updateOrder()
    }

    /// A tag moved from `from` to `to` (the list already shows it there).
    func move(from: Int, to: Int) {
        guard titles.indices.contains(from), titles.indices.contains(to) else { return }
        titles.insert(titles.remove(at: from), at: to)
        updateOrder()
    }

    @objc func reset() {
        titles = Self.initialTitles
        tagListView.setTags(withTitles: titles)
        tagListView.reloadMenuData()
        updateOrder()
    }

    private func updateOrder() {
        orderLabel.text = CYLExampleLocalizedString("当前顺序：%@", titles.joined(separator: " · "))
    }
}

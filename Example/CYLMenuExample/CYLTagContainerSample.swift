//
//  CYLTagContainerSample.swift
//  CYLMenuExample
//
//  whilu/AndroidTagView's sample in Swift (MainActivity and content_main.xml): five tag containers, each with the
//  attributes of the sample's XML, and "add tag". The core draws and lays out everything; this screen passes the data,
//  the attribute values, and handles the taps.
//

import UIKit
import CollectionViewClassifyMenu

/// The sample's lists and colors.
enum CYLTagContainerSampleData {
    static let list1 = ["Java", "C++", "Python", "Swift", "你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。",
                        "PHP", "JavaScript", "Html", "Welcome to use AndroidTagView!"]
    static let list2 = ["China", "USA", "Austria", "Japan", "Sudan", "Spain", "UK", "Germany", "Niger", "Poland", "Norway",
                        "Uruguay", "Brazil"]
    static let list3 = ["Persian", "波斯语", "فارسی", "Hello", "你好", "سلام"]
    static let list4 = ["Adele", "Whitney Houston"]
    static let list5 = ["Custom Red Color", "Custom Blue Color"]

    /// {backgroundColor, tagBorderColor, tagTextColor, tagSelectedBackgroundColor} of list5.
    static func colors5() -> [CYLTagColors] {
        ["#ff0000", "#0000ff"].map {
            CYLTagColors(backgroundColor: UIColor.cylMenuColor(from: $0), borderColor: .black, textColor: .white,
                         selectedBackgroundColor: UIColor.cylMenuColor(from: "#999999"))
        }
    }

    /// The default image (yellow_avatar): a round yellow face.
    static func avatar() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 48, height: 48)).image { _ in
            UIColor.systemYellow.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 48, height: 48)).fill()
            UIColor.brown.setFill()
            UIBezierPath(ovalIn: CGRect(x: 14, y: 16, width: 6, height: 6)).fill()
            UIBezierPath(ovalIn: CGRect(x: 28, y: 16, width: 6, height: 6)).fill()
            let smile = UIBezierPath(arcCenter: CGPoint(x: 24, y: 26), radius: 11, startAngle: 0.2 * .pi, endAngle: 0.8 * .pi, clockwise: true)
            smile.lineWidth = 3
            UIColor.brown.setStroke()
            smile.stroke()
        }
    }
}

final class CYLTagContainerSampleViewController: UIViewController {

    private(set) var containers: [CYLTagListView] = []
    private(set) var textField: UITextField!
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    /// A TagContainerLayout with the library's defaults: the container's #11FF0000 background, a 0.5 pt #22FF0000
    /// border with a 10 pt radius, 10 pt padding.
    static func makeContainer(_ configure: (CYLTagListView, CYLMenuStyle) -> Void) -> CYLTagListView {
        let list = CYLTagListView()
        let style = CYLMenuStyle.tagContainer()
        style.sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        style.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0x11 / 255.0)
        list.containerBorderWidth = 0.5
        list.containerBorderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0x22 / 255.0)
        list.containerCornerRadius = 10
        list.isScrollEnabled = false
        // tag_clickable is false by default; the sample turns it on where it wants taps.
        list.allowsTapping = false
        list.colorTheme = .pureCyan
        configure(list, style)
        list.style = style
        return list
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("标签容器示例")
        view.backgroundColor = UIColor(white: 0.98, alpha: 1)
        let data = CYLTagContainerSampleData.self

        // tagcontainerLayout1: drag, clickable, cross, pure teal, 10 pt spacing, the default avatar.
        let first = Self.makeContainer { list, style in
            style.interitemSpacing = 10
            style.lineSpacing = 10
            style.imageSize = CGSize(width: 24, height: 24)
            style.imageCornerRadius = 12
            list.allowsReordering = true
            list.allowsTapping = true
            list.colorTheme = .pureTeal
            list.removesItemsOnDelete = false
            list.defaultTagImage = data.avatar()
        }
        first.setTags(withTitles: data.list1)
        first.tagDataSource.tags.forEach { $0.isDeletable = true }
        first.reloadMenuData()
        first.tagClickHandler = { [weak self] position, tag in self?.toast(CYLExampleLocalizedString("点击位置：%ld，文字：%@", position, tag.title)) }
        first.tagLongPressHandler = { [weak self] position, _ in self?.confirmDelete(at: position) }
        first.longPressAccessibilityActionName = CYLExampleLocalizedString("删除")
        first.tagDeleteHandler = { [weak self] position, _ in self?.toast(CYLExampleLocalizedString("点了标签的叉！位置 = %ld", position)) }

        let field = CYLAndroidSample.textField(placeholder: CYLExampleLocalizedString("新标签"), label: CYLExampleLocalizedString("新标签"))
        textField = field
        let add = CYLAndroidSample.button(CYLExampleLocalizedString("添加"), identifier: "sample.add", color: .systemGray) { [weak self] in self?.addTag() }
        let addRow = UIStackView(arrangedSubviews: [field, add])
        addRow.spacing = 12
        addRow.distribution = .fillEqually

        // tagcontainerLayout2: transparent, a 4 pt #3300ff00 border, square, drag, not clickable, random colors.
        let second = Self.makeContainer { list, style in
            style.interitemSpacing = 10
            style.lineSpacing = 10
            style.backgroundColor = .clear
            list.containerBorderColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0x33 / 255.0)
            list.containerBorderWidth = 4
            list.containerCornerRadius = 0
            list.allowsReordering = true
            list.colorTheme = .random
        }
        second.setTags(withTitles: data.list2)

        // tagcontainerLayout3: right-aligned, right-to-left, white tags with a #330000ff border, selectable, cross.
        let third = Self.makeContainer { list, style in
            style.interitemSpacing = 10
            style.lineSpacing = 10
            style.backgroundColor = .clear
            style.rowAlignment = .trailing
            style.maximumTitleLength = 18
            style.reversesTitleCharacters = true
            style.deleteIndicatorPlacement = .leading
            style.tagContentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
            for appearance in [style.normalAppearance, style.selectedAppearance] {
                appearance.backgroundColor = .white
                appearance.borderColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0x33 / 255.0)
                appearance.borderWidth = 1
                appearance.cornerRadius = 1
                appearance.textColor = UIColor(white: 0x66 / 255.0, alpha: 1)
            }
            style.selectedAppearance.backgroundColor = UIColor(red: 1, green: 0x76 / 255.0, blue: 0x69 / 255.0, alpha: 0x33 / 255.0)
            list.containerBorderColor = UIColor(white: 0x66 / 255.0, alpha: 0x33 / 255.0)
            list.containerCornerRadius = 0
            list.allowsTapping = true
            list.colorTheme = CYLTagColorTheme.none
            list.removesItemsOnDelete = false
        }
        third.setTags(withTitles: data.list3)
        third.tagDataSource.tags.forEach { $0.isDeletable = true }
        third.reloadMenuData()
        third.tagClickHandler = { [weak self, weak third] position, tag in
            guard let third else { return }
            let selected = third.selectedIndexPaths.map(\.item)
            // Deselect all when an unselected tag is tapped while others are selected; otherwise show the toast.
            if selected.isEmpty || selected.contains(position) {
                self?.toast(CYLExampleLocalizedString("点击位置：%ld，文字：%@", position, tag.title))
            } else {
                third.deselectAllItems()
            }
        }
        third.tagLongPressHandler = { [weak self, weak third] position, _ in
            guard let third else { return }
            third.toggleSelection(at: IndexPath(item: position, section: 0))
            self?.toast(CYLExampleLocalizedString("已选位置：%@", third.selectedIndexPaths.map { String($0.item) }.joined(separator: ", ")))
        }
        third.longPressAccessibilityActionName = CYLExampleLocalizedString("选择或取消选择")
        third.selectedTagDragHandler = { [weak self] _, tag in self?.toast(CYLExampleLocalizedString("拖动：%@", tag.title)) }

        // tagcontainerLayout4: centered, clickable, a 2 s black ripple at alpha 47, pure teal.
        let fourth = Self.makeContainer { list, style in
            style.interitemSpacing = 10
            style.lineSpacing = 10
            style.rowAlignment = .center
            style.rippleColor = .black
            style.rippleAlpha = 47 / 255
            style.rippleDuration = 2
            list.allowsTapping = true
            list.colorTheme = .pureTeal
        }
        fourth.setTags(withTitles: data.list4)
        fourth.tagClickHandler = { [weak self] position, tag in self?.toast(CYLExampleLocalizedString("点击位置：%ld，文字：%@", position, tag.title)) }

        // tagcontainerLayout5: a 4 pt square border, not clickable, random theme, but custom colors per tag.
        let fifth = Self.makeContainer { list, style in
            style.interitemSpacing = 10
            style.lineSpacing = 10
            list.containerBorderWidth = 4
            list.containerCornerRadius = 0
            list.colorTheme = .random
        }
        fifth.setTags(withTitles: data.list5, colors: data.colors5())

        containers = [first, second, third, fourth, fifth]
        stackView.axis = .vertical
        stackView.spacing = 12
        for (index, view) in [first, addRow, second, third, fourth, fifth].enumerated() {
            stackView.addArrangedSubview(view)
            if index >= 3 {
                stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[index - 1])
            }
        }
        scrollView.keyboardDismissMode = .onDrag
        for subview in [scrollView, stackView] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Each container is as tall as its tags.
        for list in containers where list.bounds.width > 0 {
            let height = list.heightThatFitsWidth(list.bounds.width)
            if let constraint = list.constraints.first(where: { $0.firstAttribute == .height && $0.firstItem === list }) {
                if abs(constraint.constant - height) > 0.5 { constraint.constant = height }
            } else {
                list.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }
    }

    func addTag() {
        containers.first?.addTag(withTitle: textField.text ?? "")
        view.setNeedsLayout()
    }

    /// onTagLongClick: "You will delete this tag!".
    private func confirmDelete(at position: Int) {
        let alert = UIAlertController(title: CYLExampleLocalizedString("长按"), message: CYLExampleLocalizedString("将删除这个标签！"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: CYLExampleLocalizedString("删除"), style: .destructive) { [weak self] _ in
            guard let first = self?.containers.first, position < first.tags.count else { return }
            first.removeTag(at: position)
            self?.view.setNeedsLayout()
        })
        alert.addAction(UIAlertAction(title: CYLExampleLocalizedString("取消"), style: .cancel))
        present(alert, animated: true)
    }

    private func toast(_ text: String) {
        CYLAndroidSample.toast(text, in: view)
    }
}

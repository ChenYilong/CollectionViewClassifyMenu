//
//  CYLImageTagSample.swift
//  CYLMenuExample
//
//  shellljx/TagViewGroup's sample in Swift: MainActivity (a picture with two tag groups; a tap toggles them),
//  TagEditActivity (create, drag, turn and delete groups, then save) and TagListActivity (30 pictures). The core's
//  CYLImageTagView and CYLImageTagGroupView draw everything; these screens pass the data and handle the events.
//

import UIKit
import CollectionViewClassifyMenu

/// The sample's DataRepo: the groups in memory, shared by the three screens.
enum CYLImageTagSampleData {
    static var tagGroups: [CYLImageTagGroup] = initialGroups()

    static func initialGroups() -> [CYLImageTagGroup] {
        let leather = CYLImageTag(title: "头层牛皮", direction: .rightTop)
        leather.link = "http://www.baidu.com"
        let shoes = CYLImageTag(title: "英伦加绒青年棕色保暖鞋子。", direction: .rightCenter)
        shoes.link = "http://blog.licrafter.com"
        let brand = CYLImageTag(title: "PLAYBOY/花花公子", direction: .rightBottom)
        brand.link = "http://mc.licrafter.com"
        let good = CYLImageTag(title: "很不错的鞋子", direction: .rightCenter)
        good.link = "http://mc.licrafter.com"
        return [CYLImageTagGroup(tags: [leather, shoes, brand], percentPosition: CGPoint(x: 0.4, y: 0.5)),
                CYLImageTagGroup(tags: [good], percentPosition: CGPoint(x: 0.3, y: 0.2))]
    }
}

/// MainActivity.
final class CYLImageTagSampleViewController: UIViewController {

    private(set) var tagImageView: CYLImageTagView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("图片标签")
        view.backgroundColor = .systemBackground
        let imageView = CYLImageTagView()
        imageView.image = CYLAndroidSample.picture(0)
        imageView.tagGroups = CYLImageTagSampleData.tagGroups
        imageView.imageTapHandler = { [weak imageView] in imageView?.toggleTagGroups(animated: true) }
        imageView.imageAccessibilityHint = CYLExampleLocalizedString("轻点两下显示或隐藏标签")
        imageView.circleTapHandler = { [weak self] _ in self?.toast(CYLExampleLocalizedString("点击中心圆")) }
        imageView.tagTapHandler = { [weak self] _, _, tag in self?.toast(CYLExampleLocalizedString("点击标签：%@", tag.title)) }
        imageView.longPressHandler = { [weak self] _ in self?.toast(CYLExampleLocalizedString("点击中心圆")) }
        tagImageView = imageView

        let create = CYLAndroidSample.button(CYLExampleLocalizedString("创建标签"), identifier: "sample.createTags", color: .systemPink) { [weak self] in
            let edit = CYLImageTagEditViewController()
            edit.onSave = { [weak self] in self?.tagImageView.tagGroups = CYLImageTagSampleData.tagGroups }
            self?.navigationController?.pushViewController(edit, animated: true)
        }
        let list = CYLAndroidSample.button(CYLExampleLocalizedString("标签列表"), identifier: "sample.tagList", color: .systemPink) { [weak self] in
            self?.navigationController?.pushViewController(CYLImageTagListViewController(), animated: true)
        }
        let buttons = UIStackView(arrangedSubviews: [create, list])
        buttons.spacing = 8
        buttons.distribution = .fillEqually
        for subview in [imageView, buttons] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: guide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            buttons.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            buttons.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            buttons.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
        ])
    }

    private func toast(_ text: String) {
        CYLAndroidSample.toast(text, in: view)
    }
}

/// TagEditActivity: 创建 asks for up to three tags (TagEditDialog), 保存 stores the groups and goes back.
final class CYLImageTagEditViewController: UIViewController {

    private(set) var tagImageView: CYLImageTagView!
    var onSave: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("创建标签")
        view.backgroundColor = .systemBackground
        let imageView = CYLImageTagView()
        imageView.image = CYLAndroidSample.picture(0)
        imageView.isEditing = true
        imageView.circleTapHandler = { [weak self] _ in self?.toast(CYLExampleLocalizedString("点击中心圆")) }
        imageView.longPressHandler = { [weak self] index in self?.confirmDelete(groupAt: index) }
        imageView.longPressAccessibilityActionName = CYLExampleLocalizedString("删除标签组")
        tagImageView = imageView

        let info = UILabel()
        info.numberOfLines = 0
        info.font = .preferredFont(forTextStyle: .footnote)
        info.textColor = .secondaryLabel
        info.text = CYLExampleLocalizedString("1. 点击创建按钮开始创建标签组\n2. 按住标签组滑动，调整位置\n3. 点击单个标签，调整该标签的方向\n4. 点击中心圆弹出提示\n5. 长按标签组删除")
        info.adjustsFontForContentSizeCategory = true
        let create = CYLAndroidSample.button(CYLExampleLocalizedString("创建"), identifier: "sample.create", color: .systemPink) { [weak self] in self?.showCreateDialog() }
        let save = CYLAndroidSample.button(CYLExampleLocalizedString("保存"), identifier: "sample.save", color: .systemPink) { [weak self] in self?.save() }
        let buttons = UIStackView(arrangedSubviews: [create, save])
        buttons.spacing = 8
        buttons.distribution = .fillEqually
        for subview in [imageView, info, buttons] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: guide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            info.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            info.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            info.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            buttons.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 12),
            buttons.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            buttons.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
        ])
    }

    /// TagEditDialog.createTagGroup: the non-empty names, the sample's directions, at the center.
    static func group(withNames names: [String]) -> CYLImageTagGroup {
        let titles = names.filter { !$0.isEmpty }
        let directions = CYLImageTagGroup.defaultDirections(forTagCount: titles.count)
        let tags = zip(titles, directions).map { CYLImageTag(title: $0, direction: $1) }
        return CYLImageTagGroup(tags: tags, percentPosition: CGPoint(x: 0.5, y: 0.5))
    }

    func createGroup(withNames names: [String]) {
        let group = Self.group(withNames: names)
        if !group.tags.isEmpty {
            tagImageView.addTagGroup(group)
        }
    }

    private func showCreateDialog() {
        let alert = UIAlertController(title: CYLExampleLocalizedString("创建标签"), message: nil, preferredStyle: .alert)
        for index in 1...3 {
            alert.addTextField { field in
                field.placeholder = CYLExampleLocalizedString("标签 %ld", index)
                field.accessibilityLabel = field.placeholder
            }
        }
        alert.addAction(UIAlertAction(title: CYLExampleLocalizedString("取消"), style: .cancel))
        alert.addAction(UIAlertAction(title: CYLExampleLocalizedString("确定"), style: .default) { [weak self, weak alert] _ in
            self?.createGroup(withNames: alert?.textFields?.map { $0.text ?? "" } ?? [])
        })
        present(alert, animated: true)
    }

    private func confirmDelete(groupAt index: Int) {
        let alert = UIAlertController(title: CYLExampleLocalizedString("删除标签组"), message: CYLExampleLocalizedString("你确定要删除该标签组吗？"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: CYLExampleLocalizedString("取消"), style: .cancel))
        alert.addAction(UIAlertAction(title: CYLExampleLocalizedString("确定"), style: .destructive) { [weak self] _ in
            self?.tagImageView.removeTagGroup(at: index)
        })
        present(alert, animated: true)
    }

    func save() {
        CYLImageTagSampleData.tagGroups = tagImageView.tagGroups
        onSave?()
        navigationController?.popViewController(animated: true)
    }

    private func toast(_ text: String) {
        CYLAndroidSample.toast(text, in: view)
    }
}

/// A table cell with one tagged picture (item_img.xml).
final class CYLImageTagCell: UITableViewCell {
    let tagImageView = CYLImageTagView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        tagImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagImageView)
        let height = tagImageView.heightAnchor.constraint(equalTo: tagImageView.widthAnchor)
        height.priority = .defaultHigh
        NSLayoutConstraint.activate([
            tagImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            tagImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tagImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            height,
        ])
        tagImageView.imageTapHandler = { [weak self] in self?.tagImageView.toggleTagGroups(animated: true) }
        tagImageView.imageAccessibilityHint = CYLExampleLocalizedString("轻点两下显示或隐藏标签")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
}

/// TagListActivity: 30 pictures, each with one group of the repository.
final class CYLImageTagListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = CYLExampleLocalizedString("标签列表")
        tableView.register(CYLImageTagCell.self, forCellReuseIdentifier: "image")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 380
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        30
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as! CYLImageTagCell
        let groups = CYLImageTagSampleData.tagGroups
        cell.tagImageView.image = CYLAndroidSample.picture(indexPath.row % 3, size: CGSize(width: 400, height: 400))
        cell.tagImageView.tagGroups = groups.isEmpty ? [] : [groups[indexPath.row % groups.count]]
        cell.tagImageView.circleTapHandler = { [weak self] _ in self?.toast(CYLExampleLocalizedString("点击中心圆")) }
        cell.tagImageView.longPressHandler = { [weak self] _ in self?.toast(CYLExampleLocalizedString("点击中心圆")) }
        cell.tagImageView.tagTapHandler = { [weak self] _, _, tag in self?.toast(CYLExampleLocalizedString("点击标签：%@", tag.title)) }
        return cell
    }

    private func toast(_ text: String) {
        CYLAndroidSample.toast(text, in: view.window ?? view)
    }
}

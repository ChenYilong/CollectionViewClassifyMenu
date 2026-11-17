//
//  CYLMainViewController.swift
//  CollectionViewClassifyMenu
//
//  Created by https://github.com/ChenYilong on 15/4/26.
//  Copyright (c)  http://weibo.com/luohanchenyilong/ . All rights reserved.
//
//  The demo app's Classify tab: the single-choice classify menu (data.json) with a header that switches between one
//  and two default rows; the selected item becomes the title. The multiple-choice filter has its own tab
//  (CYLFilterDemoViewController).
//

import UIKit
import CollectionViewClassifyMenu

@objc(CYLMainViewController)
final class CYLMainViewController: CYLClassifyMenuViewController {

    var classifySource: CYLMenuDataSource?

    private(set) var titleLabel: UILabel?

    private(set) var rowsCountBydefaultSwitch: UISwitch?

    override func viewDidLoad() {
        let classifySource = CYLDemoDataSource.classifyDataSource()
        self.classifySource = classifySource
        menuDataSource = classifySource
        menuDelegate = self
        menuHeaderView = makeDemoHeaderView()
        super.viewDidLoad()
    }

    func makeDemoHeaderView() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 90))
        header.autoresizingMask = .flexibleWidth
        header.backgroundColor = .white

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.7
        title.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: .boldSystemFont(ofSize: 18))
        title.adjustsFontForContentSizeCategory = true
        title.accessibilityTraits = .header
        title.textColor = UIColor(red: 42 / 255.0, green: 185 / 255.0, blue: 160 / 255.0, alpha: 1)
        titleLabel = title
        header.addSubview(title)

        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(rowsCountBydefaultSwitchClicked(_:)), for: .valueChanged)
        toggle.accessibilityLabel = CYLDemoLocalizedString("默认显示两行")
        rowsCountBydefaultSwitch = toggle
        header.addSubview(toggle)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.adjustsFontSizeToFitWidth = true
        subtitle.minimumScaleFactor = 0.7
        subtitle.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12))
        subtitle.adjustsFontForContentSizeCategory = true
        subtitle.textColor = .secondaryLabel
        subtitle.text = CYLDemoLocalizedString("超出默认行数,出现\"更多\"按钮,点击展开.@iOS程序犭袁 出品")
        header.addSubview(subtitle)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            title.centerYAnchor.constraint(equalTo: toggle.centerYAnchor),
            title.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -8),
            toggle.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            toggle.topAnchor.constraint(equalTo: header.topAnchor, constant: 20),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            subtitle.topAnchor.constraint(equalTo: toggle.bottomAnchor, constant: 8),
        ])
        rowsCountBydefaultSwitchClicked(toggle)
        return header
    }

    @objc func rowsCountBydefaultSwitchClicked(_ sender: UISwitch) {
        defaultVisibleRows = sender.isOn ? 2 : 1
        let title = sender.isOn ? CYLDemoLocalizedString("默认显示两行时的效果如下所示:") : CYLDemoLocalizedString("默认显示一行时的效果如下所示:")
        let highlight = sender.isOn ? CYLDemoLocalizedString("两行") : CYLDemoLocalizedString("一行")
        let text = NSMutableAttributedString(string: title)
        // The row count stands out in every language (found by text, not by a fixed range).
        let range = (title as NSString).range(of: highlight)
        if range.location != NSNotFound {
            text.addAttribute(.foregroundColor, value: UIColor.systemRed, range: range)
        }
        titleLabel?.attributedText = text
    }

}

extension CYLMainViewController: CYLMenuDelegate {

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        if (menu as AnyObject) === self, let classifySource {
            navigationItem.title = classifySource.menuTitleForItem(at: indexPath)
        }
    }
}

//
//  CYLTagDemoViewController.swift
//  TagCollectionView
//
//  Created by ak on 16/3/9.
//  Copyright © 2016年 (year 2016) AK. All rights reserved.
//
//  The demo of the core's CYLTagView: two sections of long tags. The titles are sample data (AGENTS.md,
//  localization exceptions).
//

import UIKit
import CollectionViewClassifyMenu

@objc(CYLTagDemoViewController)
final class CYLTagDemoViewController: UIViewController {

    private(set) weak var tagV: CYLTagView?

    /// Sample data: the tags of each section, and the section titles.
    let sections: [[String]] = [
        ["吃饭", "睡觉", "看书", "跑步", "听音乐", "看电影", "做饭", "逛公园"],
        ["吃饭", "睡觉", "看书", "游泳", "爬山", "打豆豆", "练武功", "写代码"],
    ]
    let sectionTitles = ["日常安排", "周末活动"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // From its nib, as +[CYLTagView tagView].
        let tagV: CYLTagView = CYLTagView.makeTagView()
        view.addSubview(tagV)
        tagV.frame = CGRect(x: 0, y: 20, width: 320, height: 200)
        self.tagV = tagV
        tagV.menuDataSource = self
        tagV.menuDelegate = self
        tagV.reloadMenuData()
    }
}

// MARK: - CYLMenuDataSource, CYLMenuDelegate

extension CYLTagDemoViewController: CYLMenuDataSource, CYLMenuDelegate {

    func numberOfSectionsInMenu() -> Int {
        sections.count
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        sections[section].count
    }

    func menuTitle(forSection section: Int) -> String {
        sectionTitles[section]
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        sections[indexPath.section][indexPath.item] + " 扩展文字😀✨"
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        NSLog("%@", menuTitleForItem(at: indexPath))
    }
}

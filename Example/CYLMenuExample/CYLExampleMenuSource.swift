//
//  CYLExampleMenuSource.swift
//  CYLMenuExample
//
//  A host-owned CYLMenuDataSource built from plain arrays. Everything the menu
//  shows comes from here; the core library holds no business data.
//

import UIKit
import CollectionViewClassifyMenu

@objcMembers
final class CYLExampleMenuItem: NSObject {
    var title: String
    var image: UIImage?
    var selectedImage: UIImage?
    /// Animated icon file (Lottie, PAG, Rive, GIF), played by CYLTabBarController's animation engine.
    var animationURL: URL?
    var isEnabled = true
    var isExclusive = false
    /// Free-form value for the host, such as a filter key.
    var value: Any?

    init(title: String) {
        self.title = title
        super.init()
    }

    override convenience init() {
        self.init(title: "")
    }
}

@objcMembers
final class CYLExampleMenuSection: NSObject {
    var title: String
    var image: UIImage?
    var accessoryView: UIView?
    var items: [CYLExampleMenuItem]

    init(title: String, items: [CYLExampleMenuItem]) {
        self.title = title
        self.items = items
        super.init()
    }

    /// Convenience: one plain item per title.
    convenience init(title: String, titles: [String]) {
        self.init(title: title, items: titles.map(CYLExampleMenuItem.init(title:)))
    }

    override convenience init() {
        self.init(title: "", items: [])
    }
}

@objcMembers
final class CYLExampleMenuSource: NSObject, CYLMenuDataSource {
    var sections: [CYLExampleMenuSection]

    init(sections: [CYLExampleMenuSection]) {
        self.sections = sections
        super.init()
    }

    override convenience init() {
        self.init(sections: [])
    }

    func item(at indexPath: IndexPath) -> CYLExampleMenuItem {
        sections[indexPath.section].items[indexPath.item]
    }

    // MARK: CYLMenuDataSource

    func numberOfSectionsInMenu() -> Int {
        sections.count
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        sections[section].items.count
    }

    func menuTitle(forSection section: Int) -> String {
        sections[section].title
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        item(at: indexPath).title
    }

    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        item(at: indexPath).image
    }

    func menuSelectedImageForItem(at indexPath: IndexPath) -> UIImage? {
        item(at: indexPath).selectedImage
    }

    func menuAnimationURLForItem(at indexPath: IndexPath) -> URL? {
        item(at: indexPath).animationURL
    }

    func menuImage(forSection section: Int) -> UIImage? {
        sections[section].image
    }

    func menuAccessoryView(forSection section: Int) -> UIView? {
        sections[section].accessoryView
    }

    func menuItemIsEnabled(at indexPath: IndexPath) -> Bool {
        item(at: indexPath).isEnabled
    }

    func menuItemIsExclusive(at indexPath: IndexPath) -> Bool {
        item(at: indexPath).isExclusive
    }
}

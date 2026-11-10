//
//  CYLTagEditorAppDelegate.swift
//  CYLTagEditorExample
//
//  A pure Swift Example of the core library (local pod): adding tags in a chat app's
//  "编辑标签" sheet. `-CYLExampleScreen <screen>[@<language>]` opens a screen directly for
//  scripts/example-screenshots.sh:
//    remark          编辑备注 with the tags chosen
//    editor          编辑标签 (tags.json's selectedTags selected)
//    editor-bottom   … scrolled to "+ 新建标签"
//    editor-search   … searching "ios": 搜索结果 ("iOS 开发") and "+ 新建标签：ios"
//    editor-created  … after tapping "+ 新建标签：ios": the new tag, selected, at the end
//    editor-new      … the name prompt of "+ 新建标签"
//    styles          折叠样式: every fold control and title style, made in code and from configuration files
//    styles-expanded … with every list expanded (the chevrons turned 180°)
//    styles-config   … scrolled to the lists made from JSON, plist, YAML and XML files
//

import UIKit
import CollectionViewClassifyMenu
import CYLTabBarController

@main
final class CYLTagEditorAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /// Loaded from tags.json after the language is chosen.
    private(set) var store = CYLTagStore(tags: [])
    private(set) var tagData = CYLTagData(version: 1, tags: [], recentTags: [], selectedTags: [], groups: nil)
    private(set) var tabBarController: CYLTabBarController?
    private(set) weak var foldStyles: CYLFoldStylesViewController?
    /// The tags the remark screen starts with in the screenshots (tags.json's selectedTags).
    private(set) var demoSelection: [String] = []

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        var screen = UserDefaults.standard.string(forKey: "CYLExampleScreen") ?? ""
        var language = UserDefaults.standard.string(forKey: "CYLExampleLanguage")
        if let at = screen.firstIndex(of: "@") {
            language = String(screen[screen.index(after: at)...])
            screen = String(screen[..<at])
        }
        if let language, !language.isEmpty {
            CYLTagEditorLocalization.preferredLanguage = language
        }

        // The demo tags of the chosen language, from the local JSON file.
        let data = (try? CYLTagData.bundled()) ?? tagData
        tagData = data
        store = CYLTagStore(data: data)
        demoSelection = data.selectedTags
        let remark = CYLRemarkViewController(store: store, tags: screen == "remark" ? demoSelection : [])
        let window = UIWindow(frame: UIScreen.main.bounds)
        // Two tabs at the bottom: the tag editor, and the fold styles of the core's tag list.
        let styles = CYLFoldStylesViewController(data: data)
        foldStyles = styles
        let tabs = Self.makeTabBarController(remark: remark, styles: styles)
        tabBarController = tabs
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window

        if !screen.isEmpty {
            DispatchQueue.main.async {
                self.open(screen, from: remark)
            }
            Self.removeLayoutReport()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.reportLayout(of: screen, root: remark)
            }
        }
        return true
    }

    /// The root tab bar (CYLTabBarController, at the bottom): 编辑标签 and 折叠样式.
    static func makeTabBarController(remark: CYLRemarkViewController, styles: CYLFoldStylesViewController) -> CYLTabBarController {
        let attributes: [[AnyHashable: Any]] = [
            [CYLTabBarItemTitle: CYLTagEditorLocalizedString("编辑标签"),
             CYLTabBarItemImage: UIImage(systemName: "tag")!,
             CYLTabBarItemSelectedImage: UIImage(systemName: "tag.fill")!],
            [CYLTabBarItemTitle: CYLTagEditorLocalizedString("折叠样式"),
             CYLTabBarItemImage: UIImage(systemName: "rectangle.expand.vertical")!,
             CYLTabBarItemSelectedImage: UIImage(systemName: "rectangle.compress.vertical")!],
        ]
        return CYLTabBarController(viewControllers: [UINavigationController(rootViewController: remark),
                                                     UINavigationController(rootViewController: styles)],
                                   tabBarItemsAttributes: attributes)
    }

    func open(_ screen: String, from remark: CYLRemarkViewController) {
        if screen.hasPrefix("styles") {
            guard let tabs = tabBarController, let styles = foldStyles else { return }
            tabs.selectedIndex = 1
            styles.loadViewIfNeeded()
            if screen == "styles-expanded" {
                styles.view.layoutIfNeeded()
                styles.expandAll()
            } else if screen == "styles-config" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    styles.scrollToConfigurationFiles()
                }
            }
            return
        }
        guard screen.hasPrefix("editor") else { return }
        remark.updateTags(demoSelection)
        let editor = remark.editTags(animated: false)
        editor.loadViewIfNeeded()
        switch screen {
        case "editor-bottom":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let last = editor.sections.count - 1
                editor.tagListView.scrollToItem(at: IndexPath(item: editor.sections[last].items.count - 1, section: last), animated: false)
            }
        case "editor-search":
            // Without focusing the field: the simulator's first-use keyboard tutorial would cover the sheet.
            editor.setQuery("ios")
        case "editor-created":
            editor.setQuery("ios")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                editor.createTag(named: "ios")
            }
        case "editor-new":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                editor.promptForNewTag()
            }
        default:
            break
        }
    }

    // MARK: Layout report (copied next to each screenshot)

    static var layoutReportURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("CYLExampleLayout.txt")
    }

    static func removeLayoutReport() {
        try? FileManager.default.removeItem(at: layoutReportURL)
    }

    static func appendLayoutReport(_ line: String) {
        print(line)
        let existing = (try? String(contentsOf: layoutReportURL, encoding: .utf8)) ?? ""
        try? (existing + line + "\n").write(to: layoutReportURL, atomically: true, encoding: .utf8)
    }

    func reportLayout(of screen: String, root: CYLRemarkViewController) {
        if let styles = foldStyles, screen.hasPrefix("styles") {
            let lists = styles.tagListViews.map { "\($0.title ?? "-")[\($0.foldControl.position.rawValue),\($0.foldControl.content.rawValue)] h=\($0.contentHeight)" }
            Self.appendLayoutReport("[CYLExampleLayout] screen=\(screen) lists=\(lists.count) errors=\(styles.configurationErrors.mapValues { $0.localizedDescription })")
            Self.appendLayoutReport("[CYLExampleLayout] \(lists.joined(separator: " | "))")
            return
        }
        Self.appendLayoutReport("[CYLExampleLayout] screen=\(screen) top=\(type(of: root.presentedViewController ?? root)) tags=\(root.tags)")
        if let editor = root.presentedViewController as? CYLTagEditorViewController {
            let sections = editor.sections.map { "\($0.title)(\($0.items.count))" }.joined(separator: ",")
            Self.appendLayoutReport("[CYLExampleLayout] editor sections=\(sections) selected=\(editor.selectedTags) query=\(editor.query) "
                                    + "done=\(editor.isDoneEnabled) tagList=\(NSCoder.string(for: editor.tagListView.frame)) "
                                    + "contentHeight=\(editor.tagListView.contentHeight) selectedIndexPaths=\(editor.tagListView.selectedIndexPaths.count)")
        }
    }
}

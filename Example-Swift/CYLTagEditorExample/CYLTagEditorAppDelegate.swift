//
//  CYLTagEditorAppDelegate.swift
//  CYLTagEditorExample
//
//  A pure Swift Example of the core library (local pod): adding tags in a chat app's
//  "编辑标签" sheet. `-CYLExampleScreen <screen>[@<language>]` opens a screen directly for
//  scripts/example-screenshots.sh:
//    remark          编辑备注 with the tags chosen
//    editor          编辑标签 (nz, 家人, 留学 selected)
//    editor-bottom   … scrolled to "+ 新建标签"
//    editor-search   … searching "ios": 搜索结果 and "+ 新建标签：ios"
//    editor-created  … after tapping "+ 新建标签：ios": the new tag, selected, at the end
//    editor-new      … the name prompt of "+ 新建标签"
//

import UIKit
import CollectionViewClassifyMenu

@main
final class CYLTagEditorAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let store = CYLTagStore.demo()

    static let demoSelection = ["nz", "家人", "留学"]

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

        let remark = CYLRemarkViewController(store: store, tags: screen == "remark" ? Self.demoSelection : [])
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: remark)
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

    func open(_ screen: String, from remark: CYLRemarkViewController) {
        guard screen.hasPrefix("editor") else { return }
        remark.updateTags(Self.demoSelection)
        let editor = remark.editTags(animated: false)
        editor.loadViewIfNeeded()
        switch screen {
        case "editor-bottom":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let last = editor.sections.count - 1
                editor.tagListView.scrollToItem(at: IndexPath(item: editor.sections[last].items.count - 1, section: last), animated: false)
            }
        case "editor-search":
            editor.setQuery("ios")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                editor.searchField.becomeFirstResponder()
            }
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
        Self.appendLayoutReport("[CYLExampleLayout] screen=\(screen) top=\(type(of: root.presentedViewController ?? root)) tags=\(root.tags)")
        if let editor = root.presentedViewController as? CYLTagEditorViewController {
            let sections = editor.sections.map { "\($0.title)(\($0.items.count))" }.joined(separator: ",")
            Self.appendLayoutReport("[CYLExampleLayout] editor sections=\(sections) selected=\(editor.selectedTags) query=\(editor.query) "
                                    + "done=\(editor.isDoneEnabled) tagList=\(NSCoder.string(for: editor.tagListView.frame)) "
                                    + "contentHeight=\(editor.tagListView.contentHeight) selectedIndexPaths=\(editor.tagListView.selectedIndexPaths.count)")
        }
    }
}

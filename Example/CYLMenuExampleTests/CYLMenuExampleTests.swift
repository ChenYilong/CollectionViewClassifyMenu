//
//  CYLMenuExampleTests.swift
//  CYLMenuExampleTests
//
//  Covers the CYLTagListView API and the two README scenarios built with it.
//

import XCTest
import UIKit
import CollectionViewClassifyMenu
import CYLTabBarController
@testable import CYLMenuExample

final class CYLRecordingDelegate: NSObject, CYLMenuDelegate {
    var events: [String] = []
    var blockedIndexPath: IndexPath?
    var lastHeight: CGFloat = 0
    var changeCount = 0

    /// item-section, as the expectations are written.
    func describe(_ indexPath: IndexPath) -> String {
        "\(indexPath.item)-\(indexPath.section)"
    }

    func menu(_ menu: Any, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        indexPath != blockedIndexPath
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        events.append("select " + describe(indexPath))
    }

    func menu(_ menu: Any, didDeselectItemAt indexPath: IndexPath) {
        events.append("deselect " + describe(indexPath))
    }

    func menu(_ menu: Any, didChangeExpanded expanded: Bool, inSection section: Int) {
        events.append("\(expanded ? "expand" : "collapse") \(section)")
    }

    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        lastHeight = height
    }

    func menu(_ menu: Any, didChangeSelectedItems indexPaths: [IndexPath]) {
        changeCount += 1
    }
}

final class CYLMenuExampleTests: XCTestCase {

    private var window: UIWindow?

    override func setUp() {
        super.setUp()
        // The expectations below are written in Chinese; the simulator's language may differ.
        CYLMenuResources.preferredLanguage = "zh-Hans"
    }

    override func tearDown() {
        window?.isHidden = true
        window = nil
        CYLMenuResources.preferredLanguage = nil
        super.tearDown()
    }

    // MARK: Helpers

    private func makeSource(itemCount count: Int, sections: Int) -> CYLExampleMenuSource {
        var result: [CYLExampleMenuSection] = []
        for section in 0..<sections {
            let titles = (0..<count).map { "标签 \(section)-\($0) 🌟" }
            result.append(CYLExampleMenuSection(title: "分组 \(section)", titles: titles))
        }
        return CYLExampleMenuSource(sections: result)
    }

    private func hostedView(source: CYLExampleMenuSource, width: CGFloat) -> CYLTagListView {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 700))
        let controller = UIViewController()
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
        let view = CYLTagListView(frame: CGRect(x: 0, y: 0, width: width, height: 700))
        view.menuDataSource = source
        controller.view.addSubview(view)
        view.reloadMenuData()
        view.layoutIfNeeded()
        return view
    }

    private func collectionView(of view: UIView) -> UICollectionView {
        view.value(forKey: "collectionView") as! UICollectionView
    }

    private func tap(_ view: CYLTagListView, item: Int, section: Int) {
        let collection = collectionView(of: view)
        collection.delegate?.collectionView?(collection, didSelectItemAt: IndexPath(item: item, section: section))
    }

    private func ip(_ item: Int, _ section: Int) -> IndexPath {
        IndexPath(item: item, section: section)
    }

    /// The tag button of a cell (CYLTagListCell.button).
    private func tagButton(in collection: UICollectionView, at indexPath: IndexPath) -> CYLTagButton? {
        (collection.cellForItem(at: indexPath) as? CYLTagListCell)?.button
    }

    private func foldButton(of view: UICollectionReusableView?) -> CYLTagButton? {
        view?.value(forKey: "foldButton") as? CYLTagButton
    }

    private func assertNoOverlapsOrOverflow(in view: CYLTagListView, file: StaticString = #filePath, line: UInt = #line) {
        let collection = collectionView(of: view)
        collection.layoutIfNeeded()
        let maxX = collection.bounds.width - view.style.sectionInsets.right + 0.5
        for section in 0..<collection.numberOfSections {
            var previous: UICollectionViewLayoutAttributes?
            for item in 0..<collection.numberOfItems(inSection: section) {
                let attributes = collection.collectionViewLayout.layoutAttributesForItem(at: ip(item, section))
                XCTAssertNotNil(attributes, file: file, line: line)
                guard let attributes else { continue }
                XCTAssertLessThanOrEqual(attributes.frame.maxX, maxX, file: file, line: line)
                if let previous {
                    XCTAssertFalse(previous.frame.intersects(attributes.frame), file: file, line: line)
                }
                previous = attributes
            }
        }
    }

    // MARK: Selection

    func testSingleSelectionReplacesWithinSectionAndReportsDeselect() {
        let source = makeSource(itemCount: 4, sections: 2)
        let view = hostedView(source: source, width: 375)
        let delegate = CYLRecordingDelegate()
        view.menuDelegate = delegate
        XCTAssertEqual(view.selectionMode, .single)

        tap(view, item: 0, section: 0)
        tap(view, item: 2, section: 0)
        tap(view, item: 1, section: 1)
        XCTAssertEqual(view.selectedIndexPaths, [ip(2, 0), ip(1, 1)])
        XCTAssertEqual(delegate.events, ["select 0-0", "deselect 0-0", "select 2-0", "select 1-1"])
        XCTAssertEqual(delegate.changeCount, 3, "One change notification per tap that changed the selection")

        tap(view, item: 2, section: 0)
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 1)], "Empty selection is allowed by default")

        view.allowsEmptySelection = false
        tap(view, item: 1, section: 1)
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 1)], "The last selection stays")
    }

    func testMultipleSelectionHonoursExclusiveItems() {
        let source = makeSource(itemCount: 4, sections: 1)
        source.sections[0].items[0].isExclusive = true
        let view = hostedView(source: source, width: 375)
        view.selectionMode = .multiple
        view.selectedIndexPaths = [ip(0, 0)]

        tap(view, item: 1, section: 0)
        tap(view, item: 2, section: 0)
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 0), ip(2, 0)])
        tap(view, item: 0, section: 0)
        XCTAssertEqual(view.selectedIndexPaths, [ip(0, 0)])
    }

    func testNoneModeReportsTapsWithoutKeepingSelection() {
        let source = makeSource(itemCount: 3, sections: 1)
        let view = hostedView(source: source, width: 375)
        let delegate = CYLRecordingDelegate()
        view.menuDelegate = delegate
        view.selectionMode = .none
        tap(view, item: 1, section: 0)
        view.selectItem(at: ip(2, 0))
        XCTAssertEqual(view.selectedIndexPaths, [])
        XCTAssertEqual(delegate.events, ["select 1-0"])
    }

    func testDisabledAndVetoedItemsAreIgnored() {
        let source = makeSource(itemCount: 3, sections: 1)
        source.sections[0].items[1].isEnabled = false
        let view = hostedView(source: source, width: 375)
        let delegate = CYLRecordingDelegate()
        delegate.blockedIndexPath = ip(2, 0)
        view.menuDelegate = delegate
        tap(view, item: 1, section: 0)
        tap(view, item: 2, section: 0)
        XCTAssertEqual(view.selectedIndexPaths, [])
        XCTAssertEqual(delegate.events, [])
    }

    func testProgrammaticSelectionValidatesAndDoesNotCallDelegate() {
        let source = makeSource(itemCount: 3, sections: 1)
        let view = hostedView(source: source, width: 375)
        let delegate = CYLRecordingDelegate()
        view.menuDelegate = delegate
        view.selectItem(at: ip(1, 0))
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 0)])
        view.deselectItem(at: ip(1, 0))
        XCTAssertEqual(view.selectedIndexPaths, [])
        view.selectedIndexPaths = [ip(2, 0)]
        view.deselectAllItems()
        XCTAssertEqual(view.selectedIndexPaths, [])
        // Not ported: -[CYLTagListView setSelectedIndexPaths:] raises NSInvalidArgumentException for an index path
        // outside the data (the Objective-C test checked it with XCTAssertThrowsSpecificNamed); Swift cannot catch an
        // Objective-C exception, so that assertion is left out.
        XCTAssertEqual(delegate.events, [])
    }

    func testSelectedCellsUseSelectedStyleAfterReuse() {
        let style = CYLMenuStyle()
        style.selectedAppearance.backgroundColor = .red
        let source = makeSource(itemCount: 200, sections: 1)
        let view = hostedView(source: source, width: 320)
        view.style = style
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        view.layoutIfNeeded()
        view.selectedIndexPaths = [ip(0, 0)]
        let collection = collectionView(of: view)
        collection.setContentOffset(CGPoint(x: 0, y: collection.contentSize.height - 200), animated: false)
        collection.layoutIfNeeded()
        collection.setContentOffset(.zero, animated: false)
        collection.layoutIfNeeded()
        for indexPath in collection.indexPathsForVisibleItems {
            let button = tagButton(in: collection, at: indexPath)
            let red = button?.layer.backgroundColor == UIColor.red.cgColor
            XCTAssertEqual(red, indexPath.item == 0, "\(indexPath)")
        }
    }

    // MARK: Folding and size

    func testFooterChevronFoldsAndReportsHeight() {
        let source = makeSource(itemCount: 30, sections: 1)
        let view = hostedView(source: source, width: 320)
        let delegate = CYLRecordingDelegate()
        view.menuDelegate = delegate
        view.showsSectionHeaders = false
        view.defaultVisibleRows = 2
        view.foldStyle = .footerChevron
        view.layoutIfNeeded()
        let collection = collectionView(of: view)

        XCTAssertTrue(view.canFoldSection(0))
        XCTAssertGreaterThan(view.numberOfRows(inSection: 0), 2)
        let collapsed = collection.numberOfItems(inSection: 0)
        XCTAssertLessThan(collapsed, 30)
        XCTAssertEqual(collapsed, view.numberOfVisibleItems(inSection: 0))
        let collapsedHeight = view.contentHeight
        XCTAssertEqual(collapsedHeight, view.heightThatFitsWidth(320), accuracy: 1)
        XCTAssertEqual(view.intrinsicContentSize.height, collapsedHeight, accuracy: 0.5)
        let footer = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: ip(0, 0))
        XCTAssertNotNil(footer)

        view.setExpanded(true, forSection: 0, animated: false)
        XCTAssertTrue(view.isSectionExpanded(0))
        XCTAssertEqual(collection.numberOfItems(inSection: 0), 30)
        XCTAssertGreaterThan(view.contentHeight, collapsedHeight)
        XCTAssertEqual(view.contentHeight, view.heightThatFitsWidth(320), accuracy: 1)
        XCTAssertEqual(delegate.lastHeight, view.contentHeight, accuracy: 0.5)
        assertNoOverlapsOrOverflow(in: view)

        view.setExpanded(false, forSection: 0, animated: false)
        XCTAssertEqual(collection.numberOfItems(inSection: 0), collapsed)
        XCTAssertEqual(delegate.events, ["expand 0", "collapse 0"])
    }

    func testTruncateStyleShowsRowsWithoutControls() {
        let source = makeSource(itemCount: 30, sections: 1)
        let view = hostedView(source: source, width: 320)
        view.showsSectionHeaders = false
        view.defaultVisibleRows = 2
        view.foldStyle = .truncate
        view.layoutIfNeeded()
        let collection = collectionView(of: view)
        XCTAssertLessThan(collection.numberOfItems(inSection: 0), 30)
        XCTAssertNil(collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: ip(0, 0)))
        XCTAssertNil(collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: ip(0, 0)))
    }

    func testHeaderButtonFoldsEachSectionIndependently() {
        let source = makeSource(itemCount: 20, sections: 2)
        let view = hostedView(source: source, width: 320)
        view.foldStyle = .headerButton
        view.defaultVisibleRows = 1
        view.layoutIfNeeded()
        let collection = collectionView(of: view)
        let header = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: ip(0, 0))
        let fold = foldButton(of: header)
        XCTAssertNotNil(fold, "The fold control is a tag view (CYLTagFoldButton)")
        XCTAssertFalse(fold?.isHidden ?? true)
        XCTAssertEqual(fold?.title, view.style.expandTitle)
        XCTAssertEqual(view.foldControl.position, .topTrailing, "foldStyle sets foldControl")
        fold?.sendActions(for: .touchUpInside)
        XCTAssertTrue(view.isSectionExpanded(0))
        XCTAssertFalse(view.isSectionExpanded(1))
        XCTAssertEqual(collection.numberOfItems(inSection: 0), 20)
        XCTAssertLessThan(collection.numberOfItems(inSection: 1), 20)
    }

    func testReloadKeepsValidStateAndDropsStaleState() {
        let source = makeSource(itemCount: 30, sections: 2)
        let view = hostedView(source: source, width: 320)
        view.foldStyle = .headerButton
        view.selectedIndexPaths = [ip(1, 0), ip(20, 1)]
        view.setExpanded(true, forSection: 1, animated: false)
        source.sections = self.makeSource(itemCount: 5, sections: 1).sections
        view.reloadMenuData()
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 0)])
        XCTAssertFalse(view.isSectionExpanded(1))
        XCTAssertEqual(collectionView(of: view).numberOfSections, 1)
    }

    // MARK: Data source hooks and style

    func testImagesHeaderIconsAndAccessoryViewsComeFromTheHost() {
        let source = makeSource(itemCount: 3, sections: 1)
        let icon = UIImage(systemName: "star.fill")
        source.sections[0].items[0].image = icon
        // Same title, so the image alone accounts for the width difference
        // (system digits are proportional).
        source.sections[0].items[1].title = source.sections[0].items[0].title
        source.sections[0].image = icon
        let accessory = UIButton(type: .system)
        accessory.setTitle("行业: IT互联网 ▾", for: .normal)
        source.sections[0].accessoryView = accessory
        let view = hostedView(source: source, width: 375)
        let collection = collectionView(of: view)
        collection.layoutIfNeeded()

        let withImage = collection.collectionViewLayout.layoutAttributesForItem(at: ip(0, 0))?.frame.size.width ?? 0
        let withoutImage = collection.collectionViewLayout.layoutAttributesForItem(at: ip(1, 0))?.frame.size.width ?? 0
        XCTAssertEqual(withImage - withoutImage, view.style.imageSize.width + view.style.imageTitleSpacing, accuracy: 1,
                       "The image accounts for the difference")
        let button = tagButton(in: collection, at: ip(0, 0))
        XCTAssertTrue(button?.imageView.image === icon)

        let header = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: ip(0, 0))
        header?.layoutIfNeeded()
        XCTAssertTrue(accessory.superview === header)
        XCTAssertLessThanOrEqual(accessory.frame.maxX, header?.bounds.width ?? 0)
        let title = header?.value(forKey: "titleLabel") as? UILabel
        XCTAssertLessThanOrEqual(title?.frame.maxX ?? .infinity, accessory.frame.minX)
        XCTAssertTrue((header?.value(forKey: "iconView") as? UIImageView)?.image === icon)
    }

    func testStyleAndDynamicTypeChangeItemSize() {
        let source = makeSource(itemCount: 40, sections: 1)
        let view = hostedView(source: source, width: 320)
        let style = CYLMenuStyle()
        style.itemHeight = 40
        style.normalAppearance.cornerRadius = 0  // automatic capsule
        view.style = style
        view.layoutIfNeeded()
        let collection = collectionView(of: view)
        XCTAssertEqual(collection.collectionViewLayout.layoutAttributesForItem(at: ip(0, 0))?.frame.size.height ?? 0, 40, accuracy: 0.5)
        style.itemHeight = 10
        XCTAssertEqual(view.style.itemHeight, 40, accuracy: 0.01, "The view keeps its own copy")

        let large = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        let largeFont = view.style.titleFont(for: .normal, traitCollection: large)
        let base = view.style.normalAppearance.font.pointSize
        XCTAssertGreaterThan(largeFont.pointSize, base)
        XCTAssertLessThanOrEqual(largeFont.pointSize, base * CYLMaximumFontScale + 0.01)
        let fixed = view.style.copy() as! CYLMenuStyle
        fixed.adjustsFontForContentSizeCategory = false
        XCTAssertEqual(fixed.titleFont(for: .normal, traitCollection: large).pointSize, base, accuracy: 0.01)
    }

    func testNarrowWidthsAndLongTitlesStayInside() {
        for width in [240.0, 320.0, 390.0] as [CGFloat] {
            let source = makeSource(itemCount: 25, sections: 3)
            source.sections[1].items[0].title = "一个非常非常非常非常非常非常非常非常非常长的标签 🧑‍🍳✨🚀"
            let view = hostedView(source: source, width: width)
            view.foldStyle = .headerButton
            view.layoutIfNeeded()
            assertNoOverlapsOrOverflow(in: view)
            for section in 0..<3 {
                view.setExpanded(true, forSection: section, animated: false)
            }
            assertNoOverlapsOrOverflow(in: view)
            XCTAssertEqual(view.contentHeight, view.heightThatFitsWidth(width), accuracy: 1)
        }
    }

    // MARK: Tag button (CYLFlatDesignTabBarItem layout, CYLBadgeView box)

    private func makeButton(title: String?, image: UIImage?, style: CYLMenuStyle) -> CYLTagButton {
        let button = CYLTagButton(frame: CGRect(x: 0, y: 0, width: 160, height: 30))
        button.style = style
        button.title = title
        button.image = image
        button.layoutIfNeeded()
        return button
    }

    func testTagButtonPutsTheIconBeforeTheTitle() {
        let style = CYLMenuStyle()
        style.imageTitleSpacing = 6
        let button = makeButton(title: "消息", image: UIImage(systemName: "message"), style: style)
        let image = button.imageView.frame
        let title = button.titleLabel.frame
        XCTAssertEqual(title.minX - image.maxX, 6, accuracy: 0.5, "imageTitleSpacing")
        XCTAssertEqual(image.midY, title.midY, accuracy: 1, "Side by side, not stacked")
        XCTAssertEqual(image.minX, 160 - title.maxX, accuracy: 1, "The group is centered")
        XCTAssertEqual(image.size, style.imageSize)

        let font = style.titleFont(for: .normal, traitCollection: button.traitCollection)
        let expected = 2 * style.normalAppearance.margin + style.imageSize.width + 6 +
            ceil(("消息" as NSString).size(withAttributes: [.font: font]).width)
        XCTAssertEqual(CYLTagButton.width(forTitle: "消息", image: UIImage(systemName: "message"), style: style,
                                          traitCollection: button.traitCollection), expected, accuracy: 1)
    }

    func testTagButtonLayoutCenteredForIconOnlyAndTitleOnly() {
        let style = CYLMenuStyle()
        XCTAssertTrue(style.layoutCentered)
        var iconOnly = makeButton(title: nil, image: UIImage(systemName: "house"), style: style)
        XCTAssertEqual(iconOnly.imageView.frame.midX, 80, accuracy: 1)
        XCTAssertTrue(iconOnly.titleLabel.frame.isEmpty)
        var titleOnly = makeButton(title: "首页", image: nil, style: style)
        XCTAssertEqual(titleOnly.titleLabel.frame.midX, 80, accuracy: 1)
        XCTAssertTrue(titleOnly.imageView.frame.isEmpty)

        style.layoutCentered = false
        iconOnly = makeButton(title: nil, image: UIImage(systemName: "house"), style: style)
        XCTAssertEqual(iconOnly.imageView.frame.minX, style.normalAppearance.margin, accuracy: 0.5)
        titleOnly = makeButton(title: "首页", image: nil, style: style)
        XCTAssertEqual(titleOnly.titleLabel.frame.minX,
                       style.normalAppearance.margin + style.imageSize.width + style.imageTitleSpacing, accuracy: 0.5,
                       "The title keeps its place after an empty icon slot")
        XCTAssertGreaterThan(CYLTagButton.width(forTitle: "首页", image: nil, style: style, traitCollection: nil),
                             CYLTagButton.width(forTitle: "首页", image: nil, style: CYLMenuStyle(), traitCollection: nil))
    }

    func testTagButtonPositionAdjustmentsAndImageInsets() {
        let style = CYLMenuStyle()
        let plain = makeButton(title: "同城", image: UIImage(systemName: "mappin"), style: style)
        style.titlePositionAdjustment = UIOffset(horizontal: 3, vertical: -2)
        style.imagePositionAdjustment = UIOffset(horizontal: -4, vertical: 1)
        style.imageInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let moved = makeButton(title: "同城", image: UIImage(systemName: "mappin"), style: style)
        XCTAssertEqual(moved.titleLabel.frame.minX - plain.titleLabel.frame.minX, 3, accuracy: 0.5)
        XCTAssertEqual(moved.titleLabel.frame.minY - plain.titleLabel.frame.minY, -2, accuracy: 0.5)
        XCTAssertEqual(moved.imageView.frame.minX - plain.imageView.frame.minX, -4, accuracy: 0.5)
        XCTAssertEqual(moved.imageView.frame.minY - plain.imageView.frame.minY, 1, accuracy: 0.5)
        XCTAssertEqual(moved.imageView.frame.width, style.imageSize.width - 4, accuracy: 0.01, "imageInsets shrink the icon in place")
    }

    func testTagButtonColorsFontsAndSelectedImagePerState() {
        let style = CYLMenuStyle()
        let font = UIFont.boldSystemFont(ofSize: 17)
        style.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.red], for: .normal)
        style.setIconColor(.blue, for: .normal)
        style.setIconColor(.yellow, for: .selected)
        XCTAssertEqual(style.titleTextAttributes(for: .normal)[.foregroundColor] as? UIColor, UIColor.red)
        XCTAssertEqual(style.normalAppearance.font, font)
        XCTAssertEqual(style.iconColor(for: .disabled), style.disabledAppearance.textColor, "nil iconColor uses the text color")

        let normal = UIImage(systemName: "star")
        let selected = UIImage(systemName: "star.fill")
        let button = makeButton(title: "我的", image: normal, style: style)
        button.selectedImage = selected
        XCTAssertEqual(button.titleLabel.textColor, UIColor.red)
        XCTAssertEqual(button.imageView.tintColor, UIColor.blue)
        XCTAssertTrue(button.imageView.image === normal)
        button.isSelected = true
        XCTAssertTrue(button.imageView.image === selected)
        XCTAssertEqual(button.imageView.tintColor, UIColor.yellow)
        XCTAssertEqual(button.titleLabel.textColor, style.selectedAppearance.textColor)
        button.isEnabled = false
        XCTAssertEqual(button.titleLabel.textColor, style.disabledAppearance.textColor, "Disabled wins over selected")

        style.setTitleTextAttributes(nil, for: .normal)
        XCTAssertEqual(style.normalAppearance.font, UIFont.systemFont(ofSize: 14), "nil restores the default, as CYLBadgeAppearance")
    }

    func testTagBoxFollowsCYLBadgeAppearance() {
        let appearance = CYLTagAppearance()
        appearance.cornerRadius = -3
        appearance.borderWidth = .nan
        appearance.margin = -1
        XCTAssertEqual(appearance.cornerRadius, 0)
        XCTAssertEqual(appearance.borderWidth, 0)
        XCTAssertEqual(appearance.margin, 0)
        appearance.backgroundColor = .red
        appearance.backgroundColor = nil
        XCTAssertEqual(appearance.backgroundColor, UIColor.white, "null_resettable")
        appearance.reset()
        XCTAssertEqual(appearance.margin, 10)

        let style = CYLMenuStyle()
        style.normalAppearance.cornerRadius = 0
        style.normalAppearance.borderColor = .green
        style.normalAppearance.borderWidth = 2
        style.normalAppearance.backgroundColor = .cyan
        let button = makeButton(title: "首页", image: nil, style: style)
        XCTAssertEqual(button.layer.cornerRadius, 15, accuracy: 0.01, "0 is an automatic capsule")
        XCTAssertEqual(button.layer.borderWidth, 2)
        XCTAssertTrue(button.layer.borderColor == UIColor.green.cgColor)
        XCTAssertTrue(button.layer.backgroundColor == UIColor.cyan.cgColor)
        style.normalAppearance.cornerRadius = 5
        button.style = style
        button.layoutIfNeeded()
        XCTAssertEqual(button.layer.cornerRadius, 5, accuracy: 0.01)
        XCTAssertEqual((style.copy() as! CYLMenuStyle).normalAppearance.cornerRadius, 5)
        XCTAssertFalse((style.copy() as! CYLMenuStyle).normalAppearance === style.normalAppearance, "A copy has its own appearances")
    }

    func testStyleDemoRowsRestyleTheTagsLive() {
        let demo = CYLTagStyleDemoViewController()
        host(demo)
        demo.view.layoutIfNeeded()
        let actions = demo.actionIdentifiers()
        XCTAssertEqual(demo.tableView.numberOfSections, actions.count)
        XCTAssertEqual(demo.tableView.numberOfRows(inSection: 0), actions[0].count)
        let collection = collectionView(of: demo.tagListView)
        collection.layoutIfNeeded()
        var first = tagButton(in: collection, at: ip(1, 0))
        XCTAssertNotNil(first?.imageView.image)
        XCTAssertGreaterThan(first?.title?.count ?? 0, 0)

        // A tap on the cornerRadius row: 0 makes capsules.
        let cornerRow = IndexPath(row: actions[1].firstIndex(of: "cornerRadius") ?? 0, section: 1)
        demo.tableView.delegate?.tableView?(demo.tableView, didSelectRowAt: cornerRow)
        collection.layoutIfNeeded()
        first = tagButton(in: collection, at: ip(1, 0))
        XCTAssertEqual(demo.tagListView.style.normalAppearance.cornerRadius, 0)
        XCTAssertEqual(first?.layer.cornerRadius ?? -1, (first?.bounds.height ?? 0) / 2, accuracy: 0.5)

        demo.performAction("iconColor.normal")
        collection.layoutIfNeeded()
        first = tagButton(in: collection, at: ip(1, 0))
        XCTAssertEqual(first?.imageView.tintColor, demo.style.iconColor(for: .normal))

        demo.performAction("content.iconOnly")
        collection.layoutIfNeeded()
        first = tagButton(in: collection, at: ip(1, 0))
        XCTAssertEqual(first?.title?.count ?? 0, 0)
        XCTAssertEqual(first?.imageView.frame.midX ?? 0, (first?.bounds.width ?? 0) / 2, accuracy: 1, "layoutCentered")

        demo.performAction("reset")
        XCTAssertEqual(demo.content, .iconAndTitle)
        XCTAssertEqual(demo.tagListView.style.normalAppearance.cornerRadius, 3)
    }

    // MARK: Configuration (map and file, as CYLTabBarController)

    func testDictionaryConfigurationCreatesAndStylesTheTags() {
        let view = CYLTagListView(configuration: CYLTagConfigurationDemoViewController.mapConfiguration())
        view.frame = CGRect(x: 0, y: 0, width: 375, height: 300)
        view.layoutIfNeeded()
        XCTAssertEqual(view.selectionMode, .multiple)
        XCTAssertFalse(view.isScrollEnabled)
        XCTAssertEqual(view.selectedIndexPaths, [ip(1, 0)])
        XCTAssertNotNil(view.configurationDataSource, "The view keeps the data source it built")
        XCTAssertTrue(view.menuDataSource === view.configurationDataSource)
        XCTAssertEqual(view.menuDataSource?.menuNumberOfItems(inSection: 0), 5)
        XCTAssertEqual(view.menuDataSource?.menuTitleForItem(at: ip(4, 0)), "Text only", "A string item is a title")
        XCTAssertNotNil(view.menuDataSource?.menuImageForItem?(at: ip(3, 0)), "system: images are SF Symbols")
        XCTAssertEqual(view.style.imageSize, CGSize(width: 20, height: 20))
        XCTAssertEqual(view.style.normalAppearance.cornerRadius, 8)
        XCTAssertEqual(view.style.normalAppearance.iconColor, UIColor.systemIndigo)
    }

    func testConfigurationStringValuesAreConverted() {
        let normal: [String: Any] = [
            CYLTagAppearanceTextColor: "#FF0000",
            CYLTagAppearanceBorderColor: "systemBlue",
            CYLTagAppearanceFont: ["size": 15, "weight": "bold"] as [String: Any],
            CYLTagAppearanceMargin: "6",
        ]
        let style: [String: Any] = [
            CYLMenuStyleImageInsets: "{1, 2, 3, 4}",
            CYLMenuStyleTitlePositionAdjustment: [2, -1],
            CYLMenuStyleImageSize: ["width": 18, "height": 16],
            CYLMenuStyleLayoutCentered: "no",
            CYLMenuStyleNormal: normal,
        ]
        let sections: [[String: Any]] = [
            [CYLTagSectionTitle: "A", CYLTagSectionItems: ["x", "y"]],
            [CYLTagSectionTitle: "B", CYLTagSectionItems: [[CYLTagItemTitle: "z", CYLTagItemEnabled: "false"]]],
        ]
        let view = CYLTagListView(configuration: [
            CYLTagListViewSelectionMode: "single",
            CYLTagListViewFoldStyle: "footerChevron",
            CYLTagListViewDefaultVisibleRows: "2",
            CYLTagListViewShowsSectionHeaders: "false",
            CYLTagListViewSelectedItems: ["1-0"],
            CYLTagListViewStyle: style,
            CYLTagListViewSections: sections,
        ])
        XCTAssertEqual(view.selectionMode, .single)
        XCTAssertEqual(view.foldStyle, .footerChevron)
        XCTAssertEqual(view.defaultVisibleRows, 2)
        XCTAssertFalse(view.showsSectionHeaders)
        XCTAssertEqual(view.selectedIndexPaths, [ip(0, 1)], "\"section-item\"")
        XCTAssertEqual(view.style.imageInsets, UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4))
        XCTAssertEqual(view.style.titlePositionAdjustment, UIOffset(horizontal: 2, vertical: -1))
        XCTAssertEqual(view.style.imageSize, CGSize(width: 18, height: 16))
        XCTAssertFalse(view.style.layoutCentered)
        var red: CGFloat = 0, green: CGFloat = 1, blue: CGFloat = 1, alpha: CGFloat = 0
        _ = view.style.normalAppearance.textColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        XCTAssertEqual(red, 1, accuracy: 0.01)
        XCTAssertEqual(green, 0, accuracy: 0.01)
        XCTAssertEqual(view.style.normalAppearance.borderColor, UIColor.systemBlue)
        XCTAssertEqual(view.style.normalAppearance.font.pointSize, 15, accuracy: 0.01)
        XCTAssertTrue(view.style.normalAppearance.font.fontDescriptor.symbolicTraits.contains(.traitBold))
        XCTAssertEqual(view.style.normalAppearance.margin, 6)
        XCTAssertEqual(view.menuDataSource?.menuItemIsEnabled?(at: ip(0, 1)), false)
    }

    func testConfigurationFileCreatesAnimatedTags() throws {
        let file = CYLTagConfigurationDemoViewController.configurationFilePath()
        let configuration = try CYLTagListView.configuration(withContentsOfFile: file)
        XCTAssertFalse(configuration.isEmpty)
        let view = try CYLTagListView(configurationFile: file)
        XCTAssertEqual(view.selectionMode, .single)
        XCTAssertFalse(view.allowsEmptySelection)
        XCTAssertEqual(view.foldStyle, .footerChevron)
        XCTAssertEqual(view.selectedIndexPaths, [ip(0, 0)])
        XCTAssertEqual(view.style.normalAppearance.cornerRadius, 0, "A capsule")
        for item in 0..<4 {
            let url = view.menuDataSource?.menuAnimationURLForItem?(at: ip(item, 0))
            XCTAssertNotNil(url, "item \(item)")
            XCTAssertTrue(FileManager.default.fileExists(atPath: url?.path ?? ""), "\(String(describing: url)) resolves next to the file or in the app")
        }
        XCTAssertThrowsError(try CYLTagListView(configurationFile: "missing.json")) { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, CYLMenuConfigurationError.errorDomain)
            XCTAssertEqual(error.code, CYLMenuConfigurationError.Code.fileNotFound.rawValue)
        }
    }

    // MARK: Animated icons (CYLTabBarController animation engine)

    func testAnimationOptionsAreEncodedAsCYLTabBarControllerDoes() {
        let file = URL(fileURLWithPath: "/tmp/icons.riv")
        XCTAssertNil(CYLMenuAnimationURLWithOptions(nil, ["artboard": "CHAT"]))
        XCTAssertEqual(CYLMenuAnimationURLWithOptions(file, nil), file)
        let url = CYLMenuAnimationURLWithOptions(file, ["stateMachine": "State Machine 1", "artboard": "A&B", "duration": 2])
        XCTAssertEqual(url?.path, file.path)
        XCTAssertEqual(url?.fragment, "artboard=A%26B&duration=2&stateMachine=State%20Machine%201", "Sorted, percent-encoded")

        let items: [[String: Any]] = [
            [CYLTagItemTitle: "a", CYLTagItemAnimation: "CYLMenuExample.bundle/Animations/Rive/icons.riv",
             CYLTagItemAnimationOptions: ["artboard": "CHAT", "input": "active"]],
            [CYLTagItemTitle: "b", CYLTagItemAnimation: "CYLMenuExample.bundle/Animations/Rive/icons.riv#artboard=USER"],
        ]
        let sections: [[String: Any]] = [[CYLTagSectionItems: items]]
        let view = CYLTagListView(configuration: [CYLTagListViewSections: sections])
        let first = view.menuDataSource?.menuAnimationURLForItem?(at: ip(0, 0))
        let second = view.menuDataSource?.menuAnimationURLForItem?(at: ip(1, 0))
        XCTAssertEqual(first?.fragment, "artboard=CHAT&input=active")
        XCTAssertEqual(second?.fragment, "artboard=USER", "A fragment in a file name is kept")
        XCTAssertTrue(FileManager.default.fileExists(atPath: first?.path ?? ""))
        XCTAssertTrue(FileManager.default.fileExists(atPath: second?.path ?? ""))
        XCTAssertNotNil(UIImage(named: "img_tab_home_0"), "Lottie image assets are found by name, as in CYLTabBarController's Example")
    }

    func testAnimatedIconsUseCYLTabBarControllerAnimationEngine() {
        XCTAssertTrue(CYLTagButton.isAnimationEngineAvailable(), "CYLTabBarController/CYLTabBarItemAnimation is linked")
        let resources = Bundle.main.resourceURL!
        let files = [
            "GIF": "CYLMenuExample.bundle/Animations/GIF/tab_star.gif",
            "Lottie": "CYLMenuExample.bundle/Animations/Lottie/tab_home_animate.json",
            "PAG": "pag-ios/0.pag",
            "Rive": "CYLMenuExample.bundle/Animations/Rive/check.riv",
        ]
        for (library, path) in files {
            let url = resources.appendingPathComponent(path)
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "\(library) file in the app")
            let button = makeButton(title: library, image: UIImage(systemName: "star"), style: CYLMenuStyle())
            button.animationURL = url
            button.layoutIfNeeded()
            XCTAssertNotNil(button.animationView, "\(library) view from CYLTabBarItemAnimationFactory")
            XCTAssertNotNil(button.animationPlayer, "\(library) player")
            XCTAssertTrue(button.imageView.isHidden, "\(library) takes the icon slot")
            let animationFrame = button.animationView?.frame ?? .zero
            XCTAssertEqual(animationFrame.size, button.style.imageSize, "\(library) \(NSCoder.string(for: animationFrame))")
            XCTAssertEqual(button.titleLabel.frame.minX - animationFrame.maxX, button.style.imageTitleSpacing, accuracy: 0.5)
            button.isSelected = true
            button.playAnimation()
            button.isSelected = false
        }
        let missing = makeButton(title: "x", image: UIImage(systemName: "star"), style: CYLMenuStyle())
        missing.animationURL = resources.appendingPathComponent("missing.json")
        XCTAssertNil(missing.animationView, "Falls back to the image")
        XCTAssertFalse(missing.imageView.isHidden)
    }

    func testStyleDemoShowsAnimatedIconsAndOpensTheConfigurationDemo() {
        let demo = CYLTagStyleDemoViewController()
        let navigation = host(demo)
        let collection = collectionView(of: demo.tagListView)
        for library in ["lottie", "gif", "pag", "rive"] {
            demo.performAction("animation." + library)
            collection.layoutIfNeeded()
            let button = tagButton(in: collection, at: ip(0, 0))
            XCTAssertEqual(demo.animationLibrary, library)
            XCTAssertNotNil(button?.animationView, library)
        }
        demo.performAction("animation.off")
        collection.layoutIfNeeded()
        XCTAssertNil(tagButton(in: collection, at: ip(0, 0))?.animationView)

        demo.performAction("configuration")
        let configuration = navigation.topViewController as? CYLTagConfigurationDemoViewController
        XCTAssertNotNil(configuration)
        configuration?.loadViewIfNeeded()
        XCTAssertNotNil(configuration?.fileTagListView, "\(String(describing: configuration?.configurationError))")
        XCTAssertNotNil(configuration?.mapTagListView)
    }

    func testAnimationDemoPlaysEveryLibraryCopiedFromCYLTabBarController() {
        for name in ["home_normal", "home_highlight", "fishpond_normal", "message_highlight", "account_normal", "post_normal",
                     "gray_tabbar_home_animation_lottie_placeholder"] {
            XCTAssertNotNil(UIImage(named: name), "\(name) from CYLTabBarController's Example images")
        }
        let demo = CYLTagAnimationDemoViewController()
        host(demo)
        demo.view.layoutIfNeeded()
        let tags: CYLTagListView = demo.tagListView
        let collection = collectionView(of: tags)
        let sections = CYLTagAnimationDemoViewController.sectionIdentifiers()
        XCTAssertEqual(collection.numberOfSections, sections.count)
        XCTAssertEqual(tags.selectedIndexPaths.count, sections.count, "The first tag of every section is selected")
        for section in 0..<sections.count {
            let indexPath = ip(0, section)
            collection.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            collection.layoutIfNeeded()
            let button = tagButton(in: collection, at: indexPath)
            XCTAssertNotNil(button, sections[section])
            if sections[section] == "images" {
                XCTAssertNil(button?.animationView)
                XCTAssertEqual(button?.imageView.image, UIImage(named: "home_highlight"), "The selected image")
            } else {
                XCTAssertNotNil(button?.animationView, "\(sections[section]) animated by CYLTabBarController's engine")
            }
        }
        demo.playSelectedAnimations()
        demo.changeSpeed()
        XCTAssertEqual(tags.style.animationSpeed, 2, accuracy: 0.01)
        XCTAssertEqual(demo.navigationItem.leftBarButtonItem?.title, "2x")
        tap(tags, item: 1, section: 4)
        XCTAssertTrue(tags.selectedIndexPaths.contains(ip(1, 4)))
        XCTAssertFalse(tags.selectedIndexPaths.contains(ip(0, 4)), "One selected tag per section")
    }

    func testSectionStyleRestingFrameAndScrollingInTheAnimationDemo() {
        let demo = CYLTagAnimationDemoViewController()
        host(demo)
        demo.view.layoutIfNeeded()
        let tags: CYLTagListView = demo.tagListView
        let collection = collectionView(of: tags)
        let sections = CYLTagAnimationDemoViewController.sectionIdentifiers()
        let riveIcons = sections.firstIndex(of: "rive-icons") ?? 0
        let pag = sections.firstIndex(of: "pag") ?? 0

        // icons.riv's white artboards on dark tags: the section's own style, over the list's.
        let dark = tags.menuDataSource?.menuStyle?(forSection: riveIcons)
        XCTAssertNotNil(dark)
        XCTAssertTrue(tags.menuDataSource?.menuStyle?(forSection: riveIcons) === dark, "The same object until the list's style changes")
        XCTAssertNil(tags.menuDataSource?.menuStyle?(forSection: pag), "Other sections use the list's style")
        XCTAssertEqual(dark?.itemHeight, tags.style.itemHeight)
        tags.scroll(toSection: riveIcons, animated: false)
        collection.layoutIfNeeded()
        let chat = ip(0, riveIcons), search = ip(1, riveIcons)
        let selected = tagButton(in: collection, at: chat)
        let normal = tagButton(in: collection, at: search)
        XCTAssertNotNil(normal?.animationView, "icons.riv artboard")
        XCTAssertTrue(normal?.layer.backgroundColor == dark?.normalAppearance.backgroundColor.cgColor, "Dark tag")
        XCTAssertTrue(selected?.layer.backgroundColor == dark?.selectedAppearance.backgroundColor.cgColor)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        _ = normal?.titleLabel.textColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        XCTAssertTrue(red > 0.99 && green > 0.99 && blue > 0.99, "White titles: \(String(describing: normal?.titleLabel.textColor))")
        let visible = collection.bounds
        XCTAssertTrue((collection.cellForItem(at: chat)?.frame ?? .zero).intersects(visible), "Scrolled to the section")

        // 1.pag rests on its last frame; the others on their first.
        let restingItem = (tags.menuDataSource?.menuNumberOfItems(inSection: pag) ?? 0) - 1
        XCTAssertEqual(tags.menuDataSource?.menuAnimationRestingProgressForItem?(at: ip(restingItem, pag)), NSNumber(value: 1))
        XCTAssertNil(tags.menuDataSource?.menuAnimationRestingProgressForItem?(at: ip(0, pag)))
        tags.scroll(toSection: pag, animated: false)
        collection.layoutIfNeeded()
        let resting = tagButton(in: collection, at: ip(restingItem, pag))
        XCTAssertEqual(resting?.animationRestingProgress ?? 0, 1, accuracy: 0.001)
        XCTAssertFalse(resting?.isSelected ?? true)
        let progress = ((resting?.animationPlayer as AnyObject?)?.value(forKey: "progress") as? NSNumber)?.doubleValue ?? 0
        XCTAssertEqual(progress, 1, accuracy: 0.01, "Shows its last frame")
        // truck.riv (rive-app/rive-ios) replaced confetti.riv, which draws nothing at rest.
        let rive = sections.firstIndex(of: "rive") ?? 0
        let truckItem = (tags.menuDataSource?.menuNumberOfItems(inSection: rive) ?? 0) - 1
        let truck = tags.menuDataSource?.menuAnimationURLForItem?(at: ip(truckItem, rive))
        XCTAssertEqual(truck?.lastPathComponent, "truck.riv")
        XCTAssertTrue(FileManager.default.fileExists(atPath: truck?.path ?? ""))
        tags.scroll(toSection: rive, animated: false)
        collection.layoutIfNeeded()
        XCTAssertNotNil(tagButton(in: collection, at: ip(truckItem, rive))?.animationView, "truck.riv")
        for name in ["tab_home", "tab_health", "tab_moments", "tab_me"] {
            let path = (Bundle.main.resourcePath ?? "") + "/pag-ios/\(name).pag"
            XCTAssertTrue(FileManager.default.fileExists(atPath: path), "CYLTabBarController's PAG tab icon \(name)")
        }
    }

    // MARK: Accessibility

    func testVoiceOverDescribesTagsAndFoldControls() {
        let source = makeSource(itemCount: 30, sections: 1)
        source.sections[0].items[2].isEnabled = false
        let view = hostedView(source: source, width: 320)
        view.foldStyle = .footerChevron
        view.defaultVisibleRows = 2
        view.selectedIndexPaths = [ip(1, 0)]
        view.layoutIfNeeded()
        let collection = collectionView(of: view)
        collection.layoutIfNeeded()
        for item in 0..<3 {
            let cell = collection.cellForItem(at: ip(item, 0))
            XCTAssertTrue(cell?.isAccessibilityElement ?? false)
            XCTAssertEqual(cell?.accessibilityLabel, source.sections[0].items[item].title)
            let traits = cell?.accessibilityTraits ?? []
            XCTAssertTrue(traits.contains(.button))
            XCTAssertEqual(traits.contains(.selected), item == 1)
            XCTAssertEqual(traits.contains(.notEnabled), item == 2)
        }
        tap(view, item: 0, section: 0)
        XCTAssertTrue(collection.cellForItem(at: ip(0, 0))?.accessibilityTraits.contains(.selected) ?? false,
                      "Selection changes are reflected in the traits")

        var header = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: ip(0, 0))
        XCTAssertTrue((header?.value(forKey: "titleLabel") as? UILabel)?.accessibilityTraits.contains(.header) ?? false)
        var footer = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: ip(0, 0))
        let chevron = foldButton(of: footer)
        XCTAssertEqual(chevron?.accessibilityLabel, "分组 0 更多")
        view.setExpanded(true, forSection: 0, animated: false)
        collection.layoutIfNeeded()
        // Thirty expanded tags are taller than the view: scroll the footer into view.
        collection.setContentOffset(CGPoint(x: 0, y: max(0, collection.contentSize.height - collection.bounds.height)), animated: false)
        collection.layoutIfNeeded()
        footer = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: ip(0, 0))
        XCTAssertNotNil(footer)
        XCTAssertEqual(foldButton(of: footer)?.accessibilityLabel, "分组 0 收起")

        view.foldStyle = .headerButton
        collection.layoutIfNeeded()
        header = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: ip(0, 0))
        XCTAssertEqual(foldButton(of: header)?.accessibilityLabel, "分组 0 收起")
    }

    func testBoldTextMakesTagsBoldAndWider() {
        let style = CYLMenuStyle()
        let regular = UITraitCollection(traitsFrom: [UITraitCollection(legibilityWeight: .regular),
                                                     UITraitCollection(preferredContentSizeCategory: .large)])
        let bold = UITraitCollection(traitsFrom: [UITraitCollection(legibilityWeight: .bold),
                                                  UITraitCollection(preferredContentSizeCategory: .large)])
        let regularFont = style.titleFont(for: .normal, traitCollection: regular)
        let boldFont = style.titleFont(for: .normal, traitCollection: bold)
        XCTAssertFalse(regularFont.fontDescriptor.symbolicTraits.contains(.traitBold))
        XCTAssertTrue(boldFont.fontDescriptor.symbolicTraits.contains(.traitBold))
        let title = "Accessibility 无障碍" as NSString
        XCTAssertGreaterThan(title.size(withAttributes: [.font: boldFont]).width,
                             title.size(withAttributes: [.font: regularFont]).width,
                             "Measured with the bold font, so bold tags do not truncate")
    }

    func testExampleControlsHaveSpokenLabels() {
        let controller = CYLSearchCategoryViewController()
        host(controller)
        XCTAssertEqual(controller.industryButton.accessibilityLabel, "行业 IT互联网")
        XCTAssertEqual(controller.industryButton.accessibilityHint, "选择行业")
        controller.selectIndustry("金融")
        XCTAssertEqual(controller.industryButton.accessibilityLabel, "行业 金融")
    }

    // MARK: Scenario 1: review filter

    @discardableResult
    private func host(_ controller: UIViewController) -> UINavigationController {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let navigation = UINavigationController(rootViewController: controller)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        self.window = window
        controller.loadViewIfNeeded()
        controller.view.layoutIfNeeded()
        return navigation
    }

    private func waitForQuery(of controller: CYLReviewListViewController) {
        let done = NSPredicate { _, _ in !controller.query.isLoading }
        wait(for: [XCTNSPredicateExpectation(predicate: done, object: nil)], timeout: 10)
    }

    private func identifiers(of filters: [CYLReviewFilter]) -> [String] {
        filters.map { $0.identifier }
    }

    func testMemoryFilteringMatchesEverySelectedTagImmediately() {
        let store = CYLReviewStore.shared()
        let controller = CYLReviewListViewController(selectedFilterIndex: 0)
        host(controller)
        let filter: CYLTagListView = controller.filterView
        XCTAssertEqual(controller.mode, .memory)
        XCTAssertEqual(filter.selectionMode, .multiple)
        XCTAssertEqual(filter.selectedIndexPaths, [ip(0, 0)])
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), store.reviews.count)
        XCTAssertNil(controller.tableView.tableHeaderView, "The filter sits above the list, not in it")
        XCTAssertGreaterThan(collectionView(of: filter).visibleCells.count, 0)

        tap(filter, item: 1, section: 0)  // 好评
        XCTAssertEqual(filter.selectedIndexPaths, [ip(1, 0)], "Selecting a condition clears 全部")
        let good = store.reviewsMatchingAll([store.filters[1]])
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), good.count, "Refreshed synchronously")
        XCTAssertTrue(controller.statusLabel.text?.contains("点击「好评(") ?? false)

        tap(filter, item: 4, section: 0)  // 有图: both must match
        let both = store.reviewsMatchingAll([store.filters[1], store.filters[4]])
        XCTAssertLessThan(both.count, good.count)
        XCTAssertEqual(identifiers(of: controller.selectedFilters), ["good", "photo"])
        XCTAssertEqual(controller.visibleReviews, both)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), both.count)
        let matches = "匹配 \(both.count) 条"
        XCTAssertTrue(controller.statusLabel.text?.contains(matches) ?? false, controller.statusLabel.text ?? "")

        tap(filter, item: 4, section: 0)  // deselect 有图
        XCTAssertTrue(controller.statusLabel.text?.contains("取消「有图(") ?? false)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), good.count)
        tap(filter, item: 1, section: 0)  // deselect the last condition
        XCTAssertEqual(filter.selectedIndexPaths, [ip(0, 0)], "Nothing selected shows 全部")
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), store.reviews.count)

        tap(filter, item: 3, section: 0)  // 差评(0) is disabled.
        XCTAssertEqual(filter.selectedIndexPaths, [ip(0, 0)])
        tap(filter, item: 6, section: 0)
        tap(filter, item: 0, section: 0)  // 全部 clears the conditions
        XCTAssertEqual(filter.selectedIndexPaths, [ip(0, 0)])
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), store.reviews.count)
    }

    func testNetworkFilteringRefreshesWhenTheResponseArrives() {
        let store = CYLReviewStore.shared()
        let controller = CYLReviewListViewController(selectedFilterIndex: 0, mode: .network)
        guard let network = controller.query as? CYLNetworkReviewQuery else {
            return XCTFail("The network scenario uses CYLNetworkReviewQuery")
        }
        network.latency = 0.3
        host(controller)
        XCTAssertTrue(network.isLoading, "The first page is requested from the server")
        waitForQuery(of: controller)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), store.reviews.count)

        tap(controller.filterView, item: 1, section: 0)  // 好评
        XCTAssertTrue(network.isLoading)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), store.reviews.count, "The list waits for the server")
        XCTAssertTrue(controller.statusLabel.text?.contains("加载中") ?? false)
        XCTAssertEqual(network.lastRequestURL?.absoluteString, "https://api.example.com/reviews?filter=good")
        waitForQuery(of: controller)
        let good = store.reviewsMatchingAll([store.filters[1]])
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), good.count)
        let returned = "服务器返回 \(good.count) 条"
        XCTAssertTrue(controller.statusLabel.text?.contains(returned) ?? false, controller.statusLabel.text ?? "")

        // Two quick changes: only the response to the last request is shown.
        let dropped = network.droppedResponseCount
        tap(controller.filterView, item: 4, section: 0)
        tap(controller.filterView, item: 4, section: 0)
        waitForQuery(of: controller)
        let droppedOne = NSPredicate { _, _ in network.droppedResponseCount > dropped }
        wait(for: [XCTNSPredicateExpectation(predicate: droppedOne, object: nil)], timeout: 10)
        XCTAssertEqual(controller.visibleReviews, good)

        // The server receives every condition.
        let url = CYLNetworkReviewQuery.requestURL(for: [store.filters[1], store.filters[6]])
        XCTAssertTrue(url.query?.contains("filter=good") ?? false)
        XCTAssertEqual(CYLReviewServer.reviews(forRequestURL: url), store.reviewsMatchingAll([store.filters[1], store.filters[6]]))
    }

    func testFilteringModesAreSeparateScenarios() {
        let controller = CYLReviewListViewController(selectedFilterIndex: 0)
        host(controller)
        XCTAssertTrue(controller.navigationItem.titleView === controller.modeControl)
        XCTAssertEqual(controller.modeControl.titleForSegment(at: 0), "内存筛选")
        XCTAssertEqual(controller.modeControl.titleForSegment(at: 1), "网络筛选")
        XCTAssertTrue(controller.query is CYLMemoryReviewQuery)
        XCTAssertTrue(controller.statusLabel.text?.contains("内存筛选") ?? false)
        controller.modeControl.selectedSegmentIndex = 1
        controller.modeControl.sendActions(for: .valueChanged)
        XCTAssertEqual(controller.mode, .network)
        XCTAssertTrue(controller.query is CYLNetworkReviewQuery)
        XCTAssertTrue(controller.statusLabel.text?.contains("网络筛选") ?? false)
        waitForQuery(of: controller)
    }

    func testFoldChevronFoldsToTwoRowsAndTurns() {
        let controller = CYLReviewListViewController(selectedFilterIndex: 0)
        host(controller)
        let filter: CYLTagListView = controller.filterView
        let collection = collectionView(of: filter)
        collection.layoutIfNeeded()
        XCTAssertTrue(filter.canFoldSection(0))
        let total = filter.menuDataSource?.menuNumberOfItems(inSection: 0) ?? 0
        let folded = collection.numberOfItems(inSection: 0)
        XCTAssertLessThan(folded, total, "Folded to two rows")
        let footer = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: ip(0, 0))
        guard let chevron = foldButton(of: footer) else {
            return XCTFail("The footer has a fold control")
        }
        XCTAssertEqual(filter.foldControl.position, .bottom)
        XCTAssertEqual(filter.foldControl.content, .icon, "Taobao: the chevron alone")
        XCTAssertTrue(chevron.imageView.transform.isIdentity, "Points down while folded")
        let foldedHeight = filter.frame.height

        chevron.sendActions(for: .touchUpInside)
        controller.view.layoutIfNeeded()
        XCTAssertTrue(filter.isSectionExpanded(0))
        XCTAssertEqual(collection.numberOfItems(inSection: 0), total, "Every row is shown")
        let sameFooter = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: ip(0, 0))
        XCTAssertTrue(sameFooter === footer, "The footer stays, so its chevron can turn")
        XCTAssertEqual(chevron.imageView.transform.a, -1, accuracy: 0.01, "Turned 180°")
        XCTAssertGreaterThan(filter.frame.height, foldedHeight)

        chevron.sendActions(for: .touchUpInside)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(collection.numberOfItems(inSection: 0), folded)
        XCTAssertEqual(chevron.imageView.transform.a, 1, accuracy: 0.01)
        XCTAssertEqual(filter.frame.height, foldedHeight, accuracy: 1)
    }

    func testReviewPagePreselectsAndRevealsKeywordFilter() {
        let store = CYLReviewStore.shared()
        let last = store.filters.count - 1
        let controller = CYLReviewListViewController(selectedFilterIndex: last)
        host(controller)
        XCTAssertEqual(controller.filterView.selectedIndexPaths, [ip(last, 0)])
        XCTAssertGreaterThan(controller.filterView.numberOfVisibleItems(inSection: 0), last)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), store.reviewsMatching(store.filters[last]).count)
    }

    func testProductPreviewShowsTwoRowsAndOpensReviews() {
        let controller = CYLProductViewController()
        let navigation = host(controller)
        let preview = controller.previewView
        XCTAssertEqual(preview.selectionMode, .none)
        XCTAssertEqual(preview.foldStyle, .truncate)
        let total = preview.menuDataSource?.menuNumberOfItems(inSection: 0) ?? 0
        if preview.numberOfRows(inSection: 0) > 2 {
            XCTAssertLessThan(preview.numberOfVisibleItems(inSection: 0), total, "Only two rows are previewed")
        } else {
            XCTAssertEqual(preview.numberOfVisibleItems(inSection: 0), total)
        }
        XCTAssertEqual(preview.frame.height, preview.heightThatFitsWidth(preview.bounds.width), accuracy: 1)

        tap(preview, item: 1, section: 0)
        let reviews = navigation.topViewController as? CYLReviewListViewController
        XCTAssertNotNil(reviews)
        reviews?.loadViewIfNeeded()
        XCTAssertEqual(reviews?.selectedFilters.count, 1)
        XCTAssertTrue(reviews?.selectedFilters.first?.isKeyword ?? false)
        XCTAssertEqual(preview.selectedIndexPaths, [])
    }

    // MARK: Scenario 2: search categories

    /// In a window, not hidden, transparent or off screen through any of its superviews.
    private func isVisible(_ view: UIView) -> Bool {
        guard let window = view.window else { return false }
        var current: UIView? = view
        while let v = current {
            if v.isHidden || v.alpha < 0.01 { return false }
            current = v.superview
        }
        return view.convert(view.bounds, to: nil).intersects(window.bounds)
    }

    private func layOutSelectedCategory(of controller: CYLSearchCategoryViewController) {
        // The embedded tab bar controller adds its selected page's view during appearance, on the next run loop pass.
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))
        controller.view.layoutIfNeeded()
        controller.categoryTabBarController.view.layoutIfNeeded()
        controller.categoryTabBarController.selectedViewController?.view.layoutIfNeeded()
        controller.tagListView.layoutIfNeeded()
    }

    private func tabTitles(of tabs: UITabBarController) -> [String] {
        (tabs.tabBar.items ?? []).map { $0.title ?? "" }
    }

    func testSearchCategoriesUseABottomTabBarAndFillTheSearchBar() {
        let controller = CYLSearchCategoryViewController()
        host(controller)
        layOutSelectedCategory(of: controller)
        let tabs: CYLTabBarController = controller.categoryTabBarController
        XCTAssertEqual(tabs.viewControllers?.count, 4)
        XCTAssertEqual(tabTitles(of: tabs), ["找人", "动态", "八卦", "职位"])
        let tags = controller.tagListView
        let barFrame = tabs.tabBar.convert(tabs.tabBar.bounds, to: controller.view)
        let tagsFrame = tags.convert(tags.bounds, to: controller.view)
        XCTAssertGreaterThan(barFrame.minY, controller.view.bounds.height / 2, "Tab bars are always at the bottom")
        XCTAssertLessThanOrEqual(tagsFrame.maxY, barFrame.minY + 0.5, "Tags end above the tab bar")
        XCTAssertNotNil(tags.window)

        let collection = collectionView(of: tags)
        XCTAssertEqual(controller.category, .people)
        XCTAssertEqual(collection.numberOfSections, 4)
        XCTAssertEqual(controller.searchBar.placeholder, "搜人名,职位,公司...")
        tap(tags, item: 1, section: 1)
        XCTAssertEqual(controller.searchBar.text, "IDG资本")
        XCTAssertEqual(tags.selectedIndexPaths, [])

        // A tap on the 八卦 tab, as the tab bar reports it.
        tabs.selectedIndex = CYLSearchCategory.gossip.rawValue
        if let selected = tabs.selectedViewController {
            tabs.delegate?.tabBarController?(tabs, didSelect: selected)
        }
        layOutSelectedCategory(of: controller)
        XCTAssertEqual(controller.category, .gossip)
        XCTAssertEqual(controller.searchBar.placeholder, "搜八卦")
        let gossip = controller.tagListView
        XCTAssertFalse(gossip === tags)
        XCTAssertFalse(isVisible(tags), "Only the selected category's page is shown (a tab bar controller may keep the previous page hidden in the window)")
        XCTAssertTrue(isVisible(gossip))
        XCTAssertNotNil(gossip.window)
        XCTAssertEqual(collectionView(of: gossip).numberOfSections, 2)
        assertNoOverlapsOrOverflow(in: gossip)
        tap(gossip, item: 2, section: 0)
        XCTAssertEqual(controller.searchBar.text, "程序猿")
    }

    func testJobCategoriesUseSidebarAndIndustryAccessory() {
        let controller = CYLSearchCategoryViewController()
        host(controller)
        controller.select(.jobs)
        layOutSelectedCategory(of: controller)
        XCTAssertEqual(controller.categoryTabBarController.selectedIndex, CYLSearchCategory.jobs.rawValue)
        let tags = controller.tagListView
        let collection = collectionView(of: tags)
        XCTAssertTrue(controller.jobCategoryTableView.superview === tags.superview)
        XCTAssertEqual(tags.frame.minX, controller.jobCategoryTableView.frame.maxX, accuracy: 0.5)
        XCTAssertEqual(controller.jobCategoryTableView.numberOfRows(inSection: 0), 10)
        XCTAssertEqual(collection.numberOfItems(inSection: 0), 31)
        assertNoOverlapsOrOverflow(in: tags)

        collection.layoutIfNeeded()
        let header = collection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: ip(0, 0))
        XCTAssertTrue(controller.industryButton.superview === header)
        controller.selectIndustry("金融")
        XCTAssertEqual(controller.industry, "金融")
        XCTAssertTrue(controller.industryButton.title(for: .normal)?.contains("金融") ?? false)

        controller.jobCategoryTableView.delegate?.tableView?(controller.jobCategoryTableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(collection.numberOfItems(inSection: 0), 7)
        tap(tags, item: 0, section: 0)
        XCTAssertEqual(controller.searchBar.text, "测试工程师")
    }

    // MARK: Localization

    func testComponentStringsComeFromOneBundleInEveryLanguage() {
        let bundle = CYLMenuResources.bundle()
        XCTAssertEqual(bundle.bundleURL.lastPathComponent, "CYLClassifyMenuResources.bundle")
        let languages = CYLMenuResources.availableLanguages()
        XCTAssertEqual(languages, ["en", "zh-Hans", "zh-Hant"])
        func table(_ language: String) -> NSDictionary? {
            bundle.path(forResource: "CYLClassifyMenu", ofType: "strings", inDirectory: nil, forLocalization: language)
                .flatMap { NSDictionary(contentsOfFile: $0) }
        }
        let english = table("en")
        XCTAssertGreaterThan(english?.count ?? 0, 0)
        let englishKeys = Set((english?.allKeys as? [String]) ?? [])
        for language in languages {
            let keys = Set((table(language)?.allKeys as? [String]) ?? [])
            XCTAssertEqual(keys, englishKeys, "\(language) has the same keys as en")
        }
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "CYLMenuExpand", language: "en"), "More")
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "CYLMenuExpand", language: "zh-Hans"), "更多")
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "CYLMenuCollapse", language: "zh-Hant"), "收合")
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "CYLMenuExpand", language: "fr"), "More", "Unknown languages fall back to English")
        XCTAssertEqual(CYLMenuResources.localizedString(forKey: "NoSuchKey"), "NoSuchKey")

        CYLMenuResources.preferredLanguage = "en"
        XCTAssertEqual(CYLMenuResources.currentLanguage(), "en")
        XCTAssertEqual(CYLMenuStyle().expandTitle, "More")
        CYLMenuResources.preferredLanguage = "zh-Hant-TW"
        XCTAssertEqual(CYLMenuResources.currentLanguage(), "zh-Hant", "Regional variants match their language")
        XCTAssertEqual(CYLMenuStyle().collapseTitle, "收合")
    }

    func testExampleSwitchesLanguage() {
        CYLMenuResources.preferredLanguage = "en"
        let tabs = CYLExampleAppDelegate.makeRootTabBarController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window
        tabs.view.layoutIfNeeded()
        XCTAssertEqual(titlesOfTabs(of: tabs), ["Reviews", "Search", "Styles", "Animations"])

        let search = CYLSearchCategoryViewController()
        host(search)
        XCTAssertEqual(tabTitles(of: search.categoryTabBarController), ["People", "Posts", "Gossip", "Jobs"])
        XCTAssertEqual(search.searchBar.placeholder, "Search people, titles, companies...")
        XCTAssertEqual(search.industryButton.accessibilityLabel, "Industry Internet")
        search.select(.jobs)
        layOutSelectedCategory(of: search)
        XCTAssertEqual(search.tagListView.menuDataSource?.menuTitle(forSection: 0), "Trending job keywords:")

        let reviews = CYLReviewListViewController(selectedFilterIndex: 0)
        host(reviews)
        XCTAssertEqual(reviews.filterView.menuDataSource?.menuTitleForItem(at: ip(0, 0)), "All")
        XCTAssertTrue(reviews.filterView.menuDataSource?.menuTitleForItem(at: ip(1, 0)).hasPrefix("Positive(") ?? false)
        XCTAssertEqual(reviews.filterView.style.expandTitle, "More")
    }

    // MARK: Root tab bar

    /// The root tab bar's tab titles, without the plus button's tab.
    private func titlesOfTabs(of tabs: CYLTabBarController) -> [String] {
        var titles: [String] = []
        for controller in tabs.viewControllers ?? [] {
            let navigation = controller as? UINavigationController
            if !(navigation?.viewControllers.first is CYLQueryScenariosViewController) {
                // CYLTabBarController cuts long titles next to the plus button with "…" (so that the plus button stays on
                // its slot) and keeps the full title as the accessibility label.
                titles.append(controller.tabBarItem.accessibilityLabel ?? controller.tabBarItem.title ?? "")
            }
        }
        return titles
    }

    /// The navigation controller of the tab whose root is a `rootClass`.
    private func tab(of tabs: CYLTabBarController, rootClass: AnyClass) -> UINavigationController? {
        for controller in tabs.viewControllers ?? [] {
            if let navigation = controller as? UINavigationController,
               navigation.viewControllers.first?.isKind(of: rootClass) ?? false {
                return navigation
            }
        }
        return nil
    }

    func testRootTabBarHoldsBothScenarios() {
        let tabs = CYLExampleAppDelegate.makeRootTabBarController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window
        tabs.view.layoutIfNeeded()
        XCTAssertEqual(tabs.viewControllers?.count, 5, "Four tabs and the plus button's")
        XCTAssertEqual(titlesOfTabs(of: tabs), ["场景一：评价筛选", "场景二：搜索分类", "样式", "动效"])
        guard let first = tabs.viewControllers?[0] as? UINavigationController,
              let second = tabs.viewControllers?[1] as? UINavigationController else {
            return XCTFail("Every tab is a navigation controller")
        }
        XCTAssertTrue(first.viewControllers.first is CYLProductViewController)
        XCTAssertTrue(second.viewControllers.first is CYLSearchHomeViewController)
        XCTAssertGreaterThan(tabs.tabBar.frame.minY, tabs.view.bounds.height / 2, "The root tab bar is at the bottom")

        // Scenario 2: the home page pushes the search screen, which hides the root tab bar and
        // shows its own category tab bar, also at the bottom: two tab bars with different roles.
        tabs.selectedViewController = second
        guard let home = second.viewControllers.first as? CYLSearchHomeViewController else {
            return XCTFail("Scenario 2 starts on the search home page")
        }
        home.loadViewIfNeeded()
        let search = home.openSearch()
        XCTAssertTrue(second.topViewController === search)
        XCTAssertTrue(search.hidesBottomBarWhenPushed)
        search.loadViewIfNeeded()
        XCTAssertFalse(search.categoryTabBarController === tabs)
        XCTAssertTrue(search.categoryTabBarController.parent === search)

        // The review page hides the root tab bar.
        tabs.selectedIndex = 0
        guard let product = first.viewControllers.first as? CYLProductViewController else {
            return XCTFail("Scenario 1 starts on the product page")
        }
        product.loadViewIfNeeded()
        product.showReviews(withFilterIndex: 0)
        XCTAssertTrue(first.topViewController?.hidesBottomBarWhenPushed ?? false)
    }

    // MARK: Plus button: filter scenarios and database

    /// +[CYLPlusButton plusButtonForTabBarContext:] and +plusChildViewControllerForTabBarContext:, called by selector so
    /// the test does not depend on how Swift imports these class factories.
    private func plusClassMethod(_ selector: String, context: String) -> AnyObject? {
        let plusClass: AnyClass = CYLPlusButton.self
        let selector = NSSelectorFromString(selector)
        guard let implementation = class_getMethodImplementation(object_getClass(plusClass), selector) else { return nil }
        typealias ClassMethod = @convention(c) (AnyObject, Selector, NSString?) -> AnyObject?
        let method = unsafeBitCast(implementation, to: ClassMethod.self)
        return method(plusClass as AnyObject, selector, context as NSString)
    }

    func testPlusButtonOpensFilterScenariosAndOnlyTheRootTabBarHasIt() {
        let tabs = CYLExampleAppDelegate.makeRootTabBarController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window
        tabs.view.layoutIfNeeded()
        XCTAssertEqual(tabs.context, CYLExampleRootTabBarContext)
        let plus = plusClassMethod("plusButtonForTabBarContext:", context: CYLExampleRootTabBarContext) as? CYLPlusButton
        XCTAssertTrue(plus is CYLExamplePlusButton)
        XCTAssertTrue(plus?.isDescendant(of: tabs.tabBar) ?? false, "In the root tab bar")
        XCTAssertGreaterThan(tabs.tabBar.frame.minY, tabs.view.bounds.height / 2, "At the bottom")
        let plusTab = tab(of: tabs, rootClass: CYLQueryScenariosViewController.self)
        XCTAssertNotNil(plusTab)
        XCTAssertEqual(tabs.viewControllers?.firstIndex { $0 === plusTab }, Int(CYLExamplePlusButton.indexOfPlusButtonInTabBar()))
        XCTAssertTrue(plusClassMethod("plusChildViewControllerForTabBarContext:", context: CYLExampleRootTabBarContext) === plusTab)
        plus?.sendActions(for: .touchUpInside)
        XCTAssertTrue(tabs.selectedViewController === plusTab, "The plus button selects its scenario list")

        // Scenario 2's nested category tab bar has another context: no plus button there.
        let search = CYLSearchCategoryViewController()
        host(search)
        XCTAssertNotEqual(search.categoryTabBarController.context, CYLExampleRootTabBarContext)
        XCTAssertEqual(search.categoryTabBarController.viewControllers?.count, 4)
        for view in search.categoryTabBarController.tabBar.subviews {
            XCTAssertFalse(view is CYLExamplePlusButton)
        }

        // Grouped by scenario; every row pushes its demo without the tab bar.
        guard let scenarios = plusTab?.viewControllers.first as? CYLQueryScenariosViewController else {
            return XCTFail("The plus tab shows the scenario list")
        }
        scenarios.loadViewIfNeeded()
        XCTAssertNil(scenarios.title, "navigationItem.title only: the tab keeps its title")
        XCTAssertEqual(scenarios.tableView.numberOfSections, 3)
        XCTAssertEqual(scenarios.tableView.numberOfRows(inSection: 0), 3)
        XCTAssertEqual(scenarios.tableView.numberOfRows(inSection: 1), 1)
        let reviews = scenarios.viewController(for: .reviewsDatabase) as? CYLReviewListViewController
        XCTAssertNotNil(reviews)
        XCTAssertEqual(reviews?.mode, .database)
        XCTAssertTrue(reviews?.hidesBottomBarWhenPushed ?? false)
        let menu = scenarios.viewController(for: .menuLinkage)
        XCTAssertTrue(menu is CYLMenuLinkageViewController)
        XCTAssertTrue(menu.hidesBottomBarWhenPushed)
    }

    func testExampleDatabaseHoldsTheDemoData() throws {
        let database = try CYLExampleDatabase(path: ":memory:")
        XCTAssertEqual(database.count(ofTable: "reviews"), CYLReviewStore.shared().reviews.count)
        XCTAssertGreaterThan(database.count(ofTable: "review_keywords"), 0)
        XCTAssertGreaterThan(database.count(ofTable: "places"), 40)
        let tags = try database.rows(forSQL: "SELECT COUNT(DISTINCT tag) AS n, COUNT(DISTINCT region) AS r, COUNT(DISTINCT category) AS c FROM places")
        XCTAssertEqual((tags.first?["c"] as? NSNumber)?.intValue, 4, "吃喝玩逛 of data.json")
        XCTAssertEqual((tags.first?["r"] as? NSNumber)?.intValue, 4, "The filter's regions")
        XCTAssertGreaterThan((tags.first?["n"] as? NSNumber)?.intValue ?? 0, 20, "Every tag of data.json")

        // Bound values, never formatted into the SQL; the display string shows them quoted.
        let rows = try database.rows(forSQL: "SELECT ? AS text, ? AS number", arguments: ["it's", NSNumber(value: 2.5)])
        XCTAssertEqual(rows.first?["text"] as? String, "it's")
        XCTAssertEqual((rows.first?["number"] as? NSNumber)?.doubleValue ?? 0, 2.5, accuracy: 0.001)
        let query = CYLExampleSQLQuery(sql: "SELECT * FROM t WHERE a = ? AND b = ?", arguments: ["it's", NSNumber(value: 3)])
        XCTAssertEqual(query.displayString(), "SELECT * FROM t WHERE a = 'it''s' AND b = 3")
        XCTAssertThrowsError(try database.rows(forSQL: "SELECT * FROM missing")) { error in
            XCTAssertEqual((error as NSError).domain, CYLExampleDatabaseErrorDomain)
        }

        // A failed transaction leaves nothing behind.
        database.inTransaction { db in
            db.saveSelection([self.ip(1, 0)], forScenario: "test")
            return false
        }
        XCTAssertTrue(database.saveSelection([ip(3, 0), ip(2, 1)], forScenario: "test"))
        XCTAssertEqual(database.savedSelection(forScenario: "test"), [ip(3, 0), ip(2, 1)])
        XCTAssertNil(database.savedSelection(forScenario: "other"))
    }

    func testDatabaseReviewFilteringMatchesMemoryFiltering() throws {
        let store = CYLReviewStore.shared()
        let database = try CYLExampleDatabase(path: ":memory:")
        let query = CYLDatabaseReviewQuery(database: database)
        XCTAssertEqual(query.mode, .database)
        let combinations: [[String]] = [[], ["good"], ["good", "photo"], ["followup"], ["neutral"], ["bad"],
                                        ["keyword:质量不错"], ["good", "keyword:质量不错", "keyword:划算"], ["photo", "followup"]]
        for identifiers in combinations {
            let filters = identifiers.map { store.filter(withIdentifier: $0)! }
            var fromDatabase: [CYLReview]?
            query.fetchReviewsMatching(filters) { reviews in fromDatabase = reviews }
            XCTAssertNotNil(fromDatabase, "Synchronous")
            XCTAssertEqual(fromDatabase, store.reviewsMatchingAll(filters), "\(identifiers)")
        }
        let sql = CYLDatabaseReviewQuery.query(for: [store.filter(withIdentifier: "good")!, store.filter(withIdentifier: "keyword:划算")!])
        XCTAssertTrue(sql.sql.contains("r.rating = ? AND EXISTS"), sql.sql)
        XCTAssertEqual(sql.arguments as NSArray, [NSNumber(value: CYLReviewRating.good.rawValue), "划算"] as NSArray)

        let controller = CYLReviewListViewController(selectedFilterIndex: 0, mode: .database)
        host(controller)
        XCTAssertEqual(controller.modeControl.numberOfSegments, 3)
        controller.selectFilterIndexes([1, 4])
        XCTAssertEqual(controller.visibleReviews, store.reviewsMatchingAll(controller.selectedFilters))
        XCTAssertTrue(controller.statusLabel.text?.contains("SELECT r.id FROM reviews r WHERE") ?? false, controller.statusLabel.text ?? "")
    }

    func testPortedClassifyMenuDemoQueriesTheDatabase() throws {
        let database = try CYLExampleDatabase(path: ":memory:")
        let menu = CYLMenuLinkageViewController(database: database)
        host(menu)
        menu.view.layoutIfNeeded()
        let places = database.count(ofTable: "places")
        XCTAssertEqual(menu.results.count, places, "Every condition is 全部 at first")
        XCTAssertNil(menu.selectedIndexPath)
        XCTAssertFalse(menu.lastQuery.sql.contains("WHERE"))

        // Classify menu (single choice): a tag, highlighted, and only its places.
        let sichuan = ip(1, 0)
        menu.selectClassifyItem(at: sichuan)
        let tag = menu.selectedTag ?? ""
        XCTAssertTrue(tag.hasPrefix("川菜"), tag)
        XCTAssertEqual(menu.selectedIndexPath, sichuan)
        XCTAssertGreaterThan(menu.results.count, 0)
        for row in menu.results {
            XCTAssertEqual(row["tag"] as? String, tag)
        }
        let collection = menu.value(forKey: "collectionView") as! UICollectionView
        collection.layoutIfNeeded()
        let button = collection.cellForItem(at: sichuan)?.value(forKey: "button") as? UIButton
        XCTAssertTrue(button?.isSelected ?? false, "The selected tag is highlighted (core: selectedIndexPath)")
        XCTAssertTrue(button?.accessibilityTraits.contains(.selected) ?? false)
        // The results are the menu's footer, below the tags, in the scroll view.
        let footer: UIView = menu.menuFooterView
        XCTAssertGreaterThanOrEqual(footer.frame.minY, collection.frame.maxY - 0.5)
        XCTAssertGreaterThan(footer.frame.height, 40)
        let scroll = footer.superview as? UIScrollView
        XCTAssertGreaterThanOrEqual(scroll?.contentSize.height ?? 0, footer.frame.maxY - 0.5)
        XCTAssertTrue(menu.statusLabel.text?.contains("tag = '") ?? false, menu.statusLabel.text ?? "")

        // Multiple filter: regions (and dishes), ANDed with the tag.
        menu.confirmFilterSelection([ip(2, 0), ip(0, 1)])
        XCTAssertEqual(menu.selectedRegions, ["上海"])
        XCTAssertEqual(menu.selectedDishes, [])
        let expected = try database.rows(forSQL: "SELECT name FROM places WHERE tag = ? AND region = ?", arguments: [tag, "上海"])
        XCTAssertEqual(menu.results.count, expected.count)
        for row in menu.results {
            XCTAssertEqual(row["region"] as? String, "上海")
        }
        XCTAssertTrue(menu.lastQuery.sql.contains("tag = ? AND region IN (?)"), menu.lastQuery.sql)

        // Saved in the database: a new visit restores the conditions and the results.
        let again = CYLMenuLinkageViewController(database: database)
        host(again)
        XCTAssertEqual(again.selectedIndexPath, sichuan)
        XCTAssertEqual(again.selectedRegions, ["上海"])
        XCTAssertEqual(again.results.count, menu.results.count)

        // Tapping the tag again clears it; reset brings every place back.
        again.selectClassifyItem(at: sichuan)
        XCTAssertNil(again.selectedTag)
        again.confirmFilterSelection([ip(0, 0), ip(2, 1), ip(3, 1)])
        XCTAssertEqual(again.selectedDishes.count, 2)
        for row in again.results {
            XCTAssertTrue(again.selectedDishes.contains(row["tag"] as? String ?? ""))
        }
        again.resetConditions()
        XCTAssertEqual(again.results.count, places)
        XCTAssertNil(database.savedSelection(forScenario: CYLMenuLinkageClassifyScenario))
    }
}

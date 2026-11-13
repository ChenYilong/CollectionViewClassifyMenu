//
//  CYLTagListView+CYLConfiguration.swift
//  CollectionViewClassifyMenu
//
//  Creating a tag list from one dictionary (a map) or a configuration file, the way CYLTabBarController is created
//  with init(configuration:) and init(configurationFile:). In code, values have their usual types; in a file, strings
//  work for every key (colors "#RRGGBB", images "system:star", insets "{top, left, bottom, right}" or arrays, enum
//  names...).
//
//      let tags = CYLTagListView(configuration: [
//          CYLTagListKey.selectionMode: "multiple",
//          CYLTagListKey.foldStyle: "footerChevron",
//          CYLTagListKey.style: [CYLMenuStyleKey.normal: [CYLTagAppearanceKey.cornerRadius: 0]],
//          CYLTagListKey.sections: [[CYLTagSectionKey.title: "Tabs",
//                                    CYLTagSectionKey.items: [[CYLTagItemKey.title: "Home",
//                                                              CYLTagItemKey.image: "system:house",
//                                                              CYLTagItemKey.animation: "tab_home.json"]]]],
//      ])
//      let fromFile = try CYLTagListView(configurationFile: "tags.json")
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import UIKit

// MARK: - Keys

/**
 * The keys of a tag list configuration (`CYLTagListView(configuration:)`).
 */
public enum CYLTagListKey {

    /**
     * An array of section dictionaries (`CYLTagSectionKey`).
     */
    public static let sections = "sections"

    /**
     * A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys.
     */
    public static let style = "style"

    /**
     * A `CYLMenuSelectionMode` raw value, or "none", "single", "multiple".
     */
    public static let selectionMode = "selectionMode"

    /**
     * A `CYLMenuFoldStyle` raw value, or "none", "headerButton", "footerChevron", "truncate".
     */
    public static let foldStyle = "foldStyle"

    /**
     * A Boolean, or "true" / "false".
     */
    public static let allowsEmptySelection = "allowsEmptySelection"

    /**
     * A Boolean, or "true" / "false".
     */
    public static let showsSectionHeaders = "showsSectionHeaders"

    /**
     * A Boolean, or "true" / "false".
     */
    public static let scrollEnabled = "scrollEnabled"

    /**
     * A number.
     */
    public static let defaultVisibleRows = "defaultVisibleRows"

    /**
     * An array of index paths, "section-item" strings or [section, item] arrays.
     */
    public static let selectedItems = "selectedItems"

    /**
     * A `CYLMenuFoldControl`, a position name ("bottom", "topTrailing"…), or a dictionary of `CYLMenuFoldControlKey`
     * keys. Applied after `foldStyle`.
     */
    public static let foldControl = "foldControl"

    /**
     * A string: the list's title, above every section.
     */
    public static let title = "title"

    /**
     * A `CYLMenuTitlePosition` raw value, or "topLeading" ("leading", "left"), "topCenter" ("center").
     */
    public static let titlePosition = "titlePosition"

    /**
     * A `UIImage`, or an image name, "system:<SF Symbol>" or a file path: the title's icon.
     */
    public static let titleImage = "titleImage"

    /**
     * A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys applied over `CYLTagListView.defaultTitleStyle`
     * (e.g. {normal: {textColor: "#07C160", iconColor: "#07C160"}}).
     */
    public static let titleStyle = "titleStyle"

    /**
     * An array of tags, as android-tagview's addTags(): strings (titles) or dictionaries of `CYLTagItemKey` keys
     * (title, image, id, deletable, enabled, style…). Replaces the list's tags (`addTags(_:)`, `tagDataSource`).
     */
    public static let tags = "tags"
}

/**
 * The keys of a fold control configuration (`CYLMenuFoldControl(configuration:)`).
 */
public enum CYLMenuFoldControlKey {

    /**
     * A `CYLMenuFoldControlPosition` raw value, or "none", "bottom", "topTrailing" ("topRight"), "topLeading"
     * ("topLeft"), "inline" (a tag cell among the tags).
     */
    public static let position = "position"

    /**
     * A `CYLMenuFoldControlContent` raw value, or "iconAndTitle" ("titleAndIcon"), "title", "icon".
     */
    public static let content = "content"

    /**
     * A string.
     */
    public static let title = "title"

    /**
     * A string.
     */
    public static let collapseTitle = "collapseTitle"

    /**
     * A `UIImage`, or an image name, "system:<SF Symbol>" or a file path.
     */
    public static let image = "image"

    /**
     * A `UIColor` or a color string.
     */
    public static let color = "color"

    /**
     * A `UIFont`, a point size, or {size:, weight:, name:, italic:}.
     */
    public static let font = "font"

    /**
     * A Boolean, or "true" / "false".
     */
    public static let rotatesImage = "rotatesImageWhenExpanded"
}

/**
 * The keys of a section dictionary (`CYLTagListKey.sections`).
 */
public enum CYLTagSectionKey {

    /**
     * A string.
     */
    public static let title = "title"

    /**
     * A `UIImage`, or an image name, "system:<SF Symbol>" or a file path.
     */
    public static let image = "image"

    /**
     * An array of item dictionaries (`CYLTagItemKey`), or of strings (titles).
     */
    public static let items = "items"

    /**
     * A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys applied over the list's style: the look of this
     * section's tags (see `menuStyle(forSection:)`), e.g. dark tags for white icons.
     */
    public static let style = "style"
}

/**
 * The keys of an item dictionary (`CYLTagSectionKey.items`, `CYLTagListKey.tags`).
 */
public enum CYLTagItemKey {

    /**
     * A string.
     */
    public static let title = "title"

    /**
     * A `UIImage`, or an image name, "system:<SF Symbol>" or a file path.
     */
    public static let image = "image"

    /**
     * A `UIImage`, or an image name, "system:<SF Symbol>" or a file path.
     */
    public static let selectedImage = "selectedImage"

    /**
     * A `URL`, or a URL string, a file path or a file name (in the main bundle, or next to the configuration file): a
     * Lottie .json, .pag, .riv or .gif animated icon.
     */
    public static let animation = "animation"

    /**
     * A dictionary of strings (numbers are converted): options read by the animation's library, written into the
     * animation URL with `URL.cylAddingAnimationOptions(_:)`. For Rive, as in CYLTabBarController: "artboard",
     * "stateMachine", "input", "triggerInput", "animation", "duration", "legacy"...
     */
    public static let animationOptions = "animationOptions"

    /**
     * A number 0...1: the frame shown while not selected (see `menuAnimationRestingProgressForItem(at:)`).
     */
    public static let animationRestingProgress = "animationRestingProgress"

    /**
     * A Boolean, or "true" / "false". True by default.
     */
    public static let enabled = "enabled"

    /**
     * A Boolean, or "true" / "false". False by default.
     */
    public static let exclusive = "exclusive"

    /**
     * A `CYLMenuItemType` raw value, or "tag" (default), "create" ("+ 新建标签"; its title is the name to create).
     */
    public static let type = "type"

    /**
     * A Boolean, or "true" / "false": shows the delete indicator ("×"); a tap removes the item. False by default.
     */
    public static let deletable = "deletable"

    /**
     * A number: `CYLTag.identifier` (`CYLTagListKey.tags` only).
     */
    public static let identifier = "id"

    /**
     * A `CYLMenuStyle`, or a dictionary of `CYLMenuStyleKey` keys applied over the section's style: this item's own
     * look.
     */
    public static let style = "style"
}

/**
 * The keys of a style dictionary (`CYLMenuStyle(configuration:)`).
 */
public enum CYLMenuStyleKey {

    /**
     * A dictionary of `CYLTagAppearanceKey` keys for the normal state.
     */
    public static let normal = "normal"

    /**
     * A dictionary of `CYLTagAppearanceKey` keys for the selected state.
     */
    public static let selected = "selected"

    /**
     * A dictionary of `CYLTagAppearanceKey` keys for the disabled state.
     */
    public static let disabled = "disabled"

    /**
     * A number.
     */
    public static let imageTitleSpacing = "imageTitleSpacing"

    /**
     * A number.
     */
    public static let itemHeight = "itemHeight"

    /**
     * The grid's items per row (`CYLMenuStyle.numberOfItemsPerRow`); 0 for the flow layout.
     */
    public static let numberOfItemsPerRow = "itemsPerRow"

    /**
     * A number.
     */
    public static let interitemSpacing = "interitemSpacing"

    /**
     * A number.
     */
    public static let lineSpacing = "lineSpacing"

    /**
     * A number.
     */
    public static let headerHeight = "headerHeight"

    /**
     * A number.
     */
    public static let animationSpeed = "animationSpeed"

    /**
     * A size: an `NSValue`, "{width, height}", [w, h] or {width:, height:}.
     */
    public static let imageSize = "imageSize"

    /**
     * A size: an `NSValue`, "{width, height}", [w, h] or {width:, height:}.
     */
    public static let animationSize = "animationSize"

    /**
     * Insets: an `NSValue`, "{top, left, bottom, right}", [t, l, b, r] or {top:, left:, bottom:, right:}.
     */
    public static let imageInsets = "imageInsets"

    /**
     * Insets: an `NSValue`, "{top, left, bottom, right}", [t, l, b, r] or {top:, left:, bottom:, right:}.
     */
    public static let sectionInsets = "sectionInsets"

    /**
     * An offset: an `NSValue`, "{horizontal, vertical}", [h, v] or {horizontal:, vertical:}.
     */
    public static let titlePositionAdjustment = "titlePositionAdjustment"

    /**
     * An offset: an `NSValue`, "{horizontal, vertical}", [h, v] or {horizontal:, vertical:}.
     */
    public static let imagePositionAdjustment = "imagePositionAdjustment"

    /**
     * A Boolean, or "true" / "false".
     */
    public static let layoutCentered = "layoutCentered"

    /**
     * A `CYLTagImagePlacement` raw value, or "leading" (icon, then title) / "trailing" (title, then icon).
     */
    public static let imagePlacement = "imagePlacement"

    /**
     * A `CYLTagContentAlignment` raw value, or "center" / "leading".
     */
    public static let contentAlignment = "contentAlignment"

    /**
     * A Boolean, or "true" / "false".
     */
    public static let adjustsFontForContentSizeCategory = "adjustsFontForContentSizeCategory"

    /**
     * A `UIColor`, or "#RGB", "#RRGGBB", "#RRGGBBAA" or a UIColor name ("systemBlue").
     */
    public static let backgroundColor = "backgroundColor"

    /**
     * A color.
     */
    public static let headerTextColor = "headerTextColor"

    /**
     * A color.
     */
    public static let foldControlColor = "foldControlColor"

    /**
     * A `UIFont`, a point size, or {size:, weight: "semibold", name: "Menlo", italic: true}.
     */
    public static let headerFont = "headerFont"

    /**
     * A color: the background while pressed.
     */
    public static let highlightedBackgroundColor = "highlightedBackgroundColor"

    /**
     * Insets for every state (android-tagview's textPaddingTop / Left / Bottom / Right).
     */
    public static let tagContentInsets = "tagContentInsets"

    /**
     * The delete indicator's text ("×").
     */
    public static let deleteIndicatorTitle = "deleteIndicatorTitle"

    /**
     * The delete indicator's color.
     */
    public static let deleteIndicatorColor = "deleteIndicatorColor"

    /**
     * The delete indicator's font.
     */
    public static let deleteIndicatorFont = "deleteIndicatorFont"
}

/**
 * The keys of an appearance dictionary (`CYLTagAppearance.applyConfiguration(_:)`), as CYLBadgeAppearance.
 */
public enum CYLTagAppearanceKey {

    /**
     * A color.
     */
    public static let backgroundColor = "backgroundColor"

    /**
     * A color.
     */
    public static let textColor = "textColor"

    /**
     * A font.
     */
    public static let font = "font"

    /**
     * A color.
     */
    public static let iconColor = "iconColor"

    /**
     * A number.
     */
    public static let cornerRadius = "cornerRadius"

    /**
     * A color.
     */
    public static let borderColor = "borderColor"

    /**
     * A number.
     */
    public static let borderWidth = "borderWidth"

    /**
     * A number.
     */
    public static let margin = "margin"

    /**
     * Insets: space between the border and the content on each side.
     */
    public static let contentInsets = "contentInsets"

    /**
     * A `UIImage`, or an image name, "system:<SF Symbol>" or a file path, drawn behind the content.
     */
    public static let backgroundImage = "backgroundImage"
}

// MARK: - Errors

/**
 * Why a configuration file could not be read (domain `CYLMenuConfigurationErrorDomain`).
 */
public struct CYLMenuConfigurationError: Error, CustomNSError, LocalizedError {

    /**
     * The error codes.
     */
    public enum Code: Int, Sendable {
        /**
         * No file at the path.
         */
        case fileNotFound = 1
        /**
         * The file does not hold a dictionary.
         */
        case invalidContents
        /**
         * The format needs CYLTabBarController's configuration parser, which is not linked.
         */
        case unsupportedFormat
    }

    /**
     * The error domain, as in Objective-C.
     */
    public static let errorDomain = "CYLMenuConfigurationErrorDomain"

    /**
     * What went wrong.
     */
    public let code: Code

    /**
     * A description for developers.
     */
    public let message: String

    public var errorCode: Int {
        code.rawValue
    }

    public var errorUserInfo: [String: Any] {
        [NSLocalizedDescriptionKey: message]
    }

    public var errorDescription: String? {
        message
    }
}

// MARK: - Values

/**
 * Reads configuration values: the types of code, or the strings of a file.
 */
enum CYLConfigurationValue {

    /**
     * The directory of the configuration file, added by `configuration(contentsOfFile:)` so that relative file names
     * resolve next to it.
     */
    static let baseURLKey = "__CYLConfigurationBaseURL"

    static func number(_ value: Any?) -> NSNumber? {
        if let number = value as? NSNumber {
            return number
        }
        guard let string = (value as? String)?.trimmingCharacters(in: .whitespaces).lowercased() else {
            return nil
        }
        if ["true", "yes", "on"].contains(string) {
            return true
        }
        if ["false", "no", "off"].contains(string) {
            return false
        }
        return Double(string).map { NSNumber(value: $0) }
    }

    static func double(_ value: Any?) -> CGFloat? {
        number(value).map { CGFloat($0.doubleValue) }
    }

    static func bool(_ value: Any?) -> Bool? {
        number(value)?.boolValue
    }

    static func numbers(_ value: Any?, count: Int) -> [CGFloat]? {
        var parts: [Any]
        if let array = value as? [Any] {
            parts = array
        } else if let string = value as? String {
            let trimmed = string.filter { !"{}[]".contains($0) }
            parts = trimmed.components(separatedBy: ",")
        } else {
            return nil
        }
        guard parts.count == count else {
            return nil
        }
        var numbers: [CGFloat] = []
        for part in parts {
            guard let number = double(part) else {
                return nil
            }
            numbers.append(number)
        }
        return numbers
    }

    static func insets(_ value: Any?) -> UIEdgeInsets? {
        if let value = value as? NSValue, !(value is NSNumber) {
            return value.uiEdgeInsetsValue
        }
        if let dictionary = value as? [String: Any] {
            return UIEdgeInsets(top: double(dictionary["top"]) ?? 0, left: double(dictionary["left"]) ?? 0,
                                bottom: double(dictionary["bottom"]) ?? 0, right: double(dictionary["right"]) ?? 0)
        }
        return numbers(value, count: 4).map { UIEdgeInsets(top: $0[0], left: $0[1], bottom: $0[2], right: $0[3]) }
    }

    static func size(_ value: Any?) -> CGSize? {
        if let value = value as? NSValue, !(value is NSNumber) {
            return value.cgSizeValue
        }
        if let dictionary = value as? [String: Any] {
            return CGSize(width: double(dictionary["width"]) ?? 0, height: double(dictionary["height"]) ?? 0)
        }
        if let side = double(value) {
            return CGSize(width: side, height: side)
        }
        return numbers(value, count: 2).map { CGSize(width: $0[0], height: $0[1]) }
    }

    static func offset(_ value: Any?) -> UIOffset? {
        if let value = value as? NSValue, !(value is NSNumber) {
            return value.uiOffsetValue
        }
        if let dictionary = value as? [String: Any] {
            return UIOffset(horizontal: double(dictionary["horizontal"]) ?? 0,
                            vertical: double(dictionary["vertical"]) ?? 0)
        }
        return numbers(value, count: 2).map { UIOffset(horizontal: $0[0], vertical: $0[1]) }
    }

    static func color(_ value: Any?) -> UIColor? {
        if let color = value as? UIColor {
            return color
        }
        return (value as? String).flatMap { UIColor.cylMenuColor(from: $0) }
    }

    static func font(_ value: Any?) -> UIFont? {
        if let font = value as? UIFont {
            return font
        }
        if let size = double(value) {
            return UIFont.systemFont(ofSize: size)
        }
        guard let dictionary = value as? [String: Any] else {
            return nil
        }
        let pointSize = double(dictionary["size"]).flatMap { $0 != 0 ? $0 : nil } ?? 14
        let weights: [String: UIFont.Weight] = ["ultralight": .ultraLight, "thin": .thin, "light": .light,
                                                "regular": .regular, "medium": .medium, "semibold": .semibold,
                                                "bold": .bold, "heavy": .heavy, "black": .black]
        var font = (dictionary["name"] as? String).flatMap { UIFont(name: $0, size: pointSize) }
        if font == nil {
            let weight = (dictionary["weight"] as? String).flatMap { weights[$0.lowercased()] } ?? .regular
            font = UIFont.systemFont(ofSize: pointSize, weight: weight)
        }
        if bool(dictionary["italic"]) == true, let current = font,
           let italic = current.fontDescriptor.withSymbolicTraits(current.fontDescriptor.symbolicTraits.union(.traitItalic)) {
            font = UIFont(descriptor: italic, size: pointSize)
        }
        return font
    }

    static func fileURL(_ value: Any?, baseURL: URL?) -> URL? {
        if let url = value as? URL {
            return url
        }
        guard let string = value as? String, !string.isEmpty else {
            return nil
        }
        // "file.riv#artboard=HOME": resolve the file, then keep the options.
        if let hash = string.firstIndex(of: "#"), hash > string.startIndex,
           (URL(string: string)?.scheme?.count ?? 0) <= 1 {
            let file = fileURL(String(string[..<hash]), baseURL: baseURL)
            guard let file, var components = URLComponents(url: file, resolvingAgainstBaseURL: true) else {
                return file
            }
            components.percentEncodedFragment = String(string[string.index(after: hash)...])
            return components.url ?? file
        }
        if let url = URL(string: string), (url.scheme?.count ?? 0) > 1 {
            return url
        }
        if (string as NSString).isAbsolutePath {
            return URL(fileURLWithPath: string)
        }
        let candidates = [baseURL, Bundle.main.resourceURL].compactMap { $0?.appendingPathComponent(string) }
        if let existing = candidates.first(where: { FileManager.default.fileExists(atPath: $0.path) }) {
            return existing
        }
        let name = (string as NSString).deletingPathExtension
        let pathExtension = (string as NSString).pathExtension
        return Bundle.main.url(forResource: name, withExtension: pathExtension.isEmpty ? nil : pathExtension)
    }

    static func image(_ value: Any?, baseURL: URL?) -> UIImage? {
        if let image = value as? UIImage {
            return image
        }
        guard let string = value as? String, !string.isEmpty else {
            return nil
        }
        let systemPrefix = "system:"
        if string.hasPrefix(systemPrefix) {
            return UIImage(systemName: String(string.dropFirst(systemPrefix.count)))
        }
        if let image = UIImage(named: string) {
            return image
        }
        guard let url = fileURL(string, baseURL: baseURL), url.isFileURL else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    /**
     * An enum's raw value from a number or one of `names` (lowercased); nil when it is neither.
     */
    static func rawValue(_ value: Any?, names: [String: Int]) -> Int? {
        if let number = value as? NSNumber {
            return number.intValue
        }
        guard let string = value as? String else {
            return nil
        }
        return names[string.lowercased()] ?? number(string)?.intValue
    }

    static func baseURL(of configuration: [String: Any]) -> URL? {
        configuration[baseURLKey] as? URL
    }

    /**
     * `value` as a dictionary, with the configuration file's directory when there is one.
     */
    static func dictionary(_ value: Any?, baseURL: URL?) -> [String: Any]? {
        guard var dictionary = value as? [String: Any] else {
            return nil
        }
        if let baseURL {
            dictionary[baseURLKey] = baseURL
        }
        return dictionary
    }
}

// MARK: - Colors and animation URLs

extension UIColor {

    /**
     * A color from "#RGB", "#RRGGBB", "#RRGGBBAA" or a UIColor name ("systemBlue", "systemBlueColor"); `nil`
     * otherwise.
     */
    public static func cylMenuColor(from string: String) -> UIColor? {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("#") {
            var hex = String(trimmed.dropFirst())
            if hex.count == 3 {
                hex = hex.map { "\($0)\($0)" }.joined()
            }
            guard hex.count == 6 || hex.count == 8, var rgba = UInt64(hex, radix: 16) else {
                return nil
            }
            if hex.count == 6 {
                rgba = (rgba << 8) | 0xFF
            }
            return UIColor(red: CGFloat((rgba >> 24) & 0xFF) / 255, green: CGFloat((rgba >> 16) & 0xFF) / 255,
                           blue: CGFloat((rgba >> 8) & 0xFF) / 255, alpha: CGFloat(rgba & 0xFF) / 255)
        }
        // A UIColor class property name: "systemBlue" or "systemBlueColor".
        let name = trimmed.hasSuffix("Color") ? trimmed : trimmed + "Color"
        let selector = NSSelectorFromString(name)
        guard !trimmed.isEmpty, class_getClassMethod(UIColor.self, selector) != nil else {
            return nil
        }
        return (UIColor.self as AnyObject).perform(selector)?.takeUnretainedValue() as? UIColor
    }
}

extension URL {

    /**
     * This animation URL with options, encoded exactly as CYLTabBarController's CYLTabBarAnimationURLWithOptions()
     * does ("name=value&…" in the fragment, percent-encoded and sorted by name), so that its animation libraries read
     * them, e.g. which artboard and state machine of a Rive file a tag plays. Values are strings or numbers; the URL
     * itself when there are no options.
     *
     *     item.animationURL = iconsURL.cylAddingAnimationOptions(["artboard": "CHAT",
     *                                                             "stateMachine": "CHAT_Interactivity",
     *                                                             "input": "active"])
     */
    public func cylAddingAnimationOptions(_ options: [String: Any]) -> URL {
        guard !options.isEmpty, var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+#?")
        let items: [String] = options.keys.filter { !$0.isEmpty }.sorted().compactMap { name in
            let value = options[name]
            let string = value as? String ?? (value as? NSNumber)?.stringValue
            guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: allowed),
                  let encodedValue = string?.addingPercentEncoding(withAllowedCharacters: allowed),
                  !encodedName.isEmpty, !encodedValue.isEmpty else {
                return nil
            }
            return "\(encodedName)=\(encodedValue)"
        }
        components.percentEncodedFragment = items.isEmpty ? nil : items.joined(separator: "&")
        return components.url ?? self
    }
}

// MARK: - Data source built from a configuration

/**
 * The data source of `CYLTagListKey.sections`.
 */
final class CYLTagListConfigurationSource: NSObject, CYLMenuDataSource {

    private(set) var sections: [[String: Any]]
    private let baseURL: URL?
    /**
     * The view whose style a section style dictionary starts from.
     */
    private weak var owner: CYLTagListView?
    /**
     * Each section's style and the list style it was made from, so the same object is returned until the list's style
     * changes.
     */
    private var sectionStyles: [Int: (base: CYLMenuStyle, style: CYLMenuStyle)] = [:]
    /**
     * Each item's style (`CYLTagItemKey.style`) and the base style it was made from.
     */
    private var itemStyles: [IndexPath: (base: CYLMenuStyle, style: CYLMenuStyle)] = [:]

    init(sections: [[String: Any]], baseURL: URL?, owner: CYLTagListView) {
        self.sections = sections
        self.baseURL = baseURL
        self.owner = owner
        super.init()
    }

    private func items(inSection section: Int) -> [Any] {
        guard sections.indices.contains(section) else {
            return []
        }
        return sections[section][CYLTagSectionKey.items] as? [Any] ?? []
    }

    private func item(at indexPath: IndexPath) -> [String: Any] {
        let items = items(inSection: indexPath.section)
        guard items.indices.contains(indexPath.item) else {
            return [:]
        }
        let item = items[indexPath.item]
        return item as? [String: Any] ?? [CYLTagItemKey.title: "\(item)"]
    }

    private var listStyle: CYLMenuStyle {
        owner?.style ?? CYLMenuStyle()
    }

    func numberOfSectionsInMenu() -> Int {
        sections.count
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        items(inSection: section).count
    }

    func menuTitle(forSection section: Int) -> String {
        guard sections.indices.contains(section), let title = sections[section][CYLTagSectionKey.title] else {
            return ""
        }
        return "\(title)"
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        item(at: indexPath)[CYLTagItemKey.title].map { "\($0)" } ?? ""
    }

    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        CYLConfigurationValue.image(item(at: indexPath)[CYLTagItemKey.image], baseURL: baseURL)
    }

    func menuSelectedImageForItem(at indexPath: IndexPath) -> UIImage? {
        CYLConfigurationValue.image(item(at: indexPath)[CYLTagItemKey.selectedImage], baseURL: baseURL)
    }

    func menuAnimationURLForItem(at indexPath: IndexPath) -> URL? {
        let item = item(at: indexPath)
        let url = CYLConfigurationValue.fileURL(item[CYLTagItemKey.animation], baseURL: baseURL)
        let options = item[CYLTagItemKey.animationOptions] as? [String: Any] ?? [:]
        return url?.cylAddingAnimationOptions(options)
    }

    func menuImage(forSection section: Int) -> UIImage? {
        guard sections.indices.contains(section) else {
            return nil
        }
        return CYLConfigurationValue.image(sections[section][CYLTagSectionKey.image], baseURL: baseURL)
    }

    func menuAnimationRestingProgressForItem(at indexPath: IndexPath) -> NSNumber? {
        CYLConfigurationValue.number(item(at: indexPath)[CYLTagItemKey.animationRestingProgress])
    }

    func menuStyle(forSection section: Int) -> CYLMenuStyle? {
        let value = sections.indices.contains(section) ? sections[section][CYLTagSectionKey.style] : nil
        if let style = value as? CYLMenuStyle {
            return style
        }
        guard let configuration = value as? [String: Any] else {
            return nil
        }
        let base = listStyle
        if let cached = sectionStyles[section], cached.base === base {
            return cached.style
        }
        let style = base.cylCopy()
        style.applyConfiguration(configuration)
        sectionStyles[section] = (base, style)
        return style
    }

    func menuItemIsEnabled(at indexPath: IndexPath) -> Bool {
        CYLConfigurationValue.bool(item(at: indexPath)[CYLTagItemKey.enabled]) ?? true
    }

    func menuItemIsExclusive(at indexPath: IndexPath) -> Bool {
        CYLConfigurationValue.bool(item(at: indexPath)[CYLTagItemKey.exclusive]) ?? false
    }

    func menuItemIsDeletable(at indexPath: IndexPath) -> Bool {
        CYLConfigurationValue.bool(item(at: indexPath)[CYLTagItemKey.deletable]) ?? false
    }

    func menuRemoveItem(at indexPath: IndexPath) {
        guard sections.indices.contains(indexPath.section) else {
            return
        }
        var items = items(inSection: indexPath.section)
        guard items.indices.contains(indexPath.item) else {
            return
        }
        items.remove(at: indexPath.item)
        sections[indexPath.section][CYLTagSectionKey.items] = items
        itemStyles.removeAll()
    }

    func menuStyleForItem(at indexPath: IndexPath) -> CYLMenuStyle? {
        let value = item(at: indexPath)[CYLTagItemKey.style]
        if let style = value as? CYLMenuStyle {
            return style
        }
        guard let configuration = value as? [String: Any] else {
            return nil
        }
        let base = menuStyle(forSection: indexPath.section) ?? listStyle
        if let cached = itemStyles[indexPath], cached.base === base {
            return cached.style
        }
        let style = base.cylCopy()
        style.applyConfiguration(configuration)
        itemStyles[indexPath] = (base, style)
        return style
    }

    func menuItemType(at indexPath: IndexPath) -> CYLMenuItemType {
        let names = ["tag": CYLMenuItemType.tag.rawValue, "create": CYLMenuItemType.create.rawValue,
                     "new": CYLMenuItemType.create.rawValue]
        return CYLConfigurationValue.rawValue(item(at: indexPath)[CYLTagItemKey.type], names: names)
            .flatMap(CYLMenuItemType.init(rawValue:)) ?? .tag
    }
}

// MARK: - Fold control

extension CYLMenuFoldControl {

    /**
     * A fold control from a dictionary of `CYLMenuFoldControlKey` keys, or from a position name or raw value alone
     * (with the content that suits it: an icon below, an icon and a title in the header); `nil` for anything else.
     */
    public convenience init?(configuration: Any) {
        guard configuration is [String: Any] || configuration is String || configuration is NSNumber else {
            return nil
        }
        self.init(position: .none, content: .icon)
        if let dictionary = configuration as? [String: Any] {
            applyConfiguration(dictionary)
        } else {
            applyConfiguration([CYLMenuFoldControlKey.position: configuration])
            content = position == .bottom ? .icon : .iconAndTitle
        }
    }

    /**
     * Applies a dictionary of `CYLMenuFoldControlKey` keys; missing keys keep their values.
     */
    public func applyConfiguration(_ configuration: [String: Any]) {
        typealias Value = CYLConfigurationValue
        let baseURL = Value.baseURL(of: configuration)
        let positions = ["none": CYLMenuFoldControlPosition.none.rawValue,
                         "bottom": CYLMenuFoldControlPosition.bottom.rawValue,
                         "toptrailing": CYLMenuFoldControlPosition.topTrailing.rawValue,
                         "topright": CYLMenuFoldControlPosition.topTrailing.rawValue,
                         "topleading": CYLMenuFoldControlPosition.topLeading.rawValue,
                         "topleft": CYLMenuFoldControlPosition.topLeading.rawValue,
                         "inline": CYLMenuFoldControlPosition.inline.rawValue]
        if let raw = Value.rawValue(configuration[CYLMenuFoldControlKey.position], names: positions),
           let position = CYLMenuFoldControlPosition(rawValue: raw) {
            self.position = position
        }
        let contents = ["iconandtitle": CYLMenuFoldControlContent.iconAndTitle.rawValue,
                        "titleandicon": CYLMenuFoldControlContent.iconAndTitle.rawValue,
                        "title": CYLMenuFoldControlContent.title.rawValue,
                        "icon": CYLMenuFoldControlContent.icon.rawValue]
        if let raw = Value.rawValue(configuration[CYLMenuFoldControlKey.content], names: contents),
           let content = CYLMenuFoldControlContent(rawValue: raw) {
            self.content = content
        }
        if let title = configuration[CYLMenuFoldControlKey.title] as? String {
            self.title = title
        }
        if let collapseTitle = configuration[CYLMenuFoldControlKey.collapseTitle] as? String {
            self.collapseTitle = collapseTitle
        }
        if let image = Value.image(configuration[CYLMenuFoldControlKey.image], baseURL: baseURL) {
            self.image = image
        }
        if let color = Value.color(configuration[CYLMenuFoldControlKey.color]) {
            self.color = color
        }
        if let font = Value.font(configuration[CYLMenuFoldControlKey.font]) {
            self.font = font
        }
        if let rotates = Value.bool(configuration[CYLMenuFoldControlKey.rotatesImage]) {
            rotatesImageWhenExpanded = rotates
        }
    }
}

// MARK: - Style

extension CYLTagAppearance {

    /**
     * Applies a dictionary of `CYLTagAppearanceKey` keys; missing keys keep their values, a key whose value is not a
     * color, font or image clears it.
     */
    public func applyConfiguration(_ configuration: [String: Any]) {
        typealias Value = CYLConfigurationValue
        typealias Key = CYLTagAppearanceKey
        let baseURL = Value.baseURL(of: configuration)
        if let value = configuration[Key.backgroundColor] {
            backgroundColor = Value.color(value)
        }
        if let value = configuration[Key.textColor] {
            textColor = Value.color(value)
        }
        if let value = configuration[Key.font] {
            font = Value.font(value)
        }
        if let value = configuration[Key.iconColor] {
            iconColor = Value.color(value)
        }
        if let value = configuration[Key.borderColor] {
            borderColor = Value.color(value)
        }
        if let value = Value.double(configuration[Key.cornerRadius]) {
            cornerRadius = value
        }
        if let value = Value.double(configuration[Key.borderWidth]) {
            borderWidth = value
        }
        if let value = Value.double(configuration[Key.margin]) {
            margin = value
        }
        if let value = Value.insets(configuration[Key.contentInsets]) {
            contentInsets = value
        }
        if let value = configuration[Key.backgroundImage] {
            backgroundImage = Value.image(value, baseURL: baseURL)
        }
    }
}

extension CYLMenuStyle {

    /**
     * A default style with the configuration's values (`CYLMenuStyleKey` keys).
     */
    public convenience init(configuration: [String: Any]) {
        self.init()
        applyConfiguration(configuration)
    }

    /**
     * Applies a dictionary of `CYLMenuStyleKey` keys; missing keys keep their values.
     */
    public func applyConfiguration(_ configuration: [String: Any]) {
        typealias Value = CYLConfigurationValue
        typealias Key = CYLMenuStyleKey
        let baseURL = Value.baseURL(of: configuration)
        let appearances = [(Key.normal, normalAppearance), (Key.selected, selectedAppearance),
                           (Key.disabled, disabledAppearance)]
        for (key, appearance) in appearances {
            if let dictionary = Value.dictionary(configuration[key], baseURL: baseURL) {
                appearance.applyConfiguration(dictionary)
            }
        }
        if let value = Value.double(configuration[Key.imageTitleSpacing]) {
            imageTitleSpacing = value
        }
        if let value = Value.double(configuration[Key.itemHeight]) {
            itemHeight = value
        }
        if let value = Value.number(configuration[Key.numberOfItemsPerRow]) {
            numberOfItemsPerRow = UInt(max(0, value.intValue))
        }
        if let value = Value.double(configuration[Key.interitemSpacing]) {
            interitemSpacing = value
        }
        if let value = Value.double(configuration[Key.lineSpacing]) {
            lineSpacing = value
        }
        if let value = Value.double(configuration[Key.headerHeight]) {
            headerHeight = value
        }
        if let value = Value.double(configuration[Key.animationSpeed]) {
            animationSpeed = value
        }
        if let value = Value.bool(configuration[Key.layoutCentered]) {
            layoutCentered = value
        }
        let placements = ["leading": CYLTagImagePlacement.leading.rawValue, "left": CYLTagImagePlacement.leading.rawValue,
                          "trailing": CYLTagImagePlacement.trailing.rawValue,
                          "right": CYLTagImagePlacement.trailing.rawValue]
        if let raw = Value.rawValue(configuration[Key.imagePlacement], names: placements),
           let placement = CYLTagImagePlacement(rawValue: raw) {
            imagePlacement = placement
        }
        let alignments = ["center": CYLTagContentAlignment.center.rawValue,
                          "leading": CYLTagContentAlignment.leading.rawValue,
                          "left": CYLTagContentAlignment.leading.rawValue]
        if let raw = Value.rawValue(configuration[Key.contentAlignment], names: alignments),
           let alignment = CYLTagContentAlignment(rawValue: raw) {
            contentAlignment = alignment
        }
        if let value = Value.bool(configuration[Key.adjustsFontForContentSizeCategory]) {
            adjustsFontForContentSizeCategory = value
        }
        if let value = Value.size(configuration[Key.imageSize]) {
            imageSize = value
        }
        if let value = Value.size(configuration[Key.animationSize]) {
            animationSize = value
        }
        if let value = Value.insets(configuration[Key.imageInsets]) {
            imageInsets = value
        }
        if let value = Value.insets(configuration[Key.sectionInsets]) {
            sectionInsets = value
        }
        if let value = Value.offset(configuration[Key.titlePositionAdjustment]) {
            titlePositionAdjustment = value
        }
        if let value = Value.offset(configuration[Key.imagePositionAdjustment]) {
            imagePositionAdjustment = value
        }
        if let value = Value.color(configuration[Key.backgroundColor]) {
            backgroundColor = value
        }
        if let value = Value.color(configuration[Key.headerTextColor]) {
            headerTextColor = value
        }
        if let value = Value.color(configuration[Key.foldControlColor]) {
            foldControlColor = value
        }
        if let value = Value.font(configuration[Key.headerFont]) {
            headerFont = value
        }
        if let value = configuration[Key.highlightedBackgroundColor] {
            highlightedBackgroundColor = Value.color(value)
        }
        if let value = Value.insets(configuration[Key.tagContentInsets]) {
            tagContentInsets = value
        }
        if let value = configuration[Key.deleteIndicatorTitle] as? String {
            deleteIndicatorTitle = value
        }
        if let value = configuration[Key.deleteIndicatorColor] {
            deleteIndicatorColor = Value.color(value)
        }
        if let value = configuration[Key.deleteIndicatorFont] {
            deleteIndicatorFont = Value.font(value)
        }
    }
}

// MARK: - Tag

extension CYLTag {

    /**
     * A tag from a dictionary of `CYLTagItemKey` keys (title, image, selectedImage, animation, id, enabled, deletable,
     * style).
     */
    public convenience init(configuration: [String: Any]) {
        typealias Value = CYLConfigurationValue
        let baseURL = Value.baseURL(of: configuration)
        self.init(identifier: Value.number(configuration[CYLTagItemKey.identifier])?.intValue ?? 0,
                  title: configuration[CYLTagItemKey.title].map { "\($0)" } ?? "")
        image = Value.image(configuration[CYLTagItemKey.image], baseURL: baseURL)
        selectedImage = Value.image(configuration[CYLTagItemKey.selectedImage], baseURL: baseURL)
        let options = configuration[CYLTagItemKey.animationOptions] as? [String: Any] ?? [:]
        animationURL = Value.fileURL(configuration[CYLTagItemKey.animation], baseURL: baseURL)?
            .cylAddingAnimationOptions(options)
        isEnabled = Value.bool(configuration[CYLTagItemKey.enabled]) ?? true
        isDeletable = Value.bool(configuration[CYLTagItemKey.deletable]) ?? false
        if let style = configuration[CYLTagItemKey.style] as? CYLMenuStyle {
            self.style = style
        } else if let dictionary = configuration[CYLTagItemKey.style] as? [String: Any] {
            self.style = CYLMenuStyle(configuration: dictionary)
        }
    }
}

// MARK: - Tag list

/**
 * Finds CYLTabBarController's configuration parser at runtime: this library does not depend on CYLTabBarController.
 */
private enum CYLTabBarConfigurationReader {

    typealias Read = @convention(c) (AnyObject, Selector, NSString, AutoreleasingUnsafeMutablePointer<NSError?>?)
        -> AnyObject?

    /**
     * The file's contents read by `+[CYLTabBarConfigurationParser dictionaryWithContentsOfFile:error:]`, else by
     * `+[CYLTabBarController configurationWithContentsOfFile:error:]`.
     *
     * - Throws: `CYLMenuConfigurationError.Code.unsupportedFormat` when neither is linked, or the parser's error.
     */
    static func contents(ofFile url: URL) throws -> Any? {
        let candidates = [("CYLTabBarConfigurationParser", "dictionaryWithContentsOfFile:error:"),
                          ("CYLTabBarController", "configurationWithContentsOfFile:error:")]
        for (className, selectorName) in candidates {
            let selector = NSSelectorFromString(selectorName)
            guard let parser = NSClassFromString(className), let method = class_getClassMethod(parser, selector) else {
                continue
            }
            let read = unsafeBitCast(method_getImplementation(method), to: Read.self)
            var error: NSError?
            let contents = read(parser as AnyObject, selector, url.path as NSString, &error)
            if let error {
                throw error
            }
            return contents
        }
        throw CYLMenuConfigurationError(
            code: .unsupportedFormat,
            message: "Reading .\(url.pathExtension) files needs CYLTabBarController; use JSON or a property list.")
    }
}

extension CYLTagListView {

    private static var configurationDataSourceKey: UInt8 = 0

    /**
     * Creates a tag list from one dictionary holding everything (`CYLTagListKey`). The view keeps the data source it
     * builds from `CYLTagListKey.sections`.
     */
    public convenience init(configuration: [String: Any]) {
        self.init(frame: .zero)
        applyConfiguration(configuration)
    }

    /**
     * Reads a configuration file (`configuration(contentsOfFile:)`) and creates a tag list from it.
     */
    public convenience init(configurationFile filePath: String) throws {
        let configuration = try Self.configuration(contentsOfFile: filePath)
        self.init(configuration: configuration)
    }

    /**
     * The data source built from `CYLTagListKey.sections`, or `nil`.
     */
    public var configurationDataSource: CYLMenuDataSource? {
        objc_getAssociatedObject(self, &Self.configurationDataSourceKey) as? CYLMenuDataSource
    }

    /**
     * Applies a configuration to an existing view; keys that are missing keep their values.
     */
    public func applyConfiguration(_ configuration: [String: Any]) {
        typealias Value = CYLConfigurationValue
        typealias Key = CYLTagListKey
        let baseURL = Value.baseURL(of: configuration)
        if let value = configuration[Key.style] {
            if let style = value as? CYLMenuStyle {
                self.style = style
            } else if let dictionary = Value.dictionary(value, baseURL: baseURL) {
                updateStyle(with: dictionary)
            }
        }
        let modes = ["none": CYLMenuSelectionMode.none.rawValue, "single": CYLMenuSelectionMode.single.rawValue,
                     "multiple": CYLMenuSelectionMode.multiple.rawValue]
        if let raw = Value.rawValue(configuration[Key.selectionMode], names: modes),
           let mode = CYLMenuSelectionMode(rawValue: raw) {
            selectionMode = mode
        }
        let foldStyles = ["none": CYLMenuFoldStyle.none.rawValue, "headerbutton": CYLMenuFoldStyle.headerButton.rawValue,
                          "footerchevron": CYLMenuFoldStyle.footerChevron.rawValue,
                          "truncate": CYLMenuFoldStyle.truncate.rawValue]
        if let raw = Value.rawValue(configuration[Key.foldStyle], names: foldStyles),
           let foldStyle = CYLMenuFoldStyle(rawValue: raw) {
            self.foldStyle = foldStyle
        }
        if let value = configuration[Key.foldControl] {
            if let control = value as? CYLMenuFoldControl {
                foldControl = control
            } else if let control = CYLMenuFoldControl(configuration: Value.dictionary(value, baseURL: baseURL) ?? value) {
                // A relative image file of the control resolves next to the configuration file.
                foldControl = control
            }
        }
        let positions = ["topleading": CYLMenuTitlePosition.topLeading.rawValue,
                         "leading": CYLMenuTitlePosition.topLeading.rawValue,
                         "left": CYLMenuTitlePosition.topLeading.rawValue,
                         "topcenter": CYLMenuTitlePosition.topCenter.rawValue,
                         "center": CYLMenuTitlePosition.topCenter.rawValue]
        if let raw = Value.rawValue(configuration[Key.titlePosition], names: positions),
           let position = CYLMenuTitlePosition(rawValue: raw) {
            titlePosition = position
        }
        if let value = configuration[Key.titleStyle] {
            if let style = value as? CYLMenuStyle {
                titleStyle = style
            } else if let dictionary = Value.dictionary(value, baseURL: baseURL) {
                let style = Self.defaultTitleStyle
                style.applyConfiguration(dictionary)
                titleStyle = style
            }
        }
        if let image = Value.image(configuration[Key.titleImage], baseURL: baseURL) {
            titleImage = image
        }
        if let title = configuration[Key.title] as? String {
            self.title = title
        }
        if let value = Value.bool(configuration[Key.allowsEmptySelection]) {
            allowsEmptySelection = value
        }
        if let value = Value.bool(configuration[Key.showsSectionHeaders]) {
            showsSectionHeaders = value
        }
        if let value = Value.bool(configuration[Key.scrollEnabled]) {
            isScrollEnabled = value
        }
        if let value = Value.number(configuration[Key.defaultVisibleRows]) {
            defaultVisibleRows = max(0, value.intValue)
        }
        if let sections = configuration[Key.sections] as? [[String: Any]] {
            let source = CYLTagListConfigurationSource(sections: sections, baseURL: baseURL, owner: self)
            // The view holds its data source weakly: keep this one alive with the view.
            objc_setAssociatedObject(self, &Self.configurationDataSourceKey, source, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            menuDataSource = source
            reloadMenuData()
        }
        if let items = configuration[Key.tags] as? [Any] {
            let tags = items.map { item in
                CYLTag(configuration: Value.dictionary(item, baseURL: baseURL) ?? [CYLTagItemKey.title: "\(item)"])
            }
            removeAllTags()
            addTags(tags)
        }
        if let items = configuration[Key.selectedItems] as? [Any] {
            selectedIndexPaths = items.compactMap { item -> IndexPath? in
                if let indexPath = item as? IndexPath {
                    return indexPath
                }
                let pair = (item as? String).map { Value.numbers($0.replacingOccurrences(of: "-", with: ","), count: 2) }
                    ?? Value.numbers(item, count: 2)
                return pair.map { IndexPath(item: Int($0[1]), section: Int($0[0])) }
            }
        }
    }

    /**
     * Reads a configuration file: a path, a file URL string, or a file name in the main bundle (e.g. "tags.json" or
     * "Configurations.bundle/tags.plist"). JSON and property lists (XML or binary) are read directly; the other formats
     * of CYLTabBarController's CYLTabBarConfigurationParser (JSON5, YAML, TOML, INI, .properties, XML, Protocol Buffers
     * text…) are read by it when CYLTabBarController is linked. The values are then read by this project's rules
     * (strings for every key). Relative file names inside resolve next to the file.
     *
     * - Throws: `CYLMenuConfigurationError`, or the reader's error.
     */
    public static func configuration(contentsOfFile filePath: String) throws -> [String: Any] {
        guard let url = CYLConfigurationValue.fileURL(filePath, baseURL: nil), url.isFileURL,
              FileManager.default.fileExists(atPath: url.path) else {
            throw CYLMenuConfigurationError(code: .fileNotFound, message: "No configuration file at \(filePath)")
        }
        let pathExtension = url.pathExtension.lowercased()
        var contents: Any?
        if ["json", "plist", ""].contains(pathExtension) {
            let data = try Data(contentsOf: url)
            if pathExtension == "plist" {
                contents = try PropertyListSerialization.propertyList(from: data, format: nil)
            } else if pathExtension == "json" {
                contents = try JSONSerialization.jsonObject(with: data)
            } else {
                contents = (try? JSONSerialization.jsonObject(with: data))
                    ?? (try? PropertyListSerialization.propertyList(from: data, format: nil))
            }
        } else {
            // JSON5, YAML, TOML, INI, .properties, XML…: CYLTabBarController's configuration parser, when it is linked.
            contents = try CYLTabBarConfigurationReader.contents(ofFile: url)
        }
        guard var configuration = contents as? [String: Any] else {
            throw CYLMenuConfigurationError(code: .invalidContents, message: "\(filePath) does not hold a dictionary")
        }
        configuration[CYLConfigurationValue.baseURLKey] = url.deletingLastPathComponent()
        return configuration
    }

    private func updateStyle(with configuration: [String: Any]) {
        let copy = style.cylCopy()
        copy.applyConfiguration(configuration)
        style = copy
    }
}

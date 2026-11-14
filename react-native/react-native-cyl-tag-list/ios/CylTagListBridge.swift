import UIKit
import CollectionViewClassifyMenu

/// The native CYLTagListView behind the Fabric view, with an Objective-C friendly API (JSON in, dictionaries out).
@objc(CylTagListBridge)
public final class CylTagListBridge: UIView {

    @objc public var onTap: (([String: Any]) -> Void)?
    @objc public var onSelection: (([[String: Any]]) -> Void)?
    @objc public var onContentHeight: ((Double) -> Void)?

    private var tagList: CYLTagListView?
    // A separate object, so that the Objective-C header of this class does not name the core's protocol.
    private lazy var delegate = MenuDelegate(owner: self)
    private var configurationJSON = ""
    private var lastWidth: CGFloat = -1
    private var sentHeight: CGFloat = -1

    @objc public func setConfigurationJSON(_ json: String) {
        guard json != configurationJSON else {
            return
        }
        configurationJSON = json
        let configuration = Self.resolvingAssets(in: (try? JSONSerialization.jsonObject(with: Data(json.utf8))) ?? [:])
        if let tagList {
            tagList.applyConfiguration(configuration)
        } else {
            let tagList = CYLTagListView(configuration: configuration)
            tagList.menuDelegate = delegate
            tagList.frame = bounds
            tagList.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(tagList)
            self.tagList = tagList
        }
        sentHeight = -1
        setNeedsLayout()
    }

    /// 0 keeps each animation's own speed.
    @objc public func setAnimationSpeed(_ speed: Double) {
        tagList?.animationSpeed = speed > 0 ? CGFloat(speed) : nil
    }

    @objc public func setAnimationLoops(_ loops: Bool) {
        tagList?.animationLoops = loops
    }

    @objc public func playAll() {
        tagList?.playAllAnimations()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.width != lastWidth {
            lastWidth = bounds.width
            sendContentHeight()
        }
    }

    private func sendContentHeight() {
        guard let tagList, bounds.width > 0 else {
            return
        }
        let height = tagList.heightThatFitsWidth(bounds.width)
        guard abs(height - sentHeight) >= 0.5 else {
            return
        }
        sentHeight = height
        onContentHeight?(Double(height))
    }

    fileprivate func item(_ indexPath: IndexPath) -> [String: Any] {
        ["section": indexPath.section, "item": indexPath.item,
         "title": tagList?.menuDataSource?.menuTitleForItem(at: indexPath) ?? ""]
    }

    fileprivate func contentHeightChanged() {
        sendContentHeight()
    }

    // MARK: Assets

    /// "asset:<name>" becomes the path of that file in the app bundle (the core reads files).
    private static func resolvingAssets(in value: Any) -> [String: Any] {
        (resolved(value) as? [String: Any]) ?? [:]
    }

    private static func resolved(_ value: Any) -> Any {
        switch value {
        case let string as String where string.hasPrefix("asset:"):
            return Bundle.main.path(forResource: String(string.dropFirst("asset:".count)), ofType: nil) ?? string
        case let dictionary as [String: Any]:
            return dictionary.mapValues(resolved)
        case let array as [Any]:
            return array.map(resolved)
        default:
            return value
        }
    }
}

private final class MenuDelegate: NSObject, CYLMenuDelegate {
    weak var owner: CylTagListBridge?

    init(owner: CylTagListBridge) {
        self.owner = owner
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        guard let owner else { return }
        owner.onTap?(owner.item(indexPath))
    }

    func menu(_ menu: Any, didChangeSelectedItems indexPaths: [IndexPath]) {
        guard let owner else { return }
        owner.onSelection?(indexPaths.map(owner.item))
    }

    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        owner?.contentHeightChanged()
    }
}

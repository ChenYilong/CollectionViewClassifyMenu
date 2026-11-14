import Flutter
import UIKit
import CollectionViewClassifyMenu

/// Registers the platform view of `CylTagListView`.
public final class CylTagListPlugin: NSObject, FlutterPlugin {

    static let viewType = "com.cyl.cyl_tag_list/view"

    public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.register(CylTagListViewFactory(registrar: registrar), withId: viewType)
    }
}

final class CylTagListViewFactory: NSObject, FlutterPlatformViewFactory {

    private let registrar: FlutterPluginRegistrar

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        CylTagListPlatformView(frame: frame, viewId: viewId, arguments: args, registrar: registrar)
    }
}

/// A `CYLTagListView` created from the configuration map Dart sends, and the method channel that drives it.
final class CylTagListPlatformView: NSObject, FlutterPlatformView, CYLMenuDelegate {

    private let tagList: CYLTagListView
    private let channel: FlutterMethodChannel
    private let registrar: FlutterPluginRegistrar

    init(frame: CGRect, viewId: Int64, arguments: Any?, registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        let configuration = (arguments as? [String: Any])?["configuration"] as? [String: Any] ?? [:]
        tagList = CYLTagListView(configuration: Self.resolvingAssets(in: configuration, registrar: registrar))
        container.frame = frame
        channel = FlutterMethodChannel(name: "\(CylTagListPlugin.viewType)/\(viewId)", binaryMessenger: registrar.messenger())
        super.init()
        tagList.menuDelegate = self
        // The height for the width Flutter gives the view, sent whenever that width changes (Dart may size the view
        // to it, so the view's own height says nothing). Key-value observing of bounds does not see Flutter's frame
        // changes, so a container reports its layout.
        container.addSubview(tagList)
        tagList.frame = container.bounds
        tagList.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.onWidthChange = { [weak self] in
            self?.sendContentHeight()
        }
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    private let container = CylTagListContainerView()
    private var sentHeight: CGFloat = -1

    private func sendContentHeight() {
        let width = tagList.bounds.width
        guard width > 0 else {
            return
        }
        let height = tagList.heightThatFitsWidth(width)
        guard abs(height - sentHeight) >= 0.5 else {
            return
        }
        sentHeight = height
        channel.invokeMethod("onContentHeight", arguments: Double(height))
    }

    func view() -> UIView {
        container
    }

    private func handle(_ call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case "playAll":
            tagList.playAllAnimations()
        case "setSpeed":
            tagList.animationSpeed = (call.arguments as? NSNumber).map { CGFloat($0.doubleValue) }
        case "setLoops":
            tagList.animationLoops = (call.arguments as? NSNumber)?.boolValue ?? false
        case "state":
            let source = tagList.menuDataSource
            let tagCount = (0..<(source?.numberOfSectionsInMenu() ?? 0)).reduce(0) { $0 + (source?.menuNumberOfItems(inSection: $1) ?? 0) }
            var state: [String: Any] = ["loops": tagList.animationLoops, "tagCount": tagCount]
            if let speed = tagList.animationSpeed {
                state["speed"] = Double(speed)
            }
            result(state)
            return
        case "contentHeight":
            result(Double(tagList.heightThatFitsWidth(tagList.bounds.width)))
            return
        case "applyConfiguration":
            if let configuration = call.arguments as? [String: Any] {
                tagList.applyConfiguration(Self.resolvingAssets(in: configuration, registrar: registrar))
            }
        default:
            result(FlutterMethodNotImplemented)
            return
        }
        result(nil)
    }

    // MARK: CYLMenuDelegate

    func menu(_ menu: Any, didChangeContentHeight height: CGFloat) {
        sendContentHeight()
    }

    func menu(_ menu: Any, didChangeSelectedItems indexPaths: [IndexPath]) {
        let source = tagList.menuDataSource
        let items = indexPaths.map { indexPath -> [String: Any] in
            ["section": indexPath.section, "item": indexPath.item, "title": source?.menuTitleForItem(at: indexPath) ?? ""]
        }
        channel.invokeMethod("onSelectionChanged", arguments: items)
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        let title = tagList.menuDataSource?.menuTitleForItem(at: indexPath) ?? ""
        channel.invokeMethod("onTap", arguments: ["section": indexPath.section, "item": indexPath.item, "title": title])
    }

    // MARK: Flutter assets

    /// "asset:<key>" strings become the absolute path of that Flutter asset, so that animation and image files of the
    /// Flutter app are found by the core (it reads files, not asset keys).
    private static func resolvingAssets(in value: Any, registrar: FlutterPluginRegistrar) -> [String: Any] {
        (resolved(value, registrar: registrar) as? [String: Any]) ?? [:]
    }

    private static func resolved(_ value: Any, registrar: FlutterPluginRegistrar) -> Any {
        switch value {
        case let string as String where string.hasPrefix("asset:"):
            let key = registrar.lookupKey(forAsset: String(string.dropFirst("asset:".count)))
            return Bundle.main.path(forResource: key, ofType: nil) ?? string
        case let dictionary as [String: Any]:
            return dictionary.mapValues { resolved($0, registrar: registrar) }
        case let array as [Any]:
            return array.map { resolved($0, registrar: registrar) }
        default:
            return value
        }
    }
}

/** The platform view's root: holds the list and reports each change of its width after layout. */
final class CylTagListContainerView: UIView {
    var onWidthChange: (() -> Void)?
    private var lastWidth: CGFloat = -1

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width != lastWidth else {
            return
        }
        lastWidth = bounds.width
        onWidthChange?()
    }
}

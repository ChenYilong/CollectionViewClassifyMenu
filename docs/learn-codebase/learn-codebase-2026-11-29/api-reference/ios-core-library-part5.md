# ios-core: library (part 5 of 5)

## CollectionViewClassifyMenu/Class/TagList/CYLTagLongPressAction.swift

 CYLTagLongPressAction.swift
 CollectionViewClassifyMenu
 What a long press on an item does (`CYLTagListView.longPressAction`). The list owns the gesture; an action owns the
 behavior: reordering, a callout with the item's subtitle, or the host's own code. The events
 (`menu(_:didLongPressItemAt:)`, `tagLongPressHandler`) stay notifications: the built-in actions report them, and they
 never change the behavior. The same contract as HarmonyOS and Android (docs/tag-long-press-action.md).
     list.longPressAction = CYLTagLongPressActions.first([CYLTagLongPressActions.reorder, CYLTagLongPressActions.callout])
     list.longPressAction = CYLTagLongPressActions.handler { host, indexPath in host.showCallout("My text", at: indexPath) }
 The default is `first([reorder, report])`: reordering where the list can reorder, else the long press is reported,
 exactly as before this API existed.

- `public protocol CYLTagLongPressHost: AnyObject` (L22)
  The list as an action sees it: the primitives the built-in and the custom actions are made of.

- `func subtitleForItem(at indexPath: IndexPath) -> String?` (L27)
  The item's subtitle from the data source (`menuSubtitleForItem(at:)`), or `nil`.

- `func showCallout(_ text: String, at indexPath: IndexPath)` (L32)
  Shows a small callout with an arrow, pointing at the item, with `text`. Replaces a callout that is showing.

- `func dismissCallout()` (L37)
  Hides the callout.

- `func canReorderItem(at indexPath: IndexPath) -> Bool` (L42)
  Whether the list can reorder its items now.

- `func beginReordering(at indexPath: IndexPath) -> Bool` (L48)
  Starts reordering with the item picked up (a selected item's drag is reported). `false` when UIKit did not start
  the interactive movement.

- `func endReordering(destination: IndexPath?, moved: Bool)` (L54)
  Ends reordering: UIKit moves the item (the data source is told) when `moved`; a press that did not move is
  reported as a long press.

- `func cancelReordering()` (L59)
  Ends reordering without moving anything.

- `func reportLongPress(at indexPath: IndexPath)` (L64)
  Reports a long press: `menu(_:didLongPressItemAt:)`, then `tagLongPressHandler`.

- `public protocol CYLTagLongPressAction: AnyObject` (L70)
  What a long press on an item does.

- `func canBegin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool` (L75)
  Whether this action takes the press on this item (reorder: the list can reorder; callout: the item has a subtitle).

- `func begin(host: CYLTagLongPressHost, at indexPath: IndexPath) -> Bool` (L80)
  The press was recognized. Returns `true` to follow the finger; `end` or `cancel` then arrive.

- `func end(host: CYLTagLongPressHost, destination: IndexPath?, moved: Bool)` (L85)
  The finger lifted over `destination` (`nil`: outside the list); `moved` tells whether it left the item.

- `func cancel(host: CYLTagLongPressHost)` (L90)
  The gesture was cancelled.

- `public enum CYLTagLongPressActions` (L212)
  The built-in long-press actions, and the ways to combine them or write your own.

- `public static let reorder: CYLTagLongPressAction = CYLTagReorderAction()` (L217)
  Picks the item up to reorder it, where the list can reorder (UIKit moves the item, the data source is told).

- `public static let report: CYLTagLongPressAction = CYLTagReportAction()` (L222)
  Only reports the long press (`menu(_:didLongPressItemAt:)`, `tagLongPressHandler`).

- `public static let callout: CYLTagLongPressAction = CYLTagCalloutAction()` (L227)
  Shows the item's subtitle in a callout with an arrow, where the item has one, and reports the long press.

- `public static let none: CYLTagLongPressAction = CYLTagNoneAction()` (L232)
  Does nothing (not even a report).

- `public static func handler(_ handler: @escaping (CYLTagLongPressHost, IndexPath) -> Void) -> CYLTagLongPressAction` (L237)
  Runs `handler` instead of a built-in behavior; it can use the host's primitives, such as `showCallout(_:at:)`.

- `public static func first(_ actions: [CYLTagLongPressAction]) -> CYLTagLongPressAction` (L244)
  The first of `actions` that can begin takes the press, as "reorder where editable, a callout elsewhere".

- `public static func makeDefault() -> CYLTagLongPressAction` (L251)
  The default of a list: `first([reorder, report])`, the behavior before this API existed.

- `final class CYLTagCalloutView: UIView` (L259)
  The callout of a long press: a small bubble with an arrow pointing at the tag.

- `static func placesBelow(target: CGRect, height: CGFloat, safeTop: CGFloat, bottomLimit: CGFloat, header: CGRect?) -> Bool` (L313)
  Whether the callout goes below the tag (arrow up). Above first (the contract); below when it does not fit above
  or when it would cover `header` (the section header above a first-row tag) and it fits below; above when neither
  side is free of the header and below does not fit. Pure: all frames are in the container's coordinates.

- `func present(pointingAt target: CGRect, in container: UIView, avoiding header: CGRect? = nil)` (L333)
  Places the callout in `container` (the window), above `target` (the tag's frame in the container's coordinates),
  below it when there is no room above or when the bubble would cover `header` (see `placesBelow`), clamped to the
  container, its arrow at the tag's center.

- `final class CYLTagCalloutTapDelegate: NSObject, UIGestureRecognizerDelegate` (L387)
  Lets the window-wide tap that dismisses a callout run next to every other gesture, without taking a touch from them.

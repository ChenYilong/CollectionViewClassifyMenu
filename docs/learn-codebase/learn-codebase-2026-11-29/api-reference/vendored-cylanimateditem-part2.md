# vendored: cylanimateditem (part 2 of 2)

## harmony/cylanimateditem/src/main/ets/CYLAnimatedItemStackModel.ts

The state of a `CYLAnimatedItemStackView` (HarmonyOS counterpart of iOS `CYLAnimatedItemStackView.swift`): its items
     top to bottom, the action of each item, the handlers run by action name and the background action. Plain TypeScript
     with no ArkUI import, so the rules are unit tested with Node (cylanimateditem/test); the component draws it.
     不导入 ArkUI 的纯 TypeScript，因此规则可用 Node 做单元测试（cylanimateditem/test）；由组件负责绘制。

- `export type CYLAnimatedItemStackActionHandler = (stack: CYLAnimatedItemStackModel, action: string) => void;` (L17)
  Runs when an action is performed: a tap on an item, a tap on the background, or `performAction`.

- `export const CYLAnimatedItemStackDefaultSpacing: number = 16;` (L20)

- `export const CYLAnimatedItemDividerLength: number = 20;` (L23)

- `export const CYLAnimatedItemDividerThickness: number = 1;` (L26)

- `export class CYLAnimatedItemDividerSpec` (L35)
  The divider of the gap after one item (the item owns it: it moves and goes with the item). `shown` false is the "no divider
       here" override that wins over `showsDividers`; the spacings are undefined when not set (the stack defaults, then the item
       spacing apply: see `CYLAnimatedItemStackModel.gapAfter`).
       未设置的间距为 undefined（依次使用堆叠默认值与条目间距：见 `CYLAnimatedItemStackModel.gapAfter`）。

- `export class CYLAnimatedItemStackItem` (L48)
  One element of the stack, drawn as a vertical `CYLAnimatedItemView` (icon above the title). Change its fields, then
       call `CYLAnimatedItemStackModel.update` so the view redraws.

- `id: string;` (L50)

- `title: string = '';` (L52)

- `image: Object | string = '';` (L54)

- `animationUrl: string = '';` (L56)

- `iconSize: number = 48;` (L58)

- `titleLines: number = 0;` (L60)

- `accessibilityText: string = '';` (L62)

- `spacingBefore: number = -1;` (L68)
  The space before the item (above it, or on its leading side in a horizontal stack), in vp; ignored for the first
       item; negative (the default, -1) uses the stack's `spacing`.

- `iconColor: string = '';` (L70)

- `selectedIconColor: string = '';` (L72)

- `disabledIconColor: string = '';` (L74)

- `titleColor: string = '';` (L76)

- `selectedTitleColor: string = '';` (L78)

- `animationRenderingMode: string = 'automatic';` (L80)

- `enabled: boolean = true;` (L86)
  Whether the item is enabled (true by default). A disabled item is drawn dimmed and, by default, is not interactive
       (`CYLAnimatedItemStackModel.isItemInteractive`): its action does not run and a tap on it reaches the background.

- `animationTint: string = '';` (L88)

- `animationDarkTint: string = '';` (L90)

- `isHidden: boolean = false;` (L92)

- `alpha: number = 1;` (L94)

- `export class CYLAnimatedItemStackElement` (L109)
  One drawn element of the stack: an item, or the divider right after `item` (`isDivider`). Internal to the component.

- `readonly spacingBefore: number;` (L113)

- `get key(): string` (L122)

- `export class CYLAnimatedItemStackModel` (L134)
  The items, actions and handlers of a stack. The first item is the reserved one (the main icon and title); more items
       follow it: a hint, a button, a separator, an icon. A tap on an item with an action performs it; a tap anywhere else
       (an item without an action takes no taps) performs `backgroundAction`.
       （没有动作的条目不接收点击）执行 `backgroundAction`。

- `revision: number = 0;` (L160)

- `constructor(items: CYLAnimatedItemStackItem[] = [], actions?: Map<string, CYLAnimatedItemStackActionHandler>)` (L167)
  A stack of `items` (each with no action, the default spacing before) and the handlers of `actions`. An action
       without a handler does nothing.

- `get items(): CYLAnimatedItemStackItem[]` (L177)

- `get firstItem(): CYLAnimatedItemStackItem | undefined` (L182)

- `append(item: CYLAnimatedItemStackItem, action?: string, spacingBefore?: number): void` (L193)
  Appends `item` after the last one, `spacingBefore` vp from it (ignored for the first item, negative counts as 0;
       undefined keeps the item's own `spacingBefore`, by default the stack's `spacing`);
       a tap on it performs `action` when that is not undefined or ''. An item already in the stack is left where it is.
       已在堆叠中的条目保持原位。

- `appendItem(title: string, image: Object | string = '', animationUrl: string = '', action?: string,` (L209)
  Makes, appends and returns an item (icon above the title, the title wrapped to the width).

- `remove(item: CYLAnimatedItemStackItem): void` (L217)

- `insert(item: CYLAnimatedItemStackItem, index: number, action?: string, spacingBefore?: number): void` (L232)
  Inserts `item` at `index` (clamped to 0...count; an item already in the stack is moved there instead).

- `move(item: CYLAnimatedItemStackItem, index: number): void` (L246)

- `setItems(items: CYLAnimatedItemStackItem[]): void` (L260)
  Replaces the order with `items` (the items already in the stack, in the new order; the ones left out are removed, new ones appended).

- `get visibleItems(): CYLAnimatedItemStackItem[]` (L277)

- `setAction(action: string | undefined, item: CYLAnimatedItemStackItem): void` (L282)

- `actionFor(item: CYLAnimatedItemStackItem): string | undefined` (L291)

- `itemFor(action: string): CYLAnimatedItemStackItem | undefined` (L296)

- `get backgroundAction(): string | undefined` (L315)
  The action of a tap outside every item with an action; undefined (default) turns that off ('' too). A screen
       reader reaches it through the first item when that item has no action of its own.

- `setHandler(handler: CYLAnimatedItemStackActionHandler | undefined, action: string): void` (L325)

- `performAction(action: string): boolean` (L334)

- `tapItem(item: CYLAnimatedItemStackItem): boolean` (L348)
  A tap on `item` (the view calls it): its action, or the background action for the first item without one (it
       stands for the background, see `actsOnBackground`). False when nothing ran.

- `tapBackground(): boolean` (L360)

- `isItemInteractive(item: CYLAnimatedItemStackItem): boolean` (L377)
  Whether an item is interactive: its tap performs its action, a tap on it is not a background tap, and a screen
       reader reads it as a button. By default: it has an action and it is `enabled`. Override in a subclass for items
       with their own switch (CYLTableViewPlaceHolder's tap interaction), then call `updateInteractionOfItemViews()` after
       that switch changes. The same check as iOS `isItemViewInteractive(_:)` and Android `isItemInteractive`.
       的点击交互）在子类中重写，并在开关变化后调用 `updateInteractionOfItemViews()`。与 iOS `isItemViewInteractive(_:)`、Android `isItemInteractive` 相同。

- `updateInteractionOfItemViews(): void` (L385)
  Applies `isItemInteractive` again to every item (the view redraws), after a change the stack cannot see.

- `takesTaps(item: CYLAnimatedItemStackItem): boolean` (L394)
  Whether the item takes taps: an interactive item, and the first item while it stands for the background. Any other
       item lets a tap through to the background (`HitTestMode.None`).

- `actsOnBackground(item: CYLAnimatedItemStackItem): boolean` (L402)
  The first item, while it is not interactive and there is a background action: it reads as a button for it.

- `accessibilityTextOf(item: CYLAnimatedItemStackItem): string` (L407)

- `readsAsButton(item: CYLAnimatedItemStackItem): boolean` (L412)

- `isAccessibilityHidden(item: CYLAnimatedItemStackItem): boolean` (L420)
  Decoration (nothing to read: no title, no accessibility text, no action) is hidden from the screen reader.

- `get contentMargin(): number` (L427)

- `get axis(): string` (L441)
  The direction of the stack (iOS `axis`): 'vertical' (default, one item under the other) or 'horizontal' (one
       row); anything else counts as 'vertical'.

- `get isHorizontal(): boolean` (L451)

- `get spacing(): number` (L456)

- `spacingBeforeOf(item: CYLAnimatedItemStackItem): number` (L466)

- `get iconColor(): string` (L482)
  The default icon color of the items (iOS `itemAppearance` of the stack): an item's own `iconColor` wins; '' for none.

- `get disabledIconColor(): string` (L492)

- `get titleColor(): string` (L502)

- `get selectedTitleColor(): string` (L512)

- `get animationRenderingMode(): string` (L522)

- `get selectedIconColor(): string` (L532)

- `get dispatchesItemTaps(): boolean` (L542)

- `get hugsContent(): boolean` (L552)

- `get animationTint(): string` (L562)

- `get animationDarkTint(): string` (L572)

- `get dividerColor(): string` (L586)
  The color of the dividers the stack draws (`showsDividers`, `setDivider`, `appendDivider`); '' (default) derives it: the stack's explicit
       normal icon color (`iconColor`) at alpha 0.6, else the built-in divider color (secondary label, >= 3:1 on light and dark bars).

- `animationTintOf(item: CYLAnimatedItemStackItem): string` (L596)

- `animationDarkTintOf(item: CYLAnimatedItemStackItem): string` (L601)

- `get dividerLength(): number` (L606)

- `get showsDividers(): boolean` (L616)

- `setDivider(item: CYLAnimatedItemStackItem, spacingBefore?: number, spacingAfter?: number): void` (L632)
  Puts a divider in the gap after `item` (the item owns it: it moves and goes with the item), `spacingBefore` vp after the item
       and `spacingAfter` vp before the next visible one; undefined falls back (see `gapAfter`). Replaces an earlier divider or "no
       divider" of that gap. Ignored for an item not in the stack.
       undefined 时使用后备值（见 `gapAfter`）。替换该间隙之前的分隔线或「无分隔线」。不在堆叠中的条目被忽略。

- `appendDivider(spacingBefore?: number, spacingAfter?: number): void` (L647)
  Attaches a divider after the CURRENT LAST item (append flow: `append(a); appendDivider(8, 8); append(b)`); nothing on an empty stack.

- `removeDivider(item: CYLAnimatedItemStackItem): void` (L654)

- `hasDivider(item: CYLAnimatedItemStackItem): boolean` (L665)

- `setDividerAfter(item: CYLAnimatedItemStackItem, shown: boolean | undefined): void` (L671)

- `dividerAfter(item: CYLAnimatedItemStackItem): boolean` (L682)

- `showsDividerAfter(item: CYLAnimatedItemStackItem): boolean` (L698)

- `showsDividerBefore(item: CYLAnimatedItemStackItem): boolean` (L703)

- `dividerGapBefore(item: CYLAnimatedItemStackItem): number` (L710)

- `dividerGapAfter(item: CYLAnimatedItemStackItem): number` (L720)
  The space from the divider to the next visible item: the divider's own, else the stack's `dividerSpacingAfter`, else that item's
       `spacingBefore`, else `spacing`. The next item's own spacing is only this fallback, never added on top.
       下一个条目自己的间距只作为这个后备值，绝不叠加。

- `gapAfter(item: CYLAnimatedItemStackItem): number | undefined` (L732)
  The whole gap between `item` and the next visible item, undefined when there is none: with a divider before + thickness (1) +
       after (spacing 12, divider(8, 8): 8 + 1 + 8 = 17); without one the next item's `spacingBefore` or `spacing`.
       8 + 1 + 8 = 17）；没有时为下一个条目的 `spacingBefore` 或 `spacing`。

- `get dividerSpacingBefore(): number | undefined` (L744)

- `get dividerSpacingAfter(): number | undefined` (L754)

- `get elements(): CYLAnimatedItemStackElement[]` (L768)
  What the component draws, top to bottom: the visible items with the dividers between them. The items list (`items`) never
       holds dividers; they follow the items by themselves when items are appended, removed, moved or hidden.

- `iconColorOf(item: CYLAnimatedItemStackItem, selected: boolean = false, enabled: boolean = true): string` (L786)
  The EXPLICIT icon color an item view draws a static image with for a state (the item's, else the stack's; '' = none set, the image keeps
       its colors). Each state's property on its own: a selected item with only `iconColor` has none (the view draws the built-in selected color
       for symbols and the animation tint).
       显式颜色（符号图标与动画着色使用内置选中色）。

- `maxItemWidth(width: number): number` (L800)

- `update(): void` (L807)

- `addListener(listener: () => void): void` (L813)

- `removeListener(listener: () => void): void` (L818)

## harmony/cylanimateditem/src/main/ets/CYLAnimatedItemStackView.ets

- `class CYLStackItemRoleModifier implements AttributeModifier<ColumnAttribute>` (L12)
  The screen reader role of a stack item: a button when it acts, text otherwise. `accessibilityRole` exists from API 18
       and this module supports API 12, so it is set only where the system has it.

- `export struct CYLAnimatedItemStackView` (L43)
  A centered vertical stack whose every element is a `CYLAnimatedItemView` (an animated icon above a title): an empty
       state, a placeholder, an onboarding card. The HarmonyOS counterpart of iOS `CYLAnimatedItemStackView` (generic form
       of CYLTableViewPlaceHolder's `CYLPlaceholderStackView`). Its items, actions and handlers live in `model`
       (`CYLAnimatedItemStackModel`): a tap on an item with an action runs that action's handler; a tap anywhere else runs
       `backgroundAction` (an item without an action takes no taps, so the tap reaches the background). Titles wrap to the
       view's width minus `contentMargin` on each side. Screen reader: the items are read one by one, top to bottom; an item
       with an action is a button, decoration (no title, no accessibility text, no action) is hidden, and the first item
       reads as a button for the background action when it has no action of its own. `animationBuilder` is handed to every
       item, as `CYLAnimatedItemView.animationBuilder`.
       （CYLTableViewPlaceHolder `CYLPlaceholderStackView` 的通用形式）。条目、动作与处理保存在 `model`（`CYLAnimatedItemStackModel`）中：点击带动作的条目
       执行该动作的处理；点击其他位置执行 `backgroundAction`（没有动作的条目不接收点击，点击会到达背景）。标题按视图宽度减去两侧 `contentMargin` 换行。
       读屏：条目自上而下逐个朗读；带动作的条目是按钮，装饰条目（无标题、无无障碍文字、无动作）隐藏，第一个条目没有自己的动作时作为背景动作的按钮朗读。
       `animationBuilder` 传给每个条目，与 `CYLAnimatedItemView.animationBuilder` 相同。

- `model: CYLAnimatedItemStackModel = new CYLAnimatedItemStackModel();` (L45)

## harmony/cylanimateditem/src/main/ets/CYLAnimatedItemTypes.ts

The animation types of CYLAnimatedItemView and which of them an app registered (pure, unit tested with Node:
     test/CYLAnimatedItemTypes.test.mjs). Built in: Lottie, PAG, Rive, SVGA, GIF. An app can add its own type with its
     file extensions (`register('APNG', ['png', 'apng'])`), add extensions to a known type, and unregister a type
     (a type it added is then forgotten; a built-in type stays known and only stops playing). `CYLAnimatedItemEngines`
     is the public face of this registry.
     PAG、Rive、SVGA、GIF。App 可以添加自己的类型及其扩展名（`register('APNG', ['png', 'apng'])`）、为已知类型添加扩展名，也可以注销类型
     （自己添加的类型随之被遗忘；内置类型仍为已知类型，只是不再播放）。`CYLAnimatedItemEngines` 是该注册表的公开接口。

- `export class CYLAnimatedItemType` (L17)
  One animation type: its name, the package an app adds, its file extensions, and the native ABIs its library ships
       (empty: pure ArkTS, any device).

- `export const CYL_ARM64_ABI: string = 'arm64-v8a';` (L36)
  The ABI that @tencent/libpag 4.4.31 (libpag.so) and @ohos/rive 1.0.4 (libohos_rive.so) ship: arm64 only, so the
       x86_64 emulator cannot load them (instructions.md, "HarmonyOS x86_64 emulator and arm64-only animation engines").

- `export class CYLAnimatedItemTypeRegistry` (L46)

- `static setDeviceAbis(abis: string[] | undefined): void` (L58)
  Sets the device's ABIs (`deviceInfo.abiList` split on commas; the component does it on first use); undefined

- `static setRequiredNativeAbis(name: string, abis: string[]): void` (L76)
  Sets the native ABIs the engine of `name` needs (one of them must be on the device); [] = any device. Overrides
       the built-in value (PAG and Rive: arm64-v8a), e.g. when a later library version adds x86_64.

- `static requiredNativeAbis(name: string): string[]` (L81)

- `static supportsDevice(name: string): boolean` (L94)
  Whether this device can load the native library of the engine of `name` (true when it needs none, or the device

- `static unsupportedReason(url: string): string` (L105)
  Why `url` cannot play on this device although its engine is registered: its native library is not built for the
       device's ABIs; '' when it can play, or when the reason is something else (unknown type, engine not registered).

- `static knownTypes(): CYLAnimatedItemType[]` (L115)

- `static typeNamed(name: string): CYLAnimatedItemType | undefined` (L120)

- `static extensionsOf(name: string): string[]` (L125)

- `static typeOf(url: string): string` (L136)
  The type of a file from its extension, or '' when unknown. A trailing ".bin" is skipped ("icons.riv.bin" is Rive).
       A type an app added wins over a built-in type for the same extension.

- `static register(name: string, extensions?: string[], packageName?: string, nativeAbis?: string[]): void` (L157)
  Registers the engine of `name`. With `extensions`, an unknown name becomes a new type with them, and a known
       type gets them in addition (lower case, without the dot).

- `static unregister(name: string): void` (L192)
  Unregisters the engine of `name`: its files show the static image again. A type an app added is forgotten
       with its extensions; a built-in type stays known (and loses the extensions added to it).

- `static missingTypes(): string[]` (L208)

- `static canPlay(url: string): boolean` (L218)
  Whether a registered engine plays `url` on this device (its native library, if any, is built for the device's ABIs).

- `static reset(): void` (L224)

## harmony/cylanimateditem/src/main/ets/CYLAnimatedItemView.ets

- `const CYL_UNLIMITED_LINES: number = 1000;` (L32)

- `export enum CYLAnimatedItemAxis` (L37)

- `export enum CYLAnimatedItemAccessoryPlacement` (L46)
  Where the accessory sits: before the content, after it (default) or on the icon's top-trailing corner.

- `export enum CYLAnimatedItemStyle` (L58)
  The look of `CYLAnimatedItemView`: the plain animated icon + title (default), or a countdown button, e.g. for "Get the
       SMS code" (iOS `CYLAnimatedItemStyle`).

- `class CYLAnimatedItemPreferencesStorage implements CYLAnimatedItemCountdownStorage` (L67)
  Keeps a running countdown in the app's preferences, so it survives the app being ended in the background.

- `export class CYLAnimatedItemAnimationContext` (L113)
  What the animation builder gets: the file, its size, the selection, and two callbacks the engine calls once the file
       is ready (`onLoaded`) or cannot play (`onFailed`, a corrupt file, a failed download). Until `onLoaded` the item keeps
       its static image (or the placeholder) under the animation; after `onFailed` it shows them again.
       `onFailed`。调用 `onLoaded` 之前，条目在动画下方保留静态图片（或占位图）；调用 `onFailed` 之后重新显示它们。

- `speed: number = 1;` (L124)
  The playback the engine applies (the item's `animationSpeed`, `animationLoops`, and `restartToken`, which grows
       on every restart: the engine plays from progress 0 when it changes). The item hands a new context to the builder
       whenever one of them changes, so the engine view gets them as props and needs no state of the host.
       其中任一项变化时条目都会把新的 context 交给 builder，因此引擎视图通过 prop 获得它们，不需要宿主的状态。

- `onFailed: (reason?: string) => void = (_reason?: string) =>` (L130)

- `onEnded: () => void = () =>` (L138)
  Called by the engine when a play-once pass (`loops` off) reaches its end; the item then shows its still image
       (`showsImageWhenAnimationEnds`) and calls `onAnimationEnd`. An engine that cannot tell never calls it.
       `onAnimationEnd`。无法判断结束的引擎从不调用它。

- `setRestartHandler: (handler: () => void) => void = (_handler: () => void) =>` (L147)
  The engine view registers how it replays (from progress 0); the item calls it each time `restartToken` grows.
       ArkUI copies a builder's values once when an arrow function wraps the builder (a host's `this`), so a prop
       alone may never see the new token (B23).
       ArkUI 只复制一次 builder 的值，因此仅靠 prop 可能永远看不到新标记（B23）。

- `export class CYLAnimatedItemController` (L158)
  Imperative playback for a `CYLAnimatedItemView` (iOS / Android `restartAnimation`): pass one as `controller`, then
       call `restartAnimation()`, for example from `onItemTap`. The props `animationSpeed`, `animationLoops` and
       `animationRestartToken` do the same declaratively.
       例如在 `onItemTap` 中。prop `animationSpeed`、`animationLoops` 与 `animationRestartToken` 以声明式实现相同功能。

- `cylRestart: () => void = () =>` (L160)

- `restartAnimation(): void` (L164)

- `cylStartCountdown: (seconds: number) => void = (_seconds: number) =>` (L169)

- `startCountdown(seconds: number = 0): void` (L181)
  Starts (or restarts) the countdown for `seconds` (0 or less: `countdownDuration`, e.g. the server's "retry after").
       （0 或更小：使用 `countdownDuration`，例如服务器返回的「多少秒后重试」）。条目的 `itemStyle` 必须为 `CYLAnimatedItemStyle.Countdown`。

- `resetCountdown(): void` (L186)

- `refreshCountdown(): void` (L191)

- `export function cylAnimatedItemTypeOf(url: string): string` (L201)
  The animation type of a file from its extension ("Lottie", "PAG", "Rive", "SVGA", "GIF", or a type an app
       registered with its extensions), or '' when unknown.

- `export class CYLAnimatedItemEngines` (L215)
  The animation engines an app registered, by type. The component depends on no animation library: an app (or a
       library such as cyltabbar) registers the types it can play and passes `animationBuilder`; a file of a type nobody
       registered shows the static image, or the placeholder, and debug builds log once which package to add. The
       counterpart of iOS `CYLTabBarItemAnimatorRegistry` / `CYLAnimationWarnMissingEngine()` and Android
       `CYLAnimationEngines`.
       没有注册的类型显示静态图片或占位图，debug 构建会输出一次需要加入的包。对应 iOS 的 `CYLTabBarItemAnimatorRegistry` /
       `CYLAnimationWarnMissingEngine()` 与 Android 的 `CYLAnimationEngines`。

- `static resourceMissingListener: CYLAnimatedItemResourceMissingCallback | undefined = undefined;` (L226)
  Called when an animation file cannot be shown, with the file name or path as configured and a short reason ("not
       found", "unreadable", "decode failed", "engine library missing"): once per resource per item. The same call as
       `CYLAnimatedItemView.onResourceMissing`, for a host that holds no item (CYLPlaceholder's status bar). Nothing else
       changes. iOS and Android: `CYLAnimationEngines.resourceMissingListener`.
       是同一次调用，供不持有条目的宿主使用（CYLPlaceholder 状态栏）。其他行为不变。

- `static loadX86_64DebugEngines(context: common.Context | undefined): string[]` (L248)
  Turns on the engines of the x86_64 debug engine kit (`x86_64-debug-engines`, e.g. Rive built
       for x86_64) when `tools/cyl_hap_x86_64.py install` added it to this HAP, which it marks with the rawfile
       `cyl_x86_64_debug_engines.json`; those engines then also accept `x86_64`, in debug and release builds. A HAP
       installed without the kit changes nothing (PAG and Rive keep their still images on x86_64). Kept once found; returns the engines.
       CYLAnimatedItemView and CYLTabBarController call it. Owner's Plan 1: the debug-build guard was removed with
       the owner's approval (2026-11-23); the marker and the device's x86_64 ABI remain the guards.
       加入本 HAP（以 rawfile `cyl_x86_64_debug_engines.json` 标记）时，开启该包中的引擎，这些引擎随即也接受 `x86_64`。debug 与 release
       构建均适用；未安装该包的 HAP 不做任何改变（x86_64 上 PAG 与 Rive 保持静态图片）。找到后保留；返回这些引擎。

- `static x86_64DebugEngines(): string[]` (L278)

- `static setRequiredNativeAbis(type: string, abis: string[]): void` (L293)
  Sets the native ABIs the engine of `type` needs (one of them must be on the device); [] = any device. Built in:
       PAG and Rive need arm64-v8a (@tencent/libpag 4.4.31, @ohos/rive 1.0.4). Call it when a library version adds an ABI.

- `static requiredNativeAbis(type: string): string[]` (L298)

- `static isSupportedOnDevice(type: string): boolean` (L306)
  Whether this device can load the engine of `type` (false for PAG and Rive on the x86_64 emulator).

- `static deviceAbis(): string[]` (L312)

- `static setDeviceAbis(abis: string[] | undefined): void` (L321)
  Overrides the device's ABIs (tests, e.g. ['x86_64'] on an arm64 device); undefined reads `deviceInfo.abiList` again.

- `static unsupportedReason(url: string): string` (L330)
  Why `url` does not play on this device although its engine is registered (its native library is not built for the
       device's ABIs), or '' (it plays, or the engine is simply not registered).

- `static register(type: string, extensions?: string[], packageName?: string, nativeAbis?: string[]): void` (L343)
  Registers the engine of `type` ("Lottie", "PAG", "Rive", "SVGA", "GIF"). With `extensions`, an app can add its own
       type (`register('APNG', ['apng'])`, then `animationBuilder` draws it) or more extensions for a known type;
       `packageName` names what to add in the debug log; `nativeAbis` the native ABIs its library ships (see
       `setRequiredNativeAbis`).
       再由 `animationBuilder` 绘制），或为已知类型添加扩展名；`packageName` 为 debug 日志中提示加入的包；`nativeAbis` 为其库提供的原生 ABI（见 `setRequiredNativeAbis`）。

- `static unregister(type: string): void` (L351)
  Unregisters the engine of `type`: its files show the static image again; a type an app added is forgotten.

- `static isRegistered(type: string): boolean` (L356)

- `static registeredTypes(): string[]` (L361)

- `static missingTypes(): string[]` (L366)

- `static canPlay(url: string): boolean` (L371)

- `static warnMissingEngine(url: string): void` (L381)
  In debug builds, logs once per type that `url` cannot play because its engine is not registered, with the package
       to add. Nothing in release builds, for an unknown type or when the engine is registered.

- `export function cylIconColorFilter(color: ResourceColor): number[]` (L413)
  The color filter that paints a bitmap in `color` keeping each pixel's alpha (each channel = the color's component x
       the pixel's alpha; no offsets, so it does not depend on the channel range); the identity when `color` is '' or not

- `export class CYLAnimatedItemStatics` (L443)
  Static helpers of the item as an exported class (an ArkUI struct has no static members; iOS `CYLAnimatedItemView.resolvedContentHorizontalInset` /
       `isAnimationEngineAvailable`): forwarders to what exists, so a host keeps no copy of the rules.
       转发到已有的实现，宿主不必保留规则的副本。

- `static resolvedContentHorizontalInset(explicit: number, style: CYLAnimatedItemBackgroundStyle): number` (L450)
  The content inset (vp) an item with `style` really applies for the explicit `itemContentHorizontalInset` (-1 = not set): the set value, else
       `CYLAnimatedItemLiquidGlassContentInset` for the drawn glass and 0 for flat (`CYLAnimatedItemBackgroundModifier.resolvedContentInset`).
       `CYLAnimatedItemLiquidGlassContentInset`，扁平时为 0（`CYLAnimatedItemBackgroundModifier.resolvedContentInset`）。

- `static isAnimationEngineAvailable(): boolean` (L459)
  Whether any animation engine is registered (`CYLAnimatedItemEngines.registeredTypes()` is not empty): false means every animation file shows
       its still image or the placeholder.

- `export function cylSetPausesWhileUserScrolls(enabled: boolean): void` (L473)
  true: every animated item pauses while the user scrolls (the app reports the scrolling with `scrollStarted()` /
       `scrollStopped()` of a LifecycleController, or `cyl_reportScrollStarted()` of cyltabbar) and resumes afterwards. Read when
       滚动结束后恢复。条目出现时读取。放在模块级，因为 ArkTS 不在 struct 上放静态成员。

- `export struct CYLAnimatedItemView` (L487)

- `onAnimationEnd?: () => void;` (L520)

- `onResourceMissing?: CYLAnimatedItemResourceMissingCallback;` (L530)
  Called when the animation file cannot be shown, with the file name or path as configured (`animationUrl` without its
       `#` options) and a short reason: "not found", "unreadable", "decode failed" or "engine library missing". Once per
       resource per item; the item shows its image or the placeholder as before.
       `CYLAnimatedItemEngines.resourceMissingListener` hears the same call. iOS and Android: `onResourceMissing`.
       "decode failed"、"engine library missing"。每个条目每个资源一次；条目仍显示图片或占位图。
       `CYLAnimatedItemEngines.resourceMissingListener` 收到同一次调用。

- `controller?: CYLAnimatedItemController;` (L536)

- `countdownClock?: () => number;` (L797)

- `onAnimationPlayer?: (player: CYLAnimatedItemPlayer | undefined) => void;` (L852)
  The default engine view's player once it plays the file, undefined when it goes away.

- `onItemTap?: () => void;` (L855)

- `drawsLiquidGlass(): boolean` (L887)
  Whether the Liquid Glass is really drawn: the resolved style is Liquid Glass AND `CYLLiquidGlass.isActive()` (iOS `drawsLiquidGlass`; a method, because an ArkUI struct cannot have accessors: a getter compiles to undefined). Glass that is
       requested but not drawn counts as flat. Not based on a layer or the view's size, which change before layout.
       不依赖图层或视图尺寸，它们在布局之前就会变化。

- `drawsFlatBackground(): boolean` (L892)

- `adaptedOnGlass(color: ResourceColor, kind: string): ResourceColor` (L903)
  The dark-glass rule of this item as a public function (iOS `adaptedOnGlass(_:kind:)`): `color` itself unless the glass is drawn
       (`drawsLiquidGlass`) and the mode is dark; then lifted to 4.5:1 (`CYLAnimatedItemContrastKindText`) or 3:1 (`CYLAnimatedItemContrastKindIcon`) against the
       rendered glass, with the item's own background colour, tint alpha and resolved mode.
       4.5:1（`CYLAnimatedItemContrastKindText`）或 3:1（`CYLAnimatedItemContrastKindIcon`），使用条目自己的背景色、着色透明度与解析后的模式。

- `cylCountdownKeyDidChange(): void` (L991)

- `cylEnabled(): boolean` (L1031)

- `cylTitleText(): string` (L1036)

- `cylEngineAnimation(context: CYLAnimatedItemAnimationContext)` (L1086)

- `cylAnimationDidChange(): void` (L1094)
  A new file starts over: not loaded, not failed; a type nobody registered says so in debug builds.

- `cylReportResourceMissing(url: string, reason: string): void` (L1113)
  Tells `onResourceMissing` and `CYLAnimatedItemEngines.resourceMissingListener` that the file of `url` cannot be

- `cylPlaybackDidChange(): void` (L1122)
  The selection, speed, loops or a restart changed: the engine gets them in a new context, without reloading the

- `cylPostAnimationEvent(name: string): void` (L1141)
  Posts an animation event (AnimationEvents of the core library) to the observers of this item.

- `cylPauseAnimation(): void` (L1150)

- `cylResumeAnimation(): void` (L1160)

- `cylAnimationTint(): ResourceColor` (L1210)
  The color the animation is drawn in, '' for the file's own colors: `animationTintColor` when set; else `animationTint` /
       `animationDarkTint` over the source's `tint` / `darkTint` options (`cylAnimatedItemResolveTint`, with `iconColor`, the selection and
       `animationDarkTint` 覆盖来源的 `tint` / `darkTint` 选项解析（结合 `iconColor`、选中状态与颜色模式）。

- `cylExplicitIconColor(): ResourceColor` (L1317)
  The EXPLICIT icon color of the current state (own, subclass-explicit, then stack; '' when none set), adapted on drawn dark glass: what tints a

- `cylEffectiveIconColor(): ResourceColor` (L1326)

- `cylEffectiveTitleColor(): ResourceColor` (L1331)

- `cylTintDidChange(): void` (L1377)

- `cylEndImageDidChange(): void` (L1408)

- `cylAnimationShows(): boolean` (L1415)

- `cylMakesAnimation(): boolean` (L1422)

- `cylStaticImage(): ResourceStr` (L1429)

- `cylFallbackImage(): ResourceStr` (L1448)
  What the icon shows under the animation: the static image, else the placeholder when there is an animation file
       that does not show (yet), else nothing.

## harmony/cylanimateditem/src/main/ets/CYLLiquidGlass.ets

- `export class CYLLiquidGlass` (L10)
  The Liquid Glass of `CYLAnimatedItemView` on HarmonyOS NEXT (`itemBackgroundStyle = liquidGlass`): the availability rule and
       the blur values of the glass imitation (API 12 to 21 have no system glass material, so the glass is a blur with a tint). The
       tab bar (`cyltabbar`) depends on this module and draws its own capsule with the same values; this module knows nothing of it.
       An ArkUI struct has no static members, so the rule is this exported class (iOS and Android: `CYLAnimatedItemView.isLiquidGlassActive()`).
       因此玻璃是带着色的模糊）。TabBar（`cyltabbar`）依赖本模块并用相同的数值绘制自己的胶囊；本模块不了解 TabBar。ArkUI struct 没有静态成员，
       所以规则是这个导出的类（iOS 与 Android 为 `CYLAnimatedItemView.isLiquidGlassActive()`）。

- `static readonly BLUR_RADIUS: number = 28;` (L14)

- `static readonly GLASS_TINT_ALPHA: number = 0.75;` (L18)

- `static readonly BLUR_SATURATION: number = 1.6;` (L22)

- `static readonly LIGHT_BRIGHTNESS: number = 1.05;` (L26)

- `static readonly DARK_BRIGHTNESS: number = 0.9;` (L30)

- `static readonly RIM_WIDTH: number = 1;` (L35)

- `static trackSystemColorMode(): boolean` (L40)
  Registers ArkUI's system color mode in AppStorage under 'colorMode' (`Environment.envProp`); idempotent, safe to call often. Without it

- `static resolveDark(explicit: string | undefined, system: number | undefined): boolean` (L54)
  The one resolver of the color mode: `explicit` (AppStorage `cyl_colorMode`, set by cyltabbar's `cyl_updateColorMode`) when it is 'dark' or
       'light', else the system mode (`system`, AppStorage 'colorMode' as a ColorMode).

- `static isDark(): boolean` (L70)
  Whether the color mode is dark: the explicit `cyl_colorMode` ('dark' / 'light', set by cyltabbar's `cyl_updateColorMode`) wins; when it
       is unset the system dark / light mode decides. The rule of the rim and the sheen: read when the background is applied.
       细边与高光的规则：应用背景时读取。

- `static rimEdgeColors(dark: boolean): EdgeColors` (L82)
  The rim of every glass (a tag, a section card behind tags, an item, the tab bar capsule): the hairline of Android's sampled glass, the same on all four edges
       (white 70% on light glass, white 22% on dark glass: the bright edge of the Android screenshots). One definition: the tag list applies it to its cards and tags through
       `CYLAnimatedItemBackgroundModifier`, and no host keeps its own.
       只有这一份定义：标签列表通过 `CYLAnimatedItemBackgroundModifier` 把它用于卡片与标签，宿主不保留自己的。

- `static sheenColors(dark: boolean): Array<[ResourceColor, number]>` (L93)
  The sheen of every glass over its tint, top to bottom: a specular band at the top fading down and a faint glow at the bottom (the light of
       the tab bar capsule).

- `static activeOverride: boolean | undefined = undefined;` (L102)

- `static isActive(): boolean` (L109)
  Whether Liquid Glass is in use: always true on HarmonyOS, whose tab bar draws the blur imitation on every supported API
       (the system material replaces it from API 24); when false a host keeps its flat background.

## harmony/cylanimateditem/src/main/ets/svga/CYLInflate.ts

- `const LENGTH_BASE: number[] = [3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115,` (L9)
  Inflate (RFC 1951) for SVGA 2.x files, which are zlib streams (RFC 1950) of a protobuf movie, in plain TypeScript so
       the decoder runs anywhere (UI thread, worker, Node unit tests) without a native zlib binding. Moved from
       CollectionViewClassifyMenu's example (harmony/entry/src/main/ets/animation/svga/CYLInflate.ets).
       worker、Node 单元测试），无需原生 zlib。从 CollectionViewClassifyMenu 示例迁移而来。

- `class CYLHuffman` (L19)
  A canonical Huffman code: symbol counts per length and the symbols sorted by code.

- `class CYLBitReader` (L41)

- `class CYLOutput` (L97)

- `function inflateStoredBlock(reader: CYLBitReader, output: CYLOutput): void` (L194)
  Copies one stored (uncompressed) deflate block to the output.

- `function inflateCompressedBlock(reader: CYLBitReader, output: CYLOutput, codes: CYLHuffman[]): void` (L205)
  Decodes the literal and length/distance symbols of one Huffman-compressed deflate block until its end symbol.

- `function inflateMatch(reader: CYLBitReader, output: CYLOutput, codes: CYLHuffman[], symbol: number): void` (L219)
  Copies one back-reference (length symbol, then distance) to the output.

- `export function cylInflateRaw(data: Uint8Array, offset: number = 0): Uint8Array` (L235)
  Inflates a raw deflate stream starting at `offset`.

- `export function cylInflateZlib(data: Uint8Array): Uint8Array` (L257)
  Inflates a zlib stream (RFC 1950): checks the two-byte header, skips it, and inflates the rest.

## harmony/cylanimateditem/src/main/ets/svga/CYLSVGADecoder.ts

- `export class CYLSVGALayout` (L13)
  FIX: issue #415. The SVGA 2.x file format (svga.proto of SVGAPlayer, `MovieEntity`), decoded in ArkTS: the same
       decoder as the WeChat mini program player (CrossPlatform/svga-miniprogram/miniprogram_dist/svga/cyl_svga_movie.js),
       with the pure TypeScript inflate (CYLInflate.ts), so it also runs under Node (test/CYLAnimatedItemSVGADecoder.test.mjs).
       SVGA 1.x files (ZIP archives) are rejected.
       （CrossPlatform/svga-miniprogram/miniprogram_dist/svga/cyl_svga_movie.js）相同的解码器，解压使用纯 TypeScript 的 inflate（CYLInflate.ts），
       因此也能在 Node 下运行。SVGA 1.x 文件
       （ZIP）会被拒绝。

- `export class CYLSVGATransform` (L20)

- `export class CYLSVGAColor` (L29)

- `export class CYLSVGAStyle` (L36)

- `export class CYLSVGARect` (L46)

- `export class CYLSVGAEllipse` (L54)

- `export class CYLSVGAShape` (L65)
  type 0 shape (an SVG path `d`), 1 rect, 2 ellipse, 3 keep (the shapes of the previous frame, resolved while decoding).

- `export class CYLSVGAFrame` (L74)

- `export class CYLSVGASprite` (L82)

- `export class CYLSVGAMovie` (L88)

- `function cylUTF8(bytes: Uint8Array): string` (L99)

- `class CYLProtoReader` (L123)

- `function cylMessage(bytes: Uint8Array, handle: CYLFieldHandler): void` (L184)
  Reads the fields of one message; `handle` reads a field and returns true, or returns false to skip it.

- `function cylTransform(bytes: Uint8Array): CYLSVGATransform` (L221)

- `export function cylDecodeSVGAMovie(bytes: Uint8Array): CYLSVGAMovie` (L391)

- `export function cylInflateSVGAMovie(data: Uint8Array): CYLSVGAMovie` (L444)
  Inflates and decodes the bytes of an .svga file; rejects SVGA 1.x (ZIP) and damaged files.

## harmony/cylanimateditem/src/main/ets/svga/CYLSVGAMovie.ets

FIX: issue #415. The SVGA 2.x decoder (CYLSVGADecoder.ts, pure TypeScript with its own inflate, unit tested with Node)
     under the names cyltabbar and the renderer import. `cylLoadSVGAMovie` keeps its asynchronous signature.
     `cylLoadSVGAMovie` 保持异步签名。

- `export async function cylLoadSVGAMovie(data: Uint8Array): Promise<CYLSVGAMovie>` (L15)

## harmony/cylanimateditem/src/main/ets/svga/CYLSVGARenderer.ets

- `class CYLPathCommand` (L13)
  FIX: issue #415. Draws one frame of an SVGA movie on an ArkUI CanvasRenderingContext2D, the same way as the WeChat
       mini program renderer (cyl_svga_renderer.js): per sprite its alpha, transform and clip path, then its bitmap (in
       its layout size) or its vector shapes. ".matte" sprites are masks and are not drawn; masking itself is not
       supported yet.
       （cyl_svga_renderer.js）相同：每个 sprite 先设置透明度、变换与裁剪路径，再绘制其位图（按布局尺寸）或矢量形状。".matte"
       sprite 是遮罩，不绘制；遮罩效果暂不支持。

- `export function cylParseSVGAPath(d: string): CYLPathCommand[]` (L43)
  Parses an SVG path into absolute M, L, C, Q and Z commands (H, V, S, T and relative forms converted; an arc
       becomes a line to its end point).

- `export function cylDrawSVGAFrame(context: CanvasRenderingContext2D, movie: CYLSVGAMovie, bitmaps: Map<string, image.PixelMap>,` (L229)
  Clears the canvas area and draws frame `frameIndex` (clamped), the view box fitted (contain) into `width` × `height`.

## harmony/cylanimateditem/test/CYLAnimatedItemBuiltIns.test.mjs

Unit tests of the built-in colors and the state color resolution (tint spec v2, sections 1-3, 7): precedence item explicit > stack
     explicit > built-in; the EFFECTIVE color vs the EXPLICIT one; the constants (iOS probe values) are pinned.

## harmony/cylanimateditem/test/CYLAnimatedItemColorCount.test.mjs

Unit tests of CYLAnimatedItemColorCount.ts (tint spec v2, section 5): one-color detection of Lottie JSON text and of decoded GIF
     pixels. The fixtures are the same files every platform tests: search_camera.json (the search bar's camera, one near-black color),
     multi_color.json (green_lottie_tab_discover.json of the examples, 3 colors), gradient.json (CYLPlaceholderSuccess.json, a gradient
     stroke), image_asset.json (gray_tabbar_home_animation.json, image assets).
     Node 22.18+: node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemColors.test.mjs

Unit tests of CYLAnimatedItemColors.ts: hex colors to components and to Rive's ARGB integer.
     Node 22.18+: node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemCountdown.test.mjs

Unit tests of CYLAnimatedItemCountdown, the countdown rules of the HarmonyOS CYLAnimatedItemView (the same cases as iOS
     CYLAnimatedItemCountdownTests, Android CYLAnimatedItemCountdownTest and the mini program's
     cyl_animated_item_countdown.test.js). Run with Node 22.18+ (type stripping):
     node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs
     CYLAnimatedItemCountdownTest 以及小程序的 cyl_animated_item_countdown.test.js 相同。用 Node 22.18+（类型擦除）运行：
     node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemGIFFallback.test.mjs

Unit tests of the GIF fallbacks in CYLAnimatedItemGIFTiming.ts (CYLTableViewPlaceHolder 3fe1896d, 76762c6a): the
     trailer check, the frames kept from a truncated file, and the cache file name. Node 22.18+:
     node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemMissing.test.mjs

Unit tests of CYLAnimatedItemMissing.ts (the reasons and the once-per-resource reporter of
     `onResourceMissing` / `CYLAnimatedItemEngines.resourceMissingListener`). Node 22.18+:
     node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemPlayer.test.mjs

Unit tests of CYLAnimatedItemPlayer.ts (timed player, default playback rules, engine binding) and
     CYLAnimatedItemGIFTiming.ts. Node 22.18+: node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

- `class FakeClock` (L12)

- `class TimedPlayer extends P.CYLAnimatedItemTimedPlayer` (L22)

- `class Recorder extends P.CYLAnimatedItemPlayer` (L65)

## harmony/cylanimateditem/test/CYLAnimatedItemResources.test.mjs

Unit tests of CYLAnimatedItemResources.ts (B30: system symbols). Node 22.18+:
     node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemSVGADecoder.test.mjs

Unit tests of the SVGA 2.x decoder (svga/CYLSVGADecoder.ts and svga/CYLInflate.ts), ported from
     CollectionViewClassifyMenu's SVGADecoder.test.ets and svga-decoder-test.js: params / images / sprites, frames as
     SVGAPlayer draws them, progress to frames, SVGA 1.x and damaged files rejected, the inflate against Node's zlib on the
     example's .svga files and on stored / fixed-Huffman blocks, and the engine picked by extension.
     Node 22.18+: node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

- `class ProtoWriter` (L23)

- `function zlibStored(payload)` (L46)

## harmony/cylanimateditem/test/CYLAnimatedItemSVGATiming.test.mjs

Unit tests of CYLAnimatedItemSVGATiming.ts: one pass's duration and the frame at a progress (1 is the last frame).
     Node 22.18+: node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemSource.test.mjs

Unit tests of CYLAnimatedItemSource.ts (values, options, rawfile names). Node 22.18+:
     node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemStackModel.test.mjs

Unit tests of CYLAnimatedItemStackModel, the rules of the HarmonyOS CYLAnimatedItemStackView (the same cases as
     iOS CYLTabBarControllerTests/CYLAnimatedItemStackViewTests.m). Run with Node 22.18+ (type stripping):
     node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs
     用 Node 22.18+（类型擦除）运行：node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemStackTint.test.mjs

Unit tests of the divider color, the stack inheritance (effective = item ?? stack) and the host-row needs of the stack
     (spec /tmp/xpr/stack-tint-spec.txt, A, B, C, E). Node: node --test test/*.test.mjs

## harmony/cylanimateditem/test/CYLAnimatedItemTypes.test.mjs

Unit tests of CYLAnimatedItemTypes.ts (CYLAnimatedItemEngines: app types, extra extensions, unregister). Node 22.18+:
     node --test CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test/*.test.mjs

## harmony/cylanimateditem/test/cyl-ts-import.mjs

Registers cyl-ts-resolve.mjs; a test imports this first, then the module under test with a dynamic import().

## harmony/cylanimateditem/test/cyl-ts-resolve.mjs

- `export async function resolve(specifier, context, nextResolve)` (L4)
  Node resolve hook for the tests: the module's .ts files import each other without an extension (as ArkTS needs), so
       an extensionless relative import is retried with ".ts". Used through cyl-ts-import.mjs.

## harmony/cylanimateditem/test/test_cyl_hap_x86_64.py

Unit tests of tools/cyl_hap_x86_64.py (strip and ABI listing). Run: python3 -m unittest discover -s
CrossPlatform/harmonyos-cyltabbar/cylanimateditem/test -p "test_*.py"

## harmony/cylanimateditem/tools/cyl_hap_x86_64.py

CYLAnimatedItem x86_64 emulator helper (CYLTabBarController HarmonyOS, cylanimateditem/tools).
The x86_64 HarmonyOS emulator rejects a HAP that carries arm64-v8a-only native libraries (@ohos/rive libohos_rive.so,
@tencent/libpag libpag.so, and the libc++_shared.so next to them): "install parse native so failed", error 9568347.
Prefer the build profile's "emulator" target (cylanimateditem/README.md, "x86_64 emulator"); this tool is for a HAP
that was built without it, and for installing any HAP on the right device.
python3 cyl_hap_x86_64.py strip  <in.hap> [<out.hap>]   copy the HAP without the native libraries the device cannot load
python3 cyl_hap_x86_64.py install <app.hap> [--target 127.0.0.1:5557] [--hdc <path>] [--strip auto|yes|no]
[--x86-engines auto|yes|no]
"install" asks the device for its ABIs (hdc shell param get const.product.cpu.abilist); with --strip auto (default) it
strips libs/<abi>/ folders the device does not list, then runs hdc install -r. CYL_HAP_STRIP_LIBS=1 / 0 forces strip on /
off. With --x86-engines auto (default) on an x86_64 device, it also adds the x86_64 debug engine kit
(../x86_64-debug-engines/rive: libohos_rive.so of @ohos/rive 1.0.4, libc++_shared.so; ../x86_64-debug-engines/pag: libpag.so
of @tencent/libpag 4.4.31, ../x86_64-debug-engines/pag-4.5.102), only for the engines the HAP uses and only in the exact
package version its ArkTS was built with (kit.json; another version is skipped with a message), and the marker rawfile
cyl_x86_64_debug_engines.json, so Rive and PAG play (CYLAnimatedItemEngines reads the marker in debug and release builds); CYL_X86_ENGINES=1 / 0
forces it. Standard library only. The Rive and PAG items of the stripped app show their still images
(CYLAnimatedItemEngines.isSupportedOnDevice); their playback still needs an arm64 device.

# vendored: miniprogram-cyl-animated-item (part 2 of 2)

## CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist/cyl-animated-item/index.js

- `const` (L18)
  cyl-animated-item: an icon + title view to reuse in other repositories (CollectionViewClassifyMenu's tags,
       CYLSearchViewController's bar items): an icon that plays an animation file through the abstract nodes
       `cyl-lottie-view`, `cyl-pag-view`, `cyl-rive-view`, `cyl-svga-view` (the app names its engine components, e.g.
       `generic:cyl-lottie-view="cyl-lottie"`; GIF is drawn by `<image>`), its static image, a title beside or below it,
       an optional accessory with its own tap (`accessorytap`), and gestures on the whole item (`itemtap`,
       `itemlongpress`, `dragstart` / `dragmove` / `dragend` when `drag-enabled`). It depends on no animation package.
       A file whose engine is not installed shows the static image, or the placeholder, and logs once in the developer
       tools which package to add. Accessibility: one element, role button, `accessibility-label` (else the title),
       selected and disabled states.
       通过抽象节点 `cyl-lottie-view`、`cyl-pag-view`、`cyl-rive-view`、`cyl-svga-view` 播放动画文件的图标（App 指定引擎组件，例如
       `generic:cyl-lottie-view="cyl-lottie"`；GIF 由 `<image>` 绘制）、其静态图片、位于旁边或下方的标题、带独立点击的可选附加图标
       （`accessorytap`），以及整个条目的手势（`itemtap`、`itemlongpress`，`drag-enabled` 时的 `dragstart` / `dragmove` / `dragend`）。
       不依赖任何动画包。没有安装引擎的文件显示静态图片或占位图，并在开发者工具中输出一次需要安装的包。无障碍：一个元素，角色为按钮，
       `accessibility-label`（否则为标题），带选中与禁用状态。

- `function cylTeardown(item)` (L38)
  What `detached` releases: the countdown timer, the app-show and theme listeners and the GIF timers. It runs as the keyed
       teardown block `cyl.animatedItem.teardown` of CYLDeallocBlockExecutor (see `lifetimes`).
       `cyl.animatedItem.teardown` 运行（见 `lifetimes`）。

- `const CYL_ENGINE_ID = '#cyl-animated-item-engine'` (L52)
  The id of the engine node (only one is rendered), reached by `selectComponent` for the playback methods.

- `animationData: { type: Object, value: null },` (L89)
  Lottie JSON as an object (a data module), instead of `animationUrl`; each item plays its own copy.

- `animationType: { type: String, value: '' },` (L96)
  The type of `animationUrl` ('lottie', 'pag', 'rive', 'svga', 'gif') when its extension does not say it (a file
       renamed to `.bin` for a code package); '' or an unknown type reads it from the extension.
       '' 或未知类型时根据扩展名判断。

- `embedded: { type: Boolean, value: false },` (L102)
  Inside a control that is itself the accessibility element and handles taps (a tag, a bar item): no padding,
       no 44 px minimum, hidden from accessibility, no gestures. The control keeps its own label and touch target.

- `autoplay: { type: Boolean, value: true },` (L107)
  Plays once when the file is ready (default, as before). false: rests until `playAnimation()`.

- `showsImageWhenAnimationEnds: { type: Boolean, value: false },` (L118)
  Whether a play-once animation (`loop` off) is replaced by the still image when it ends (iOS / Android
       `showsImageWhenAnimationEnds`): the engine is hidden and `selectedImage` / `image` (else the placeholder)
       shows. Off by default, so the last frame stays. `playAnimation()`, `stopAnimation()`, a new selection, a new
       file or turning `loop` on shows the animation again. The end is the engine's `complete` (Lottie, PAG, Rive,
       SVGA) or the end of a timed GIF pass (with stills); `animationcomplete` and its alias `animationend` are sent either way.
       `selectedImage` / `image`（没有时为占位图）。默认关闭，保留最后一帧。`playAnimation()`、`stopAnimation()`、重新选中、新文件或开启
       `loop` 时重新显示动画。结束来自引擎的 `complete`（Lottie、PAG、Rive、SVGA）或有静帧的 GIF 一遍计时结束；两种情况都发送 `animationcomplete` 与别名 `animationend`。

- `drivesAnimationPlayback: { type: Boolean, value: true },` (L131)
  Whether the item applies the default playback rules (HarmonyOS `drivesAnimationPlayback`, default true): selected plays
       once from the start, unselected rests, `restartToken` plays again, `autoplay` plays on ready. false: the host drives
       playback itself (resting progress, Play all) through `cyl_player()`; the item only hands out the player and applies
       none of those rules (a selection change touches no engine, the engine never autoplays, `restartToken` is ignored).
       `playAnimation()`, `restartAnimation()` and `stopAnimation()` still do what they are called for. Set it when the
       item is created.
       再次播放，`autoplay` 在就绪时播放。false：宿主通过 `cyl_player()` 自行驱动播放（静止进度、全部播放）；条目只交出播放器，
       不应用上述任何规则（选中状态变化不触及引擎，引擎不自动播放，忽略 `restartToken`）。`playAnimation()`、`restartAnimation()`、
       `stopAnimation()` 仍按调用执行。请在创建条目时设置。

- `restartToken: { type: Number, value: 0 },` (L139)
  A number that plays the animation again from the start each time it grows (HarmonyOS `animationRestartToken`), next
       to `restartAnimation()`. The value at creation is not a restart; a lower value is not one either. Ignored while
       `drivesAnimationPlayback` is false.
       变小也不算。`drivesAnimationPlayback` 为 false 时忽略。

- `animationRestartToken: { type: Number, value: 0 },` (L144)
  Alias of `restartToken` under the HarmonyOS name: the same behavior; growth of either one restarts the animation.

- `restingProgress: { type: Number, value: 0 },` (L149)
  The frame (0...1) shown at rest while not selected (iOS `animationRestingProgress`); selected shows the last.

- `gifFirstFrame: { type: String, value: '' },` (L156)
  GIF stills (PNG): the first and last frames shown at rest; with them a GIF plays one pass (`gifDuration` ms)
       on `playAnimation()`, or until `loop` is turned off. Without them a GIF always plays, as before.
       `loop`。没有静帧时 GIF 一直播放（与之前相同）。

- `riveWasmPath: { type: String, value: '' },` (L163)
  Where cyl-rive and cyl-pag load their WebAssembly from (their `wasm-path`); '' keeps the engine's default.

- `selectedIconTint: { type: String, value: null, optionalTypes: [Object] },` (L185)
  The tint of `selectedImage` while selected. Not set (the default): `iconTint` for both. With both images set, each
       is its own layer and a selection change only toggles their opacity (no node re-created, no `src` change).
       它们的不透明度（不重建节点，不改变 `src`）。

- `animationTint: { type: String, value: '' },` (L196)
  One color for the animation, like a template image (the same names and values as Rive's `tint`): '' (default) keeps the
       file's colors; "title" draws it in the item's icon color (the selected state's icon color when selected); "#RRGGBB" /
       "#RRGGBBAA" is a fixed color (the selected item takes its selected icon color when it has one). A set value overrides the same
       option of the animation source. Rive (canvas fill) and GIF (CSS filter) are recolored; Lottie, PAG and SVGA keep their
       colors. See `cylAnimatedItemAnimationTint`.
       状态的图标颜色）；"#RRGGBB" / "#RRGGBBAA" 是固定颜色（选中条目有选中图标颜色时用它）。已设置的值覆盖动画来源中的同名选项。
       Rive（canvas 填充）与 GIF（CSS filter）会改色；Lottie、PAG、SVGA 保持自身颜色。见 `cylAnimatedItemAnimationTint`。

- `animationDarkTint: { type: String, value: '' },` (L201)
  The dark-mode color of a fixed `animationTint` (a color; not needed for "title"), used while the item is dark.

- `animationIconTint: { type: String, value: '' },` (L208)
  The icon colors `animationTint` follows, when they differ from the static image's `iconTint` / `selectedIconTint` (a tab bar
       item passes its title colors): '' (default) means `iconTint` / `selectedIconTint`. They never tint the static image.
       '' （默认）表示用 `iconTint` / `selectedIconTint`。它们不会给静态图片着色。

- `animationRenderingMode: { type: String, value: '' },` (L224)
  The rendering mode of the animation when `animationTint` is NOT set (also the URL option `renderingMode=`): 'automatic' (default, also '')
       tints with the effective icon color only a file detected as ONE color (here only a GIF; Rive, Lottie, PAG and SVGA are undetectable, and
       Lottie, PAG and SVGA cannot be recolored in a mini program at all); 'alwaysTemplate' tints (Rive and GIF) with the effective icon
       color; 'alwaysOriginal' never tints. An explicit `animationTint` always wins.
       颜色着色（这里只有 GIF；Rive、Lottie、PAG、SVGA 无法检测，而 Lottie、PAG、SVGA 在小程序里根本无法改色）；'alwaysTemplate' 用有效图标颜色给
       Rive 与 GIF 着色；'alwaysOriginal' 从不着色。显式的 `animationTint` 始终优先。

- `builtInSelectedColor: { type: String, value: '' },` (L231)
  The built-in SELECTED color (icon, title, rendering-mode tint) when no explicit selected color exists: the host's default selected color (the
       stack passes its own, the tab bar its default); '' (default) is systemBlue 0,136,255 (dark 0,145,255). The normal built-in is label.
       systemBlue 0,136,255（深色 0,145,255）。普通状态的内置色为 label。

- `subclassTitleColor: { type: String, value: '' },` (L243)
  SUBCLASS-EXPLICIT colors per state (the iOS `setSubclassTitleColor(_:for:)` / `setSubclassIconColor(_:for:)` channel; '' = none): a host built on this item
       (a cyl-tag-list tag) hands its per-state colors here WITHOUT touching the integrator's own `titleColor` / `iconTint` or the stack-inherited ones. They count as
       EXPLICIT (adapted on drawn dark glass: title 4.5, icon and animation tint 3) and are never written into the public properties. A missing selected value falls
       back to the normal one. Precedence (one function for the title, one for the icon, see `cylAnimatedItemResolvedTitleColor` / `cylAnimatedItemResolvedIconColor`): own
       `titleColor` / `iconTint` > subclass-explicit of the state > stack-inherited > subclass built-in > component built-in. A static image is tinted by the explicit levels only (tint spec v2).
       交到这里，「不触碰」集成方自己的 `titleColor` / `iconTint` 与堆叠继承的颜色。它们算「显式」颜色（在绘制的深色玻璃上适配：标题 4.5，图标与动画着色 3），且绝不写入公开属性。
       缺少选中值时回退到常态值。优先级（标题一个函数、图标一个函数，见 `cylAnimatedItemResolvedTitleColor` / `cylAnimatedItemResolvedIconColor`）：自己的 `titleColor` / `iconTint` >
       该状态的子类显式 > 堆叠继承 > 子类内置 > 组件内置。静态图片只由显式层着色（着色规范 v2）。

- `builtInTitleColor: { type: String, value: '' },` (L256)
  SUBCLASS BUILT-IN colors per state (the twin of iOS `applyTitleTintColor(_:)` / `applyIconTintColor(_:)`; '' = none): the host's effective color of each state when it
       has no explicit one. Adapted on drawn dark glass like the explicit levels (normal and selected; NOT the disabled look), as the iOS doc says (the message that said
       "not adapted" is superseded). They tint no static image (built-in), but are the icon color of `animationTint: 'title'` and the rendering modes.
       （常态与选中；「不」含禁用外观），依据 iOS 文档（说「不适配」的消息已被取代）。它们不给静态图片着色（内置），但是 `animationTint: 'title'` 与渲染模式所用的图标颜色。

- `itemHighlightedBackgroundColor: { type: String, value: '' },` (L270)
  The background color while the item is pressed and enabled (iOS `itemHighlightedBackgroundColor`); '' (default) = none. A finger down / up (or a cancelled touch) toggles it.

- `itemDisabledAnimationAlpha: { type: Number, value: -1 },` (L275)
  The alpha (0...1) of the animation (engine, GIF) while the item is disabled (iOS `itemDisabledAnimationAlpha`); -1 (default) = not set = 1. The static image is not changed.

- `showsLastFrameWhenSelected: { type: Boolean, value: false },` (L281)
  A selected HOST-DRIVEN item (`drivesAnimationPlayback` false) rests on the last frame (iOS `showsLastFrameWhenSelected`); default off. With the default rules a selected item
       always rests on its last frame already.

- `disabledWinsImage: { type: Boolean, value: false },` (L286)
  Disabled wins the image (iOS `disabledWinsImage`): `selectedImage` shows only when selected AND enabled; default off.

- `titleColor: { type: String, value: '' },` (L291)
  The title's color (any CSS color); '' keeps the inherited color.

- `titleFontSize: { type: Number, value: 0 },` (L296)
  The title's font size in px; 0 keeps the default 14 px.

- `titleFontWeight: { type: String, optionalTypes: [Number], value: '' },` (L302)
  The title's font weight: 'normal', 'bold', 'bolder', 'lighter' or 100–900 (string or number); '' keeps the
       default.

- `titleDarkColor: { type: String, value: '' },` (L307)
  The title's color in dark mode (any CSS color); '' keeps `titleColor`. Dark follows `userInterfaceStyle`.

- `userInterfaceStyle: { type: String, value: 'system' },` (L312)
  'system' (default) follows the system theme (needs `"darkmode": true` in app.json); 'light' or 'dark' forces it.

- `titleLines: { type: Number, value: 1 },` (L317)
  The title's line count: 1 one line with an ellipsis (default), 0 no limit, n > 1 up to n lines, then an ellipsis.

- `titleLineHeight: { type: Number, value: 0 },` (L322)
  The title's line height in px; 0 keeps the default.

- `titleSpacing: { type: Number, value: -1 },` (L328)
  The gap between the icon and the title in px (below the icon when vertical, beside it when horizontal); -1
       keeps the default 2 px (vertical) / 4 px (horizontal).

- `itemStyle: { type: String, value: 'plain' },` (L341)
  'plain' (default) or 'countdown': a countdown button, e.g. "Get code" of an SMS login (`itemStyle`, the same name
       as on iOS, Android and HarmonyOS; `style` is the host's own attribute). Set the `countdown…` properties, then call
       `startCountdown()` (or set `startsCountdownOnTap`). The end is a time read from the local clock, so the seconds in the
       background count (FIX: issue #1 of SMSCodeButton); a clock past the longest duration, or set back to before the start,
       closes it; `countdownCacheKey` keeps it across a restart. While it runs the item is disabled. Events: `countdownstart`,
       `countdowntick` (`detail.seconds`, once per second), `countdownfinish`.
       同名；`style` 是宿主自己的属性）。设置 `countdown…` 属性后调用 `startCountdown()`（或设置 `startsCountdownOnTap`）。结束是从本地时钟读取的时间点，
       因此后台的秒数计入（修复 SMSCodeButton 的 issue #1）；时钟超过最长时长或被调回到开始之前时关闭；`countdownCacheKey` 使其在重启后继续。
       倒计时中条目不可用。事件：`countdownstart`、`countdowntick`（`detail.seconds`，每秒一次）、`countdownfinish`。

- `cyl_refreshBackground()` (L517)
  Builds the background (flat or drawn Liquid Glass) for the current inputs and mode: the default frosted tint of dark mode is white at 0.04, of
       light mode (225, 222, 220) at 0.10. Called by the observer and again when the system theme changes (`userInterfaceStyle` `system`).
       系统主题变化时（`userInterfaceStyle` 为 `system`）再次调用。

- `adaptedOnGlass(color, kind)` (L538)
  The item's own dark-glass rule as a public function (iOS `adaptedOnGlass(_:kind:)`): `color` as it must be drawn for this item's glass state, theme, background
       colour and tint alpha; `kind` 'icon' (minimum 3) or 'title' (minimum 4.5, 'text' too). Unchanged unless dark Liquid Glass is drawn.
       `kind` 为 'icon'（最低 3）或 'title'（最低 4.5，'text' 亦可）。除非绘制深色液态玻璃，否则原样返回。

- `cyl_isAnimationEngineAvailable(type)` (L543)

- `cyl_setPressed(pressed)` (L548)

- `cyl_countdown()` (L562)
  The countdown state machine of this item, made on first use with the local clock and the mini program storage.

- `startCountdown(seconds)` (L605)
  Starts (or restarts) the countdown for `seconds` (default `countdownDuration`, e.g. the server's "retry after").
       例如服务器返回的「多少秒后重试」）。条目不是倒计时样式时切换为倒计时样式。

- `resetCountdown()` (L614)

- `refreshCountdown()` (L619)

- `cyl_detectColorKind(m)` (L636)
  One-color detection of a GIF ANIMATION (the only type this mini program tints without an explicit color; cached per URL): needed only
       with no explicit tint and a rendering mode that is not alwaysOriginal. Sets `animationColorKind` ('one' | 'multi' | 'unknown').

- `cyl_readBytes(path, done)` (L654)

- `cyl_loadGIFImage(path)` (L670)
  Reads and decodes a GIF image (a package or local file, or an http(s) URL), then draws its first frame.

- `cyl_drawGIFImageStill()` (L697)

- `cyl_playGIFImage()` (L729)
  Plays the GIF image from its first frame: one pass, or until `loop` is turned off; then the still again.

- `cyl_scheduleGIFImageEnd()` (L740)

- `cyl_restGIFImage()` (L753)

- `cyl_onAnimationReady(event)` (L762)

- `playAnimation()` (L783)
  Plays the animation from progress 0, once (or until `loop` is turned off): the engine's `cyl_playFromStart()`, or
       the GIF again from its first frame. A file still loading plays when it is ready. Play all calls this on every item.
       “全部播放”对每个条目调用此方法。

- `pauseAnimation()` (L814)
  Pauses the playing animation on its current frame (`cyl.animation.didPause`); the engine's `cyl_pause`. A GIF has no pause and keeps

- `resumeAnimation()` (L819)

- `restartAnimation()` (L824)

- `stopAnimation()` (L829)

- `cyl_halt()` (L842)
  Cancels a play that waits for the file and stops the engine where it is (a seek alone, `cyl_setProgress`, does not stop
       SVGA or PAG, and Rive has no seek), so the resting frame that follows is the last thing drawn.
       这样随后显示的静止帧就是最后绘制的内容。

- `cyl_rest()` (L858)
  The resting frame: the last one while selected, else `restingProgress`. Lottie through `cyl_goToAndStop`, PAG
       and SVGA through `cyl_setProgress`, Rive through its `resting-frame` (first / last), GIF through its stills.
       Rive 用 `resting-frame`（first / last），GIF 用其静帧。

- `cyl_restAt(progress)` (L868)
  The resting frame at `progress` (0...1): `cyl_rest()` for the item's own resting progress, `cyl_stopAtProgress()` for
       the host's. An engine with no seek rests through `cyl_stop()` (Rive: its `resting-frame`).
       没有跳转的引擎通过 `cyl_stop()` 静止（Rive：其 `resting-frame`）。

- `cyl_scheduleGifEnd()` (L908)

- `cyl_animationDidEnd()` (L925)
  A play-once pass ended: the still image replaces the animation when `showsImageWhenAnimationEnds`.

- `cyl_showAnimationAgain()` (L933)

- `cyl_onAnimationError(event)` (L943)
  No engine, a corrupt file or a failed download: back to the static image (or the placeholder), and once per type

- `cyl_reportResourceMissing(reason)` (L966)
  `resourcemissing` with `{ resource, reason }`: the file as configured (`animationUrl` without its `#` options) and
       "not found", "unreadable", "decode failed" or "engine library missing". Once per resource per item; the item still
       shows its image or the placeholder. A Lottie given as `animationData` has no file to name.
       条目仍显示图片或占位图。以 `animationData` 传入的 Lottie 没有文件可报告。

- `cyl_onAnimationComplete(event)` (L979)
  The engine finished a play (a non-looping pass): forwarded as `animationcomplete`, e.g. to count repeats.

- `cyl_emitComplete(detail)` (L989)
  A play-once pass ended: sends `animationcomplete` and its alias `animationend` (HarmonyOS name), both with the same detail.

- `cyl_onAnimationLoopComplete(event)` (L995)

- `cyl_playDidEnd()` (L1003)
  A play-once pass ended: not playing any more, and the player's `onEnded` callback runs.

- `cyl_canLoop()` (L1012)
  Whether `loop` takes effect on this file: an engine, a GIF with stills, or a GIF image; a GIF with neither plays

- `cyl_player()` (L1026)
  The player of this item (once per item, see cyl_animated_item_player.js): `play()`, `stopAtProgress(p)`, `speed`,
       `loops`, `supportsSpeed` / `supportsLoops` / `supportsProgress`, `isPlaying`, `onEnded(cb)`, `supportsColors` /
       `applyColors(colors)`. The way to play an item with `drivesAnimationPlayback` off; also fine with it on (the
       default rules play through the same item). `animationready` says the engine is live.
       `supportsSpeed` / `supportsLoops` / `supportsProgress`、`isPlaying`、`onEnded(cb)`、`supportsColors` / `applyColors(colors)`。
       播放 `drivesAnimationPlayback` 关闭的条目的方式；开启时也可用（默认规则通过同一个条目播放）。`animationready` 表示引擎已就绪。

- `cyl_stopAtProgress(progress)` (L1046)
  Stops where it is, then shows the frame at `progress` (0...1): the player's `stopAtProgress`. Host-driven, the
       resting frame and the GIF stills follow this progress until the next call.

- `cyl_animationView()` (L1057)

- `cyl_playFromStart(offset)` (L1065)
  Plays the animation from its first frame, or `offset` seconds in, when its engine can.

- `cyl_stop()` (L1078)

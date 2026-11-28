# Vendored modules (copies of the owner's other libraries)

Read at CollectionViewClassifyMenu 03707ba2. [CN] comment lines, import lines and blank lines were left out of the reading.
Nothing was built or run. Do not edit these copies: fix upstream and re-copy.

| Copy | Upstream | Pin (per VENDORED.md / fetch script) |
|---|---|---|
| harmony/cylanimateditem, _lottie, _pag, _rive, cylanimateditemrive | CYLTabBarController | b5b36fbf |
| harmony/cylliquidglass | CYLTabBarController | 8fa168fa |
| harmony/cyldeallocblockexecutor | CYLDeallocBlockExecutor | 4276a6da |
| miniprogram_dist/cyl-animated-item, cyl-animation-placeholder | CYLTabBarController (scripts/fetch-cyltabbar.js, COMMIT) | b5b36fbf |
| miniprogram_dist/cyl-dealloc-block-executor | CYLDeallocBlockExecutor | 4276a6da |

miniprogram_dist = CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist.

## cyldeallocblockexecutor (HarmonyOS and mini program)
- Each owner has a registry of lifecycle blocks: run in identifier order, a key replaces the earlier block, timings
  beforeSuper / afterSuper / end, optional forwarding to another owner. LifecycleCenter holds global observers.
- Controllers map ArkUI or wx page callbacks to iOS-style event names. Teardown blocks run on aboutToDisappear / onUnload
  (onDetach); a torn-down controller never runs new teardown blocks.
- whileUserScrolls(pause, resume) is two keyed observers: scrollWillBeginDragging and scrollDidEndScrolling.
- The mini program copy is the TypeScript with types removed. Without WeakRef it holds owners strongly.

## cylliquidglass
Blur + tint view and capsule. isActive() is true unless activeOverride is set. Dark glass brightness 0.9, light 1.05.

## cylanimateditem (HarmonyOS)
- CYLAnimatedItemView: icon (still image or placeholder under the animation until onLoaded) + title + accessory;
  countdown style; bare and divider modes; tint drawn as a SRC_IN layer; engine state is changed in place.
- Background modifier: the one place for flat or drawn glass. Default tint light #1AE1DEDC, dark #0AFFFFFF; capsule
  radius constant 1000; glass content inset 14; 1 vp rim and a sheen.
- Colors: own > subclass-explicit > stack > subclass built-in > component built-in. Colors are lifted only on drawn DARK
  glass (title 4.5:1, icon 3:1) against a floor of 0.4 white share.
- Tint: an explicit animationTint wins; "title" = effective icon color; a fixed color yields to an EXPLICIT selected icon
  color when selected. Without a tint the rendering mode decides (item > URL option > stack > automatic); automatic tints
  only files detected as one color (Lottie fill/stroke colors, or a GIF with 98 % of pixels in one 4-bit bucket).
- Countdown: stores the end time, ticks every 250 ms, optional cache "start,end,duration", closes on clock rollback.
- Source: "asset:" prefix, options after # or ?, percent-decoded, text starting with { or [ is inline Lottie JSON.
- Engines: a registry of wrapped builders; views are created 50 ms apart (to avoid an appfreeze). Each engine view calls
  binding.update(state); PlaybackDriver applies selection, speed, loop and restart. drivesPlayback false hands the player
  to the host and applies none of those rules.
- Built-in types: Lottie, PAG, Rive, SVGA, GIF. PAG and Rive need arm64, except with the x86_64 engine kit
  (marker rawfile cyl_x86_64_debug_engines.json, added by tools/cyl_hap_x86_64.py).
- GIF fallback: decoded frames, then first frame, then ArkUI Image from a cache copy, then failure. Delays of 10 ms or
  less become 100 ms. A truncated GIF drops its last frame but keeps at least one.
- SVGA: own zlib inflate, protobuf decoder for SVGA 2.x and canvas renderer. SVGA 1.x is rejected; mattes are not
  supported; an arc is drawn as a line.
- Lottie: recoloring uses only the first color; restoring colors reloads the file; destroy is by name.
- PAG: the player drives progress with a timer. Rive: no playback speed; Canvas renderer on the emulator; restart logic
  depends on the input kind. CYLRiveIcon + CYLRiveLoopPolicy are shared; cylanimateditem_rive only re-exports.
- StackModel / StackView: ordered items with actions, a background action (the first item stands for it), per-gap
  dividers (alpha 0.6 of an explicit icon color, else secondary label), accessibility rules for decorative items.

## cyl-animated-item (mini program)
- model.js: pure render model (type table, source option parser, color precedence, tint table, glass CSS
  blur 16 px, saturate 160 %, brightness 1.05 in both modes, countdown title width, missing-resource reasons).
- index.js: component; teardown as a keyed dealloc block; GIF resting frame drawn on a canvas from its own LZW decoder;
  playback per engine capability; countdown kept in wx storage and refreshed on onAppShow.
- player.js capability table: only Rive has no seek; GIF has no speed or seek; colors only for Lottie and Rive.
- contrast.js: the dark-glass floor 0.37 is calculated from the CSS, not measured on a device (its own comment).
- animation_events.js: didStart / didPause / didResume / didStop and optional pause-while-scrolling.
- Engine components are not in these folders; the app names them with generic:. The example's wrapper is
  miniprogram/components/cyl-tag-animation-view.

## Vendored tests (read, not run)
- harmony/cylanimateditem/test: Node tests for colors, tint table, color count, countdown, GIF, SVGA, source parsing,
  stack model, type registry, player; Python tests of the HAP tool. cylanimateditemrive/test: options, loop policy,
  export list. The upstream-copied mini program test runs with the app's npm test.
- No CollectionViewClassifyMenu workflow runs the HarmonyOS ones (the workflows are ios, localization, miniprogram,
  screenshots; none names these tests). See V8 in 09 for one that cannot pass here.

Findings for these modules: V1-V8 in 09-findings.md.

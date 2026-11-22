# Example demo rules

Tag: `examples`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[examples] Example demo rules`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "Example demo rules" now
means the section of that name here.


## Example demo rules

- **Animation playback controls.** Every example screen that shows animations (Lottie, PAG, Rive, GIF, symbol
  effects), on every platform (iOS, Android, React Native, Flutter, Mini Program, HarmonyOS), offers three controls
  that combine and act in real time: **Play all** (restart every animation from progress 0, once), a **speed slider**
  and a **loop switch**. Change the core library (and CYLTabBarController's animation engine) when an engine lacks
  the speed or loop API; never work around it in the example. Details, status per platform and the TODO:
  `docs/example-demo-rules.md`. The same rule, with the library-side notes, is in CYLTabBarController's
  `docs/Tab-Icon-Animation-Quick-Start.md` ("Playback controls in the animation examples").


## Search bars

- A search bar never covers any view, at any time: not the view controller's view, not a sibling, not a background
  view, not a bar item, in every state (scrolling, editing, Cancel shown) and at every Dynamic Type size. A screen
  whose navigation bar holds the search bar removes `.top` from `edgesForExtendedLayout`; a `CYLSearchBarView` is
  laid out against the safe area beside the content, and a colored area behind the status bar ends where the bar
  begins. `CYLSearchBarPlacementTests` checks every screen with a search bar through `CYLViewOverlapInspecting`;
  add a test there for each new one.


## Tab bars

- Tab bars are always at the bottom of the screen, including tab bars nested in
  a screen (such as scenario 2's category tabs); never move a tab bar to the top.
- A screen pushed from a tab sets `hidesBottomBarWhenPushed = YES`, so the
  parent tab bar is hidden after the push.
- Do not set a tab's root view controller `title`; set `navigationItem.title`,
  otherwise it replaces the tab item's title.

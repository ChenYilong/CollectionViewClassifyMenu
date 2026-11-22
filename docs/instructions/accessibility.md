# Accessibility

Tag: `accessibility`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[accessibility] Accessibility`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "Accessibility" now
means the section of that name here.


## Accessibility

Copied from CYLTabBarController ("Accessibility is required everywhere" in its
AGENTS.md, newest commit) and adapted to this project:

- The core library (the CocoaPods pod) and every example fully support
  accessibility: VoiceOver, Voice Control, Switch Control, Full Keyboard Access
  and Dynamic Type, plus Reduce Motion, Bold Text, Increase Contrast and Larger
  Text. This applies to new code, to code you change and to existing code you
  review: fix what is missing when you meet it.
- Every control and every piece of text is an accessibility element with a
  meaningful, localized label, and a value, traits (button, header, selected,
  not enabled) and a hint when useful: tags (selected or not), "+ 新建标签", the
  fold control ("<section> 更多/收起"), the list's title (a header), section
  headers, search fields, buttons and rows.
- Hide purely decorative views from accessibility; never leave an interactive
  view without a label. An icon-only element needs a label of its own.
- Text uses Dynamic Type (`adjustsFontForContentSizeCategory`, scaled fonts) and
  layouts grow with it; animations respect Reduce Motion
  (`UIAccessibilityIsReduceMotionEnabled`); colors keep enough contrast and do
  not carry meaning alone.
- The core's views have stable `accessibilityIdentifier`s (for example
  `CYLTagListFoldControl`, `CYLTagCreateItem`, `CYLTagListTitle`), so tests and
  tools find them without coordinates.
- Tests and simulator checks drive the UI through accessibility first: find
  elements by their accessibility label or identifier, and fall back to
  coordinates only when no element can be found, then file the missing label as
  a bug and fix it.
- A change that adds a control or a text without accessibility is not done.
- Details and checks: `.agents/skills/cyl-accessibility/` (and the copied
  `ios-accessibility`, `uikit-accessibility-auditor` and `accessibility-audit`
  skills).

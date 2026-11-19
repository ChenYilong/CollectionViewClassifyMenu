/**
 * Stable accessibility identifiers of the tag list's views (iOS CYLTagListAccessibility.swift; Android
 * CYLTagListAccessibility.kt), so UI tests and tools find them without coordinates. The labels stay localized; the
 * identifiers never change. ArkUI takes them as a component's `id`.
 */
export class CYLTagListAccessibilityIdentifier {
  /** The list's title view, a header. */
  static readonly title: string = 'CYLTagListTitle';
  /** Every fold control ("<section> 更多/收起"), in a section header, at the bottom or among the tags. */
  static readonly foldControl: string = 'CYLTagListFoldControl';
  /** Every tag cell; its label is the tag's title. */
  static readonly item: string = 'CYLTagListItem';
  /** The "+ 新建标签" item (`CYLMenuItemType.create`). */
  static readonly createItem: string = 'CYLTagCreateItem';
  /** The More button of a section header (`menuShowsMoreButtonInSection`). */
  static readonly moreButton: string = 'CYLTagListMoreButton';
  /** The tappable delete indicator ("×") of a deletable tag. */
  static readonly deleteButton: string = 'CYLTagListDeleteButton';
  /** The rename indicator of a tag in editing mode (an edit icon before the delete indicator). */
  static readonly renameButton: string = 'CYLTagListRenameButton';
  /** The title of a renamable tag in editing mode: a tap renames it too (`renamesOnTitleTapWhileEditing`). */
  static readonly renameTitle: string = 'CYLTagListRenameTitle';
  /** A section header's clear button (`menuShowsClearButtonForSection`). */
  static readonly clearButton: string = 'CYLTagListClearButton';
}

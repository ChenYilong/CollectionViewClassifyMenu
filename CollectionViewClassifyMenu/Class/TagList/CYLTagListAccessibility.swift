//
//  CYLTagListAccessibility.swift
//  CollectionViewClassifyMenu
//
//  Stable accessibility identifiers of CYLTagListView's views, so UI tests, Voice Control scripts and tools find them
//  without coordinates. The labels stay localized; the identifiers never change.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import Foundation

/**
 * The accessibility identifiers of `CYLTagListView`'s views.
 */
public enum CYLTagListAccessibilityIdentifier {

    /**
     * The list's title view (`CYLTagListView.titleView`), a header.
     */
    public static let title = "CYLTagListTitle"

    /**
     * Every fold control ("<section> 更多/收起"), in a section header, at the bottom or among the tags.
     */
    public static let foldControl = "CYLTagListFoldControl"

    /**
     * Every tag cell; its label is the tag's title.
     */
    public static let item = "CYLTagListItem"

    /**
     * The "+ 新建标签" item (`CYLMenuItemType.create`).
     */
    public static let createItem = "CYLTagCreateItem"

    /**
     * The More button of a section header (`menuShowsMoreButton(inSection:)`).
     */
    public static let moreButton = "CYLTagListMoreButton"

    /**
     * The tappable delete indicator ("×") of a deletable tag; VoiceOver users get a "Delete" action on the tag instead.
     */
    public static let deleteButton = "CYLTagListDeleteButton"
}

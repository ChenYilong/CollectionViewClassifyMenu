//
//  CYLTagListAccessibility.h
//  CollectionViewClassifyMenu
//
//  Stable accessibility identifiers of CYLTagListView's views, so UI tests, Voice Control scripts
//  and tools find them without coordinates. The labels stay localized; the identifiers never change.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * The list's title view (CYLTagListView.titleView), a header.
 */
FOUNDATION_EXTERN NSString *const CYLTagListTitleAccessibilityIdentifier;
/*!
 * Every fold control ("<section> 更多/收起"), in a section header or at the bottom.
 */
FOUNDATION_EXTERN NSString *const CYLTagListFoldControlAccessibilityIdentifier;
/*!
 * Every tag cell; its label is the tag's title.
 */
FOUNDATION_EXTERN NSString *const CYLTagListItemAccessibilityIdentifier;
/*!
 * The "+ 新建标签" item (CYLMenuItemTypeCreate).
 */
FOUNDATION_EXTERN NSString *const CYLTagCreateItemAccessibilityIdentifier;

NS_ASSUME_NONNULL_END

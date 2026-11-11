//
//  CYLTagListView.h
//  CollectionViewClassifyMenu
//
//  A configurable, embeddable tag menu. The host owns the data (through
//  CYLMenuDataSource) and reacts to taps (through CYLMenuDelegate); the view
//  owns only layout, folding and selection state.
//

#import <UIKit/UIKit.h>
#import "CYLMenuDataSource.h"
#import "CYLMenuStyle.h"
#import "CYLMenuFoldControl.h"
#import "CYLTagButton.h"
#import "CYLTagListAccessibility.h"
#import "CYLTag.h"
#import "CYLTagColors.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLMenuSelectionMode) {
    /*!
     * Items behave like buttons: taps are reported, nothing stays selected.
     */
    CYLMenuSelectionModeNone = 0,
    /*!
     * At most one selected item per section.
     */
    CYLMenuSelectionModeSingle,
    /*!
     * Any number of selected items; exclusive items clear the others.
     */
    CYLMenuSelectionModeMultiple,
};

/*!
 * Where the list's title (`title`) is: above every section, at the leading edge or centered.
 */
typedef NS_ENUM(NSInteger, CYLMenuTitlePosition) {
    CYLMenuTitlePositionTopLeading = 0,
    CYLMenuTitlePositionTopCenter,
};

/*!
 * The older way of choosing a fold control; foldControl gives the position and content separately.
 */
typedef NS_ENUM(NSInteger, CYLMenuFoldStyle) {
    /*!
     * Every row is always visible.
     */
    CYLMenuFoldStyleNone = 0,
    /*!
     * A "更多/收起" button at the trailing edge of the section header.
     */
    CYLMenuFoldStyleHeaderButton,
    /*!
     * A chevron below the section, as in shopping review filters.
     */
    CYLMenuFoldStyleFooterChevron,
    /*!
     * Shows only `defaultVisibleRows` rows with no control, for previews;
     * the host may still call -setExpanded:forSection:animated:.
     */
    CYLMenuFoldStyleTruncate,
};

@interface CYLTagListView : UIView

/*!
 * A tag list with its fold control and title, the styles fixed at creation (both can change later).
 */
- (instancetype)initWithFoldControl:(nullable CYLMenuFoldControl *)foldControl
                              title:(nullable NSString *)title
                      titlePosition:(CYLMenuTitlePosition)titlePosition;
/*!
 * With an icon before the title (either may be nil: icon only, title only).
 */
- (instancetype)initWithFoldControl:(nullable CYLMenuFoldControl *)foldControl
                              title:(nullable NSString *)title
                         titleImage:(nullable UIImage *)titleImage
                      titlePosition:(CYLMenuTitlePosition)titlePosition;
/*!
 * The same without a title.
 */
- (instancetype)initWithFoldControl:(nullable CYLMenuFoldControl *)foldControl;
+ (instancetype)tagListViewWithFoldPosition:(CYLMenuFoldControlPosition)position content:(CYLMenuFoldControlContent)content;

@property (nonatomic, weak, nullable) id<CYLMenuDataSource> menuDataSource;
@property (nonatomic, weak, nullable) id<CYLMenuDelegate> menuDelegate;

/*!
 * Appearance. Setting copies the style; set it again after changing it.
 */
@property (nonatomic, copy, null_resettable) CYLMenuStyle *style;

/*!
 * Defaults to CYLMenuSelectionModeSingle.
 */
@property (nonatomic, assign) CYLMenuSelectionMode selectionMode;
/*!
 * When NO, a tap never removes the last selected item of a section.
 * Defaults to YES.
 */
@property (nonatomic, assign) BOOL allowsEmptySelection;

/*!
 * Defaults to YES. When NO, sections are laid out back to back without titles.
 */
@property (nonatomic, assign) BOOL showsSectionHeaders;

/*!
 * The fold control of a foldable section (more rows than `defaultVisibleRows`): where it is and what
 * it shows. Default: none. Setting it also sets `foldStyle` (Bottom: FooterChevron, Top…:
 * HeaderButton, None: None, or Truncate when foldStyle was Truncate).
 */
@property (nonatomic, copy, null_resettable) CYLMenuFoldControl *foldControl;
/*!
 * Defaults to CYLMenuFoldStyleNone. Setting it also sets `foldControl`: HeaderButton is a top
 * trailing title ("更多"), FooterChevron a bottom icon; None and Truncate have none.
 */
@property (nonatomic, assign) CYLMenuFoldStyle foldStyle;

/*!
 * A title above every section (nil, the default, for none), e.g. "评价". It is drawn by `titleView`,
 * the same tag view as the tags (CYLTagButton), laid out horizontally: an icon (`titleImage`), a title,
 * or both. Neither: no title area.
 */
@property (nonatomic, copy, nullable) NSString *title;
/*!
 * The title's icon, before the title (or after it with titleStyle.imagePlacement); nil for none.
 */
@property (nonatomic, strong, nullable) UIImage *titleImage;
@property (nonatomic, assign) CYLMenuTitlePosition titlePosition;
/*!
 * The title's look (font, colors, icon size and color, spacing…). Default `+defaultTitleStyle`: the bold
 * headline font in the label color, no box. Setting copies the style.
 */
@property (nonatomic, copy, null_resettable) CYLMenuStyle *titleStyle;
/*!
 * The view that draws the title: every public API of CYLTagButton is available (e.g. an animated icon
 * with animationURL). Set the title, icon and style through the properties above.
 */
@property (nonatomic, strong, readonly) CYLTagButton *titleView;
/*!
 * The title's label (`titleView.titleLabel`).
 */
@property (nonatomic, strong, readonly) UILabel *titleLabel;
/*!
 * The default title look: the headline font (bold, scaled with Dynamic Type) in the label color, an
 * 18 pt icon in the label color, no background or border.
 */
+ (CYLMenuStyle *)defaultTitleStyle;
/*!
 * Rows shown while a foldable section is collapsed. 0 shows every row.
 * Defaults to 1.
 */
@property (nonatomic, assign) NSUInteger defaultVisibleRows;

/*!
 * Turn off to embed the view in another scroll view and size it with
 * contentHeight or Auto Layout's intrinsic content size. Defaults to YES.
 */
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnabled;

/*!
 * Height needed to show the current content at the current width. Also
 * reported as the intrinsic content height and through
 * -menu:didChangeContentHeight:.
 */
@property (nonatomic, assign, readonly) CGFloat contentHeight;

/*!
 * Reads everything from the data source again. Selections and expanded
 * sections that are still in range are kept.
 */
- (void)reloadMenuData;

/*!
 * Height the content needs at `width` with the current data and fold state,
 * without laying the view out.
 */
- (CGFloat)heightThatFitsWidth:(CGFloat)width;

#pragma mark Spacing (android-tagview's lineMargin, tagMargin and textPadding…)

/*!
 * Shortcuts to `style` (each one copies the style, changes it and sets it again), also settable in Interface Builder
 * (IBInspectable), as android-tagview's XML attributes: the space between rows (style.lineSpacing, lineMargin),
 * between tags in a row (style.interitemSpacing, tagMargin) and inside every tag (style.tagContentInsets,
 * textPaddingTop / Left / Bottom / Right).
 */
@property (nonatomic, assign) IBInspectable CGFloat lineSpacing;
@property (nonatomic, assign) IBInspectable CGFloat interitemSpacing;
@property (nonatomic, assign) UIEdgeInsets tagContentInsets;
@property (nonatomic, assign) IBInspectable CGFloat tagContentInsetTop;
@property (nonatomic, assign) IBInspectable CGFloat tagContentInsetLeft;
@property (nonatomic, assign) IBInspectable CGFloat tagContentInsetBottom;
@property (nonatomic, assign) IBInspectable CGFloat tagContentInsetRight;

#pragma mark Tags (android-tagview's TagView)

/*!
 * The list's own tags, for a list filled the android-tagview way: create it, add CYLTag objects (or titles), react to
 * taps and deletions in blocks. The first tag method makes `tagDataSource` the menuDataSource and, the way android-tagview
 * behaves, turns section headers off and sets selectionMode to CYLMenuSelectionModeNone (change them afterwards to
 * select tags). Every other API (styles, folding, selection, configuration) keeps working.
 */
@property (nonatomic, strong, readonly) CYLTagDataSource *tagDataSource;
/*!
 * The tags of `tagDataSource`, in order (android-tagview's getTags()).
 */
@property (nonatomic, copy, readonly) NSArray<CYLTag *> *tags;
- (void)addTag:(CYLTag *)tag;
- (void)addTags:(NSArray<CYLTag *> *)tags;
/*!
 * Tags with these titles and the list's look (android-tagview's addTags(String[])).
 */
- (void)addTagsWithTitles:(NSArray<NSString *> *)titles NS_SWIFT_NAME(addTags(withTitles:));
- (void)insertTag:(CYLTag *)tag atIndex:(NSUInteger)index;
/*!
 * Removes a tag (android-tagview's remove(position)); selections after it move up. Out-of-range indexes are ignored.
 */
- (void)removeTagAtIndex:(NSUInteger)index NS_SWIFT_NAME(removeTag(at:));
- (void)removeAllTags;
/*!
 * Called for every accepted tap on one of `tags` (android-tagview's OnTagClickListener), after the menu delegate.
 */
@property (nonatomic, copy, nullable) void (^tagClickHandler)(NSInteger index, CYLTag *tag);
/*!
 * Called after a tap on a tag's delete indicator removed it (android-tagview's OnTagDeleteListener), after the menu delegate.
 */
@property (nonatomic, copy, nullable) void (^tagDeleteHandler)(NSInteger index, CYLTag *tag);
/*!
 * Deletes a deletable item as a tap on its delete indicator does: the data source removes it
 * (-menuRemoveItemAtIndexPath:), the list reloads and reports it. Does nothing for an item that is not deletable or
 * not enabled.
 */
- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark Container (AndroidTagView's TagContainerLayout)

/*!
 * The list's own border (container_border_width, container_border_color, container_border_radius). 0, nil and 0 by
 * default. The background is `style.backgroundColor`.
 */
@property (nonatomic, assign) CGFloat containerBorderWidth;
@property (nonatomic, strong, nullable) UIColor *containerBorderColor;
@property (nonatomic, assign) CGFloat containerCornerRadius;
/*!
 * At most this many rows of each section (container_max_lines); 0 (the default) shows every row. Setting it sets
 * foldStyle to CYLMenuFoldStyleTruncate and defaultVisibleRows to it.
 */
@property (nonatomic, assign) NSUInteger maximumNumberOfRows;
/*!
 * Colors every item that has no look of its own from a theme (tag_theme): CYLTagColorThemeNone (the default), random,
 * pure cyan or pure teal.
 */
@property (nonatomic, assign) CYLTagColorTheme colorTheme;
/*!
 * NO ignores taps on tags: no highlight, no selection, no callbacks (tag_clickable). Long presses still work. Defaults to YES.
 */
@property (nonatomic, assign) BOOL allowsTapping;
/*!
 * The icon of every item without one of its own (setDefaultImageDrawableID), e.g. an avatar. nil by default.
 */
@property (nonatomic, strong, nullable) UIImage *defaultTagImage;
/*!
 * NO makes a tap on a delete indicator only report it (AndroidTagView's onTagCrossClick); the host removes the item.
 * Defaults to YES.
 */
@property (nonatomic, assign) BOOL removesItemsOnDelete;
/*!
 * The tag view of a shown item (getTagView), or nil when it is not on screen.
 */
- (nullable CYLTagButton *)tagButtonAtIndexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(tagButton(at:));

#pragma mark Long press and reordering

/*!
 * A long press on an item without moving it: -menu:didLongPressItemAtIndexPath:, then this (onTagLongClick).
 */
@property (nonatomic, copy, nullable) void (^tagLongPressHandler)(NSInteger index, CYLTag *tag);
/*!
 * The name of the long-press custom action that VoiceOver, Voice Control and Switch Control users pick instead of a
 * long press (each tag gets it while `tagLongPressHandler` is set or the delegate handles long presses), such as
 * "删除". nil: "长按" (core string `CYLMenuLongPress`). While `allowsReordering`, tags also get 前移 / 后移 actions,
 * which move them like a drag and announce the new position.
 */
@property (nonatomic, copy, nullable) NSString *longPressAccessibilityActionName;
/*!
 * A long press and a move reorders the items of a section (container_enable_drag). Needs a data source that implements
 * -menuMoveItemAtIndexPath:toIndexPath: (CYLTagDataSource does). NO by default.
 */
@property (nonatomic, assign) BOOL allowsReordering;
/*!
 * How quickly a press starts reordering (container_drag_sensitivity): the press lasts 0.5 s divided by it. 1 by default.
 */
@property (nonatomic, assign) CGFloat reorderingSensitivity;
/*!
 * Whether an item is being moved (getTagViewState).
 */
@property (nonatomic, assign, readonly, getter=isReordering) BOOL reordering;
/*!
 * One of `tags` moved (after -menu:didMoveItemAtIndexPath:toIndexPath:).
 */
@property (nonatomic, copy, nullable) void (^tagMoveHandler)(NSInteger fromIndex, NSInteger toIndex);
/*!
 * A selected tag started moving (onSelectedTagDrag), after -menu:didBeginDraggingSelectedItemAtIndexPath:.
 */
@property (nonatomic, copy, nullable) void (^selectedTagDragHandler)(NSInteger index, CYLTag *tag);

#pragma mark More tag methods (AndroidTagView)

/*!
 * Replaces the tags (setTags).
 */
- (void)replaceTags:(NSArray<CYLTag *> *)tags;
- (void)setTagsWithTitles:(NSArray<NSString *> *)titles NS_SWIFT_NAME(setTags(withTitles:));
/*!
 * With colors per tag, in order (setTags(List, List<int[]>)); tags past the colors keep the list's look.
 */
- (void)setTagsWithTitles:(NSArray<NSString *> *)titles colors:(NSArray<CYLTagColors *> *)colors NS_SWIFT_NAME(setTags(withTitles:colors:));
- (void)addTagWithTitle:(NSString *)title NS_SWIFT_NAME(addTag(withTitle:));
- (void)insertTagWithTitle:(NSString *)title atIndex:(NSUInteger)index NS_SWIFT_NAME(insertTag(withTitle:at:));
/*!
 * Removes several tags (removeConsecutiveTags).
 */
- (void)removeTagsAtIndexes:(NSIndexSet *)indexes NS_SWIFT_NAME(removeTags(at:));
/*!
 * Selects an unselected item or deselects a selected one (toggleSelectTagView). In CYLMenuSelectionModeNone, where taps
 * never select, it still selects (any number of items), as AndroidTagView's long press does.
 */
- (void)toggleSelectionOfItemAtIndexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(toggleSelection(at:));
/*!
 * The titles of the selected items, in order (getSelectedTagViewText).
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *selectedTitles;

#pragma mark Selection

/*!
 * Selected items in ascending order.
 */
@property (nonatomic, copy) NSArray<NSIndexPath *> *selectedIndexPaths;
/*!
 * Applies the selection rules of `selectionMode` without calling the delegate.
 */
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectAllItems;

#pragma mark Folding

- (BOOL)isSectionExpanded:(NSInteger)section;
/*!
 * Expands or collapses a section and calls -menu:didChangeExpanded:inSection:.
 */
- (void)setExpanded:(BOOL)expanded forSection:(NSInteger)section animated:(BOOL)animated;
/*!
 * Whether the section has more rows than `defaultVisibleRows` and can fold.
 */
- (BOOL)canFoldSection:(NSInteger)section;
/*!
 * Number of rows the section's items occupy at the current width.
 */
- (NSUInteger)numberOfRowsInSection:(NSInteger)section;
/*!
 * Number of items currently shown in the section (fewer while collapsed).
 */
- (NSInteger)numberOfVisibleItemsInSection:(NSInteger)section;
/*!
 * Scrolls so that the section (its header, or its first row) is at the top, as far as the content allows.
 */
- (void)scrollToSection:(NSInteger)section animated:(BOOL)animated;
/*!
 * Scrolls so that the item is centered vertically, as far as the content allows (e.g. a tag just
 * created, or the last item). Does nothing for an item that is not shown (folded away).
 */
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END

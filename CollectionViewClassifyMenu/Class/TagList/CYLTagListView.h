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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLMenuSelectionMode) {
    /// Items behave like buttons: taps are reported, nothing stays selected.
    CYLMenuSelectionModeNone = 0,
    /// At most one selected item per section.
    CYLMenuSelectionModeSingle,
    /// Any number of selected items; exclusive items clear the others.
    CYLMenuSelectionModeMultiple,
};

typedef NS_ENUM(NSInteger, CYLMenuFoldStyle) {
    /// Every row is always visible.
    CYLMenuFoldStyleNone = 0,
    /// A "更多/收起" button at the trailing edge of the section header.
    CYLMenuFoldStyleHeaderButton,
    /// A chevron below the section, as in shopping review filters.
    CYLMenuFoldStyleFooterChevron,
    /// Shows only `defaultVisibleRows` rows with no control, for previews;
    /// the host may still call -setExpanded:forSection:animated:.
    CYLMenuFoldStyleTruncate,
};

@interface CYLTagListView : UIView

@property (nonatomic, weak, nullable) id<CYLMenuDataSource> menuDataSource;
@property (nonatomic, weak, nullable) id<CYLMenuDelegate> menuDelegate;

/// Appearance. Setting copies the style; set it again after changing it.
@property (nonatomic, copy, null_resettable) CYLMenuStyle *style;

/// Defaults to CYLMenuSelectionModeSingle.
@property (nonatomic, assign) CYLMenuSelectionMode selectionMode;
/// When NO, a tap never removes the last selected item of a section.
/// Defaults to YES.
@property (nonatomic, assign) BOOL allowsEmptySelection;

/// Defaults to YES. When NO, sections are laid out back to back without titles.
@property (nonatomic, assign) BOOL showsSectionHeaders;

/// Defaults to CYLMenuFoldStyleNone.
@property (nonatomic, assign) CYLMenuFoldStyle foldStyle;
/// Rows shown while a foldable section is collapsed. 0 shows every row.
/// Defaults to 1.
@property (nonatomic, assign) NSUInteger defaultVisibleRows;

/// Turn off to embed the view in another scroll view and size it with
/// contentHeight or Auto Layout's intrinsic content size. Defaults to YES.
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnabled;

/// Height needed to show the current content at the current width. Also
/// reported as the intrinsic content height and through
/// -menu:didChangeContentHeight:.
@property (nonatomic, assign, readonly) CGFloat contentHeight;

/// Reads everything from the data source again. Selections and expanded
/// sections that are still in range are kept.
- (void)reloadMenuData;

/// Height the content needs at `width` with the current data and fold state,
/// without laying the view out.
- (CGFloat)heightThatFitsWidth:(CGFloat)width;

#pragma mark Selection

/// Selected items in ascending order.
@property (nonatomic, copy) NSArray<NSIndexPath *> *selectedIndexPaths;
/// Applies the selection rules of `selectionMode` without calling the delegate.
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectAllItems;

#pragma mark Folding

- (BOOL)isSectionExpanded:(NSInteger)section;
/// Expands or collapses a section and calls -menu:didChangeExpanded:inSection:.
- (void)setExpanded:(BOOL)expanded forSection:(NSInteger)section animated:(BOOL)animated;
/// Whether the section has more rows than `defaultVisibleRows` and can fold.
- (BOOL)canFoldSection:(NSInteger)section;
/// Number of rows the section's items occupy at the current width.
- (NSUInteger)numberOfRowsInSection:(NSInteger)section;
/// Number of items currently shown in the section (fewer while collapsed).
- (NSInteger)numberOfVisibleItemsInSection:(NSInteger)section;
/// Scrolls so that the section (its header, or its first row) is at the top, as far as the content allows.
- (void)scrollToSection:(NSInteger)section animated:(BOOL)animated;
/// Scrolls so that the item is centered vertically, as far as the content allows (e.g. a tag just
/// created, or the last item). Does nothing for an item that is not shown (folded away).
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END

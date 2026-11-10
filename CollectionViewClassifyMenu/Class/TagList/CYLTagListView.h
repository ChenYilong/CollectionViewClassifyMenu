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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLMenuSelectionMode) {
    /// Items behave like buttons: taps are reported, nothing stays selected.
    CYLMenuSelectionModeNone = 0,
    /// At most one selected item per section.
    CYLMenuSelectionModeSingle,
    /// Any number of selected items; exclusive items clear the others.
    CYLMenuSelectionModeMultiple,
};

/// Where the list's title (`title`) is: above every section, at the leading edge or centered.
typedef NS_ENUM(NSInteger, CYLMenuTitlePosition) {
    CYLMenuTitlePositionTopLeading = 0,
    CYLMenuTitlePositionTopCenter,
};

/// The older way of choosing a fold control; foldControl gives the position and content separately.
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

/// A tag list with its fold control and title, the styles fixed at creation (both can change later).
- (instancetype)initWithFoldControl:(nullable CYLMenuFoldControl *)foldControl
                              title:(nullable NSString *)title
                      titlePosition:(CYLMenuTitlePosition)titlePosition;
/// The same without a title.
- (instancetype)initWithFoldControl:(nullable CYLMenuFoldControl *)foldControl;
+ (instancetype)tagListViewWithFoldPosition:(CYLMenuFoldControlPosition)position content:(CYLMenuFoldControlContent)content;

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

/// The fold control of a foldable section (more rows than `defaultVisibleRows`): where it is and what
/// it shows. Default: none. Setting it also sets `foldStyle` (Bottom: FooterChevron, Top…:
/// HeaderButton, None: None, or Truncate when foldStyle was Truncate).
@property (nonatomic, copy, null_resettable) CYLMenuFoldControl *foldControl;
/// Defaults to CYLMenuFoldStyleNone. Setting it also sets `foldControl`: HeaderButton is a top
/// trailing title ("更多"), FooterChevron a bottom icon; None and Truncate have none.
@property (nonatomic, assign) CYLMenuFoldStyle foldStyle;

/// A title above every section (nil, the default, for none), e.g. "评价". Its label is `titleLabel`
/// (the headline font, scaled with Dynamic Type).
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, assign) CYLMenuTitlePosition titlePosition;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
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

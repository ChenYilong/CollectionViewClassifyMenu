//
//  CYLTagListView.m
//  CollectionViewClassifyMenu
//

#import "CYLTagListView.h"
#import "CYLCollectionViewLeftAlignedLayout.h"
#import "CYLParameterConfiguration.h"
#import "CYLTagButton.h"
#import "CYLTagListCell.h"
#import "CYLTagCreateCell.h"
#import "CYLTagFoldButton.h"
#import "CYLTagFoldCell.h"
#import "CYLMenuResources.h"

NSString *const CYLTagListTitleAccessibilityIdentifier = @"CYLTagListTitle";
NSString *const CYLTagListFoldControlAccessibilityIdentifier = @"CYLTagListFoldControl";
NSString *const CYLTagListItemAccessibilityIdentifier = @"CYLTagListItem";
NSString *const CYLTagCreateItemAccessibilityIdentifier = @"CYLTagCreateItem";
NSString *const CYLTagListMoreButtonAccessibilityIdentifier = @"CYLTagListMoreButton";

static NSString * const kCYLTagListCellIdentifier = @"CYLTagListCell";
static NSString * const kCYLTagListHeaderIdentifier = @"CYLTagListHeader";
static NSString * const kCYLTagListFooterIdentifier = @"CYLTagListFooter";
static NSString * const kCYLTagFoldCellIdentifier = @"CYLTagFoldCell";
/// The More button's touch target in a section header.
static CGFloat const kCYLTagListMoreButtonSize = 44;
static CGFloat const kCYLTagListFooterHeight = 28;
static CGFloat const kCYLTagListHeaderIconSize = 16;

#pragma mark - Header

@interface CYLTagListHeaderView : UICollectionReusableView
@property (nonatomic, strong, readonly) UIImageView *iconView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) CYLTagFoldButton *foldButton;
/// The More button (three dots) at the trailing edge, hidden unless the data source asks for it.
@property (nonatomic, strong, readonly) UIButton *moreButton;
@property (nonatomic, copy, nullable) void (^moreHandler)(NSInteger section);
/// The fold control's size, and whether it is at the leading edge (before the title).
@property (nonatomic, assign) CGSize foldSize;
@property (nonatomic, assign) BOOL foldAtLeadingEdge;
@property (nonatomic, strong, nullable) UIView *accessoryView;
@property (nonatomic, assign) CGFloat horizontalInset;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, copy, nullable) void (^foldHandler)(NSInteger section);
@end

@implementation CYLTagListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.accessibilityTraits = UIAccessibilityTraitHeader;
        _foldButton = [[CYLTagFoldButton alloc] initWithFrame:CGRectZero];
        [_foldButton addTarget:self action:@selector(foldTapped) forControlEvents:UIControlEventTouchUpInside];
        _moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _moreButton.hidden = YES;
        _moreButton.accessibilityIdentifier = CYLTagListMoreButtonAccessibilityIdentifier;
        _moreButton.accessibilityLabel = CYLMenuLocalizedString(@"CYLMenuMoreActions", @"The More button of a section");
        _moreButton.largeContentTitle = _moreButton.accessibilityLabel;
        _moreButton.showsLargeContentViewer = YES;
        [_moreButton addTarget:self action:@selector(moreTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_iconView];
        [self addSubview:_titleLabel];
        [self addSubview:_foldButton];
        [self addSubview:_moreButton];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.accessoryView = nil;
    self.foldHandler = nil;
    self.moreHandler = nil;
}

- (void)moreTapped {
    if (self.moreHandler) {
        self.moreHandler(self.section);
    }
}

- (void)setAccessoryView:(UIView *)accessoryView {
    if (_accessoryView == accessoryView) {
        return;
    }
    if (_accessoryView.superview == self) {
        [_accessoryView removeFromSuperview];
    }
    _accessoryView = accessoryView;
    if (accessoryView) {
        [self addSubview:accessoryView];
    }
    [self setNeedsLayout];
}

- (void)foldTapped {
    if (self.foldHandler) {
        self.foldHandler(self.section);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat trailing = width - self.horizontalInset;
    CGFloat leading = self.horizontalInset;
    if (!self.moreButton.hidden) {
        // A 44 pt touch target whose icon lines up with the trailing inset.
        CGFloat size = MIN(kCYLTagListMoreButtonSize, height > 0 ? MAX(height, 30) : kCYLTagListMoreButtonSize);
        CGFloat iconWidth = self.moreButton.currentImage ? self.moreButton.currentImage.size.width : 22;
        trailing += floor((size - iconWidth) / 2);
        trailing -= size;
        self.moreButton.frame = CGRectMake(trailing, floor((height - size) / 2), size, size);
        trailing -= 4;
    }
    if (!self.foldButton.hidden) {
        CGSize size = CGSizeMake(MIN(self.foldSize.width, width / 2), MIN(self.foldSize.height, height));
        CGFloat y = floor((height - size.height) / 2);
        // The control's own margin lines its content up with the title.
        if (self.foldAtLeadingEdge) {
            self.foldButton.frame = CGRectMake(leading - 6, y, size.width, size.height);
            leading += size.width - 6 + 4;
        } else {
            trailing -= size.width - 6;
            self.foldButton.frame = CGRectMake(trailing, y, size.width, size.height);
            trailing -= 8;
        }
    }
    if (self.accessoryView) {
        CGSize size = [self.accessoryView sizeThatFits:CGSizeMake(width / 2, height)];
        size.width = MIN(size.width, width / 2);
        size.height = MIN(MAX(size.height, 1), height);
        trailing -= size.width;
        self.accessoryView.frame = CGRectMake(trailing, floor((height - size.height) / 2), size.width, size.height);
        trailing -= 8;
    }
    CGFloat x = leading;
    if (self.iconView.image) {
        self.iconView.frame = CGRectMake(x, floor((height - kCYLTagListHeaderIconSize) / 2),
                                         kCYLTagListHeaderIconSize, kCYLTagListHeaderIconSize);
        x += kCYLTagListHeaderIconSize + 8;
    } else {
        self.iconView.frame = CGRectZero;
    }
    self.titleLabel.frame = CGRectMake(x, 0, MAX(0, trailing - x), height);
}

@end

#pragma mark - Footer

@interface CYLTagListFooterView : UICollectionReusableView
/// The fold control below the section (CYLMenuFoldControlPositionBottom), centered.
@property (nonatomic, strong, readonly) CYLTagFoldButton *foldButton;
@property (nonatomic, assign) CGSize foldSize;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, copy, nullable) void (^foldHandler)(NSInteger section);
@end

@implementation CYLTagListFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _foldButton = [[CYLTagFoldButton alloc] initWithFrame:CGRectZero];
        [_foldButton addTarget:self action:@selector(foldTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_foldButton];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.foldHandler = nil;
}

- (void)foldTapped {
    if (self.foldHandler) {
        self.foldHandler(self.section);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = CGSizeMake(MIN(self.foldSize.width, CGRectGetWidth(self.bounds)), MIN(self.foldSize.height, CGRectGetHeight(self.bounds)));
    self.foldButton.frame = CGRectMake(floor((CGRectGetWidth(self.bounds) - size.width) / 2),
                                       floor((CGRectGetHeight(self.bounds) - size.height) / 2), size.width, size.height);
}

@end

#pragma mark - Tag list view

@interface CYLTagListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *titles;
@property (nonatomic, copy) NSArray<NSArray<NSNumber *> *> *itemWidths;
@property (nonatomic, copy) NSArray<NSArray<NSNumber *> *> *rows;
@property (nonatomic, strong) NSMutableSet<NSIndexPath *> *selection;
@property (nonatomic, strong) NSMutableIndexSet *expandedSections;
@property (nonatomic, assign) CGFloat measuredWidth;
/// The collection view's size at the last layout: any change (also the height, e.g. a host's height constraint
/// going from 0 to the content height) lays the tags out again.
@property (nonatomic, assign) CGSize laidOutSize;
@property (nonatomic, assign, readwrite) CGFloat contentHeight;
@property (nonatomic, strong, readwrite) CYLTagButton *titleView;
/// The outlined look of "+ 新建标签" items and the style it was made from.
@property (nonatomic, strong) CYLMenuStyle *createItemStyle;
@property (nonatomic, weak) CYLMenuStyle *createItemBaseStyle;
@end

static NSString * const kCYLTagCreateCellIdentifier = @"CYLTagCreateCell";
/// Space around the list's title.
static CGFloat const kCYLTagListTitleVerticalInset = 10;

@implementation CYLTagListView

@synthesize style = _style;
@synthesize titleStyle = _titleStyle;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self cyl_commonInit];
    }
    return self;
}

- (instancetype)initWithFoldControl:(CYLMenuFoldControl *)foldControl title:(NSString *)title titlePosition:(CYLMenuTitlePosition)titlePosition {
    return [self initWithFoldControl:foldControl title:title titleImage:nil titlePosition:titlePosition];
}

- (instancetype)initWithFoldControl:(CYLMenuFoldControl *)foldControl title:(NSString *)title titleImage:(UIImage *)titleImage
                      titlePosition:(CYLMenuTitlePosition)titlePosition {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.foldControl = foldControl;
        self.titlePosition = titlePosition;
        self.titleImage = titleImage;
        self.title = title;
    }
    return self;
}

- (instancetype)initWithFoldControl:(CYLMenuFoldControl *)foldControl {
    return [self initWithFoldControl:foldControl title:nil titlePosition:CYLMenuTitlePositionTopLeading];
}

+ (instancetype)tagListViewWithFoldPosition:(CYLMenuFoldControlPosition)position content:(CYLMenuFoldControlContent)content {
    return [[self alloc] initWithFoldControl:[CYLMenuFoldControl foldControlWithPosition:position content:content]];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self cyl_commonInit];
    }
    return self;
}

- (void)cyl_commonInit {
    _style = [CYLMenuStyle defaultStyle];
    _selectionMode = CYLMenuSelectionModeSingle;
    _allowsEmptySelection = YES;
    _showsSectionHeaders = YES;
    _defaultVisibleRows = 1;
    _foldControl = [CYLMenuFoldControl noFoldControl];
    _titles = @[];
    _itemWidths = @[];
    _rows = @[];
    _selection = [NSMutableSet set];
    _expandedSections = [NSMutableIndexSet indexSet];
    _measuredWidth = -1;

    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    // Laid out in -layoutSubviews, below the title.
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[CYLTagListCell class] forCellWithReuseIdentifier:kCYLTagListCellIdentifier];
    [_collectionView registerClass:[CYLTagCreateCell class] forCellWithReuseIdentifier:kCYLTagCreateCellIdentifier];
    [_collectionView registerClass:[CYLTagFoldCell class] forCellWithReuseIdentifier:kCYLTagFoldCellIdentifier];
    [_collectionView registerClass:[CYLTagListHeaderView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:kCYLTagListHeaderIdentifier];
    [_collectionView registerClass:[CYLTagListFooterView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:kCYLTagListFooterIdentifier];
    [self addSubview:_collectionView];
    // The list's title: a tag view (icon and/or title, horizontal), not tappable.
    _titleStyle = [[self class] defaultTitleStyle];
    _titleView = [[CYLTagButton alloc] initWithFrame:CGRectZero];
    _titleView.style = _titleStyle;
    _titleView.userInteractionEnabled = NO;
    _titleView.isAccessibilityElement = YES;
    _titleView.accessibilityTraits = UIAccessibilityTraitHeader;
    _titleView.accessibilityIdentifier = CYLTagListTitleAccessibilityIdentifier;
    _titleView.hidden = YES;
    [self addSubview:_titleView];
    [self cyl_applyStyleColors];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cyl_refreshVisibleCells)
                                                 name:UIAccessibilityDarkerSystemColorsStatusDidChangeNotification
                                               object:nil];
}

#pragma mark Properties

- (CYLMenuStyle *)style {
    return _style;
}

- (void)setStyle:(CYLMenuStyle *)style {
    _style = [(style ?: [CYLMenuStyle defaultStyle]) copy];
    [self cyl_applyStyleColors];
    [self cyl_invalidateMeasurements];
}

- (void)cyl_applyStyleColors {
    self.backgroundColor = _style.backgroundColor;
    self.collectionView.backgroundColor = _style.backgroundColor;
}

- (void)setSelectionMode:(CYLMenuSelectionMode)selectionMode {
    _selectionMode = selectionMode;
    if (selectionMode == CYLMenuSelectionModeNone) {
        [self.selection removeAllObjects];
    } else if (selectionMode == CYLMenuSelectionModeSingle) {
        NSMutableIndexSet *seen = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in [self selectedIndexPaths]) {
            if ([seen containsIndex:indexPath.section]) {
                [self.selection removeObject:indexPath];
            }
            [seen addIndex:indexPath.section];
        }
    }
    [self cyl_refreshVisibleCells];
}

- (void)setFoldControl:(CYLMenuFoldControl *)foldControl {
    _foldControl = [(foldControl ?: [CYLMenuFoldControl noFoldControl]) copy];
    switch (_foldControl.position) {
        case CYLMenuFoldControlPositionBottom: _foldStyle = CYLMenuFoldStyleFooterChevron; break;
        case CYLMenuFoldControlPositionTopTrailing:
        case CYLMenuFoldControlPositionTopLeading: _foldStyle = CYLMenuFoldStyleHeaderButton; break;
        case CYLMenuFoldControlPositionNone:
            if (_foldStyle != CYLMenuFoldStyleTruncate) _foldStyle = CYLMenuFoldStyleNone;
            break;
        case CYLMenuFoldControlPositionInline:
            // No legacy fold style matches a fold control among the tags.
            _foldStyle = CYLMenuFoldStyleNone;
            break;
    }
    [self cyl_reloadLayout];
}

+ (CYLMenuStyle *)defaultTitleStyle {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    for (NSNumber *state in @[@(UIControlStateNormal), @(UIControlStateSelected), @(UIControlStateDisabled)]) {
        CYLTagAppearance *appearance = [style appearanceForState:state.unsignedIntegerValue];
        appearance.backgroundColor = [UIColor clearColor];
        appearance.borderWidth = 0;
        appearance.borderColor = nil;
        appearance.margin = 0;
        appearance.font = font;
        appearance.textColor = [UIColor labelColor];
        [style setIconColor:[UIColor labelColor] forState:state.unsignedIntegerValue];
    }
    style.imageSize = CGSizeMake(18, 18);
    style.imageTitleSpacing = 6;
    style.layoutCentered = YES;
    style.adjustsFontForContentSizeCategory = YES;
    style.itemHeight = 24;
    return style;
}

- (BOOL)cyl_hasTitle {
    return self.title.length > 0 || self.titleImage != nil;
}

- (UILabel *)titleLabel {
    return self.titleView.titleLabel;
}

- (void)cyl_titleDidChange {
    self.titleView.hidden = ![self cyl_hasTitle];
    NSString *label = self.title.length > 0 ? self.title : self.titleImage.accessibilityLabel;
    self.titleView.accessibilityLabel = label;
    // An icon-only title without a label is decorative; give the title image an accessibilityLabel to announce it.
    self.titleView.isAccessibilityElement = label.length > 0;
    [self setNeedsLayout];
    [self cyl_updateContentHeight];
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleView.title = title;
    [self cyl_titleDidChange];
}

- (void)setTitleImage:(UIImage *)titleImage {
    _titleImage = titleImage;
    self.titleView.image = titleImage;
    [self cyl_titleDidChange];
}

- (CYLMenuStyle *)titleStyle {
    return _titleStyle;
}

- (void)setTitleStyle:(CYLMenuStyle *)titleStyle {
    _titleStyle = [(titleStyle ?: [[self class] defaultTitleStyle]) copy];
    self.titleView.style = _titleStyle;
    [self cyl_titleDidChange];
}

- (void)setTitlePosition:(CYLMenuTitlePosition)titlePosition {
    _titlePosition = titlePosition;
    [self setNeedsLayout];
}

/// The height of the title area, 0 without a title or an icon.
- (CGFloat)cyl_titleHeightForWidth:(CGFloat)width {
    if (![self cyl_hasTitle]) {
        return 0;
    }
    return ceil([CYLTagButton heightForStyle:self.titleStyle traitCollection:self.traitCollection]) + 2 * kCYLTagListTitleVerticalInset;
}

/// The title view's frame: as wide as its content (no wider than the list), at the leading edge or centered.
- (CGRect)cyl_titleFrameForWidth:(CGFloat)width height:(CGFloat)titleHeight {
    CGFloat inset = self.style.sectionInsets.left;
    CGFloat available = MAX(0, width - 2 * inset);
    CGFloat contentWidth = MIN(available, ceil([CYLTagButton widthForTitle:self.title image:self.titleImage
                                                                     style:self.titleStyle traitCollection:self.traitCollection]));
    BOOL rightToLeft = self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
    CGFloat x = self.titlePosition == CYLMenuTitlePositionTopCenter ? floor((width - contentWidth) / 2)
                                                                    : (rightToLeft ? width - inset - contentWidth : inset);
    return CGRectMake(x, kCYLTagListTitleVerticalInset, contentWidth, titleHeight - 2 * kCYLTagListTitleVerticalInset);
}

- (void)setShowsSectionHeaders:(BOOL)showsSectionHeaders {
    _showsSectionHeaders = showsSectionHeaders;
    [self cyl_reloadLayout];
}

- (void)setFoldStyle:(CYLMenuFoldStyle)foldStyle {
    _foldStyle = foldStyle;
    switch (foldStyle) {
        case CYLMenuFoldStyleHeaderButton:
            _foldControl = [CYLMenuFoldControl foldControlWithPosition:CYLMenuFoldControlPositionTopTrailing content:CYLMenuFoldControlContentTitle];
            break;
        case CYLMenuFoldStyleFooterChevron:
            _foldControl = [CYLMenuFoldControl foldControlWithPosition:CYLMenuFoldControlPositionBottom content:CYLMenuFoldControlContentIcon];
            break;
        default:
            _foldControl = [CYLMenuFoldControl noFoldControl];
            break;
    }

    [self cyl_reloadLayout];
}

- (void)setDefaultVisibleRows:(NSUInteger)defaultVisibleRows {
    _defaultVisibleRows = defaultVisibleRows;
    [self cyl_reloadLayout];
}

- (BOOL)isScrollEnabled {
    return self.collectionView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    self.collectionView.scrollEnabled = scrollEnabled;
    // An embedded, non-scrolling menu is laid out by its host: safe-area insets
    // (for example under a navigation bar in a table header) must not shift it.
    self.collectionView.contentInsetAdjustmentBehavior = scrollEnabled
        ? UIScrollViewContentInsetAdjustmentAutomatic : UIScrollViewContentInsetAdjustmentNever;
    if (!scrollEnabled) {
        [self cyl_resetContentOffset];
    }
}

- (void)cyl_resetContentOffset {
    CGPoint top = CGPointMake(0, -self.collectionView.contentInset.top);
    if (!CGPointEqualToPoint(self.collectionView.contentOffset, top)) {
        self.collectionView.contentOffset = top;
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, self.contentHeight);
}

#pragma mark Data

- (void)reloadMenuData {
    id<CYLMenuDataSource> source = self.menuDataSource;
    NSMutableArray *titles = [NSMutableArray array];
    NSInteger sections = source ? [source numberOfSectionsInMenu] : 0;
    for (NSInteger section = 0; section < sections; section++) {
        NSMutableArray *items = [NSMutableArray array];
        NSInteger count = [source menuNumberOfItemsInSection:section];
        for (NSInteger item = 0; item < count; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSString *title = [source menuTitleForItemAtIndexPath:indexPath] ?: @"";
            // "+ 新建标签": the title is the name to create; the item shows "新建标签：<name>".
            [items addObject:[self cyl_itemTypeAtIndexPath:indexPath] == CYLMenuItemTypeCreate ? [CYLTagCreateCell titleForName:title] : title];
        }
        [titles addObject:items];
    }
    self.titles = titles;
    for (NSIndexPath *indexPath in [self.selection allObjects]) {
        if (![self cyl_isValidIndexPath:indexPath]) {
            [self.selection removeObject:indexPath];
        }
    }
    [self.expandedSections removeIndexesInRange:NSMakeRange((NSUInteger)sections, NSUIntegerMax - (NSUInteger)sections)];
    [self cyl_invalidateMeasurements];
}

- (BOOL)cyl_isValidIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section >= 0 && indexPath.section < (NSInteger)self.titles.count &&
           indexPath.item >= 0 && indexPath.item < (NSInteger)self.titles[indexPath.section].count;
}

- (BOOL)cyl_isEnabledAtIndexPath:(NSIndexPath *)indexPath {
    id<CYLMenuDataSource> source = self.menuDataSource;
    return ![source respondsToSelector:@selector(menuItemIsEnabledAtIndexPath:)] ||
           [source menuItemIsEnabledAtIndexPath:indexPath];
}

- (BOOL)cyl_isExclusiveAtIndexPath:(NSIndexPath *)indexPath {
    id<CYLMenuDataSource> source = self.menuDataSource;
    return [source respondsToSelector:@selector(menuItemIsExclusiveAtIndexPath:)] &&
           [source menuItemIsExclusiveAtIndexPath:indexPath];
}

- (UIImage *)cyl_imageAtIndexPath:(NSIndexPath *)indexPath {
    if ([self cyl_itemTypeAtIndexPath:indexPath] == CYLMenuItemTypeCreate) {
        return [CYLTagCreateCell plusImage];
    }
    id<CYLMenuDataSource> source = self.menuDataSource;
    return [source respondsToSelector:@selector(menuImageForItemAtIndexPath:)]
        ? [source menuImageForItemAtIndexPath:indexPath] : nil;
}

- (CYLMenuItemType)cyl_itemTypeAtIndexPath:(NSIndexPath *)indexPath {
    id<CYLMenuDataSource> source = self.menuDataSource;
    return [source respondsToSelector:@selector(menuItemTypeAtIndexPath:)] ? [source menuItemTypeAtIndexPath:indexPath] : CYLMenuItemTypeTag;
}

- (NSURL *)cyl_animationURLAtIndexPath:(NSIndexPath *)indexPath {
    id<CYLMenuDataSource> source = self.menuDataSource;
    return [source respondsToSelector:@selector(menuAnimationURLForItemAtIndexPath:)]
        ? [source menuAnimationURLForItemAtIndexPath:indexPath] : nil;
}

- (CGFloat)cyl_animationRestingProgressAtIndexPath:(NSIndexPath *)indexPath {
    id<CYLMenuDataSource> source = self.menuDataSource;
    NSNumber *progress = [source respondsToSelector:@selector(menuAnimationRestingProgressForItemAtIndexPath:)]
        ? [source menuAnimationRestingProgressForItemAtIndexPath:indexPath] : nil;
    return [progress isKindOfClass:[NSNumber class]] ? progress.doubleValue : 0;
}

/// The item's own look, or its section's.
- (CYLMenuStyle *)cyl_styleForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<CYLMenuDataSource> source = self.menuDataSource;
    CYLMenuStyle *style = [source respondsToSelector:@selector(menuStyleForItemAtIndexPath:)] ? [source menuStyleForItemAtIndexPath:indexPath] : nil;
    if ([style isKindOfClass:[CYLMenuStyle class]]) {
        return style;
    }
    CYLMenuStyle *sectionStyle = [self cyl_styleForSection:indexPath.section];
    if ([self cyl_itemTypeAtIndexPath:indexPath] != CYLMenuItemTypeCreate) {
        return sectionStyle;
    }
    // "+ 新建标签": outlined, made once per base style.
    if (self.createItemBaseStyle != sectionStyle || !self.createItemStyle) {
        self.createItemStyle = [CYLTagCreateCell styleWithStyle:sectionStyle];
        self.createItemBaseStyle = sectionStyle;
    }
    return self.createItemStyle;
}

- (BOOL)cyl_isSelectableAtIndexPath:(NSIndexPath *)indexPath {
    if ([self cyl_itemTypeAtIndexPath:indexPath] == CYLMenuItemTypeCreate) {
        return NO;
    }
    id<CYLMenuDataSource> source = self.menuDataSource;
    return ![source respondsToSelector:@selector(menuItemIsSelectableAtIndexPath:)] || [source menuItemIsSelectableAtIndexPath:indexPath];
}

/// The section's own look, or the list's style.
- (CYLMenuStyle *)cyl_styleForSection:(NSInteger)section {
    id<CYLMenuDataSource> source = self.menuDataSource;
    CYLMenuStyle *style = [source respondsToSelector:@selector(menuStyleForSection:)] ? [source menuStyleForSection:section] : nil;
    return [style isKindOfClass:[CYLMenuStyle class]] ? style : self.style;
}

- (NSString *)cyl_badgeAtIndexPath:(NSIndexPath *)indexPath {
    id<CYLMenuDataSource> source = self.menuDataSource;
    return [source respondsToSelector:@selector(menuBadgeForItemAtIndexPath:)] ? [source menuBadgeForItemAtIndexPath:indexPath] : nil;
}

- (BOOL)cyl_showsMoreButtonInSection:(NSInteger)section {
    id<CYLMenuDataSource> source = self.menuDataSource;
    return [source respondsToSelector:@selector(menuShowsMoreButtonInSection:)] && [source menuShowsMoreButtonInSection:section];
}

- (UIImage *)cyl_selectedImageAtIndexPath:(NSIndexPath *)indexPath {
    id<CYLMenuDataSource> source = self.menuDataSource;
    return [source respondsToSelector:@selector(menuSelectedImageForItemAtIndexPath:)]
        ? [source menuSelectedImageForItemAtIndexPath:indexPath] : nil;
}

#pragma mark Measurement

- (CGFloat)cyl_itemHeight {
    return [CYLTagButton heightForStyle:self.style traitCollection:self.traitCollection];
}

- (BOOL)cyl_foldControlIsInHeader {
    CYLMenuFoldControlPosition position = self.foldControl.position;
    return position == CYLMenuFoldControlPositionTopTrailing || position == CYLMenuFoldControlPositionTopLeading;
}

- (BOOL)cyl_foldControlIsInFooter {
    return self.foldControl.position == CYLMenuFoldControlPositionBottom;
}

- (BOOL)cyl_foldControlIsInline {
    return self.foldControl.position == CYLMenuFoldControlPositionInline;
}

/// Whether a section shows the inline fold cell (it can fold: some items do not fit in the visible rows).
- (BOOL)cyl_showsInlineFoldCellInSection:(NSInteger)section {
    return [self cyl_foldControlIsInline] && [self canFoldSection:section];
}

/// The inline fold cell comes right after the section's visible items.
- (BOOL)cyl_isInlineFoldCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self cyl_showsInlineFoldCellInSection:indexPath.section] &&
           indexPath.item == [self numberOfVisibleItemsInSection:indexPath.section];
}

/// The inline fold cell's look and size, from the section's item style (the default chevron or CYLMenuStyle.foldChevronImage).
- (CYLMenuFoldControl *)cyl_displayedFoldControl {
    CYLMenuFoldControl *control = self.foldControl;
    if (self.style.foldChevronImage && control.usesDefaultImage) {
        control = [control copy];
        control.image = self.style.foldChevronImage;
    }
    return control;
}

- (CGSize)cyl_inlineFoldSizeInSection:(NSInteger)section expanded:(BOOL)expanded {
    return [CYLTagFoldButton inlineSizeForFoldControl:[self cyl_displayedFoldControl] itemStyle:[self cyl_styleForSection:section]
                                             expanded:expanded traitCollection:self.traitCollection];
}

/// The fold control's size in a state.
- (CGSize)cyl_foldSizeExpanded:(BOOL)expanded {
    return [CYLTagFoldButton sizeForFoldControl:self.foldControl expanded:expanded traitCollection:self.traitCollection];
}

- (CGFloat)cyl_footerHeight {
    return MAX(kCYLTagListFooterHeight, [self cyl_foldSizeExpanded:NO].height);
}

- (CGFloat)cyl_headerHeight {
    // A fold control at the top needs the header, also when section titles are hidden.
    CGFloat foldHeight = [self cyl_foldControlIsInHeader] ? [self cyl_foldSizeExpanded:NO].height : 0;
    if (!self.showsSectionHeaders) {
        return foldHeight;
    }
    UIFont *font = [self.style headerFontForTraitCollection:self.traitCollection];
    return MAX(MAX(self.style.headerHeight, ceil(font.lineHeight) + 12), foldHeight);
}

- (CGFloat)cyl_contentWidthForWidth:(CGFloat)width {
    return MAX(0, width - self.style.sectionInsets.left - self.style.sectionInsets.right);
}

- (NSArray<NSArray<NSNumber *> *> *)cyl_widthsForContentWidth:(CGFloat)contentWidth {
    UITraitCollection *traits = self.traitCollection;
    NSMutableArray *widths = [NSMutableArray arrayWithCapacity:self.titles.count];
    [self.titles enumerateObjectsUsingBlock:^(NSArray<NSString *> *items, NSUInteger section, BOOL *stop) {
        NSMutableArray *sectionWidths = [NSMutableArray arrayWithCapacity:items.count];
        [items enumerateObjectsUsingBlock:^(NSString *title, NSUInteger item, BOOL *itemStop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CYLMenuStyle *style = [self cyl_styleForItemAtIndexPath:indexPath];
            CGSize iconSize = [CYLTagButton iconSizeForImage:[self cyl_imageAtIndexPath:indexPath]
                                                    animated:[self cyl_animationURLAtIndexPath:indexPath] != nil
                                                       style:style];
            CGFloat width = [CYLTagButton widthForTitle:title iconSize:iconSize style:style traitCollection:traits];
            width += [CYLTagListCell badgeSizeForText:[self cyl_badgeAtIndexPath:indexPath] traitCollection:traits].width;
            NSUInteger perRow = [self cyl_styleForSection:(NSInteger)section].numberOfItemsPerRow;
            if (perRow > 0) {
                // The grid: every item the same width, a longer title truncated.
                width = [self cyl_gridItemWidthForContentWidth:contentWidth itemsPerRow:perRow];
            }
            [sectionWidths addObject:@(MIN(width, contentWidth))];
        }];
        [widths addObject:sectionWidths];
    }];
    return widths;
}

/// The width of a grid item: the content width minus the spacing, divided evenly.
- (CGFloat)cyl_gridItemWidthForContentWidth:(CGFloat)contentWidth itemsPerRow:(NSUInteger)itemsPerRow {
    CGFloat spacing = self.style.interitemSpacing;
    return MAX(1, floor((contentWidth - spacing * (CGFloat)(itemsPerRow - 1)) / (CGFloat)itemsPerRow));
}

/// Items per row, computed in a single pass.
- (NSArray<NSArray<NSNumber *> *> *)cyl_rowsForWidths:(NSArray<NSArray<NSNumber *> *> *)widths
                                         contentWidth:(CGFloat)contentWidth {
    CGFloat spacing = self.style.interitemSpacing;
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:widths.count];
    for (NSArray<NSNumber *> *sectionWidths in widths) {
        NSMutableArray *sectionRows = [NSMutableArray array];
        CGFloat used = 0;
        NSUInteger count = 0;
        for (NSNumber *number in sectionWidths) {
            CGFloat width = number.doubleValue;
            if (count > 0 && used + spacing + width > contentWidth) {
                [sectionRows addObject:@(count)];
                used = 0;
                count = 0;
            }
            used += (count > 0 ? spacing : 0) + width;
            count++;
        }
        if (count > 0) {
            [sectionRows addObject:@(count)];
        }
        [rows addObject:sectionRows];
    }
    return rows;
}

- (void)cyl_measureIfNeeded {
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    if (width == self.measuredWidth) {
        return;
    }
    self.measuredWidth = width;
    CGFloat contentWidth = [self cyl_contentWidthForWidth:width];
    self.itemWidths = [self cyl_widthsForContentWidth:contentWidth];
    self.rows = [self cyl_rowsForWidths:self.itemWidths contentWidth:contentWidth];
}

- (void)cyl_invalidateMeasurements {
    self.measuredWidth = -1;
    [self cyl_reloadLayout];
}

- (void)cyl_reloadLayout {
    [self cyl_measureIfNeeded];
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self setNeedsLayout];
    [self cyl_updateContentHeight];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // The list's title, then the sections.
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat titleHeight = [self cyl_titleHeightForWidth:width];
    self.titleView.frame = titleHeight > 0 ? [self cyl_titleFrameForWidth:width height:titleHeight] : CGRectZero;
    CGRect collectionFrame = CGRectMake(0, titleHeight, width, MAX(0, CGRectGetHeight(self.bounds) - titleHeight));
    if (!CGRectEqualToRect(self.collectionView.frame, collectionFrame)) {
        self.collectionView.frame = collectionFrame;
    }
    if (CGRectGetWidth(self.collectionView.bounds) != self.measuredWidth) {
        [self cyl_reloadLayout];
    } else if (!CGSizeEqualToSize(self.collectionView.bounds.size, self.laidOutSize)) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
    self.laidOutSize = self.collectionView.bounds.size;
    if (!self.collectionView.scrollEnabled) {
        [self cyl_resetContentOffset];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (![previousTraitCollection.preferredContentSizeCategory isEqualToString:self.traitCollection.preferredContentSizeCategory] ||
        previousTraitCollection.legibilityWeight != self.traitCollection.legibilityWeight) {
        // Dynamic Type or Bold Text changed: measure every tag again.
        [self cyl_invalidateMeasurements];
    }
}

- (void)cyl_updateContentHeight {
    CGFloat height = 0;
    if (CGRectGetWidth(self.collectionView.bounds) > 0) {
        [self.collectionView layoutIfNeeded];
        // Explicit insets only: safe-area adjustments belong to the host's layout.
        height = ceil(self.collectionView.collectionViewLayout.collectionViewContentSize.height +
                      self.collectionView.contentInset.top + self.collectionView.contentInset.bottom) +
                 [self cyl_titleHeightForWidth:CGRectGetWidth(self.bounds)];
    } else {
        height = [self heightThatFitsWidth:0];
    }
    if (fabs(height - self.contentHeight) < 0.5) {
        return;
    }
    self.contentHeight = height;
    [self invalidateIntrinsicContentSize];
    if ([self.menuDelegate respondsToSelector:@selector(menu:didChangeContentHeight:)]) {
        [self.menuDelegate menu:self didChangeContentHeight:height];
    }
}

- (CGFloat)heightThatFitsWidth:(CGFloat)width {
    CGFloat contentWidth = [self cyl_contentWidthForWidth:width];
    NSArray *widths = (width == self.measuredWidth) ? self.itemWidths : [self cyl_widthsForContentWidth:contentWidth];
    NSArray<NSArray<NSNumber *> *> *rows = (width == self.measuredWidth) ? self.rows : [self cyl_rowsForWidths:widths contentWidth:contentWidth];
    CGFloat itemHeight = [self cyl_itemHeight];
    CGFloat headerHeight = [self cyl_headerHeight];
    UIEdgeInsets insets = self.style.sectionInsets;
    CGFloat height = 0;
    for (NSUInteger section = 0; section < rows.count; section++) {
        NSUInteger rowCount = rows[section].count;
        BOOL foldable = [self cyl_canFoldRowCount:rowCount];
        if (foldable && ![self.expandedSections containsIndex:section]) {
            rowCount = self.defaultVisibleRows;
        } else if (foldable && [self cyl_foldControlIsInline]) {
            // Expanded, the inline fold cell follows the last item and may start a row of its own.
            NSMutableArray *sectionWidths = [widths[section] mutableCopy];
            [sectionWidths addObject:@([self cyl_inlineFoldSizeInSection:(NSInteger)section expanded:YES].width)];
            rowCount = [self cyl_rowsForWidths:@[sectionWidths] contentWidth:contentWidth].firstObject.count;
        }
        height += headerHeight + insets.top + insets.bottom;
        if (rowCount > 0) {
            height += rowCount * itemHeight + (rowCount - 1) * self.style.lineSpacing;
        }
        if (foldable && [self cyl_foldControlIsInFooter]) {
            height += [self cyl_footerHeight];
        }
    }
    return ceil(height) + [self cyl_titleHeightForWidth:width];
}

#pragma mark Scrolling

- (void)scrollToSection:(NSInteger)section animated:(BOOL)animated {
    UICollectionView *collection = self.collectionView;
    if (section < 0 || section >= [collection numberOfSections]) {
        return;
    }
    [self layoutIfNeeded];
    [collection layoutIfNeeded];
    UICollectionViewLayout *layout = collection.collectionViewLayout;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGFloat top = CGFLOAT_MAX;
    UICollectionViewLayoutAttributes *header = [layout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
    if (header && CGRectGetHeight(header.frame) > 0) {
        top = CGRectGetMinY(header.frame);
    } else if ([collection numberOfItemsInSection:section] > 0) {
        top = CGRectGetMinY([layout layoutAttributesForItemAtIndexPath:indexPath].frame) - self.style.sectionInsets.top;
    }
    if (top == CGFLOAT_MAX) {
        return;
    }
    UIEdgeInsets inset = collection.adjustedContentInset;
    CGFloat maxOffset = MAX(-inset.top, layout.collectionViewContentSize.height + inset.bottom - CGRectGetHeight(collection.bounds));
    [collection setContentOffset:CGPointMake(collection.contentOffset.x, MIN(MAX(top - inset.top, -inset.top), maxOffset)) animated:animated];
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (![self cyl_isValidIndexPath:indexPath] || indexPath.item >= [self numberOfVisibleItemsInSection:indexPath.section]) {
        return;
    }
    UICollectionView *collection = self.collectionView;
    [self layoutIfNeeded];
    [collection layoutIfNeeded];
    UICollectionViewLayout *layout = collection.collectionViewLayout;
    UICollectionViewLayoutAttributes *attributes = [layout layoutAttributesForItemAtIndexPath:indexPath];
    if (!attributes) {
        return;
    }
    UIEdgeInsets inset = collection.adjustedContentInset;
    CGFloat visibleHeight = CGRectGetHeight(collection.bounds) - inset.top - inset.bottom;
    CGFloat target = CGRectGetMidY(attributes.frame) - visibleHeight / 2 - inset.top;
    CGFloat maxOffset = MAX(-inset.top, layout.collectionViewContentSize.height + inset.bottom - CGRectGetHeight(collection.bounds));
    [collection setContentOffset:CGPointMake(collection.contentOffset.x, MIN(MAX(target, -inset.top), maxOffset)) animated:animated];
}

#pragma mark Folding

- (BOOL)cyl_canFoldRowCount:(NSUInteger)rowCount {
    BOOL folds = self.foldStyle == CYLMenuFoldStyleTruncate || self.foldControl.position != CYLMenuFoldControlPositionNone;
    return folds && self.defaultVisibleRows > 0 && rowCount > self.defaultVisibleRows;
}

- (BOOL)canFoldSection:(NSInteger)section {
    [self cyl_measureIfNeeded];
    return section >= 0 && section < (NSInteger)self.rows.count && [self cyl_canFoldRowCount:self.rows[section].count];
}

- (NSUInteger)numberOfRowsInSection:(NSInteger)section {
    [self cyl_measureIfNeeded];
    return (section >= 0 && section < (NSInteger)self.rows.count) ? self.rows[section].count : 0;
}

- (BOOL)isSectionExpanded:(NSInteger)section {
    return [self.expandedSections containsIndex:(NSUInteger)section];
}

- (NSInteger)numberOfVisibleItemsInSection:(NSInteger)section {
    [self cyl_measureIfNeeded];
    if (section < 0 || section >= (NSInteger)self.titles.count) {
        return 0;
    }
    NSInteger total = self.titles[section].count;
    if (section >= (NSInteger)self.rows.count || ![self canFoldSection:section] || [self isSectionExpanded:section]) {
        return total;
    }
    NSInteger visible = 0;
    NSArray<NSNumber *> *sectionRows = self.rows[section];
    NSUInteger lastRowCount = 0;
    for (NSUInteger row = 0; row < self.defaultVisibleRows && row < sectionRows.count; row++) {
        lastRowCount = (NSUInteger)sectionRows[row].integerValue;
        visible += (NSInteger)lastRowCount;
    }
    visible = MIN(visible, total);
    if ([self cyl_foldControlIsInline] && lastRowCount > 0 && section < (NSInteger)self.itemWidths.count) {
        // The inline fold cell ends the last visible row: hide the items it needs the room of.
        NSArray<NSNumber *> *widths = self.itemWidths[section];
        CGFloat spacing = self.style.interitemSpacing;
        CGFloat contentWidth = [self cyl_contentWidthForWidth:self.measuredWidth];
        CGFloat foldWidth = [self cyl_inlineFoldSizeInSection:section expanded:NO].width;
        CGFloat used = 0;
        for (NSInteger item = visible - (NSInteger)lastRowCount; item < visible; item++) {
            used += (item > visible - (NSInteger)lastRowCount ? spacing : 0) + widths[item].doubleValue;
        }
        while (lastRowCount > 1 && used + spacing + foldWidth > contentWidth) {
            used -= widths[visible - 1].doubleValue + spacing;
            lastRowCount--;
            visible--;
        }
    }
    return visible;
}

- (void)setExpanded:(BOOL)expanded forSection:(NSInteger)section animated:(BOOL)animated {
    if (section < 0 || section >= (NSInteger)self.titles.count || expanded == [self isSectionExpanded:section]) {
        return;
    }
    if ([self cyl_foldControlIsInline]) {
        [self cyl_setInlineExpanded:expanded forSection:section animated:animated];
        return;
    }
    // Insert or delete only the rows beyond the folded ones, so the header and
    // footer stay in place and their fold control can animate.
    NSInteger before = [self.collectionView numberOfItemsInSection:section];
    if (expanded) {
        [self.expandedSections addIndex:(NSUInteger)section];
    } else {
        [self.expandedSections removeIndex:(NSUInteger)section];
    }
    NSInteger after = [self numberOfVisibleItemsInSection:section];
    NSMutableArray<NSIndexPath *> *changed = [NSMutableArray array];
    for (NSInteger item = MIN(before, after); item < MAX(before, after); item++) {
        [changed addObject:[NSIndexPath indexPathForItem:item inSection:section]];
    }
    void (^update)(void) = ^{
        if (after > before) {
            [self.collectionView insertItemsAtIndexPaths:changed];
        } else if (after < before) {
            [self.collectionView deleteItemsAtIndexPaths:changed];
        }
    };
    // Reduce Motion: change the content without animating it.
    BOOL animate = animated && self.window && !UIAccessibilityIsReduceMotionEnabled();
    if (animate) {
        [self.collectionView performBatchUpdates:update completion:nil];
    } else {
        [UIView performWithoutAnimation:^{
            [self.collectionView performBatchUpdates:update completion:nil];
            [self.collectionView layoutIfNeeded];
        }];
    }
    [self cyl_updateFoldControlsInSection:section animated:animate];
    [self cyl_updateContentHeight];
    [self cyl_moveAccessibilityFocusToFoldControlInSection:section];
    if ([self.menuDelegate respondsToSelector:@selector(menu:didChangeExpanded:inSection:)]) {
        [self.menuDelegate menu:self didChangeExpanded:expanded inSection:section];
    }
}

/// The inline fold cell moves with the items: reload the section (the chevron turns in its new place).
- (void)cyl_setInlineExpanded:(BOOL)expanded forSection:(NSInteger)section animated:(BOOL)animated {
    if (expanded) {
        [self.expandedSections addIndex:(NSUInteger)section];
    } else {
        [self.expandedSections removeIndex:(NSUInteger)section];
    }
    BOOL animate = animated && self.window && !UIAccessibilityIsReduceMotionEnabled();
    void (^update)(void) = ^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger)section]];
    };
    if (animate) {
        [self.collectionView performBatchUpdates:update completion:nil];
    } else {
        [UIView performWithoutAnimation:^{
            [self.collectionView performBatchUpdates:update completion:nil];
            [self.collectionView layoutIfNeeded];
        }];
    }
    [self cyl_updateContentHeight];
    [self cyl_moveAccessibilityFocusToFoldControlInSection:section];
    if ([self.menuDelegate respondsToSelector:@selector(menu:didChangeExpanded:inSection:)]) {
        [self.menuDelegate menu:self didChangeExpanded:expanded inSection:section];
    }
}

/// VoiceOver keeps its place after the section changes size: focus the section's fold control.
- (void)cyl_moveAccessibilityFocusToFoldControlInSection:(NSInteger)section {
    if (!UIAccessibilityIsVoiceOverRunning()) {
        return;
    }
    [self.collectionView layoutIfNeeded];
    UIView *control = [self cyl_foldControlInSection:section];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, control);
}

/// Updates the visible fold controls of a section without reloading it.
- (void)cyl_updateFoldControlsInSection:(NSInteger)section animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    BOOL expanded = [self isSectionExpanded:section];
    CYLTagListFooterView *footer = (CYLTagListFooterView *)[self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
    if ([footer isKindOfClass:[CYLTagListFooterView class]]) {
        [self cyl_configureFoldButton:footer.foldButton section:section expanded:expanded animated:animated];
        footer.foldSize = [self cyl_foldSizeExpanded:expanded];
        [footer setNeedsLayout];
    }
    CYLTagListHeaderView *header = (CYLTagListHeaderView *)[self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
    if ([header isKindOfClass:[CYLTagListHeaderView class]] && !header.foldButton.hidden) {
        [self cyl_configureFoldButton:header.foldButton section:section expanded:expanded animated:animated];
        header.foldSize = [self cyl_foldSizeExpanded:expanded];
        [header setNeedsLayout];
    }
}

/// Shows the fold control in a state, with its VoiceOver label ("<section> 更多/收起") and value.
- (void)cyl_configureFoldButton:(CYLTagFoldButton *)button section:(NSInteger)section expanded:(BOOL)expanded animated:(BOOL)animated {
    CYLMenuFoldControl *control = self.foldControl;
    // CYLMenuStyle.foldChevronImage replaces the default chevron, as before fold controls.
    if (self.style.foldChevronImage && control.usesDefaultImage) {
        control = [control copy];
        control.image = self.style.foldChevronImage;
    }
    [button applyFoldControl:control color:self.style.foldControlColor expanded:expanded animated:animated];
    button.accessibilityLabel = [self cyl_foldAccessibilityLabelForSection:section];
    button.accessibilityHint = expanded ? nil : CYLMenuLocalizedString(@"CYLMenuExpandHint", @"Shows every tag");
}

- (nullable UIView *)cyl_foldControlInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    if ([self cyl_showsInlineFoldCellInSection:section]) {
        NSIndexPath *foldPath = [NSIndexPath indexPathForItem:[self numberOfVisibleItemsInSection:section] inSection:section];
        return [self.collectionView cellForItemAtIndexPath:foldPath];
    }
    if ([self cyl_foldControlIsInFooter]) {
        CYLTagListFooterView *footer = (CYLTagListFooterView *)[self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
        return footer.foldButton;
    }
    if ([self cyl_foldControlIsInHeader]) {
        CYLTagListHeaderView *header = (CYLTagListHeaderView *)[self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        return header.foldButton.hidden ? nil : header.foldButton;
    }
    return nil;
}

/// "<section title> <expand or collapse title>", so a fold control says which section it changes.
- (NSString *)cyl_foldAccessibilityLabelForSection:(NSInteger)section {
    BOOL titled = self.foldControl.position != CYLMenuFoldControlPositionNone;
    NSString *action = [self isSectionExpanded:section] ? (titled ? self.foldControl.collapseTitle : self.style.collapseTitle)
                                                        : (titled ? self.foldControl.title : self.style.expandTitle);
    NSString *title = [self.menuDataSource menuTitleForSection:section];
    return title.length > 0 ? [NSString stringWithFormat:@"%@ %@", title, action] : action;
}

- (void)cyl_toggleSection:(NSInteger)section {
    [self setExpanded:![self isSectionExpanded:section] forSection:section animated:YES];
}

#pragma mark Selection

- (NSArray<NSIndexPath *> *)selectedIndexPaths {
    return [[self.selection allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)setSelectedIndexPaths:(NSArray<NSIndexPath *> *)selectedIndexPaths {
    [self.selection removeAllObjects];
    if (self.selectionMode != CYLMenuSelectionModeNone) {
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            if (![self cyl_isValidIndexPath:indexPath]) {
                [NSException raise:NSInvalidArgumentException format:@"Invalid menu selection: %@", indexPath];
            }
            if ([self cyl_isSelectableAtIndexPath:indexPath]) {
                [self cyl_applySelectionOfIndexPath:indexPath removed:nil];
            }
        }
    }
    [self cyl_refreshVisibleCells];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectionMode == CYLMenuSelectionModeNone || ![self cyl_isValidIndexPath:indexPath] ||
        ![self cyl_isSelectableAtIndexPath:indexPath]) {
        return;
    }
    [self cyl_applySelectionOfIndexPath:indexPath removed:nil];
    [self cyl_refreshVisibleCells];
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selection removeObject:indexPath];
    [self cyl_refreshVisibleCells];
}

- (void)deselectAllItems {
    [self.selection removeAllObjects];
    [self cyl_refreshVisibleCells];
}

/// Adds `indexPath` and removes items that the selection mode excludes.
- (void)cyl_applySelectionOfIndexPath:(NSIndexPath *)indexPath removed:(NSMutableArray<NSIndexPath *> *)removed {
    BOOL exclusive = [self cyl_isExclusiveAtIndexPath:indexPath];
    for (NSIndexPath *other in [self.selection allObjects]) {
        if (other.section != indexPath.section || [other isEqual:indexPath]) {
            continue;
        }
        BOOL remove = self.selectionMode == CYLMenuSelectionModeSingle ||
                      exclusive || [self cyl_isExclusiveAtIndexPath:other];
        if (remove) {
            [self.selection removeObject:other];
            [removed addObject:other];
        }
    }
    [self.selection addObject:indexPath];
}

- (NSUInteger)cyl_selectedCountInSection:(NSInteger)section {
    NSUInteger count = 0;
    for (NSIndexPath *indexPath in self.selection) {
        if (indexPath.section == section) count++;
    }
    return count;
}

- (void)cyl_handleTapAtIndexPath:(NSIndexPath *)indexPath {
    if (![self cyl_isEnabledAtIndexPath:indexPath]) {
        return;
    }
    id<CYLMenuDelegate> delegate = self.menuDelegate;
    if ([delegate respondsToSelector:@selector(menu:shouldSelectItemAtIndexPath:)] &&
        ![delegate menu:self shouldSelectItemAtIndexPath:indexPath]) {
        return;
    }
    if ([self cyl_itemTypeAtIndexPath:indexPath] == CYLMenuItemTypeCreate &&
        [delegate respondsToSelector:@selector(menu:didRequestNewItemWithName:atIndexPath:)]) {
        NSString *name = [self.menuDataSource menuTitleForItemAtIndexPath:indexPath] ?: @"";
        [delegate menu:self didRequestNewItemWithName:name atIndexPath:indexPath];
        return;
    }
    NSMutableArray<NSIndexPath *> *removed = [NSMutableArray array];
    BOOL selected = NO;
    BOOL selectable = [self cyl_isSelectableAtIndexPath:indexPath];
    switch (selectable ? self.selectionMode : CYLMenuSelectionModeNone) {
        case CYLMenuSelectionModeNone:
            selected = YES;
            break;
        case CYLMenuSelectionModeSingle:
        case CYLMenuSelectionModeMultiple:
            if ([self.selection containsObject:indexPath]) {
                if (self.allowsEmptySelection || [self cyl_selectedCountInSection:indexPath.section] > 1) {
                    [self.selection removeObject:indexPath];
                    [removed addObject:indexPath];
                }
            } else {
                [self cyl_applySelectionOfIndexPath:indexPath removed:removed];
                selected = YES;
            }
            break;
    }
    [self cyl_refreshVisibleCells];
    if (selected) {
        // A tapped tag plays its animated icon, as a tapped tab does.
        CYLTagListCell *cell = (CYLTagListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isKindOfClass:[CYLTagListCell class]]) {
            [cell.button playAnimation];
        }
    }
    if ([delegate respondsToSelector:@selector(menu:didDeselectItemAtIndexPath:)]) {
        for (NSIndexPath *path in removed) {
            [delegate menu:self didDeselectItemAtIndexPath:path];
        }
    }
    if (selected && [delegate respondsToSelector:@selector(menu:didSelectItemAtIndexPath:)]) {
        [delegate menu:self didSelectItemAtIndexPath:indexPath];
    }
    BOOL changed = removed.count > 0 || (selected && selectable && self.selectionMode != CYLMenuSelectionModeNone);
    if (changed && [delegate respondsToSelector:@selector(menu:didChangeSelectedItems:)]) {
        [delegate menu:self didChangeSelectedItems:self.selectedIndexPaths];
    }
}

- (void)cyl_refreshVisibleCells {
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        CYLTagListCell *cell = (CYLTagListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self cyl_configureCell:cell atIndexPath:indexPath];
    }
}

- (void)cyl_configureFoldCell:(CYLTagFoldCell *)cell section:(NSInteger)section animated:(BOOL)animated {
    BOOL expanded = [self isSectionExpanded:section];
    [cell configureWithFoldControl:[self cyl_displayedFoldControl] itemStyle:[self cyl_styleForSection:section]
                          expanded:expanded animated:animated];
    cell.accessibilityLabel = [self cyl_foldAccessibilityLabelForSection:section];
    cell.accessibilityHint = expanded ? nil : CYLMenuLocalizedString(@"CYLMenuExpandHint", @"Shows every tag");
}

- (void)cyl_configureCell:(CYLTagListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[CYLTagFoldCell class]]) {
        [self cyl_configureFoldCell:(CYLTagFoldCell *)cell section:indexPath.section animated:NO];
        return;
    }
    if (![self cyl_isValidIndexPath:indexPath]) {
        return;
    }
    if ([cell isKindOfClass:[CYLTagCreateCell class]]) {
        [(CYLTagCreateCell *)cell configureWithName:[self.menuDataSource menuTitleForItemAtIndexPath:indexPath]
                                              style:[self cyl_styleForItemAtIndexPath:indexPath]
                                            enabled:[self cyl_isEnabledAtIndexPath:indexPath]];
        return;
    }
    [cell configureWithTitle:self.titles[indexPath.section][indexPath.item]
                       image:[self cyl_imageAtIndexPath:indexPath]
               selectedImage:[self cyl_selectedImageAtIndexPath:indexPath]
                animationURL:[self cyl_animationURLAtIndexPath:indexPath]
                       style:[self cyl_styleForItemAtIndexPath:indexPath]
                    selected:[self.selection containsObject:indexPath]
                     enabled:[self cyl_isEnabledAtIndexPath:indexPath]];
    cell.button.animationRestingProgress = [self cyl_animationRestingProgressAtIndexPath:indexPath];
    [cell setBadgeText:[self cyl_badgeAtIndexPath:indexPath] style:[self cyl_styleForItemAtIndexPath:indexPath]];
    if ([self.menuDataSource respondsToSelector:@selector(menuAccessibilityHintForItemAtIndexPath:)]) {
        cell.accessibilityHint = [self.menuDataSource menuAccessibilityHintForItemAtIndexPath:indexPath];
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.titles.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // The inline fold cell follows the visible items.
    return [self numberOfVisibleItemsInSection:section] + ([self cyl_showsInlineFoldCellInSection:section] ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self cyl_isInlineFoldCellAtIndexPath:indexPath]) {
        CYLTagFoldCell *foldCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCYLTagFoldCellIdentifier forIndexPath:indexPath];
        [self cyl_configureFoldCell:foldCell section:indexPath.section animated:NO];
        return foldCell;
    }
    NSString *identifier = [self cyl_itemTypeAtIndexPath:indexPath] == CYLMenuItemTypeCreate ? kCYLTagCreateCellIdentifier : kCYLTagListCellIdentifier;
    CYLTagListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [self cyl_configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    __weak __typeof(self) weakSelf = self;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        CYLTagListFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                          withReuseIdentifier:kCYLTagListFooterIdentifier
                                                                                 forIndexPath:indexPath];
        footer.section = section;
        BOOL expanded = [self isSectionExpanded:section];
        [self cyl_configureFoldButton:footer.foldButton section:section expanded:expanded animated:NO];
        footer.foldSize = [self cyl_foldSizeExpanded:expanded];
        [footer setNeedsLayout];
        footer.foldHandler = ^(NSInteger tappedSection) {
            [weakSelf cyl_toggleSection:tappedSection];
        };
        return footer;
    }
    CYLTagListHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                      withReuseIdentifier:kCYLTagListHeaderIdentifier
                                                                             forIndexPath:indexPath];
    id<CYLMenuDataSource> source = self.menuDataSource;
    header.section = section;
    header.horizontalInset = self.style.headerHorizontalInset;
    header.titleLabel.text = [source menuTitleForSection:section];
    header.titleLabel.font = [self.style headerFontForTraitCollection:self.traitCollection];
    header.titleLabel.textColor = self.style.headerTextColor;
    header.iconView.image = [source respondsToSelector:@selector(menuImageForSection:)] ? [source menuImageForSection:section] : nil;
    header.accessoryView = [source respondsToSelector:@selector(menuAccessoryViewForSection:)] ? [source menuAccessoryViewForSection:section] : nil;
    BOOL showsFoldButton = [self cyl_foldControlIsInHeader] && [self canFoldSection:section];
    header.foldButton.hidden = !showsFoldButton;
    header.foldAtLeadingEdge = self.foldControl.position == CYLMenuFoldControlPositionTopLeading;
    if (showsFoldButton) {
        BOOL expanded = [self isSectionExpanded:section];
        [self cyl_configureFoldButton:header.foldButton section:section expanded:expanded animated:NO];
        header.foldSize = [self cyl_foldSizeExpanded:expanded];
    }
    // Section titles hidden: the header only holds the fold control.
    header.titleLabel.hidden = !self.showsSectionHeaders;
    header.iconView.hidden = !self.showsSectionHeaders;
    header.foldHandler = ^(NSInteger tappedSection) {
        [weakSelf cyl_toggleSection:tappedSection];
    };
    // The More button: the bundle's three dots (or the style's image), the host's action.
    BOOL showsMore = [self cyl_showsMoreButtonInSection:section];
    header.moreButton.hidden = !showsMore;
    if (showsMore) {
        UIImage *image = self.style.moreButtonImage ?: CYLMenuImage(@"cyl_more") ?: [UIImage systemImageNamed:@"ellipsis"];
        [header.moreButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        header.moreButton.tintColor = self.style.moreButtonColor;
        NSString *title = [source menuTitleForSection:section];
        NSString *more = CYLMenuLocalizedString(@"CYLMenuMoreActions", @"The More button of a section");
        header.moreButton.accessibilityLabel = title.length > 0 ? [NSString stringWithFormat:@"%@ %@", title, more] : more;
        header.moreHandler = ^(NSInteger tappedSection) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            id<CYLMenuDelegate> delegate = strongSelf.menuDelegate;
            if ([delegate respondsToSelector:@selector(menu:didTapMoreButtonInSection:)]) {
                [delegate menu:strongSelf didTapMoreButtonInSection:tappedSection];
            }
        };
    }
    [header setNeedsLayout];
    return header;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([self cyl_isInlineFoldCellAtIndexPath:indexPath]) {
        // The inline fold cell's built-in action.
        [self cyl_toggleSection:indexPath.section];
        return;
    }
    [self cyl_handleTapAtIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self cyl_measureIfNeeded];
    if ([self cyl_isInlineFoldCellAtIndexPath:indexPath]) {
        return [self cyl_inlineFoldSizeInSection:indexPath.section expanded:[self isSectionExpanded:indexPath.section]];
    }
    CGFloat width = 0;
    if (indexPath.section < (NSInteger)self.itemWidths.count &&
        indexPath.item < (NSInteger)self.itemWidths[indexPath.section].count) {
        width = self.itemWidths[indexPath.section][indexPath.item].doubleValue;
    }
    return CGSizeMake(MAX(1, width), [self cyl_itemHeight]);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return self.style.sectionInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.style.interitemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.style.lineSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat height = [self cyl_headerHeight];
    return height > 0 ? CGSizeMake(CGRectGetWidth(collectionView.bounds), height) : CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    BOOL showsControl = [self cyl_foldControlIsInFooter] && [self canFoldSection:section];
    return showsControl ? CGSizeMake(CGRectGetWidth(collectionView.bounds), [self cyl_footerHeight]) : CGSizeZero;
}

@end

//
//  CYLTagListView.m
//  CollectionViewClassifyMenu
//

#import "CYLTagListView.h"
#import "CYLCollectionViewLeftAlignedLayout.h"
#import "CYLParameterConfiguration.h"

static NSString * const kCYLTagListCellIdentifier = @"CYLTagListCell";
static NSString * const kCYLTagListHeaderIdentifier = @"CYLTagListHeader";
static NSString * const kCYLTagListFooterIdentifier = @"CYLTagListFooter";
static CGFloat const kCYLTagListFooterHeight = 28;
static CGFloat const kCYLTagListHeaderIconSize = 16;

#pragma mark - Cell

@interface CYLTagListCell : UICollectionViewCell
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UIImageView *iconView;
@property (nonatomic, assign) CGSize iconSize;
@property (nonatomic, assign) CGFloat iconSpacing;
@property (nonatomic, assign) CGFloat horizontalPadding;
@end

@implementation CYLTagListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_iconView];
        [self.contentView addSubview:_titleLabel];
        self.contentView.layer.masksToBounds = YES;
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    BOOL hasIcon = self.iconView.image != nil;
    CGFloat iconWidth = hasIcon ? self.iconSize.width + self.iconSpacing : 0;
    CGFloat available = MAX(0, CGRectGetWidth(bounds) - 2 * self.horizontalPadding - iconWidth);
    CGFloat titleWidth = MIN(available, ceil([self.titleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(bounds))].width));
    CGFloat x = floor((CGRectGetWidth(bounds) - iconWidth - titleWidth) / 2);
    if (hasIcon) {
        self.iconView.frame = CGRectMake(x, floor((CGRectGetHeight(bounds) - self.iconSize.height) / 2),
                                         self.iconSize.width, self.iconSize.height);
        x += iconWidth;
    } else {
        self.iconView.frame = CGRectZero;
    }
    self.titleLabel.frame = CGRectMake(x, 0, titleWidth, CGRectGetHeight(bounds));
    CGFloat radius = self.contentView.layer.cornerRadius;
    if (radius > CGRectGetHeight(bounds) / 2) {
        self.contentView.layer.cornerRadius = CGRectGetHeight(bounds) / 2;
    }
}

- (void)configureWithTitle:(NSString *)title
                     image:(UIImage *)image
                      font:(UIFont *)font
                     style:(CYLMenuStyle *)style
                  selected:(BOOL)selected
                   enabled:(BOOL)enabled {
    self.titleLabel.text = title;
    self.titleLabel.font = font;
    self.titleLabel.textColor = !enabled ? style.disabledTextColor
                              : (selected ? style.selectedTextColor : style.textColor);
    self.iconView.image = image;
    self.iconView.alpha = enabled ? 1 : 0.4;
    self.iconSize = style.imageSize;
    self.iconSpacing = style.imageTitleSpacing;
    self.horizontalPadding = style.itemHorizontalPadding;
    CALayer *layer = self.contentView.layer;
    layer.backgroundColor = (selected ? style.selectedItemBackgroundColor : style.itemBackgroundColor).CGColor;
    layer.borderColor = (selected ? style.selectedBorderColor : style.borderColor).CGColor;
    layer.borderWidth = style.borderWidth;
    layer.cornerRadius = style.cornerRadius < 0 ? CGFLOAT_MAX : style.cornerRadius;
    self.accessibilityLabel = title;
    UIAccessibilityTraits traits = UIAccessibilityTraitButton;
    if (selected) traits |= UIAccessibilityTraitSelected;
    if (!enabled) traits |= UIAccessibilityTraitNotEnabled;
    self.accessibilityTraits = traits;
    [self setNeedsLayout];
}

@end

#pragma mark - Header

@interface CYLTagListHeaderView : UICollectionReusableView
@property (nonatomic, strong, readonly) UIImageView *iconView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UIButton *foldButton;
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
        _foldButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _foldButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_foldButton addTarget:self action:@selector(foldTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_iconView];
        [self addSubview:_titleLabel];
        [self addSubview:_foldButton];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.accessoryView = nil;
    self.foldHandler = nil;
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
    if (!self.foldButton.hidden) {
        CGSize size = [self.foldButton sizeThatFits:CGSizeMake(width / 3, height)];
        trailing -= size.width;
        self.foldButton.frame = CGRectMake(trailing, 0, size.width, height);
        trailing -= 8;
    }
    if (self.accessoryView) {
        CGSize size = [self.accessoryView sizeThatFits:CGSizeMake(width / 2, height)];
        size.width = MIN(size.width, width / 2);
        size.height = MIN(MAX(size.height, 1), height);
        trailing -= size.width;
        self.accessoryView.frame = CGRectMake(trailing, floor((height - size.height) / 2), size.width, size.height);
        trailing -= 8;
    }
    CGFloat x = self.horizontalInset;
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
@property (nonatomic, strong, readonly) UIButton *chevronButton;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, copy, nullable) void (^foldHandler)(NSInteger section);
@end

@implementation CYLTagListFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _chevronButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _chevronButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _chevronButton.frame = self.bounds;
        [_chevronButton addTarget:self action:@selector(foldTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_chevronButton];
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
@property (nonatomic, assign, readwrite) CGFloat contentHeight;
@end

@implementation CYLTagListView

@synthesize style = _style;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self cyl_commonInit];
    }
    return self;
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
    _titles = @[];
    _itemWidths = @[];
    _rows = @[];
    _selection = [NSMutableSet set];
    _expandedSections = [NSMutableIndexSet indexSet];
    _measuredWidth = -1;

    CYLCollectionViewLeftAlignedLayout *layout = [[CYLCollectionViewLeftAlignedLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[CYLTagListCell class] forCellWithReuseIdentifier:kCYLTagListCellIdentifier];
    [_collectionView registerClass:[CYLTagListHeaderView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:kCYLTagListHeaderIdentifier];
    [_collectionView registerClass:[CYLTagListFooterView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:kCYLTagListFooterIdentifier];
    [self addSubview:_collectionView];
    [self cyl_applyStyleColors];
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

- (void)setShowsSectionHeaders:(BOOL)showsSectionHeaders {
    _showsSectionHeaders = showsSectionHeaders;
    [self cyl_reloadLayout];
}

- (void)setFoldStyle:(CYLMenuFoldStyle)foldStyle {
    _foldStyle = foldStyle;
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
            [items addObject:[source menuTitleForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]] ?: @""];
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
    id<CYLMenuDataSource> source = self.menuDataSource;
    return [source respondsToSelector:@selector(menuImageForItemAtIndexPath:)]
        ? [source menuImageForItemAtIndexPath:indexPath] : nil;
}

#pragma mark Measurement

- (UIFont *)cyl_itemFont {
    return [self.style itemFontForTraitCollection:self.traitCollection];
}

- (CGFloat)cyl_itemHeight {
    return CYLTagHeightForFont([self cyl_itemFont], self.style.itemHeight);
}

- (CGFloat)cyl_headerHeight {
    if (!self.showsSectionHeaders) {
        return 0;
    }
    UIFont *font = [self.style headerFontForTraitCollection:self.traitCollection];
    return MAX(self.style.headerHeight, ceil(font.lineHeight) + 12);
}

- (CGFloat)cyl_contentWidthForWidth:(CGFloat)width {
    return MAX(0, width - self.style.sectionInsets.left - self.style.sectionInsets.right);
}

- (NSArray<NSArray<NSNumber *> *> *)cyl_widthsForContentWidth:(CGFloat)contentWidth {
    UIFont *font = [self cyl_itemFont];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CYLMenuStyle *style = self.style;
    NSMutableArray *widths = [NSMutableArray arrayWithCapacity:self.titles.count];
    [self.titles enumerateObjectsUsingBlock:^(NSArray<NSString *> *items, NSUInteger section, BOOL *stop) {
        NSMutableArray *sectionWidths = [NSMutableArray arrayWithCapacity:items.count];
        [items enumerateObjectsUsingBlock:^(NSString *title, NSUInteger item, BOOL *itemStop) {
            CGFloat width = ceil([title sizeWithAttributes:attributes].width) + 2 * style.itemHorizontalPadding;
            if ([self cyl_imageAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]]) {
                width += style.imageSize.width + style.imageTitleSpacing;
            }
            [sectionWidths addObject:@(MIN(width, contentWidth))];
        }];
        [widths addObject:sectionWidths];
    }];
    return widths;
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
    if (CGRectGetWidth(self.collectionView.bounds) != self.measuredWidth) {
        [self cyl_reloadLayout];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (![previousTraitCollection.preferredContentSizeCategory isEqualToString:self.traitCollection.preferredContentSizeCategory]) {
        [self cyl_invalidateMeasurements];
    }
}

- (void)cyl_updateContentHeight {
    CGFloat height = 0;
    if (CGRectGetWidth(self.collectionView.bounds) > 0) {
        [self.collectionView layoutIfNeeded];
        height = ceil(self.collectionView.collectionViewLayout.collectionViewContentSize.height +
                      self.collectionView.adjustedContentInset.top + self.collectionView.adjustedContentInset.bottom);
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
        }
        height += headerHeight + insets.top + insets.bottom;
        if (rowCount > 0) {
            height += rowCount * itemHeight + (rowCount - 1) * self.style.lineSpacing;
        }
        if (foldable && self.foldStyle == CYLMenuFoldStyleFooterChevron) {
            height += kCYLTagListFooterHeight;
        }
    }
    return ceil(height);
}

#pragma mark Folding

- (BOOL)cyl_canFoldRowCount:(NSUInteger)rowCount {
    return self.foldStyle != CYLMenuFoldStyleNone && self.defaultVisibleRows > 0 && rowCount > self.defaultVisibleRows;
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
    for (NSUInteger row = 0; row < self.defaultVisibleRows && row < sectionRows.count; row++) {
        visible += sectionRows[row].integerValue;
    }
    return MIN(visible, total);
}

- (void)setExpanded:(BOOL)expanded forSection:(NSInteger)section animated:(BOOL)animated {
    if (section < 0 || section >= (NSInteger)self.titles.count || expanded == [self isSectionExpanded:section]) {
        return;
    }
    if (expanded) {
        [self.expandedSections addIndex:(NSUInteger)section];
    } else {
        [self.expandedSections removeIndex:(NSUInteger)section];
    }
    void (^reload)(void) = ^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger)section]];
    };
    if (animated && self.window) {
        [self.collectionView performBatchUpdates:reload completion:nil];
    } else {
        [UIView performWithoutAnimation:^{
            reload();
            [self.collectionView layoutIfNeeded];
        }];
    }
    [self cyl_updateContentHeight];
    if ([self.menuDelegate respondsToSelector:@selector(menu:didChangeExpanded:inSection:)]) {
        [self.menuDelegate menu:self didChangeExpanded:expanded inSection:section];
    }
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
            [self cyl_applySelectionOfIndexPath:indexPath removed:nil];
        }
    }
    [self cyl_refreshVisibleCells];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectionMode == CYLMenuSelectionModeNone || ![self cyl_isValidIndexPath:indexPath]) {
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
    NSMutableArray<NSIndexPath *> *removed = [NSMutableArray array];
    BOOL selected = NO;
    switch (self.selectionMode) {
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
    if ([delegate respondsToSelector:@selector(menu:didDeselectItemAtIndexPath:)]) {
        for (NSIndexPath *path in removed) {
            [delegate menu:self didDeselectItemAtIndexPath:path];
        }
    }
    if (selected && [delegate respondsToSelector:@selector(menu:didSelectItemAtIndexPath:)]) {
        [delegate menu:self didSelectItemAtIndexPath:indexPath];
    }
}

- (void)cyl_refreshVisibleCells {
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        CYLTagListCell *cell = (CYLTagListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self cyl_configureCell:cell atIndexPath:indexPath];
    }
}

- (void)cyl_configureCell:(CYLTagListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (![self cyl_isValidIndexPath:indexPath]) {
        return;
    }
    [cell configureWithTitle:self.titles[indexPath.section][indexPath.item]
                       image:[self cyl_imageAtIndexPath:indexPath]
                        font:[self cyl_itemFont]
                       style:self.style
                    selected:[self.selection containsObject:indexPath]
                     enabled:[self cyl_isEnabledAtIndexPath:indexPath]];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.titles.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfVisibleItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CYLTagListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCYLTagListCellIdentifier forIndexPath:indexPath];
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
        UIImage *chevron = [UIImage systemImageNamed:expanded ? @"chevron.up" : @"chevron.down"];
        [footer.chevronButton setImage:chevron forState:UIControlStateNormal];
        footer.chevronButton.tintColor = self.style.foldControlColor;
        footer.chevronButton.accessibilityLabel = expanded ? self.style.collapseTitle : self.style.expandTitle;
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
    BOOL showsFoldButton = self.foldStyle == CYLMenuFoldStyleHeaderButton && [self canFoldSection:section];
    header.foldButton.hidden = !showsFoldButton;
    [header.foldButton setTitle:[self isSectionExpanded:section] ? self.style.collapseTitle : self.style.expandTitle
                       forState:UIControlStateNormal];
    [header.foldButton setTitleColor:self.style.foldControlColor forState:UIControlStateNormal];
    header.foldHandler = ^(NSInteger tappedSection) {
        [weakSelf cyl_toggleSection:tappedSection];
    };
    [header setNeedsLayout];
    return header;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self cyl_handleTapAtIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self cyl_measureIfNeeded];
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
    BOOL showsChevron = self.foldStyle == CYLMenuFoldStyleFooterChevron && [self canFoldSection:section];
    return showsChevron ? CGSizeMake(CGRectGetWidth(collectionView.bounds), kCYLTagListFooterHeight) : CGSizeZero;
}

@end

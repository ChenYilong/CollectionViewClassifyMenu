//
//  CYLReviewListViewController.m
//  CYLMenuExample
//

#import "CYLReviewListViewController.h"
#import "CYLExampleMenuSource.h"
#import "CYLExampleLocalization.h"

static NSString * const kReviewCellIdentifier = @"ReviewCell";

@interface CYLReviewListViewController () <CYLMenuDelegate, UITableViewDataSource>
@property (nonatomic, strong, readwrite) CYLTagListView *filterView;
@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite) UISegmentedControl *modeControl;
@property (nonatomic, strong, readwrite) UILabel *statusLabel;
@property (nonatomic, assign, readwrite) CYLReviewFilteringMode mode;
@property (nonatomic, strong, readwrite) id<CYLReviewQuerying> query;
@property (nonatomic, copy, readwrite) NSArray<CYLReviewFilter *> *selectedFilters;
@property (nonatomic, copy, readwrite) NSArray<CYLReview *> *visibleReviews;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) CYLExampleMenuSource *menuSource;
@property (nonatomic, strong) NSLayoutConstraint *filterHeight;
@property (nonatomic, assign) NSUInteger initialFilterIndex;
@property (nonatomic, copy) NSString *lastEvent;
@end

@implementation CYLReviewListViewController

+ (CYLMenuStyle *)reviewFilterStyle {
    UIColor *orange = [UIColor colorWithRed:1 green:0.31 blue:0 alpha:1];
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    style.font = [UIFont systemFontOfSize:12];
    style.itemHeight = 28;
    style.itemHorizontalPadding = 8;
    style.cornerRadius = 2;
    style.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    style.itemBackgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    style.borderColor = [UIColor colorWithWhite:0.88 alpha:1];
    style.selectedItemBackgroundColor = orange;
    style.selectedBorderColor = orange;
    style.selectedTextColor = [UIColor whiteColor];
    style.interitemSpacing = 8;
    style.lineSpacing = 10;
    style.sectionInsets = UIEdgeInsetsMake(10, 12, 6, 12);
    style.imageSize = CGSizeMake(13, 13);
    style.imageTitleSpacing = 3;
    style.foldControlColor = [UIColor colorWithWhite:0.45 alpha:1];
    return style;
}

- (instancetype)initWithSelectedFilterIndex:(NSUInteger)index {
    return [self initWithSelectedFilterIndex:index mode:CYLReviewFilteringModeMemory];
}

- (instancetype)initWithSelectedFilterIndex:(NSUInteger)index mode:(CYLReviewFilteringMode)mode {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _initialFilterIndex = index;
        _mode = mode;
        _selectedFilters = @[];
        _visibleReviews = @[];
        _query = [[self class] queryForMode:mode];
    }
    return self;
}

+ (id<CYLReviewQuerying>)queryForMode:(CYLReviewFilteringMode)mode {
    return mode == CYLReviewFilteringModeNetwork ? [[CYLNetworkReviewQuery alloc] init] : [[CYLMemoryReviewQuery alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CYLReviewStore *store = [CYLReviewStore sharedStore];
    self.title = [NSString stringWithFormat:CYLExampleLocalizedString(@"评价(%lu)"), (unsigned long)store.reviews.count];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.modeControl = [[UISegmentedControl alloc] initWithItems:@[CYLExampleLocalizedString(@"内存筛选"), CYLExampleLocalizedString(@"网络筛选")]];
    self.modeControl.selectedSegmentIndex = self.mode;
    [self.modeControl addTarget:self action:@selector(modeChanged) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.modeControl;

    NSMutableArray *items = [NSMutableArray array];
    for (CYLReviewFilter *filter in store.filters) {
        CYLExampleMenuItem *item = [CYLExampleMenuItem itemWithTitle:[store titleForFilter:filter]];
        item.image = filter.image;
        item.value = filter;
        item.enabled = [store reviewsMatchingFilter:filter].count > 0;
        item.exclusive = [filter.identifier isEqualToString:@"all"];
        [items addObject:item];
    }
    self.menuSource = [CYLExampleMenuSource sourceWithSections:@[[CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"评价") items:items]]];

    // Multiple choice, folded to two rows behind a chevron that turns when it expands.
    self.filterView = [[CYLTagListView alloc] init];
    self.filterView.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterView.style = [[self class] reviewFilterStyle];
    self.filterView.selectionMode = CYLMenuSelectionModeMultiple;
    self.filterView.showsSectionHeaders = NO;
    self.filterView.foldStyle = CYLMenuFoldStyleFooterChevron;
    self.filterView.defaultVisibleRows = 2;
    self.filterView.scrollEnabled = NO;
    self.filterView.menuDelegate = self;
    self.filterView.menuDataSource = self.menuSource;
    [self.filterView reloadMenuData];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.statusLabel.adjustsFontForContentSizeCategory = YES;
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.numberOfLines = 0;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.hidesWhenStopped = YES;
    UIStackView *status = [[UIStackView alloc] initWithArrangedSubviews:@[self.spinner, self.statusLabel]];
    status.spacing = 6;
    status.alignment = UIStackViewAlignmentCenter;
    status.layoutMarginsRelativeArrangement = YES;
    status.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(4, 12, 8, 12);
    status.backgroundColor = [UIColor secondarySystemBackgroundColor];
    status.translatesAutoresizingMaskIntoConstraints = NO;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReviewCellIdentifier];

    for (UIView *view in @[self.filterView, status, self.tableView]) {
        [self.view addSubview:view];
    }
    self.filterHeight = [self.filterView.heightAnchor constraintEqualToConstant:0];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.filterView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.filterView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.filterView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        self.filterHeight,
        [status.topAnchor constraintEqualToAnchor:self.filterView.bottomAnchor],
        [status.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [status.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:status.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    NSUInteger index = MIN(self.initialFilterIndex, items.count - 1);
    NSIndexPath *selected = [NSIndexPath indexPathForItem:(NSInteger)index inSection:0];
    self.filterView.selectedIndexPaths = @[selected];
    // A preselected chip hidden by folding would be confusing, so show it.
    if (index >= (NSUInteger)[self.filterView numberOfVisibleItemsInSection:0]) {
        [self.filterView setExpanded:YES forSection:0 animated:NO];
    }
    self.lastEvent = [NSString stringWithFormat:CYLExampleLocalizedString(@"点击「%@」"), [self.menuSource itemAtIndexPath:selected].title];
    [self refreshReviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateFilterHeight];
}

- (void)updateFilterHeight {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = [self.filterView heightThatFitsWidth:width];
    if (fabs(self.filterHeight.constant - height) > 0.5) {
        self.filterHeight.constant = height;
    }
}

#pragma mark Mode

- (void)modeChanged {
    [self setMode:(CYLReviewFilteringMode)self.modeControl.selectedSegmentIndex];
}

- (void)setMode:(CYLReviewFilteringMode)mode {
    _mode = mode;
    self.modeControl.selectedSegmentIndex = mode;
    self.query = [[self class] queryForMode:mode];
    if (self.isViewLoaded) {
        [self refreshReviews];
    }
}

#pragma mark Filtering

- (void)selectFilterIndexes:(NSArray<NSNumber *> *)indexes {
    [self loadViewIfNeeded];
    for (NSNumber *index in indexes) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index.integerValue inSection:0];
        [self.filterView selectItemAtIndexPath:indexPath];
        self.lastEvent = [NSString stringWithFormat:CYLExampleLocalizedString(@"点击「%@」"), [self.menuSource itemAtIndexPath:indexPath].title];
    }
    [self refreshReviews];
}

- (void)refreshReviews {
    NSMutableArray<CYLReviewFilter *> *filters = [NSMutableArray array];
    for (NSIndexPath *indexPath in self.filterView.selectedIndexPaths) {
        CYLReviewFilter *filter = [self.menuSource itemAtIndexPath:indexPath].value;
        if (![filter.identifier isEqualToString:@"all"]) {
            [filters addObject:filter];
        }
    }
    self.selectedFilters = filters;
    __weak __typeof(self) weakSelf = self;
    [self.query fetchReviewsMatchingFilters:filters completion:^(NSArray<CYLReview *> *reviews) {
        [weakSelf showReviews:reviews];
    }];
    if (self.query.isLoading) {
        [self.spinner startAnimating];
        self.tableView.alpha = 0.5;
        [self updateStatus];
    }
}

- (void)showReviews:(NSArray<CYLReview *> *)reviews {
    self.visibleReviews = reviews;
    [self.spinner stopAnimating];
    self.tableView.alpha = 1;
    [self.tableView reloadData];
    [self updateEmptyState];
    [self updateStatus];
}

- (void)updateEmptyState {
    if (self.visibleReviews.count > 0) {
        self.tableView.backgroundView = nil;
        return;
    }
    UILabel *empty = [[UILabel alloc] init];
    empty.text = CYLExampleLocalizedString(@"没有匹配的评价");
    empty.textAlignment = NSTextAlignmentCenter;
    empty.textColor = [UIColor secondaryLabelColor];
    self.tableView.backgroundView = empty;
}

- (void)updateStatus {
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    for (CYLReviewFilter *filter in self.selectedFilters) {
        [names addObject:filter.isKeyword ? filter.name : CYLExampleLocalizedString(filter.name)];
    }
    NSString *selection = names.count > 0 ? [names componentsJoinedByString:CYLExampleLocalizedString(@"、")] : CYLExampleLocalizedString(@"全部");
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"%@ · %@", self.lastEvent ?: @"",
                      [NSString stringWithFormat:CYLExampleLocalizedString(@"已选：%@"), selection]]];
    if (self.mode == CYLReviewFilteringModeNetwork) {
        CYLNetworkReviewQuery *network = (CYLNetworkReviewQuery *)self.query;
        NSString *request = [NSString stringWithFormat:@"GET %@%@", network.lastRequestURL.path,
                             network.lastRequestURL.query.length > 0 ? [@"?" stringByAppendingString:network.lastRequestURL.query.stringByRemovingPercentEncoding] : @""];
        [lines addObject:[NSString stringWithFormat:@"%@ · %@", CYLExampleLocalizedString(@"网络筛选：向服务器发送条件"), request]];
        [lines addObject:network.isLoading ? CYLExampleLocalizedString(@"加载中…")
                                           : [NSString stringWithFormat:CYLExampleLocalizedString(@"服务器返回 %lu 条"), (unsigned long)self.visibleReviews.count]];
    } else {
        [lines addObject:[NSString stringWithFormat:@"%@ · %@", CYLExampleLocalizedString(@"内存筛选：在已加载的评价中立即匹配"),
                          [NSString stringWithFormat:CYLExampleLocalizedString(@"匹配 %lu 条"), (unsigned long)self.visibleReviews.count]]];
    }
    self.statusLabel.text = [lines componentsJoinedByString:@"\n"];
}

#pragma mark CYLMenuDelegate

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.lastEvent = [NSString stringWithFormat:CYLExampleLocalizedString(@"点击「%@」"), [self.menuSource itemAtIndexPath:indexPath].title];
}

- (void)menu:(id)menu didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.lastEvent = [NSString stringWithFormat:CYLExampleLocalizedString(@"取消「%@」"), [self.menuSource itemAtIndexPath:indexPath].title];
}

/// Every tap that changes the selection refreshes the list once.
- (void)menu:(id)menu didChangeSelectedItems:(NSArray<NSIndexPath *> *)indexPaths {
    if (indexPaths.count == 0) {
        // Nothing selected means no condition: show "全部" as selected.
        [self.filterView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    [self refreshReviews];
}

- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height {
    [self updateFilterHeight];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.visibleReviews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReviewCellIdentifier forIndexPath:indexPath];
    CYLReview *review = self.visibleReviews[indexPath.row];
    UIListContentConfiguration *content = [UIListContentConfiguration subtitleCellConfiguration];
    content.text = review.user;
    content.secondaryText = [NSString stringWithFormat:@"%@\n%@ %@", review.text, review.date, review.sku];
    content.secondaryTextProperties.numberOfLines = 0;
    content.secondaryTextProperties.color = [UIColor secondaryLabelColor];
    content.image = [UIImage systemImageNamed:@"person.crop.circle"];
    cell.contentConfiguration = content;
    return cell;
}

@end

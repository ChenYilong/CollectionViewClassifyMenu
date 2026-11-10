//
//  CYLReviewListViewController.m
//  CYLMenuExample
//

#import "CYLReviewListViewController.h"
#import "CYLReviewStore.h"
#import "CYLExampleMenuSource.h"

static NSString * const kReviewCellIdentifier = @"ReviewCell";

@interface CYLReviewListViewController () <CYLMenuDelegate, UITableViewDataSource>
@property (nonatomic, strong, readwrite) CYLTagListView *filterView;
@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, assign, readwrite) NSUInteger selectedFilterIndex;
@property (nonatomic, strong) CYLExampleMenuSource *menuSource;
@property (nonatomic, copy) NSArray<CYLReview *> *visibleReviews;
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
    return style;
}

- (instancetype)initWithSelectedFilterIndex:(NSUInteger)index {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _selectedFilterIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CYLReviewStore *store = [CYLReviewStore sharedStore];
    self.title = [NSString stringWithFormat:@"评价(%lu)", (unsigned long)store.reviews.count];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    NSMutableArray *items = [NSMutableArray array];
    for (CYLReviewFilter *filter in store.filters) {
        CYLExampleMenuItem *item = [CYLExampleMenuItem itemWithTitle:[store titleForFilter:filter]];
        item.image = filter.image;
        item.value = filter;
        item.enabled = [store reviewsMatchingFilter:filter].count > 0;
        [items addObject:item];
    }
    self.menuSource = [CYLExampleMenuSource sourceWithSections:@[[CYLExampleMenuSection sectionWithTitle:@"评价" items:items]]];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReviewCellIdentifier];
    [self.view addSubview:self.tableView];

    // The filter scrolls with the reviews, so it is the table header and does not scroll itself.
    self.filterView = [[CYLTagListView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0)];
    self.filterView.style = [[self class] reviewFilterStyle];
    self.filterView.selectionMode = CYLMenuSelectionModeSingle;
    self.filterView.allowsEmptySelection = NO;
    self.filterView.showsSectionHeaders = NO;
    self.filterView.foldStyle = CYLMenuFoldStyleFooterChevron;
    self.filterView.defaultVisibleRows = 2;
    self.filterView.scrollEnabled = NO;
    self.filterView.menuDelegate = self;
    self.filterView.menuDataSource = self.menuSource;
    [self.filterView reloadMenuData];
    NSUInteger index = MIN(self.selectedFilterIndex, items.count - 1);
    NSIndexPath *selected = [NSIndexPath indexPathForItem:(NSInteger)index inSection:0];
    self.filterView.selectedIndexPaths = @[selected];
    // A preselected chip hidden by folding would be confusing, so show it.
    if (index >= (NSUInteger)[self.filterView numberOfVisibleItemsInSection:0]) {
        [self.filterView setExpanded:YES forSection:0 animated:NO];
    }
    [self applyFilterAtIndex:index];
    [self updateFilterHeaderHeight];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (CGRectGetWidth(self.filterView.frame) != CGRectGetWidth(self.tableView.bounds)) {
        [self updateFilterHeaderHeight];
    }
}

- (void)updateFilterHeaderHeight {
    CGFloat width = CGRectGetWidth(self.tableView.bounds);
    CGFloat height = [self.filterView heightThatFitsWidth:width];
    self.filterView.frame = CGRectMake(0, 0, width, height);
    [self.filterView layoutIfNeeded];
    self.tableView.tableHeaderView = self.filterView;
}

- (void)applyFilterAtIndex:(NSUInteger)index {
    self.selectedFilterIndex = index;
    CYLReviewFilter *filter = [CYLReviewStore sharedStore].filters[index];
    self.visibleReviews = [[CYLReviewStore sharedStore] reviewsMatchingFilter:filter];
    [self.tableView reloadData];
}

#pragma mark CYLMenuDelegate

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self applyFilterAtIndex:(NSUInteger)indexPath.item];
}

- (void)menu:(id)menu didChangeExpanded:(BOOL)expanded inSection:(NSInteger)section {
    [self updateFilterHeaderHeight];
}

- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height {
    if (self.tableView.tableHeaderView == self.filterView && fabs(CGRectGetHeight(self.filterView.frame) - height) > 0.5) {
        [self updateFilterHeaderHeight];
    }
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

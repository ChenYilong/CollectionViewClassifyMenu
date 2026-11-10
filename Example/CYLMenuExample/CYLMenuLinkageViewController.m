//
//  CYLMenuLinkageViewController.m
//  CYLMenuExample
//

#import "CYLMenuLinkageViewController.h"
// The original app's data source, compiled from CollectionViewClassifyMenu/Class (shared, not copied).
#import "../../CollectionViewClassifyMenu/Class/ClassifyMenu/Controller/CYLDemoDataSource.h"
#import "CYLExampleLocalization.h"

NSString *const CYLMenuLinkageClassifyScenario = @"menu.classify";
NSString *const CYLMenuLinkageFilterScenario = @"menu.filter";

@interface CYLMenuLinkageViewController () <CYLMenuDelegate, CYLFilterControllerDelegate>
@property (nonatomic, strong, readwrite) CYLExampleDatabase *database;
@property (nonatomic, strong, readwrite) CYLMultipleFilterController *filterController;
@property (nonatomic, strong) CYLDemoDataSource *classifySource;
@property (nonatomic, strong) CYLDemoDataSource *filterSource;
@property (nonatomic, copy, readwrite, nullable) NSString *selectedTag;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *selectedRegions;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *selectedDishes;
@property (nonatomic, strong, readwrite) CYLExampleSQLQuery *lastQuery;
@property (nonatomic, copy, readwrite) NSArray<NSDictionary<NSString *, id> *> *results;
@property (nonatomic, strong, readwrite) UILabel *statusLabel;
@property (nonatomic, strong) UIStackView *resultsStack;
@end

@implementation CYLMenuLinkageViewController

- (instancetype)init {
    return [self initWithDatabase:[CYLExampleDatabase sharedDatabase]];
}

- (instancetype)initWithDatabase:(CYLExampleDatabase *)database {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _database = database;
        _classifySource = [CYLDemoDataSource classifyDataSource];
        _filterSource = [CYLDemoDataSource filterDataSource];
        _selectedRegions = @[];
        _selectedDishes = @[];
        _results = @[];
    }
    return self;
}

#pragma mark Life cycle

- (void)viewDidLoad {
    self.menuDataSource = self.classifySource;
    self.menuDelegate = self;
    self.defaultVisibleRows = 2;
    self.menuHeaderView = [self makeHeaderView];
    self.menuFooterView = [self makeFooterView];
    [super viewDidLoad];
    // navigationItem, not title: CYLClassifyMenuViewController sets its own title.
    self.navigationItem.title = CYLExampleLocalizedString(@"菜单选择 · 数据库联动");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CYLExampleLocalizedString(@"重置")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(resetConditions)];
    [self restoreSavedSelection];
    [self runQuery];
}

- (UIView *)makeHeaderView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds), 52)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize:12];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.7;
    label.textColor = [UIColor secondaryLabelColor];
    label.backgroundColor = [UIColor systemBackgroundColor];
    label.text = [NSString stringWithFormat:@"  %@\n  %@", CYLExampleLocalizedString(@"点按分类标签（单选），左上角按钮多选地区与菜品"),
                  CYLExampleLocalizedString(@"每次选择 → 生成 SQL → SQLite 查询 → 刷新下方结果")];
    return label;
}

- (UIView *)makeFooterView {
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.statusLabel.adjustsFontForContentSizeCategory = YES;
    self.statusLabel.textColor = [UIColor secondaryLabelColor];

    self.resultsStack = [[UIStackView alloc] init];
    self.resultsStack.axis = UILayoutConstraintAxisVertical;
    self.resultsStack.spacing = 1;
    self.resultsStack.backgroundColor = [UIColor separatorColor];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.statusLabel, self.resultsStack]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.layoutMarginsRelativeArrangement = YES;
    stack.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(10, 16, 16, 16);
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor secondarySystemBackgroundColor];
    [footer addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:footer.topAnchor],
        [stack.leadingAnchor constraintEqualToAnchor:footer.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:footer.trailingAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:footer.bottomAnchor],
    ]];
    return footer;
}

#pragma mark Filter

- (CYLMultipleFilterController *)filterController {
    if (!_filterController) {
        _filterController = [[CYLMultipleFilterController alloc] init];
        _filterController.delegate = self;
        _filterController.menuDataSource = self.filterSource;
        _filterController.menuDelegate = self;
        [_filterController loadViewIfNeeded];
    }
    return _filterController;
}

- (void)updateFilterButton {
    BOOL modified = self.selectedRegions.count > 0 || self.selectedDishes.count > 0;
    NSString *name = modified ? @"navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_modified"
                              : @"navigationbar_leftBarButtonItem_itis_multiple_choice_filter_params_normal";
    UIImage *image = [[CYLMenuResources imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(showFilter)];
    item.accessibilityLabel = CYLExampleLocalizedString(@"多选筛选");
    item.accessibilityValue = modified ? CYLExampleLocalizedString(@"已修改") : nil;
    self.navigationItem.leftBarButtonItem = item;
}

- (void)showFilter {
    [self.filterController refreshFilterParams];
    [self.filterController showInView:self.navigationController.view ?: self.view];
}

- (void)confirmFilterSelection:(NSArray<NSIndexPath *> *)indexPaths {
    [self.filterController setSelectedIndexPaths:indexPaths];
    [self applyFilterSelection:self.filterController.selectedIndexPaths save:YES];
}

/// Regions and dishes from the filter's selection: section 0 and 1, without the exclusive "全部".
- (void)applyFilterSelection:(NSArray<NSIndexPath *> *)indexPaths save:(BOOL)save {
    NSMutableArray *regions = [NSMutableArray array], *dishes = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        if ([self.filterSource menuItemIsExclusiveAtIndexPath:indexPath]) {
            continue;
        }
        NSString *title = [self.filterSource menuTitleForItemAtIndexPath:indexPath];
        [(indexPath.section == 0 ? regions : dishes) addObject:title];
    }
    self.selectedRegions = regions;
    self.selectedDishes = dishes;
    if (save) {
        [self.database saveSelection:indexPaths forScenario:CYLMenuLinkageFilterScenario];
    }
    [self runQuery];
}

#pragma mark Classify menu

- (void)selectClassifyItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL deselect = [self.selectedIndexPath isEqual:indexPath];
    self.selectedIndexPath = deselect ? nil : indexPath;
    self.selectedTag = deselect ? nil : [self.classifySource menuTitleForItemAtIndexPath:indexPath];
    [self.database saveSelection:self.selectedIndexPath ? @[self.selectedIndexPath] : @[] forScenario:CYLMenuLinkageClassifyScenario];
    [self runQuery];
}

- (void)resetConditions {
    self.selectedIndexPath = nil;
    self.selectedTag = nil;
    [self.database saveSelection:@[] forScenario:CYLMenuLinkageClassifyScenario];
    NSMutableArray *all = [NSMutableArray array];
    for (NSInteger section = 0; section < [self.filterSource numberOfSectionsInMenu]; section++) {
        [all addObject:[NSIndexPath indexPathForItem:0 inSection:section]];
    }
    [self confirmFilterSelection:all];
}

/// The selections saved in the database by the last visit, if they still fit the menus.
- (void)restoreSavedSelection {
    NSIndexPath *classify = [self.database savedSelectionForScenario:CYLMenuLinkageClassifyScenario].firstObject;
    if (classify && classify.section < [self.classifySource numberOfSectionsInMenu] &&
        classify.item < [self.classifySource menuNumberOfItemsInSection:classify.section]) {
        self.selectedIndexPath = classify;
        self.selectedTag = [self.classifySource menuTitleForItemAtIndexPath:classify];
    }
    NSMutableArray *filter = [NSMutableArray array];
    for (NSIndexPath *indexPath in [self.database savedSelectionForScenario:CYLMenuLinkageFilterScenario]) {
        if (indexPath.section < [self.filterSource numberOfSectionsInMenu] &&
            indexPath.item < [self.filterSource menuNumberOfItemsInSection:indexPath.section]) {
            [filter addObject:indexPath];
        }
    }
    if (filter.count > 0) {
        @try {
            [self.filterController setSelectedIndexPaths:filter];
        } @catch (NSException *exception) {
            // A selection saved for other filter data ("全部" with another item): start over.
            NSLog(@"[CYLMenuExample] Ignoring the saved filter selection: %@", exception.reason);
            [self.filterController reloadMenuData];
        }
    }
    [self applyFilterSelection:self.filterController.selectedIndexPaths save:NO];
}

#pragma mark Query

+ (CYLExampleSQLQuery *)queryForTag:(NSString *)tag regions:(NSArray<NSString *> *)regions dishes:(NSArray<NSString *> *)dishes {
    NSMutableArray<NSString *> *conditions = [NSMutableArray array];
    NSMutableArray *arguments = [NSMutableArray array];
    if (tag.length > 0) {
        [conditions addObject:@"tag = ?"];
        [arguments addObject:tag];
    }
    for (NSArray *pair in @[@[@"region", regions], @[@"tag", dishes]]) {
        NSArray<NSString *> *values = pair[1];
        if (values.count == 0) {
            continue;
        }
        NSMutableArray *marks = [NSMutableArray array];
        for (NSString *value in values) {
            [marks addObject:@"?"];
            [arguments addObject:value];
        }
        [conditions addObject:[NSString stringWithFormat:@"%@ IN (%@)", pair[0], [marks componentsJoinedByString:@", "]]];
    }
    NSString *SQL = @"SELECT name, category, tag, region, rating, price FROM places";
    if (conditions.count > 0) {
        SQL = [SQL stringByAppendingFormat:@" WHERE %@", [conditions componentsJoinedByString:@" AND "]];
    }
    return [CYLExampleSQLQuery querySQL:[SQL stringByAppendingString:@" ORDER BY rating DESC, id"] arguments:arguments];
}

- (void)runQuery {
    self.lastQuery = [[self class] queryForTag:self.selectedTag regions:self.selectedRegions dishes:self.selectedDishes];
    NSError *error = nil;
    NSArray *rows = [self.database rowsForQuery:self.lastQuery error:&error];
    if (!rows) {
        NSLog(@"[CYLMenuExample] %@: %@", self.lastQuery.SQL, error);
    }
    self.results = rows ?: @[];
    [self updateFilterButton];
    [self showResults];
}

- (void)showResults {
    NSString *all = CYLExampleLocalizedString(@"全部");
    NSString *separator = CYLExampleLocalizedString(@"、");
    NSString *(^names)(NSArray<NSString *> *) = ^NSString *(NSArray<NSString *> *values) {
        NSMutableArray *short_ = [NSMutableArray array];
        for (NSString *value in values) [short_ addObject:[CYLDemoDataSource shortTitleForTitle:value]];
        return short_.count > 0 ? [short_ componentsJoinedByString:separator] : all;
    };
    NSArray<NSString *> *lines = @[
        [NSString stringWithFormat:CYLExampleLocalizedString(@"分类：%@ · 地区：%@ · 菜品：%@"),
         self.selectedTag ? [CYLDemoDataSource shortTitleForTitle:self.selectedTag] : all, names(self.selectedRegions), names(self.selectedDishes)],
        self.lastQuery.displayString,
        [NSString stringWithFormat:CYLExampleLocalizedString(@"SQLite 返回 %lu 条（共 %ld 家）"),
         (unsigned long)self.results.count, (long)[self.database countOfTable:@"places"]],
    ];
    self.statusLabel.text = [lines componentsJoinedByString:@"\n"];

    for (UIView *view in self.resultsStack.arrangedSubviews) {
        [view removeFromSuperview];
    }
    if (self.results.count == 0) {
        [self.resultsStack addArrangedSubview:[self rowLabelWithTitle:CYLExampleLocalizedString(@"没有符合条件的商家") detail:nil]];
    }
    for (NSDictionary *row in self.results) {
        NSString *detail = [NSString stringWithFormat:@"%@ · %@ · %@ · ★%.1f · ¥%@", row[@"category"],
                            [CYLDemoDataSource shortTitleForTitle:row[@"tag"]], [CYLDemoDataSource shortTitleForTitle:row[@"region"]],
                            [row[@"rating"] doubleValue], row[@"price"]];
        [self.resultsStack addArrangedSubview:[self rowLabelWithTitle:row[@"name"] detail:detail]];
    }
    [self updateMenuLayout];
}

- (UILabel *)rowLabelWithTitle:(NSString *)title detail:(nullable NSString *)detail {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName: [UIColor labelColor]}];
    if (detail) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingString:detail] attributes:@{
            NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote], NSForegroundColorAttributeName: [UIColor secondaryLabelColor]}]];
    }
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.attributedText = text;
    label.adjustsFontForContentSizeCategory = YES;
    label.backgroundColor = [UIColor systemBackgroundColor];
    label.isAccessibilityElement = YES;
    return label;
}

#pragma mark CYLMenuDelegate

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (menu == self) {
        [self selectClassifyItemAtIndexPath:indexPath];
    }
}

- (void)menu:(id)menu didConfirmSelectedItems:(NSArray<NSIndexPath *> *)indexPaths {
    if (menu == self.filterController) {
        [self applyFilterSelection:indexPaths save:YES];
    }
}

#pragma mark CYLFilterControllerDelegate

- (void)filterControllerDidComplete:(CYLFilterBaseController *)controller {
    [self updateFilterButton];
}

@end

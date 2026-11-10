//
//  CYLQueryScenariosViewController.m
//  CYLMenuExample
//

#import "CYLQueryScenariosViewController.h"
#import "CYLReviewListViewController.h"
#import "CYLMenuLinkageViewController.h"
#import "CYLExampleLocalization.h"

static NSString *const kScenarioCell = @"CYLQueryScenarioCell";

@interface CYLQueryScenariosViewController ()
@property (nonatomic, strong, readwrite) CYLExampleDatabase *database;
@end

@implementation CYLQueryScenariosViewController

- (instancetype)init {
    return [self initWithDatabase:[CYLExampleDatabase sharedDatabase]];
}

- (instancetype)initWithDatabase:(CYLExampleDatabase *)database {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) {
        _database = database;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigationItem, not title: a view controller's title would replace its tab's title.
    self.navigationItem.title = CYLExampleLocalizedString(@"查询筛选");
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kScenarioCell];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // The selections saved by the demos change the database section.
    [self.tableView reloadData];
}

#pragma mark Scenarios

- (NSArray<NSNumber *> *)scenariosInSection:(NSInteger)section {
    switch (section) {
        case 0: return @[@(CYLQueryScenarioReviewsDatabase), @(CYLQueryScenarioReviewsMemory), @(CYLQueryScenarioReviewsNetwork)];
        case 1: return @[@(CYLQueryScenarioMenuLinkage)];
        default: return @[];
    }
}

- (NSString *)titleForScenario:(CYLQueryScenario)scenario {
    switch (scenario) {
        case CYLQueryScenarioReviewsDatabase: return CYLExampleLocalizedString(@"评价筛选 · 数据库（SQLite）");
        case CYLQueryScenarioReviewsMemory: return CYLExampleLocalizedString(@"评价筛选 · 内存");
        case CYLQueryScenarioReviewsNetwork: return CYLExampleLocalizedString(@"评价筛选 · 网络");
        case CYLQueryScenarioMenuLinkage: return CYLExampleLocalizedString(@"分类菜单 + 多选筛选 · 数据库联动");
    }
    return @"";
}

- (NSString *)symbolForScenario:(CYLQueryScenario)scenario {
    switch (scenario) {
        case CYLQueryScenarioReviewsDatabase: return @"cylinder.split.1x2";
        case CYLQueryScenarioReviewsMemory: return @"memorychip";
        case CYLQueryScenarioReviewsNetwork: return @"network";
        case CYLQueryScenarioMenuLinkage: return @"square.grid.3x2";
    }
    return @"circle";
}

- (UIViewController *)viewControllerForScenario:(CYLQueryScenario)scenario {
    UIViewController *controller;
    switch (scenario) {
        case CYLQueryScenarioReviewsDatabase:
            controller = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0 mode:CYLReviewFilteringModeDatabase];
            break;
        case CYLQueryScenarioReviewsMemory:
            controller = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0 mode:CYLReviewFilteringModeMemory];
            break;
        case CYLQueryScenarioReviewsNetwork:
            controller = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:0 mode:CYLReviewFilteringModeNetwork];
            break;
        case CYLQueryScenarioMenuLinkage:
            controller = [[CYLMenuLinkageViewController alloc] initWithDatabase:self.database];
            break;
    }
    // A screen pushed from a tab hides the tab bar.
    controller.hidesBottomBarWhenPushed = YES;
    return controller;
}

- (void)openScenario:(CYLQueryScenario)scenario {
    [self.navigationController pushViewController:[self viewControllerForScenario:scenario] animated:NO];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 2 ? 3 : (NSInteger)[self scenariosInSection:section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return CYLExampleLocalizedString(@"场景：查询参数设置（多选）");
        case 1: return CYLExampleLocalizedString(@"场景：菜单选择（移植原 Demo）");
        default: return CYLExampleLocalizedString(@"数据库（SQLite）");
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0: return CYLExampleLocalizedString(@"淘宝评价默认显示全部；条件太多时，由用户多选输入筛选条件，标签列表就是为此而做。每次选择后按全部条件（AND）刷新列表。");
        case 1: return CYLExampleLocalizedString(@"原 Demo 只实现了筛选界面，没有筛选数据；现在每次选择都会生成 SQL、查询数据库并显示结果，选择也保存在数据库中。");
        default: return CYLExampleLocalizedString(@"每次启动时由 App 内的数据重新生成，selections 表保留各演示最后确认的条件。");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kScenarioCell forIndexPath:indexPath];
    UIListContentConfiguration *content = [UIListContentConfiguration valueCellConfiguration];
    if (indexPath.section == 2) {
        NSString *table = @[@"reviews", @"places", @"selections"][indexPath.row];
        content.text = table;
        content.textProperties.font = [UIFont monospacedSystemFontOfSize:15 weight:UIFontWeightRegular];
        content.secondaryText = [NSString stringWithFormat:CYLExampleLocalizedString(@"%ld 行"), (long)[self.database countOfTable:table]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        CYLQueryScenario scenario = (CYLQueryScenario)[self scenariosInSection:indexPath.section][indexPath.row].integerValue;
        content = [UIListContentConfiguration cellConfiguration];
        content.text = [self titleForScenario:scenario];
        content.image = [UIImage systemImageNamed:[self symbolForScenario:scenario]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    cell.contentConfiguration = content;
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section < 2) {
        CYLQueryScenario scenario = (CYLQueryScenario)[self scenariosInSection:indexPath.section][indexPath.row].integerValue;
        [self.navigationController pushViewController:[self viewControllerForScenario:scenario] animated:YES];
    }
}

@end

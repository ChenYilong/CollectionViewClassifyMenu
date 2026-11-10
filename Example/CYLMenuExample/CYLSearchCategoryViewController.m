//
//  CYLSearchCategoryViewController.m
//  CYLMenuExample
//

#import "CYLSearchCategoryViewController.h"
#import "CYLExampleMenuSource.h"
#import "CYLExampleLocalization.h"

static CGFloat const kJobCategoryWidth = 90;
static NSString * const kJobCategoryCell = @"JobCategoryCell";

#pragma mark - Category page

/// One tab of the category tab bar: a tag list, plus the job category sidebar on the 职位 page.
@interface CYLSearchCategoryPageViewController : UIViewController
@property (nonatomic, assign) CYLSearchCategory category;
@property (nonatomic, strong) CYLTagListView *tagListView;
@property (nonatomic, strong, nullable) UITableView *sidebar;
@end

@implementation CYLSearchCategoryPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.tagListView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tagListView];
    // The safe area ends above the tab bar at the bottom.
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    NSLayoutXAxisAnchor *leading = self.view.leadingAnchor;
    if (self.sidebar) {
        self.sidebar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.sidebar];
        [NSLayoutConstraint activateConstraints:@[
            [self.sidebar.topAnchor constraintEqualToAnchor:safe.topAnchor],
            [self.sidebar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [self.sidebar.widthAnchor constraintEqualToConstant:kJobCategoryWidth],
            [self.sidebar.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor],
        ]];
        leading = self.sidebar.trailingAnchor;
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.tagListView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.tagListView.leadingAnchor constraintEqualToAnchor:leading],
        [self.tagListView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tagListView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor],
    ]];
}

@end

#pragma mark - Search screen

@interface CYLSearchCategoryViewController () <CYLMenuDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarControllerDelegate>
@property (nonatomic, strong, readwrite) UISearchBar *searchBar;
@property (nonatomic, strong, readwrite) CYLTabBarController *categoryTabBarController;
@property (nonatomic, strong, readwrite) UITableView *jobCategoryTableView;
@property (nonatomic, strong, readwrite) UIButton *industryButton;
@property (nonatomic, assign, readwrite) CYLSearchCategory category;
@property (nonatomic, copy, readwrite) NSString *industry;
@property (nonatomic, copy) NSArray<CYLSearchCategoryPageViewController *> *pages;
/// One data source per tag list; the lists hold them weakly.
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, CYLExampleMenuSource *> *menuSources;
@property (nonatomic, copy) NSArray<NSString *> *jobCategories;
@property (nonatomic, assign) NSUInteger jobCategoryIndex;
@end

@implementation CYLSearchCategoryViewController

+ (NSArray<NSString *> *)industries {
    return @[@"IT互联网", @"金融", @"教育培训", @"医疗健康", @"房地产"];
}

+ (NSDictionary<NSString *, NSArray<NSString *> *> *)jobKeywords {
    return @{
        @"开发": @[@"后端开发", @"PHP", @"Java", @"Python", @".NET", @"C#", @"C/C++", @"Ruby", @"Hadoop", @"Node.js",
                 @"Perl", @"搜索算法", @"推荐算法", @"数据挖掘", @"机器学习", @"信息检索", @"NLP", @"语音算法",
                 @"视频算法", @"图像算法", @"全栈", @"Linux", @"广告算法", @"GO", @"ASP", @"Shell", @"VB",
                 @"Delphi", @"前端开发", @"Web前端", @"Flash"],
        @"测试": @[@"测试工程师", @"自动化测试", @"性能测试", @"测试开发", @"白盒测试", @"游戏测试", @"手机测试"],
        @"运维/DBA": @[@"运维工程师", @"DBA", @"系统管理员", @"网络工程师", @"IT支持", @"SRE"],
        @"硬件": @[@"嵌入式", @"单片机", @"电路设计", @"FPGA", @"驱动开发", @"射频工程师"],
        @"产品": @[@"产品经理", @"产品助理", @"产品总监", @"数据产品", @"游戏策划", @"移动产品"],
        @"运营": @[@"内容运营", @"用户运营", @"活动运营", @"新媒体", @"社区运营", @"数据运营", @"SEO"],
        @"设计": @[@"UI设计", @"交互设计", @"视觉设计", @"平面设计", @"用户研究", @"动效设计"],
        @"编辑/记者": @[@"编辑", @"记者", @"文案", @"主编", @"撰稿人"],
        @"游戏": @[@"游戏开发", @"游戏策划", @"游戏美术", @"Unity3D", @"Cocos2d-x"],
        @"市场BD": @[@"市场推广", @"商务拓展", @"品牌", @"公关", @"渠道", @"大客户"],
    };
}

+ (NSArray<CYLExampleMenuSection *> *)sectionsForCategory:(CYLSearchCategory)category {
    switch (category) {
        case CYLSearchCategoryPeople:
            return @[[CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"认识同行") titles:@[@"百度研发", @"腾讯工程师", @"搜狗开发", @"腾讯开发", @"搜狗研究员"]],
                     [CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"找投资") titles:@[@"创投", @"IDG资本", @"晨兴资本", @"合伙人", @"投资经理"]],
                     [CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"谈合作") titles:@[@"CEO", @"副总裁", @"VP", @"总经理", @"总监"]],
                     [CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"挖人才") titles:@[@"Java", @"Android", @"JS", @"C++", @"HTML/CSS", @"iOS", @"PHP", @"前端"]]];
        case CYLSearchCategoryFeeds:
            return @[[CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"热门动态关键词") titles:@[@"投资", @"创业", @"o2o", @"社交", @"招聘", @"运营", @"线下聚会", @"脉脉", @"融资", @"在线教育", @"硬件", @"电商", @"产品经理"]]];
        case CYLSearchCategoryGossip:
            return @[[CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"热门词") titles:@[@"百度", @"新浪", @"程序猿", @"离职", @"阿里", @"360", @"创业", @"工资", @"跳槽", @"小三", @"裁员", @"加班", @"女同事", @"产品经理", @"投资人", @"老板"]],
                     [CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"我关注的标签") titles:@[@"社交", @"移动", @"程序猿"]]];
        case CYLSearchCategoryJobs:
            return @[];
    }
    return @[];
}

+ (NSString *)placeholderForCategory:(CYLSearchCategory)category {
    // A variable, not an inline array: commas inside the macro's argument would split it.
    NSString *key = @[@"搜人名,职位,公司...", @"搜动态", @"搜八卦", @"搜职位"][category];
    return CYLExampleLocalizedString(key);
}

+ (CYLMenuStyle *)maimaiStyle {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    style.font = [UIFont systemFontOfSize:14];
    style.textColor = [UIColor colorWithWhite:0.35 alpha:1];
    style.borderColor = [UIColor colorWithWhite:0.8 alpha:1];
    style.borderWidth = 1;
    style.cornerRadius = 2;
    style.itemHeight = 32;
    style.itemHorizontalPadding = 14;
    style.interitemSpacing = 14;
    style.lineSpacing = 14;
    style.sectionInsets = UIEdgeInsetsMake(4, 24, 14, 16);
    style.headerHeight = 32;
    style.headerFont = [UIFont systemFontOfSize:13];
    style.headerTextColor = [UIColor colorWithWhite:0.6 alpha:1];
    return style;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.menuSources = [NSMutableDictionary dictionary];
    self.jobCategories = @[@"开发", @"测试", @"运维/DBA", @"硬件", @"产品", @"运营", @"设计", @"编辑/记者", @"游戏", @"市场BD"];
    self.industry = [[self class] industries].firstObject;

    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.navigationItem.titleView = self.searchBar;

    self.jobCategoryTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.jobCategoryTableView.dataSource = self;
    self.jobCategoryTableView.delegate = self;
    self.jobCategoryTableView.rowHeight = 50;
    self.jobCategoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.jobCategoryTableView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    [self.jobCategoryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kJobCategoryCell];

    // A header accessory supplied by the host, not drawn by the menu.
    self.industryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.industryButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.industryButton.showsMenuAsPrimaryAction = YES;
    [self updateIndustryButton];

    NSArray<NSString *> *titles = @[@"找人", @"动态", @"八卦", @"职位"];
    NSArray<NSString *> *symbols = @[@"person.2", @"bubble.left.and.bubble.right", @"flame", @"briefcase"];
    NSMutableArray *pages = [NSMutableArray array];
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger index = 0; index < (NSInteger)titles.count; index++) {
        CYLSearchCategoryPageViewController *page = [[CYLSearchCategoryPageViewController alloc] init];
        page.category = (CYLSearchCategory)index;
        page.tagListView = [self makeTagListView];
        if (index == CYLSearchCategoryJobs) {
            page.sidebar = self.jobCategoryTableView;
        }
        [pages addObject:page];
        [attributes addObject:@{
            CYLTabBarItemTitle: CYLExampleLocalizedString(titles[index]),
            CYLTabBarItemImage: [UIImage systemImageNamed:symbols[index]],
            CYLTabBarItemSelectedImage: [UIImage systemImageNamed:[symbols[index] stringByAppendingString:@".fill"]] ?: [UIImage systemImageNamed:symbols[index]],
        }];
    }
    self.pages = pages;
    for (CYLSearchCategoryPageViewController *page in pages) {
        [self reloadTagsForCategory:page.category];
    }

    // The second tab bar of the app: the category tabs of this screen, at the bottom like
    // every tab bar. The root tab bar is hidden while this screen is pushed.
    self.categoryTabBarController = [[CYLTabBarController alloc] initWithViewControllers:pages tabBarItemsAttributes:attributes];
    self.categoryTabBarController.delegate = self;
    [self addChildViewController:self.categoryTabBarController];
    UIView *tabs = self.categoryTabBarController.view;
    tabs.frame = self.view.bounds;
    tabs.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tabs];
    [self.categoryTabBarController didMoveToParentViewController:self];
    [self selectCategory:CYLSearchCategoryPeople];
}

- (CYLTagListView *)makeTagListView {
    CYLTagListView *view = [[CYLTagListView alloc] init];
    view.style = [[self class] maimaiStyle];
    view.selectionMode = CYLMenuSelectionModeNone;
    view.menuDelegate = self;
    return view;
}

#pragma mark Category

- (CYLTagListView *)tagListViewForCategory:(CYLSearchCategory)category {
    return self.pages[category].tagListView;
}

- (CYLTagListView *)tagListView {
    return [self tagListViewForCategory:self.category];
}

- (void)selectCategory:(CYLSearchCategory)category {
    [self loadViewIfNeeded];
    self.categoryTabBarController.selectedIndex = (NSUInteger)category;
    [self categoryDidChange:category];
}

- (void)categoryDidChange:(CYLSearchCategory)category {
    self.category = category;
    self.searchBar.placeholder = [[self class] placeholderForCategory:category];
    if (category == CYLSearchCategoryJobs) {
        [self.jobCategoryTableView reloadData];
        [self selectJobCategoryAtIndex:self.jobCategoryIndex];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self categoryDidChange:((CYLSearchCategoryPageViewController *)viewController).category];
}

- (void)reloadTagsForCategory:(CYLSearchCategory)category {
    NSArray<CYLExampleMenuSection *> *sections;
    if (category == CYLSearchCategoryJobs) {
        NSString *name = self.jobCategories[self.jobCategoryIndex];
        CYLExampleMenuSection *section = [CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"热搜职位关键词:") titles:[[self class] jobKeywords][name]];
        section.accessoryView = self.industryButton;
        sections = @[section];
    } else {
        sections = [[self class] sectionsForCategory:category];
    }
    CYLExampleMenuSource *source = [CYLExampleMenuSource sourceWithSections:sections];
    self.menuSources[@(category)] = source;
    CYLTagListView *view = [self tagListViewForCategory:category];
    view.menuDataSource = source;
    [view reloadMenuData];
}

- (void)selectJobCategoryAtIndex:(NSUInteger)index {
    self.jobCategoryIndex = MIN(index, self.jobCategories.count - 1);
    NSIndexPath *row = [NSIndexPath indexPathForRow:(NSInteger)self.jobCategoryIndex inSection:0];
    [self.jobCategoryTableView selectRowAtIndexPath:row animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self reloadTagsForCategory:CYLSearchCategoryJobs];
}

- (void)selectIndustry:(NSString *)industry {
    self.industry = industry;
    [self updateIndustryButton];
    [[self tagListViewForCategory:CYLSearchCategoryJobs] reloadMenuData];
}

- (void)updateIndustryButton {
    NSString *industryName = CYLExampleLocalizedString(self.industry);
    [self.industryButton setTitle:[NSString stringWithFormat:CYLExampleLocalizedString(@"行业: %@ ▾"), industryName] forState:UIControlStateNormal];
    // Without the "▾" glyph, which VoiceOver would read aloud.
    self.industryButton.accessibilityLabel = [NSString stringWithFormat:CYLExampleLocalizedString(@"行业 %@"), industryName];
    self.industryButton.accessibilityHint = CYLExampleLocalizedString(@"选择行业");
    [self.industryButton sizeToFit];
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];
    __weak __typeof(self) weakSelf = self;
    for (NSString *industry in [[self class] industries]) {
        UIAction *action = [UIAction actionWithTitle:CYLExampleLocalizedString(industry) image:nil identifier:nil handler:^(__kindof UIAction *a) {
            [weakSelf selectIndustry:industry];
        }];
        action.state = [industry isEqualToString:self.industry] ? UIMenuElementStateOn : UIMenuElementStateOff;
        [actions addObject:action];
    }
    self.industryButton.menu = [UIMenu menuWithTitle:CYLExampleLocalizedString(@"行业") children:actions];
}

#pragma mark CYLMenuDelegate

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NSNumber *category in self.menuSources) {
        if ([self tagListViewForCategory:category.integerValue] == menu) {
            self.searchBar.text = [self.menuSources[category] itemAtIndexPath:indexPath].title;
        }
    }
}

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.jobCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJobCategoryCell forIndexPath:indexPath];
    UIListContentConfiguration *content = [UIListContentConfiguration cellConfiguration];
    content.text = CYLExampleLocalizedString(self.jobCategories[indexPath.row]);
    content.textProperties.alignment = UIListContentTextAlignmentCenter;
    content.textProperties.font = [UIFont systemFontOfSize:15];
    // Longer translations ("Development") wrap or shrink instead of being cut off.
    content.textProperties.numberOfLines = 2;
    content.textProperties.adjustsFontSizeToFitWidth = YES;
    content.textProperties.minimumScaleFactor = 0.7;
    cell.contentConfiguration = content;
    cell.backgroundColor = [UIColor clearColor];
    UIView *selected = [[UIView alloc] init];
    selected.backgroundColor = [UIColor systemBackgroundColor];
    cell.selectedBackgroundView = selected;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectJobCategoryAtIndex:(NSUInteger)indexPath.row];
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end

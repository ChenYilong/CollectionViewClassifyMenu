//
//  CYLSearchCategoryViewController.m
//  CYLMenuExample
//

#import "CYLSearchCategoryViewController.h"
#import "CYLExampleMenuSource.h"

static CGFloat const kJobCategoryWidth = 90;
static NSString * const kJobCategoryCell = @"JobCategoryCell";

@interface CYLSearchCategoryViewController () <CYLMenuDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong, readwrite) UISearchBar *searchBar;
@property (nonatomic, strong, readwrite) UISegmentedControl *categoryControl;
@property (nonatomic, strong, readwrite) CYLTagListView *tagListView;
@property (nonatomic, strong, readwrite) UITableView *jobCategoryTableView;
@property (nonatomic, strong, readwrite) UIButton *industryButton;
@property (nonatomic, assign, readwrite) CYLSearchCategory category;
@property (nonatomic, copy, readwrite) NSString *industry;
@property (nonatomic, strong) CYLExampleMenuSource *menuSource;
@property (nonatomic, copy) NSArray<NSString *> *jobCategories;
@property (nonatomic, assign) NSUInteger jobCategoryIndex;
@property (nonatomic, strong) NSLayoutConstraint *tagListLeading;
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
            return @[[CYLExampleMenuSection sectionWithTitle:@"认识同行" titles:@[@"百度研发", @"腾讯工程师", @"搜狗开发", @"腾讯开发", @"搜狗研究员"]],
                     [CYLExampleMenuSection sectionWithTitle:@"找投资" titles:@[@"创投", @"IDG资本", @"晨兴资本", @"合伙人", @"投资经理"]],
                     [CYLExampleMenuSection sectionWithTitle:@"谈合作" titles:@[@"CEO", @"副总裁", @"VP", @"总经理", @"总监"]],
                     [CYLExampleMenuSection sectionWithTitle:@"挖人才" titles:@[@"Java", @"Android", @"JS", @"C++", @"HTML/CSS", @"iOS", @"PHP", @"前端"]]];
        case CYLSearchCategoryFeeds:
            return @[[CYLExampleMenuSection sectionWithTitle:@"热门动态关键词" titles:@[@"投资", @"创业", @"o2o", @"社交", @"招聘", @"运营", @"线下聚会", @"脉脉", @"融资", @"在线教育", @"硬件", @"电商", @"产品经理"]]];
        case CYLSearchCategoryGossip:
            return @[[CYLExampleMenuSection sectionWithTitle:@"热门词" titles:@[@"百度", @"新浪", @"程序猿", @"离职", @"阿里", @"360", @"创业", @"工资", @"跳槽", @"小三", @"裁员", @"加班", @"女同事", @"产品经理", @"投资人", @"老板"]],
                     [CYLExampleMenuSection sectionWithTitle:@"我关注的标签" titles:@[@"社交", @"移动", @"程序猿"]]];
        case CYLSearchCategoryJobs:
            return @[];
    }
    return @[];
}

+ (NSString *)placeholderForCategory:(CYLSearchCategory)category {
    return @[@"搜人名,职位,公司...", @"搜动态", @"搜八卦", @"搜职位"][category];
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
    self.jobCategories = @[@"开发", @"测试", @"运维/DBA", @"硬件", @"产品", @"运营", @"设计", @"编辑/记者", @"游戏", @"市场BD"];
    self.industry = [[self class] industries].firstObject;

    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.navigationItem.titleView = self.searchBar;

    self.categoryControl = [[UISegmentedControl alloc] initWithItems:@[@"找人", @"动态", @"八卦", @"职位"]];
    self.categoryControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.categoryControl addTarget:self action:@selector(categoryChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.categoryControl];

    self.jobCategoryTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.jobCategoryTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.jobCategoryTableView.dataSource = self;
    self.jobCategoryTableView.delegate = self;
    self.jobCategoryTableView.rowHeight = 50;
    self.jobCategoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.jobCategoryTableView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    [self.jobCategoryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kJobCategoryCell];
    [self.view addSubview:self.jobCategoryTableView];

    // A header accessory supplied by the host, not drawn by the menu.
    self.industryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.industryButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.industryButton.showsMenuAsPrimaryAction = YES;
    [self updateIndustryButton];

    self.tagListView = [[CYLTagListView alloc] init];
    self.tagListView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tagListView.style = [[self class] maimaiStyle];
    self.tagListView.selectionMode = CYLMenuSelectionModeNone;
    self.tagListView.menuDelegate = self;
    [self.view addSubview:self.tagListView];

    self.tagListLeading = [self.tagListView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.categoryControl.topAnchor constraintEqualToAnchor:safe.topAnchor constant:8],
        [self.categoryControl.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [self.categoryControl.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [self.jobCategoryTableView.topAnchor constraintEqualToAnchor:self.categoryControl.bottomAnchor constant:8],
        [self.jobCategoryTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.jobCategoryTableView.widthAnchor constraintEqualToConstant:kJobCategoryWidth],
        [self.jobCategoryTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.tagListView.topAnchor constraintEqualToAnchor:self.categoryControl.bottomAnchor constant:8],
        self.tagListLeading,
        [self.tagListView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tagListView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    [self selectCategory:CYLSearchCategoryPeople];
}

#pragma mark Category

- (void)categoryChanged {
    [self selectCategory:(CYLSearchCategory)self.categoryControl.selectedSegmentIndex];
}

- (void)selectCategory:(CYLSearchCategory)category {
    self.category = category;
    self.categoryControl.selectedSegmentIndex = category;
    self.searchBar.placeholder = [[self class] placeholderForCategory:category];
    BOOL jobs = category == CYLSearchCategoryJobs;
    self.jobCategoryTableView.hidden = !jobs;
    self.tagListLeading.constant = jobs ? kJobCategoryWidth : 0;
    if (jobs) {
        [self.jobCategoryTableView reloadData];
        [self selectJobCategoryAtIndex:self.jobCategoryIndex];
    } else {
        [self showSections:[[self class] sectionsForCategory:category]];
    }
}

- (void)showSections:(NSArray<CYLExampleMenuSection *> *)sections {
    self.menuSource = [CYLExampleMenuSource sourceWithSections:sections];
    self.tagListView.menuDataSource = self.menuSource;
    [self.tagListView reloadMenuData];
    [self.view setNeedsLayout];
}

- (void)selectJobCategoryAtIndex:(NSUInteger)index {
    self.jobCategoryIndex = MIN(index, self.jobCategories.count - 1);
    NSIndexPath *row = [NSIndexPath indexPathForRow:(NSInteger)self.jobCategoryIndex inSection:0];
    [self.jobCategoryTableView selectRowAtIndexPath:row animated:NO scrollPosition:UITableViewScrollPositionNone];
    NSString *name = self.jobCategories[self.jobCategoryIndex];
    CYLExampleMenuSection *section = [CYLExampleMenuSection sectionWithTitle:@"热搜职位关键词:" titles:[[self class] jobKeywords][name]];
    section.accessoryView = self.industryButton;
    [self showSections:@[section]];
}

- (void)selectIndustry:(NSString *)industry {
    self.industry = industry;
    [self updateIndustryButton];
    [self.tagListView reloadMenuData];
}

- (void)updateIndustryButton {
    [self.industryButton setTitle:[NSString stringWithFormat:@"行业: %@ ▾", self.industry] forState:UIControlStateNormal];
    [self.industryButton sizeToFit];
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];
    __weak __typeof(self) weakSelf = self;
    for (NSString *industry in [[self class] industries]) {
        UIAction *action = [UIAction actionWithTitle:industry image:nil identifier:nil handler:^(__kindof UIAction *a) {
            [weakSelf selectIndustry:industry];
        }];
        action.state = [industry isEqualToString:self.industry] ? UIMenuElementStateOn : UIMenuElementStateOff;
        [actions addObject:action];
    }
    self.industryButton.menu = [UIMenu menuWithTitle:@"行业" children:actions];
}

#pragma mark CYLMenuDelegate

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.searchBar.text = [self.menuSource itemAtIndexPath:indexPath].title;
}

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.jobCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJobCategoryCell forIndexPath:indexPath];
    UIListContentConfiguration *content = [UIListContentConfiguration cellConfiguration];
    content.text = self.jobCategories[indexPath.row];
    content.textProperties.alignment = UIListContentTextAlignmentCenter;
    content.textProperties.font = [UIFont systemFontOfSize:15];
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

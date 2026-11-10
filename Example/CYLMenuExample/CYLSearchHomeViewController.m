//
//  CYLSearchHomeViewController.m
//  CYLMenuExample
//

#import "CYLSearchHomeViewController.h"
#import "CYLSearchCategoryViewController.h"
#import "CYLExampleLocalization.h"

@interface CYLSearchHomeViewController ()
@property (nonatomic, strong, readwrite) UIButton *searchButton;
@end

@implementation CYLSearchHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigationItem, not title: a view controller's title would replace its tab's title.
    self.navigationItem.title = CYLExampleLocalizedString(@"脉脉搜索");
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    UIButtonConfiguration *configuration = [UIButtonConfiguration grayButtonConfiguration];
    configuration.title = CYLExampleLocalizedString(@"搜人名,职位,公司...");
    configuration.image = [UIImage systemImageNamed:@"magnifyingglass"];
    configuration.imagePadding = 8;
    configuration.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
    configuration.baseForegroundColor = [UIColor secondaryLabelColor];
    configuration.contentInsets = NSDirectionalEdgeInsetsMake(12, 16, 12, 16);
    self.searchButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    self.searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    [self.searchButton addTarget:self action:@selector(openSearch) forControlEvents:UIControlEventTouchUpInside];

    UILabel *hint = [[UILabel alloc] init];
    hint.text = CYLExampleLocalizedString(@"按分类浏览热门标签：找人、动态、八卦、职位");
    hint.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    hint.adjustsFontForContentSizeCategory = YES;
    hint.textColor = [UIColor secondaryLabelColor];
    hint.numberOfLines = 0;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.searchButton, hint]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:safe.topAnchor constant:16],
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
    ]];
}

- (CYLSearchCategoryViewController *)openSearch {
    CYLSearchCategoryViewController *search = [[CYLSearchCategoryViewController alloc] init];
    // Tab bars stay at the bottom and are hidden for pushed screens.
    search.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:search animated:YES];
    return search;
}

@end

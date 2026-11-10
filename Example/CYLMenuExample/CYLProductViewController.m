//
//  CYLProductViewController.m
//  CYLMenuExample
//

#import "CYLProductViewController.h"
#import "CYLReviewListViewController.h"
#import "CYLReviewStore.h"
#import "CYLExampleMenuSource.h"
#import "CYLExampleLocalization.h"

@interface CYLProductViewController () <CYLMenuDelegate>
@property (nonatomic, strong, readwrite) CYLTagListView *previewView;
@property (nonatomic, strong) CYLExampleMenuSource *previewSource;
/// Maps preview items to indexes in CYLReviewStore.filters.
@property (nonatomic, copy) NSArray<NSNumber *> *previewFilterIndexes;
@property (nonatomic, strong) NSLayoutConstraint *previewHeight;
@end

@implementation CYLProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigationItem, not title: a view controller's title would replace its tab's title.
    self.navigationItem.title = CYLExampleLocalizedString(@"宝贝详情");
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    CYLReviewStore *store = [CYLReviewStore sharedStore];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 1;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:stack];

    UILabel *name = [self labelWithText:@"潮牌电镀镜面MLGB字母iphone6手机壳苹果6plus手机壳情侣5S外壳潮" font:[UIFont systemFontOfSize:16] color:[UIColor labelColor]];
    UILabel *price = [self labelWithText:@"¥9.90-14.90" font:[UIFont boldSystemFontOfSize:22] color:[UIColor colorWithRed:1 green:0.31 blue:0 alpha:1]];
    UILabel *reviewTitle = [self labelWithText:[NSString stringWithFormat:CYLExampleLocalizedString(@"宝贝评价(%lu)"), (unsigned long)store.reviews.count]
                                          font:[UIFont systemFontOfSize:15] color:[UIColor labelColor]];

    // Keyword chips only, two rows, no fold control: a preview of the review page.
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *indexes = [NSMutableArray array];
    [store.filters enumerateObjectsUsingBlock:^(CYLReviewFilter *filter, NSUInteger idx, BOOL *stop) {
        if (filter.isKeyword) {
            CYLExampleMenuItem *item = [CYLExampleMenuItem itemWithTitle:[store titleForFilter:filter]];
            [items addObject:item];
            [indexes addObject:@(idx)];
        }
    }];
    self.previewFilterIndexes = indexes;
    self.previewSource = [CYLExampleMenuSource sourceWithSections:@[[CYLExampleMenuSection sectionWithTitle:CYLExampleLocalizedString(@"关键词") items:items]]];
    CYLMenuStyle *style = [CYLReviewListViewController reviewFilterStyle];
    style.sectionInsets = UIEdgeInsetsMake(4, 0, 12, 0);
    self.previewView = [[CYLTagListView alloc] init];
    self.previewView.style = style;
    self.previewView.selectionMode = CYLMenuSelectionModeNone;
    self.previewView.showsSectionHeaders = NO;
    self.previewView.foldStyle = CYLMenuFoldStyleTruncate;
    self.previewView.defaultVisibleRows = 2;
    self.previewView.scrollEnabled = NO;
    self.previewView.menuDelegate = self;
    self.previewView.menuDataSource = self.previewSource;
    [self.previewView reloadMenuData];
    self.previewHeight = [self.previewView.heightAnchor constraintEqualToConstant:[self.previewView heightThatFitsWidth:CGRectGetWidth(self.view.bounds) - 32]];
    self.previewHeight.active = YES;

    UIView *reviewBlock = [[UIView alloc] init];
    reviewBlock.backgroundColor = [UIColor systemBackgroundColor];
    UIStackView *reviewStack = [[UIStackView alloc] initWithArrangedSubviews:@[reviewTitle, self.previewView]];
    reviewStack.axis = UILayoutConstraintAxisVertical;
    reviewStack.spacing = 6;
    reviewStack.layoutMarginsRelativeArrangement = YES;
    reviewStack.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
    reviewStack.translatesAutoresizingMaskIntoConstraints = NO;
    [reviewBlock addSubview:reviewStack];
    for (CYLReview *review in [store.reviews subarrayWithRange:NSMakeRange(0, MIN(2, store.reviews.count))]) {
        UILabel *label = [self labelWithText:[NSString stringWithFormat:@"%@\n%@", review.user, review.text]
                                        font:[UIFont systemFontOfSize:13] color:[UIColor secondaryLabelColor]];
        [reviewStack addArrangedSubview:label];
    }
    UIButton *more = [UIButton buttonWithType:UIButtonTypeSystem];
    [more setTitle:CYLExampleLocalizedString(@"查看更多评价") forState:UIControlStateNormal];
    [more addTarget:self action:@selector(moreTapped) forControlEvents:UIControlEventTouchUpInside];
    [more.heightAnchor constraintEqualToConstant:44].active = YES;
    [reviewStack addArrangedSubview:more];
    [NSLayoutConstraint activateConstraints:@[
        [reviewStack.topAnchor constraintEqualToAnchor:reviewBlock.topAnchor constant:8],
        [reviewStack.leadingAnchor constraintEqualToAnchor:reviewBlock.leadingAnchor],
        [reviewStack.trailingAnchor constraintEqualToAnchor:reviewBlock.trailingAnchor],
        [reviewStack.bottomAnchor constraintEqualToAnchor:reviewBlock.bottomAnchor],
    ]];

    for (UIView *view in @[[self cardWithViews:@[name, price]], reviewBlock]) {
        [stack addArrangedSubview:view];
    }
    UILayoutGuide *frame = scrollView.frameLayoutGuide;
    UILayoutGuide *content = scrollView.contentLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:content.topAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:content.bottomAnchor],
        [stack.leadingAnchor constraintEqualToAnchor:frame.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:frame.trailingAnchor],
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.previewView.bounds) ?: CGRectGetWidth(self.view.bounds) - 32;
    CGFloat height = [self.previewView heightThatFitsWidth:width];
    if (fabs(self.previewHeight.constant - height) > 0.5) {
        self.previewHeight.constant = height;
    }
}

- (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

- (UIView *)cardWithViews:(NSArray<UIView *> *)views {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor systemBackgroundColor];
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:views];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:12],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-12],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
    ]];
    return card;
}

- (void)moreTapped {
    [self showReviewsWithFilterIndex:0];
}

- (void)showReviewsWithFilterIndex:(NSUInteger)index {
    CYLReviewListViewController *reviews = [[CYLReviewListViewController alloc] initWithSelectedFilterIndex:index];
    reviews.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:reviews animated:YES];
}

#pragma mark CYLMenuDelegate

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showReviewsWithFilterIndex:self.previewFilterIndexes[indexPath.item].unsignedIntegerValue];
}

@end

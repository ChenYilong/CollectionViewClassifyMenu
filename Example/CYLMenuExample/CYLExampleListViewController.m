//
//  CYLExampleListViewController.m
//  CYLMenuExample
//

#import "CYLExampleListViewController.h"
#import "CYLProductViewController.h"
#import "CYLSearchCategoryViewController.h"

static NSString * const kExampleCell = @"ExampleCell";

@implementation CYLExampleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CYLTagListView 示例";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kExampleCell];
}

- (NSArray<NSArray<NSString *> *> *)rows {
    return @[@[@"场景一：淘宝评价筛选", @"可折叠、单选、带图标和数量的评价标签；商品页显示两行预览"],
             @[@"场景二：脉脉搜索分类", @"搜索框 + 分类标签；职位页左侧类别、右侧关键词与行业选择"]];
}

- (UIViewController *)viewControllerForRow:(NSInteger)row {
    return row == 0 ? [[CYLProductViewController alloc] init] : [[CYLSearchCategoryViewController alloc] init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self rows].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExampleCell forIndexPath:indexPath];
    UIListContentConfiguration *content = [UIListContentConfiguration subtitleCellConfiguration];
    content.text = [self rows][indexPath.row][0];
    content.secondaryText = [self rows][indexPath.row][1];
    content.secondaryTextProperties.color = [UIColor secondaryLabelColor];
    cell.contentConfiguration = content;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[self viewControllerForRow:indexPath.row] animated:YES];
}

@end

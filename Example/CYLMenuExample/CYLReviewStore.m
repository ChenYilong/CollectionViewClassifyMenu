//
//  CYLReviewStore.m
//  CYLMenuExample
//

#import "CYLReviewStore.h"

@implementation CYLReview
@end

@implementation CYLReviewFilter
@end

@interface CYLReviewStore ()
@property (nonatomic, copy, readwrite) NSArray<CYLReview *> *reviews;
@property (nonatomic, copy, readwrite) NSArray<CYLReviewFilter *> *filters;
@end

@implementation CYLReviewStore

+ (instancetype)sharedStore {
    static CYLReviewStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[self alloc] init];
    });
    return store;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _reviews = [[self class] mockReviews];
        _filters = [[self class] filters];
    }
    return self;
}

+ (CYLReview *)reviewWithUser:(NSString *)user text:(NSString *)text date:(NSString *)date sku:(NSString *)sku
                       rating:(CYLReviewRating)rating photo:(BOOL)photo followUp:(BOOL)followUp
                     keywords:(NSArray<NSString *> *)keywords {
    CYLReview *review = [[CYLReview alloc] init];
    review.user = user;
    review.text = text;
    review.date = date;
    review.sku = sku;
    review.rating = rating;
    review.hasPhoto = photo;
    review.hasFollowUp = followUp;
    review.keywords = keywords;
    return review;
}

+ (NSArray<CYLReview *> *)mockReviews {
    NSString *pink = @"颜色分类:苹果6 4.7【镜面粉字】";
    NSString *white = @"颜色分类:苹果6plus【白边白字】";
    return @[
        [self reviewWithUser:@"1**1" text:@"这是我买的第二个了，太棒了，酷毙了，又能当化妆镜，又能当手机壳，价格真的很实惠，质量也不错。" date:@"2015-06-17" sku:pink rating:CYLReviewRatingGood photo:YES followUp:NO keywords:@[@"手机套不错", @"质量不错", @"划算"]],
        [self reviewWithUser:@"雨**4" text:@"刚收到就拆卡看壳，然后手机壳上有一层膜，没看到，找了卖家，卖家非常细心的解说，宝贝不错。" date:@"2015-06-16" sku:white rating:CYLReviewRatingGood photo:NO followUp:NO keywords:@[@"态度不错", @"手机套不错"]],
        [self reviewWithUser:@"j**8" text:@"太炫了，闪瞎眼，质量蛮不错的非常超值，好几个朋友看了都说也要买。" date:@"2015-06-12" sku:pink rating:CYLReviewRatingGood photo:NO followUp:YES keywords:@[@"质量不错", @"划算"]],
        [self reviewWithUser:@"杨**6" text:@"已经第N次购买了，不管是老板还是客服都非常好，东西更加不用说，超级靓。" date:@"2015-06-13" sku:white rating:CYLReviewRatingGood photo:YES followUp:NO keywords:@[@"态度不错", @"质量不错"]],
        [self reviewWithUser:@"小**猫" text:@"颜色很正，和图片一样，镜面效果很好，就是有点容易留指纹。" date:@"2015-06-11" sku:pink rating:CYLReviewRatingGood photo:YES followUp:YES keywords:@[@"颜色不错"]],
        [self reviewWithUser:@"t**2" text:@"背面细节一般，边缘有一点毛刺，不过这个价格可以接受。" date:@"2015-06-10" sku:white rating:CYLReviewRatingNeutral photo:NO followUp:NO keywords:@[@"背面细节一般"]],
        [self reviewWithUser:@"阿**宝" text:@"手机壳很薄，手感好，颜色也漂亮，推荐购买。" date:@"2015-06-09" sku:pink rating:CYLReviewRatingGood photo:NO followUp:NO keywords:@[@"手机套不错", @"颜色不错"]],
        [self reviewWithUser:@"z**9" text:@"物流很快，第二天就到了，壳子做工精细，背面细节一般。" date:@"2015-06-08" sku:white rating:CYLReviewRatingGood photo:YES followUp:NO keywords:@[@"质量不错", @"背面细节一般"]],
        [self reviewWithUser:@"大**熊" text:@"给女朋友买的，她很喜欢，客服回复也很及时。" date:@"2015-06-07" sku:pink rating:CYLReviewRatingGood photo:NO followUp:YES keywords:@[@"态度不错"]],
        [self reviewWithUser:@"m**0" text:@"性价比高，用了一周没有掉色，会回购。" date:@"2015-06-05" sku:white rating:CYLReviewRatingGood photo:NO followUp:NO keywords:@[@"划算", @"质量不错"]],
    ];
}

+ (CYLReviewFilter *)filterNamed:(NSString *)name symbol:(NSString *)symbol color:(UIColor *)color
                         keyword:(BOOL)keyword matches:(BOOL (^)(CYLReview *review))matches {
    CYLReviewFilter *filter = [[CYLReviewFilter alloc] init];
    filter.name = name;
    filter.keyword = keyword;
    filter.matches = matches;
    if (symbol) {
        filter.image = [[UIImage systemImageNamed:symbol] imageWithTintColor:color renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    return filter;
}

+ (NSArray<CYLReviewFilter *> *)filters {
    UIColor *orange = [UIColor colorWithRed:1 green:0.45 blue:0.1 alpha:1];
    NSMutableArray *filters = [NSMutableArray arrayWithArray:@[
        [self filterNamed:@"全部" symbol:nil color:orange keyword:NO matches:^BOOL(CYLReview *r) { return YES; }],
        [self filterNamed:@"好评" symbol:@"hand.thumbsup.fill" color:orange keyword:NO matches:^BOOL(CYLReview *r) { return r.rating == CYLReviewRatingGood; }],
        [self filterNamed:@"中评" symbol:@"hand.raised.fill" color:orange keyword:NO matches:^BOOL(CYLReview *r) { return r.rating == CYLReviewRatingNeutral; }],
        [self filterNamed:@"差评" symbol:@"hand.thumbsdown.fill" color:[UIColor grayColor] keyword:NO matches:^BOOL(CYLReview *r) { return r.rating == CYLReviewRatingBad; }],
        [self filterNamed:@"有图" symbol:nil color:orange keyword:NO matches:^BOOL(CYLReview *r) { return r.hasPhoto; }],
        [self filterNamed:@"追加" symbol:nil color:orange keyword:NO matches:^BOOL(CYLReview *r) { return r.hasFollowUp; }],
    ]];
    for (NSString *keyword in @[@"手机套不错", @"质量不错", @"态度不错", @"划算", @"颜色不错", @"背面细节一般"]) {
        [filters addObject:[self filterNamed:keyword symbol:nil color:orange keyword:YES matches:^BOOL(CYLReview *r) {
            return [r.keywords containsObject:keyword];
        }]];
    }
    return filters;
}

- (NSArray<CYLReview *> *)reviewsMatchingFilter:(CYLReviewFilter *)filter {
    NSMutableArray *result = [NSMutableArray array];
    for (CYLReview *review in self.reviews) {
        if (filter.matches(review)) {
            [result addObject:review];
        }
    }
    return result;
}

- (NSString *)titleForFilter:(CYLReviewFilter *)filter {
    if ([filter.name isEqualToString:@"全部"]) {
        return filter.name;
    }
    return [NSString stringWithFormat:@"%@(%lu)", filter.name, (unsigned long)[self reviewsMatchingFilter:filter].count];
}

@end

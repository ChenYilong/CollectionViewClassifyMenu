//
//  CYLReviewQuery.m
//  CYLMenuExample
//

#import "CYLReviewQuery.h"

@implementation CYLMemoryReviewQuery

- (CYLReviewFilteringMode)mode {
    return CYLReviewFilteringModeMemory;
}

- (BOOL)isLoading {
    return NO;
}

- (void)fetchReviewsMatchingFilters:(NSArray<CYLReviewFilter *> *)filters completion:(CYLReviewQueryCompletion)completion {
    completion([[CYLReviewStore sharedStore] reviewsMatchingAllFilters:filters]);
}

@end

@implementation CYLReviewServer

+ (NSArray<CYLReview *> *)reviewsForRequestURL:(NSURL *)URL {
    CYLReviewStore *store = [CYLReviewStore sharedStore];
    NSMutableArray *filters = [NSMutableArray array];
    for (NSURLQueryItem *item in [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO].queryItems) {
        CYLReviewFilter *filter = [item.name isEqualToString:@"filter"] ? [store filterWithIdentifier:item.value] : nil;
        if (filter) {
            [filters addObject:filter];
        }
    }
    return [store reviewsMatchingAllFilters:filters];
}

@end

@interface CYLNetworkReviewQuery ()
@property (nonatomic, assign, readwrite, getter=isLoading) BOOL loading;
@property (nonatomic, strong, readwrite, nullable) NSURL *lastRequestURL;
@property (nonatomic, assign, readwrite) NSUInteger requestCount;
@property (nonatomic, assign, readwrite) NSUInteger droppedResponseCount;
@end

@implementation CYLNetworkReviewQuery

- (instancetype)init {
    self = [super init];
    if (self) {
        _latency = 0.6;
    }
    return self;
}

- (CYLReviewFilteringMode)mode {
    return CYLReviewFilteringModeNetwork;
}

+ (NSURL *)requestURLForFilters:(NSArray<CYLReviewFilter *> *)filters {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://api.example.com/reviews"];
    NSMutableArray *items = [NSMutableArray array];
    for (CYLReviewFilter *filter in filters) {
        [items addObject:[NSURLQueryItem queryItemWithName:@"filter" value:filter.identifier]];
    }
    components.queryItems = items.count > 0 ? items : nil;
    return components.URL;
}

- (void)fetchReviewsMatchingFilters:(NSArray<CYLReviewFilter *> *)filters completion:(CYLReviewQueryCompletion)completion {
    NSURL *URL = [[self class] requestURLForFilters:filters];
    self.lastRequestURL = URL;
    NSUInteger request = ++self.requestCount;
    self.loading = YES;
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.latency * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        if (request != self.requestCount) {
            // The user changed the filters again: this response is out of date.
            self.droppedResponseCount++;
            return;
        }
        self.loading = NO;
        completion([CYLReviewServer reviewsForRequestURL:URL]);
    });
}

@end

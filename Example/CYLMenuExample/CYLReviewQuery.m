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

@interface CYLDatabaseReviewQuery ()
@property (nonatomic, strong, readwrite, nullable) CYLExampleSQLQuery *lastQuery;
@end

@implementation CYLDatabaseReviewQuery

- (instancetype)init {
    return [self initWithDatabase:[CYLExampleDatabase sharedDatabase]];
}

- (instancetype)initWithDatabase:(CYLExampleDatabase *)database {
    self = [super init];
    if (self) {
        _database = database;
    }
    return self;
}

- (CYLReviewFilteringMode)mode {
    return CYLReviewFilteringModeDatabase;
}

- (BOOL)isLoading {
    return NO;
}

+ (CYLExampleSQLQuery *)queryForFilters:(NSArray<CYLReviewFilter *> *)filters {
    NSMutableArray<NSString *> *conditions = [NSMutableArray array];
    NSMutableArray *arguments = [NSMutableArray array];
    NSDictionary<NSString *, NSNumber *> *ratings = @{@"good": @(CYLReviewRatingGood), @"neutral": @(CYLReviewRatingNeutral), @"bad": @(CYLReviewRatingBad)};
    for (CYLReviewFilter *filter in filters) {
        NSString *identifier = filter.identifier;
        if (ratings[identifier]) {
            [conditions addObject:@"r.rating = ?"];
            [arguments addObject:ratings[identifier]];
        } else if ([identifier isEqualToString:@"photo"]) {
            [conditions addObject:@"r.has_photo = 1"];
        } else if ([identifier isEqualToString:@"followup"]) {
            [conditions addObject:@"r.has_follow_up = 1"];
        } else if (filter.isKeyword) {
            [conditions addObject:@"EXISTS (SELECT 1 FROM review_keywords k WHERE k.review_id = r.id AND k.keyword = ?)"];
            [arguments addObject:filter.name];
        }
    }
    NSString *SQL = @"SELECT r.id FROM reviews r";
    if (conditions.count > 0) {
        SQL = [SQL stringByAppendingFormat:@" WHERE %@", [conditions componentsJoinedByString:@" AND "]];
    }
    return [CYLExampleSQLQuery querySQL:[SQL stringByAppendingString:@" ORDER BY r.id"] arguments:arguments];
}

- (void)fetchReviewsMatchingFilters:(NSArray<CYLReviewFilter *> *)filters completion:(CYLReviewQueryCompletion)completion {
    CYLExampleSQLQuery *query = [[self class] queryForFilters:filters];
    self.lastQuery = query;
    NSError *error = nil;
    NSArray *rows = [self.database rowsForQuery:query error:&error];
    if (!rows) {
        NSLog(@"[CYLMenuExample] %@: %@", query.SQL, error);
    }
    NSArray<CYLReview *> *reviews = [CYLReviewStore sharedStore].reviews;
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *row in rows) {
        NSUInteger index = [row[@"id"] unsignedIntegerValue];
        if (index < reviews.count) {
            [result addObject:reviews[index]];
        }
    }
    completion(result);
}

@end

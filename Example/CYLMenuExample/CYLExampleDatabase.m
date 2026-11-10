//
//  CYLExampleDatabase.m
//  CYLMenuExample
//

#import "CYLExampleDatabase.h"
#import <sqlite3.h>
#import "CYLReviewStore.h"
// The original app's demo data, compiled from CollectionViewClassifyMenu/Class (shared, not copied).
#import "../../CollectionViewClassifyMenu/Class/Other/Tool/CYLDBManager.h"
#import "../../CollectionViewClassifyMenu/Class/ClassifyMenu/Controller/CYLDemoDataSource.h"

NSErrorDomain const CYLExampleDatabaseErrorDomain = @"CYLExampleDatabaseErrorDomain";

@implementation CYLExampleSQLQuery

+ (instancetype)querySQL:(NSString *)SQL arguments:(NSArray *)arguments {
    CYLExampleSQLQuery *query = [[self alloc] init];
    query->_SQL = [SQL copy];
    query->_arguments = [arguments copy] ?: @[];
    return query;
}

- (NSString *)displayString {
    NSMutableString *result = [NSMutableString string];
    NSArray<NSString *> *parts = [self.SQL componentsSeparatedByString:@"?"];
    for (NSUInteger index = 0; index < parts.count; index++) {
        [result appendString:parts[index]];
        if (index + 1 < parts.count) {
            id value = index < self.arguments.count ? self.arguments[index] : [NSNull null];
            if ([value isKindOfClass:[NSString class]]) {
                [result appendFormat:@"'%@'", [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
            } else if ([value isKindOfClass:[NSNumber class]]) {
                [result appendString:[value stringValue]];
            } else {
                [result appendString:@"NULL"];
            }
        }
    }
    return result;
}

@end

@interface CYLExampleDatabase () {
    sqlite3 *_handle;
}
@end

@implementation CYLExampleDatabase

+ (instancetype)sharedDatabase {
    static CYLExampleDatabase *database;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *caches = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].firstObject;
        NSString *path = [caches URLByAppendingPathComponent:@"CYLMenuExample.sqlite"].path;
        NSError *error = nil;
        database = [[self alloc] initWithPath:path error:&error];
        if (!database) {
            NSLog(@"[CYLMenuExample] Cannot open %@ (%@), using an in-memory database.", path, error);
            database = [[self alloc] initWithPath:@":memory:" error:NULL];
        }
    });
    return database;
}

- (instancetype)initWithPath:(NSString *)path error:(NSError **)error {
    self = [super init];
    if (self) {
        _path = [path copy];
        if (sqlite3_open_v2(path.fileSystemRepresentation, &_handle, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) != SQLITE_OK) {
            if (error) *error = [self lastError];
            sqlite3_close(_handle);
            _handle = NULL;
            return nil;
        }
        if (![self createTables:error] || ![self fillTables:error]) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    if (_handle) {
        sqlite3_close(_handle);
    }
}

- (NSError *)lastError {
    const char *message = _handle ? sqlite3_errmsg(_handle) : "cannot open the database";
    return [NSError errorWithDomain:CYLExampleDatabaseErrorDomain code:_handle ? sqlite3_errcode(_handle) : SQLITE_CANTOPEN
                           userInfo:@{NSLocalizedDescriptionKey: @(message)}];
}

#pragma mark Statements

- (sqlite3_stmt *)preparedStatement:(NSString *)SQL arguments:(NSArray *)arguments error:(NSError **)error {
    sqlite3_stmt *statement = NULL;
    if (sqlite3_prepare_v2(_handle, SQL.UTF8String, -1, &statement, NULL) != SQLITE_OK) {
        if (error) *error = [self lastError];
        return NULL;
    }
    int index = 1;
    for (id value in arguments) {
        int result;
        if ([value isKindOfClass:[NSString class]]) {
            result = sqlite3_bind_text(statement, index, [value UTF8String], -1, SQLITE_TRANSIENT);
        } else if ([value isKindOfClass:[NSNumber class]]) {
            const char *type = [value objCType];
            BOOL floating = strcmp(type, @encode(double)) == 0 || strcmp(type, @encode(float)) == 0;
            result = floating ? sqlite3_bind_double(statement, index, [value doubleValue])
                              : sqlite3_bind_int64(statement, index, [value longLongValue]);
        } else {
            result = sqlite3_bind_null(statement, index);
        }
        if (result != SQLITE_OK) {
            if (error) *error = [self lastError];
            sqlite3_finalize(statement);
            return NULL;
        }
        index++;
    }
    return statement;
}

- (BOOL)executeSQL:(NSString *)SQL arguments:(NSArray *)arguments error:(NSError **)error {
    sqlite3_stmt *statement = [self preparedStatement:SQL arguments:arguments error:error];
    if (!statement) {
        return NO;
    }
    int result = sqlite3_step(statement);
    sqlite3_finalize(statement);
    if (result != SQLITE_DONE && result != SQLITE_ROW) {
        if (error) *error = [self lastError];
        return NO;
    }
    return YES;
}

- (NSArray<NSDictionary<NSString *, id> *> *)rowsForSQL:(NSString *)SQL arguments:(NSArray *)arguments error:(NSError **)error {
    sqlite3_stmt *statement = [self preparedStatement:SQL arguments:arguments error:error];
    if (!statement) {
        return nil;
    }
    NSMutableArray *rows = [NSMutableArray array];
    int result;
    while ((result = sqlite3_step(statement)) == SQLITE_ROW) {
        NSMutableDictionary *row = [NSMutableDictionary dictionary];
        for (int column = 0; column < sqlite3_column_count(statement); column++) {
            NSString *name = @(sqlite3_column_name(statement, column));
            switch (sqlite3_column_type(statement, column)) {
                case SQLITE_INTEGER: row[name] = @(sqlite3_column_int64(statement, column)); break;
                case SQLITE_FLOAT: row[name] = @(sqlite3_column_double(statement, column)); break;
                case SQLITE_TEXT: row[name] = @((const char *)sqlite3_column_text(statement, column)); break;
                default: row[name] = [NSNull null]; break;
            }
        }
        [rows addObject:row];
    }
    sqlite3_finalize(statement);
    if (result != SQLITE_DONE) {
        if (error) *error = [self lastError];
        return nil;
    }
    return rows;
}

- (NSArray<NSDictionary<NSString *, id> *> *)rowsForQuery:(CYLExampleSQLQuery *)query error:(NSError **)error {
    return [self rowsForSQL:query.SQL arguments:query.arguments error:error];
}

- (BOOL)inTransaction:(BOOL (^)(CYLExampleDatabase *))block {
    if (![self executeSQL:@"BEGIN" arguments:nil error:NULL]) {
        return NO;
    }
    BOOL ok = block(self);
    [self executeSQL:ok ? @"COMMIT" : @"ROLLBACK" arguments:nil error:NULL];
    return ok;
}

- (NSInteger)countOfTable:(NSString *)table {
    NSString *SQL = [NSString stringWithFormat:@"SELECT COUNT(*) AS n FROM \"%@\"", [table stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
    return [[[self rowsForSQL:SQL arguments:nil error:NULL].firstObject objectForKey:@"n"] integerValue];
}

#pragma mark Schema and data

- (BOOL)createTables:(NSError **)error {
    NSArray<NSString *> *statements = @[
        @"PRAGMA foreign_keys = ON",
        @"DROP TABLE IF EXISTS review_keywords",
        @"DROP TABLE IF EXISTS reviews",
        @"DROP TABLE IF EXISTS places",
        @"CREATE TABLE reviews (id INTEGER PRIMARY KEY, user TEXT NOT NULL, text TEXT NOT NULL, date TEXT NOT NULL, "
         "sku TEXT NOT NULL, rating INTEGER NOT NULL, has_photo INTEGER NOT NULL, has_follow_up INTEGER NOT NULL)",
        @"CREATE TABLE review_keywords (review_id INTEGER NOT NULL REFERENCES reviews(id), keyword TEXT NOT NULL)",
        @"CREATE INDEX review_keywords_keyword ON review_keywords(keyword)",
        @"CREATE TABLE places (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL, tag TEXT NOT NULL, "
         "region TEXT NOT NULL, rating REAL NOT NULL, price INTEGER NOT NULL)",
        @"CREATE INDEX places_tag ON places(tag)",
        @"CREATE INDEX places_region ON places(region)",
        @"CREATE TABLE IF NOT EXISTS selections (scenario TEXT NOT NULL, section INTEGER NOT NULL, item INTEGER NOT NULL)",
    ];
    for (NSString *SQL in statements) {
        if (![self executeSQL:SQL arguments:nil error:error]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)fillTables:(NSError **)error {
    __block NSError *fillError = nil;
    BOOL ok = [self inTransaction:^BOOL(CYLExampleDatabase *database) {
        // Scenario 1: the reviews, with their position in CYLReviewStore as id.
        NSArray<CYLReview *> *reviews = [CYLReviewStore sharedStore].reviews;
        for (NSUInteger index = 0; index < reviews.count; index++) {
            CYLReview *review = reviews[index];
            if (![database executeSQL:@"INSERT INTO reviews VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
                            arguments:@[@(index), review.user, review.text, review.date, review.sku, @(review.rating),
                                        @(review.hasPhoto), @(review.hasFollowUp)] error:&fillError]) {
                return NO;
            }
            for (NSString *keyword in review.keywords) {
                if (![database executeSQL:@"INSERT INTO review_keywords VALUES (?, ?)" arguments:@[@(index), keyword] error:&fillError]) {
                    return NO;
                }
            }
        }
        // The classify menu demo: every tag of data.json (CYLDBManager, from the original app), in
        // some of the regions of its filter.
        NSArray<NSString *> *regions = [CYLDemoDataSource regions];
        NSInteger placeID = 0, tagIndex = 0;
        for (NSDictionary *category in [CYLDBManager dataSource]) {
            NSString *type = category[@"Type"];
            for (NSDictionary *item in category[kDataSourceSectionKey]) {
                NSString *tag = item[kDataSourceCellTextKey];
                for (NSUInteger region = 0; region < regions.count; region++) {
                    if ((tagIndex + (NSInteger)region) % 3 == 2) {
                        continue;
                    }
                    double rating = 3.5 + (double)((tagIndex * 7 + (NSInteger)region * 3) % 16) / 10.0;
                    NSInteger price = 30 + ((tagIndex * 37 + (NSInteger)region * 53) % 270);
                    NSString *name = [NSString stringWithFormat:@"%@ · %@", [CYLDemoDataSource shortTitleForTitle:tag],
                                      [CYLDemoDataSource shortTitleForTitle:regions[region]]];
                    if (![database executeSQL:@"INSERT INTO places VALUES (?, ?, ?, ?, ?, ?, ?)"
                                    arguments:@[@(placeID++), name, type, tag, regions[region], @(rating), @(price)] error:&fillError]) {
                        return NO;
                    }
                }
                tagIndex++;
            }
        }
        return YES;
    }];
    if (!ok && error) *error = fillError ?: [self lastError];
    return ok;
}

#pragma mark Selections

- (NSArray<NSIndexPath *> *)savedSelectionForScenario:(NSString *)scenario {
    NSArray *rows = [self rowsForSQL:@"SELECT section, item FROM selections WHERE scenario = ? ORDER BY section, item"
                           arguments:@[scenario] error:NULL];
    if (rows.count == 0) {
        return nil;
    }
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSDictionary *row in rows) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:[row[@"item"] integerValue] inSection:[row[@"section"] integerValue]]];
    }
    return indexPaths;
}

- (BOOL)saveSelection:(NSArray<NSIndexPath *> *)indexPaths forScenario:(NSString *)scenario {
    return [self inTransaction:^BOOL(CYLExampleDatabase *database) {
        if (![database executeSQL:@"DELETE FROM selections WHERE scenario = ?" arguments:@[scenario] error:NULL]) {
            return NO;
        }
        for (NSIndexPath *indexPath in indexPaths) {
            if (![database executeSQL:@"INSERT INTO selections VALUES (?, ?, ?)"
                            arguments:@[scenario, @(indexPath.section), @(indexPath.item)] error:NULL]) {
                return NO;
            }
        }
        return YES;
    }];
}

@end

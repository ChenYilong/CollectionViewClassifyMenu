//
//  CYLExampleDatabase.h
//  CYLMenuExample
//
//  The Example's SQLite database (libsqlite3 of the iOS SDK), so that every filter demo runs the
//  whole chain: tags selected → SQL built from them → query → list refreshed. It holds
//  - reviews / review_keywords: the reviews of scenario 1 (CYLReviewStore);
//  - places: shops and venues for the classify menu demo ported from CollectionViewClassifyMenu's
//    original app (its data.json categories and tags, and the regions of its filter);
//  - selections: the conditions each demo last confirmed, restored when it opens again.
//  The tables are filled again at every launch from the in-app data; selections are kept.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSErrorDomain const CYLExampleDatabaseErrorDomain;

/// A statement and the values bound to its "?" placeholders, as shown to the user.
@interface CYLExampleSQLQuery : NSObject
@property (nonatomic, copy, readonly) NSString *SQL;
@property (nonatomic, copy, readonly) NSArray *arguments;
+ (instancetype)querySQL:(NSString *)SQL arguments:(nullable NSArray *)arguments;
/// The SQL with each "?" replaced by its value ('text', numbers as is), for display only.
- (NSString *)displayString;
@end

@interface CYLExampleDatabase : NSObject

/// The Example's database, opened and filled on first use.
+ (instancetype)sharedDatabase;
/// A database at `path` (":memory:" for an in-memory one), filled with the Example's data.
- (nullable instancetype)initWithPath:(NSString *)path error:(NSError *_Nullable *_Nullable)error NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSString *path;

/// Runs a statement that returns no rows. Arguments: NSString, NSNumber or NSNull.
- (BOOL)executeSQL:(NSString *)SQL arguments:(nullable NSArray *)arguments error:(NSError *_Nullable *_Nullable)error;
/// Rows of a SELECT, one dictionary per row (column name → NSString, NSNumber or NSNull).
- (nullable NSArray<NSDictionary<NSString *, id> *> *)rowsForQuery:(CYLExampleSQLQuery *)query error:(NSError *_Nullable *_Nullable)error;
- (nullable NSArray<NSDictionary<NSString *, id> *> *)rowsForSQL:(NSString *)SQL arguments:(nullable NSArray *)arguments error:(NSError *_Nullable *_Nullable)error;
/// Runs `block` in one transaction: committed if it returns YES, rolled back otherwise.
- (BOOL)inTransaction:(BOOL (^)(CYLExampleDatabase *database))block;

/// Number of rows of a table.
- (NSInteger)countOfTable:(NSString *)table;

#pragma mark Selections

/// The [section, item] pairs a demo saved last, or nil.
- (nullable NSArray<NSIndexPath *> *)savedSelectionForScenario:(NSString *)scenario;
/// Saves a demo's selection (replacing the previous one).
- (BOOL)saveSelection:(NSArray<NSIndexPath *> *)indexPaths forScenario:(NSString *)scenario;

@end

NS_ASSUME_NONNULL_END

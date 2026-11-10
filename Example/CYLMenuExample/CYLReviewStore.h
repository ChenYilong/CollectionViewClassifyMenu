//
//  CYLReviewStore.h
//  CYLMenuExample
//
//  Mock reviews and the filters shown above them (场景一：淘宝评价筛选).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLReviewRating) {
    CYLReviewRatingGood,
    CYLReviewRatingNeutral,
    CYLReviewRatingBad,
};

@interface CYLReview : NSObject
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *sku;
@property (nonatomic, assign) CYLReviewRating rating;
@property (nonatomic, assign) BOOL hasPhoto;
@property (nonatomic, assign) BOOL hasFollowUp;
@property (nonatomic, copy) NSArray<NSString *> *keywords;
@end

/// One filter chip, such as "好评(3)" or the keyword "质量不错(2)".
@interface CYLReviewFilter : NSObject
/// Stable identifier sent to the server: all, good, neutral, bad, photo, followup or keyword:<word>.
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong, nullable) UIImage *image;
/// YES for keyword chips, which also appear in the product page preview.
@property (nonatomic, assign, getter=isKeyword) BOOL keyword;
@property (nonatomic, copy) BOOL (^matches)(CYLReview *review);
@end

@interface CYLReviewStore : NSObject
@property (nonatomic, copy, readonly) NSArray<CYLReview *> *reviews;
/// 全部, 好评, 中评, 差评, 有图, 追加, then keywords.
@property (nonatomic, copy, readonly) NSArray<CYLReviewFilter *> *filters;
+ (instancetype)sharedStore;
- (NSArray<CYLReview *> *)reviewsMatchingFilter:(CYLReviewFilter *)filter;
/// Reviews that match every filter (AND); "all" adds no condition.
- (NSArray<CYLReview *> *)reviewsMatchingAllFilters:(NSArray<CYLReviewFilter *> *)filters;
- (nullable CYLReviewFilter *)filterWithIdentifier:(NSString *)identifier;
/// "好评(3)".
- (NSString *)titleForFilter:(CYLReviewFilter *)filter;
@end

NS_ASSUME_NONNULL_END

//
//  CYLReviewQuery.h
//  CYLMenuExample
//
//  Two ways to apply the selected review filters, kept apart on purpose:
//  - CYLMemoryReviewQuery filters the reviews already in memory, synchronously.
//  - CYLNetworkReviewQuery sends the conditions to a server and refreshes when the
//    response arrives; responses to older requests are dropped. The server is
//    simulated (CYLReviewServer) so the Example runs offline.
//

#import <Foundation/Foundation.h>
#import "CYLReviewStore.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLReviewFilteringMode) {
    CYLReviewFilteringModeMemory = 0,
    CYLReviewFilteringModeNetwork,
};

typedef void (^CYLReviewQueryCompletion)(NSArray<CYLReview *> *reviews);

@protocol CYLReviewQuerying <NSObject>
@property (nonatomic, assign, readonly) CYLReviewFilteringMode mode;
@property (nonatomic, assign, readonly, getter=isLoading) BOOL loading;
/// Reviews matching every filter (AND). The completion runs on the main queue,
/// synchronously for memory filtering; it is not called for superseded requests.
- (void)fetchReviewsMatchingFilters:(NSArray<CYLReviewFilter *> *)filters completion:(CYLReviewQueryCompletion)completion;
@end

@interface CYLMemoryReviewQuery : NSObject <CYLReviewQuerying>
@end

/// A stand-in for a backend: answers a request URL with the matching reviews.
@interface CYLReviewServer : NSObject
+ (NSArray<CYLReview *> *)reviewsForRequestURL:(NSURL *)URL;
@end

@interface CYLNetworkReviewQuery : NSObject <CYLReviewQuerying>
/// Simulated round trip. Defaults to 0.6 s.
@property (nonatomic, assign) NSTimeInterval latency;
@property (nonatomic, strong, readonly, nullable) NSURL *lastRequestURL;
@property (nonatomic, assign, readonly) NSUInteger requestCount;
@property (nonatomic, assign, readonly) NSUInteger droppedResponseCount;
+ (NSURL *)requestURLForFilters:(NSArray<CYLReviewFilter *> *)filters;
@end

NS_ASSUME_NONNULL_END

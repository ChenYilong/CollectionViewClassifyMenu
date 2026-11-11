//
//  CYLImageTagGroupView.h
//  CollectionViewClassifyMenu
//
//  Tags attached to a point of a picture, as shellljx/TagViewGroup (Xiaohongshu-style): a white dot with a dark ring
//  and an optional ripple, and up to six tags joined to it by white lines in eleven directions. The view covers the
//  picture; only the dot and the tags take touches, so several groups can lie over one picture.
//
//      CYLImageTagGroupView *group = [[CYLImageTagGroupView alloc] initWithFrame:imageView.bounds];
//      group.tags = @[[CYLImageTag tagWithTitle:@"头层牛皮" direction:CYLImageTagDirectionRightTop],
//                     [CYLImageTag tagWithTitle:@"PLAYBOY/花花公子" direction:CYLImageTagDirectionRightBottom]];
//      group.percentPosition = CGPointMake(0.4, 0.5);
//      group.showsRipple = YES;
//      [imageView addSubview:group];
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * Where a tag goes from the dot (TagViewGroup's DIRECTION). "Straight" tags hang on a slanted line; the others on a
 * vertical line and then along their bottom edge.
 */
typedef NS_ENUM(NSInteger, CYLImageTagDirection) {
    CYLImageTagDirectionLeftCenter = 0,
    CYLImageTagDirectionLeftTop,
    CYLImageTagDirectionLeftTopStraight,
    CYLImageTagDirectionLeftBottom,
    CYLImageTagDirectionLeftBottomStraight,
    CYLImageTagDirectionRightCenter,
    CYLImageTagDirectionRightTop,
    CYLImageTagDirectionRightTopStraight,
    CYLImageTagDirectionRightBottom,
    CYLImageTagDirectionRightBottomStraight,
    /*!
     * Centered on the dot, without a line (the ripple).
     */
    CYLImageTagDirectionCenter,
};

/*!
 * The next of the ten line directions, in the order above (the Center direction is skipped), as the sample turns a
 * tag on each tap while editing.
 */
FOUNDATION_EXTERN CYLImageTagDirection CYLImageTagDirectionNext(CYLImageTagDirection direction);

/*!
 * TagViewGroup's defaults, in points.
 */
/*!
 * 8: the dot's outer radius.
 */
FOUNDATION_EXTERN const CGFloat CYLImageTagGroupDefaultCircleRadius;
/*!
 * 4: the dot's inner radius.
 */
FOUNDATION_EXTERN const CGFloat CYLImageTagGroupDefaultCircleInnerRadius;
/*!
 * 28: the vertical distance of the lines.
 */
FOUNDATION_EXTERN const CGFloat CYLImageTagGroupDefaultVerticalDistance;
/*!
 * 20: the tilt distance of the slanted lines.
 */
FOUNDATION_EXTERN const CGFloat CYLImageTagGroupDefaultTiltDistance;
/*!
 * 1: the line width.
 */
FOUNDATION_EXTERN const CGFloat CYLImageTagGroupDefaultLineWidth;
/*!
 * 6: the most tags in one group.
 */
FOUNDATION_EXTERN const NSUInteger CYLImageTagGroupMaximumTagCount;
/*!
 * 20: the ripple's largest radius.
 */
FOUNDATION_EXTERN const CGFloat CYLImageTagGroupDefaultRippleMaxRadius;

/*!
 * Animatable values of a group (TagViewGroup's CIRCLE_RADIUS, CIRCLE_INNER_RADIUS, LINES_RATIO, TAG_ALPHA properties),
 * for -animateValueForKey:values:duration:completion: and key-value coding.
 */
FOUNDATION_EXTERN NSString *const CYLImageTagGroupKeyCircleRadius;
FOUNDATION_EXTERN NSString *const CYLImageTagGroupKeyCircleInnerRadius;
FOUNDATION_EXTERN NSString *const CYLImageTagGroupKeyLinesProgress;
FOUNDATION_EXTERN NSString *const CYLImageTagGroupKeyTagAlpha;

/*!
 * A view that can be a tag of a group (TagViewGroup's ITagView). The group sizes it with -sizeThatFits: and places it.
 */
@protocol CYLImageTagItem <NSObject>
@property (nonatomic, assign) CYLImageTagDirection tagDirection;
@end

/*!
 * One tag: a title, its direction and anything the host keeps with it (the sample's TagGroupModel.Tag).
 */
@interface CYLImageTag : NSObject <NSCopying>
+ (instancetype)tagWithTitle:(NSString *)title direction:(CYLImageTagDirection)direction;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CYLImageTagDirection direction;
/*!
 * A link of the tag (the sample's Tag.link), not opened by the view.
 */
@property (nonatomic, copy, nullable) NSString *link;
@property (nonatomic, strong, nullable) id userInfo;
@end

/*!
 * A group of tags at a point of the picture, as fractions of its size (the sample's TagGroupModel).
 */
@interface CYLImageTagGroup : NSObject <NSCopying>
+ (instancetype)groupWithTags:(NSArray<CYLImageTag *> *)tags percentPosition:(CGPoint)percentPosition;
@property (nonatomic, copy) NSArray<CYLImageTag *> *tags;
@property (nonatomic, assign) CGPoint percentPosition;
/*!
 * Directions for `count` new tags, as the sample's edit dialog sets them: one tag right-center; two right-top and
 * right-bottom; three right-top, right-center and right-bottom.
 */
+ (NSArray<NSNumber *> *)defaultDirectionsForTagCount:(NSUInteger)count;
@end

/*!
 * The default tag view (TagViewGroup's TagTextView): white 13 pt text with a black glow, 12 × 4 pt padding.
 */
@interface CYLImageTagLabel : UILabel <CYLImageTagItem>
@property (nonatomic, assign) CYLImageTagDirection tagDirection;
/*!
 * Space around the text. {4, 12, 4, 12} by default.
 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@end

/*!
 * A pulsing circle (TagViewGroup's RippleView): it grows to `maximumRadius` and fades out, once a second.
 */
@interface CYLImageTagRippleView : UIView <CYLImageTagItem>
@property (nonatomic, assign) CYLImageTagDirection tagDirection;
@property (nonatomic, assign) CGFloat maximumRadius;
/*!
 * The opacity at the start, 0...1. 100/255 by default.
 */
@property (nonatomic, assign) CGFloat startAlpha;
@property (nonatomic, strong) UIColor *color;
- (void)startAnimating;
- (void)stopAnimating;
@end

@class CYLImageTagGroupView;

/*!
 * TagViewGroup's TagAdapter: the views of the tags.
 */
@protocol CYLImageTagGroupViewDataSource <NSObject>
- (NSInteger)numberOfTagsInGroupView:(CYLImageTagGroupView *)groupView;
- (UIView<CYLImageTagItem> *)groupView:(CYLImageTagGroupView *)groupView viewForTagAtIndex:(NSInteger)index;
@end

/*!
 * TagViewGroup's OnTagGroupClickListener and OnTagGroupDragListener.
 */
@protocol CYLImageTagGroupViewDelegate <NSObject>
@optional
- (void)groupViewDidTapCircle:(CYLImageTagGroupView *)groupView;
- (void)groupView:(CYLImageTagGroupView *)groupView didTapTagAtIndex:(NSInteger)index;
- (void)groupViewDidLongPress:(CYLImageTagGroupView *)groupView;
/*!
 * The user dragged the group (only while `draggable`); `percentPosition` is its new place.
 */
- (void)groupView:(CYLImageTagGroupView *)groupView didDragToPercentPosition:(CGPoint)percentPosition;
@end

IB_DESIGNABLE
@interface CYLImageTagGroupView : UIView

/*!
 * The dot's outer and inner radius, the line width and the line lengths (TagViewGroup's radius, inner_radius,
 * line_width, v_distance, tilt_distance), in points. When a tag is taller than `verticalDistance`, the layout grows both
 * distances by the difference, so tags in neighboring directions never overlap at large Dynamic Type sizes; a tag wider than the room
 * beside the dot wraps.
 */
@property (nonatomic, assign) IBInspectable CGFloat circleRadius;
@property (nonatomic, assign) IBInspectable CGFloat circleInnerRadius;
@property (nonatomic, assign) IBInspectable CGFloat lineWidth;
@property (nonatomic, assign) IBInspectable CGFloat verticalDistance;
@property (nonatomic, assign) IBInspectable CGFloat tiltDistance;
/*!
 * The ring, dot and line colors: 0x30 black, white and white by default.
 */
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, strong) UIColor *circleInnerColor;
@property (nonatomic, strong) UIColor *lineColor;

/*!
 * The dot's place as fractions of the view's size (setPercent); it moves inward when tags would leave the view.
 */
@property (nonatomic, assign) CGPoint percentPosition;
- (void)setPercentX:(CGFloat)percentX percentY:(CGFloat)percentY;
/*!
 * The dot's center, in the view's coordinates (getCenterPoint).
 */
@property (nonatomic, assign, readonly) CGPoint centerPoint;

#pragma mark Tags
/*!
 * Tags shown with CYLImageTagLabel views. Setting it replaces the data source's views.
 */
@property (nonatomic, copy) NSArray<CYLImageTag *> *tags;
/*!
 * Custom tag views instead (setTagAdapter); call -reloadData when they change (notifyDataSetChanged).
 */
@property (nonatomic, weak, nullable) id<CYLImageTagGroupViewDataSource> dataSource;
- (void)reloadData;
/*!
 * The tag views, in order (getTagList), without the ripple.
 */
@property (nonatomic, copy, readonly) NSArray<UIView<CYLImageTagItem> *> *tagViews;
/*!
 * Configures each CYLImageTagLabel the group makes (font, colors, insets).
 */
@property (nonatomic, copy, nullable) void (^tagLabelConfiguration)(CYLImageTagLabel *label, CYLImageTag *tag);

#pragma mark Ripple
/*!
 * A pulsing circle under the dot (addRipple, RippleView). NO by default.
 */
@property (nonatomic, assign) BOOL showsRipple;
@property (nonatomic, assign) CGFloat rippleMaxRadius;
/*!
 * 0...1, 100/255 by default (ripple_alpha 100).
 */
@property (nonatomic, assign) CGFloat rippleAlpha;
@property (nonatomic, strong, readonly, nullable) CYLImageTagRippleView *rippleView;

#pragma mark Animation
/*!
 * How much of each line is drawn, 0...1 (setLinesRatio). 1 by default.
 */
@property (nonatomic, assign) CGFloat linesProgress;
/*!
 * The tags' opacity (setTagAlpha). 1 by default.
 */
@property (nonatomic, assign) CGFloat tagAlpha;
/*!
 * Animates one of the CYLImageTagGroupKey… values through `values` (as an ObjectAnimator).
 */
- (void)animateValueForKey:(NSString *)key values:(NSArray<NSNumber *> *)values duration:(NSTimeInterval)duration
                completion:(nullable void (^)(void))completion;
/*!
 * Shows the group: the dot bounces, the lines grow, the tags fade in (the sample's show animator), or runs
 * `showAnimation` when set.
 */
- (void)showAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;
/*!
 * Hides it: the dot bounces, then the lines and tags fade together (the sample's hide animator), or `hideAnimation`.
 */
- (void)hideAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;
/*!
 * Whether the group is hidden by -hideAnimated:completion:.
 */
@property (nonatomic, assign, readonly, getter=isGroupHidden) BOOL groupHidden;
/*!
 * Custom animations (setShowAnimator, setHideAnimator): call `completion` when done.
 */
@property (nonatomic, copy, nullable) void (^showAnimation)(CYLImageTagGroupView *groupView, void (^completion)(void));
@property (nonatomic, copy, nullable) void (^hideAnimation)(CYLImageTagGroupView *groupView, void (^completion)(void));

#pragma mark Interaction
@property (nonatomic, weak, nullable) id<CYLImageTagGroupViewDelegate> delegate;
/*!
 * Lets the user drag the group (setOnTagGroupDragListener). NO by default.
 */
@property (nonatomic, assign, getter=isDraggable) BOOL draggable;

#pragma mark Accessibility
/*!
 * The dot as one VoiceOver / Voice Control / Switch Control element, before the tags. Its label is
 * "标签组：<the tag titles>" (core string `CYLImageTagGroup`); activating it is a tap on the dot. Its custom actions:
 * the long press (named by `longPressAccessibilityActionName`, when the delegate handles long presses), and
 * 上移 / 下移 / 左移 / 右移 while `draggable` (each moves the group by `accessibilityMoveStep` and reports a drag).
 */
@property (nonatomic, strong, readonly) UIAccessibilityElement *circleAccessibilityElement;
/*!
 * The name of the long-press custom action of the dot, such as "删除标签组". nil: "长按" (core string `CYLMenuLongPress`).
 */
@property (nonatomic, copy, nullable) NSString *longPressAccessibilityActionName;
/*!
 * The hint of every tag view, such as "轻点两下改变方向" in edit mode. nil by default.
 */
@property (nonatomic, copy, nullable) NSString *tagAccessibilityHint;
/*!
 * How far one 上移 / 下移 / 左移 / 右移 action moves the group, as a fraction of the view. 0.05 by default.
 */
@property (nonatomic, assign) CGFloat accessibilityMoveStep;

#pragma mark Geometry (TagGroupUtils)
/*!
 * The space the dot and the tags need on each side of the center (getTagViewUsed).
 */
- (UIEdgeInsets)tagSpaceUsed;
/*!
 * The top-left corner of a tag view of `size` in `direction` (getStartPoint).
 */
- (CGPoint)originForTagOfSize:(CGSize)size direction:(CYLImageTagDirection)direction;

@end

NS_ASSUME_NONNULL_END

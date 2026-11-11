//
//  CYLImageTagGroupView.m
//  CollectionViewClassifyMenu
//
//  Geometry after shellljx/TagViewGroup (TagGroupUtils, Apache License 2.0).
//

#import "CYLImageTagGroupView.h"
#import "CYLMenuResources.h"

const CGFloat CYLImageTagGroupDefaultCircleRadius = 8;
const CGFloat CYLImageTagGroupDefaultCircleInnerRadius = 4;
const CGFloat CYLImageTagGroupDefaultVerticalDistance = 28;
const CGFloat CYLImageTagGroupDefaultTiltDistance = 20;
const CGFloat CYLImageTagGroupDefaultLineWidth = 1;
const NSUInteger CYLImageTagGroupMaximumTagCount = 6;
const CGFloat CYLImageTagGroupDefaultRippleMaxRadius = 20;

NSString *const CYLImageTagGroupKeyCircleRadius = @"circleRadius";
NSString *const CYLImageTagGroupKeyCircleInnerRadius = @"circleInnerRadius";
NSString *const CYLImageTagGroupKeyLinesProgress = @"linesProgress";
NSString *const CYLImageTagGroupKeyTagAlpha = @"tagAlpha";

CYLImageTagDirection CYLImageTagDirectionNext(CYLImageTagDirection direction) {
    if (direction < CYLImageTagDirectionLeftCenter || direction >= CYLImageTagDirectionRightBottomStraight) {
        return CYLImageTagDirectionLeftCenter;
    }
    return direction + 1;
}

static BOOL CYLImageTagDirectionIsLeft(CYLImageTagDirection direction) {
    return direction <= CYLImageTagDirectionLeftBottomStraight;
}

#pragma mark - Models

@implementation CYLImageTag

+ (instancetype)tagWithTitle:(NSString *)title direction:(CYLImageTagDirection)direction {
    CYLImageTag *tag = [[self alloc] init];
    tag.title = title ?: @"";
    tag.direction = direction;
    return tag;
}

- (id)copyWithZone:(NSZone *)zone {
    CYLImageTag *copy = [[self class] tagWithTitle:self.title direction:self.direction];
    copy.link = self.link;
    copy.userInfo = self.userInfo;
    return copy;
}

@end

@implementation CYLImageTagGroup

+ (instancetype)groupWithTags:(NSArray<CYLImageTag *> *)tags percentPosition:(CGPoint)percentPosition {
    CYLImageTagGroup *group = [[self alloc] init];
    group.tags = tags ?: @[];
    group.percentPosition = percentPosition;
    return group;
}

+ (NSArray<NSNumber *> *)defaultDirectionsForTagCount:(NSUInteger)count {
    switch (count) {
        case 0: return @[];
        case 1: return @[@(CYLImageTagDirectionRightCenter)];
        case 2: return @[@(CYLImageTagDirectionRightTop), @(CYLImageTagDirectionRightBottom)];
        default: {
            NSMutableArray *directions = [@[@(CYLImageTagDirectionRightTop), @(CYLImageTagDirectionRightCenter), @(CYLImageTagDirectionRightBottom)] mutableCopy];
            NSArray *more = @[@(CYLImageTagDirectionLeftTop), @(CYLImageTagDirectionLeftCenter), @(CYLImageTagDirectionLeftBottom)];
            for (NSUInteger index = 3; index < MIN(count, CYLImageTagGroupMaximumTagCount); index++) {
                [directions addObject:more[index - 3]];
            }
            return directions;
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    NSMutableArray *tags = [NSMutableArray arrayWithCapacity:self.tags.count];
    for (CYLImageTag *tag in self.tags) {
        [tags addObject:[tag copy]];
    }
    return [[self class] groupWithTags:tags percentPosition:self.percentPosition];
}

@end

#pragma mark - Tag label

@implementation CYLImageTagLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentInsets = UIEdgeInsetsMake(4, 12, 4, 12);
        _tagDirection = CYLImageTagDirectionRightCenter;
        self.textColor = [UIColor whiteColor];
        // 13 pt at the default text size, scaled with Dynamic Type.
        self.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleFootnote] scaledFontForFont:[UIFont systemFontOfSize:13]];
        self.adjustsFontForContentSizeCategory = YES;
        self.numberOfLines = 0;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 3.5;
        self.layer.shadowOffset = CGSizeZero;
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.contentInsets)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    // One line when it fits; wrapped to `size.width` otherwise (long titles, large Dynamic Type sizes).
    CGFloat horizontal = self.contentInsets.left + self.contentInsets.right;
    CGFloat maximum = size.width > horizontal ? size.width - horizontal : CGFLOAT_MAX;
    CGSize text = [super sizeThatFits:CGSizeMake(maximum, CGFLOAT_MAX)];
    return CGSizeMake(ceil(MIN(text.width, maximum) + horizontal),
                      ceil(text.height + self.contentInsets.top + self.contentInsets.bottom));
}

@end

#pragma mark - Ripple

@interface CYLImageTagRippleView ()
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@end

@implementation CYLImageTagRippleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _maximumRadius = CYLImageTagGroupDefaultRippleMaxRadius;
        _startAlpha = 100.0 / 255.0;
        _color = [UIColor whiteColor];
        _tagDirection = CYLImageTagDirectionCenter;
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.opacity = 0;
        [self.layer addSublayer:_circleLayer];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(2 * self.maximumRadius, 2 * self.maximumRadius);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.circleLayer.frame = self.bounds;
    self.circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
    self.circleLayer.fillColor = self.color.CGColor;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

- (void)startAnimating {
    if (UIAccessibilityIsReduceMotionEnabled()) {
        return;
    }
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @0;
    scale.toValue = @1;
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @(self.startAlpha);
    fade.toValue = @0;
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scale, fade];
    group.duration = 1;
    group.repeatCount = HUGE_VALF;
    [self.circleLayer addAnimation:group forKey:@"ripple"];
}

- (void)stopAnimating {
    [self.circleLayer removeAnimationForKey:@"ripple"];
}

@end

#pragma mark - Group

#pragma mark - Circle element

/// The dot as an accessibility element: its frame follows the dot, activating it taps the dot.
@interface CYLImageTagCircleElement : UIAccessibilityElement
@property (nonatomic, weak) CYLImageTagGroupView *groupView;
@end

@interface CYLImageTagGroupView (CYLAccessibilityPrivate)
- (CGRect)cyl_circleAccessibilityFrame;
- (void)cyl_reportCircleTap;
@end

@implementation CYLImageTagCircleElement

- (CGRect)accessibilityFrameInContainerSpace {
    return [self.groupView cyl_circleAccessibilityFrame];
}

- (BOOL)accessibilityActivate {
    [self.groupView cyl_reportCircleTap];
    return YES;
}

@end

@interface CYLImageTagGroupView ()
@property (nonatomic, strong, readwrite) UIAccessibilityElement *circleAccessibilityElement;
@property (nonatomic, strong) NSMutableArray<UIView<CYLImageTagItem> *> *itemViews;
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *lineLayers;
@property (nonatomic, strong) CAShapeLayer *outerCircleLayer;
@property (nonatomic, strong) CAShapeLayer *innerCircleLayer;
@property (nonatomic, strong, readwrite, nullable) CYLImageTagRippleView *rippleView;
@property (nonatomic, assign, readwrite) CGPoint centerPoint;
@property (nonatomic, assign, readwrite, getter=isGroupHidden) BOOL groupHidden;
@property (nonatomic, strong, nullable) CADisplayLink *displayLink;
@property (nonatomic, copy, nullable) void (^displayStep)(CFTimeInterval now);
@property (nonatomic, assign) CGPoint dragOffset;
/// The distances of the last layout: at least the tallest tag, so that tags in neighboring directions never overlap.
@property (nonatomic, assign) CGFloat layoutVerticalDistance;
@property (nonatomic, assign) CGFloat layoutTiltDistance;
@end

@implementation CYLImageTagGroupView

@synthesize tags = _tags;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self cyl_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self cyl_commonInit];
    }
    return self;
}

- (void)cyl_commonInit {
    _circleRadius = CYLImageTagGroupDefaultCircleRadius;
    _circleInnerRadius = CYLImageTagGroupDefaultCircleInnerRadius;
    _lineWidth = CYLImageTagGroupDefaultLineWidth;
    _verticalDistance = CYLImageTagGroupDefaultVerticalDistance;
    _tiltDistance = CYLImageTagGroupDefaultTiltDistance;
    _rippleMaxRadius = CYLImageTagGroupDefaultRippleMaxRadius;
    _rippleAlpha = 100.0 / 255.0;
    _circleColor = [UIColor colorWithWhite:0 alpha:0x30 / 255.0];
    _circleInnerColor = [UIColor whiteColor];
    _lineColor = [UIColor whiteColor];
    _linesProgress = 1;
    _tagAlpha = 1;
    _tags = @[];
    _itemViews = [NSMutableArray array];
    _lineLayers = [NSMutableArray array];
    _percentPosition = CGPointMake(0.5, 0.5);
    _accessibilityMoveStep = 0.05;
    CYLImageTagCircleElement *circle = [[CYLImageTagCircleElement alloc] initWithAccessibilityContainer:self];
    circle.groupView = self;
    circle.accessibilityTraits = UIAccessibilityTraitButton;
    _circleAccessibilityElement = circle;
    self.backgroundColor = [UIColor clearColor];
    _outerCircleLayer = [CAShapeLayer layer];
    _innerCircleLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_outerCircleLayer];
    [self.layer addSublayer:_innerCircleLayer];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cyl_handleTap:)];
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cyl_handleLongPress:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cyl_handlePan:)];
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:press];
    [self addGestureRecognizer:pan];
}

#pragma mark Properties

- (void)setCircleRadius:(CGFloat)circleRadius { _circleRadius = MAX(0, circleRadius); [self setNeedsLayout]; [self cyl_updateCircles]; }
- (void)setCircleInnerRadius:(CGFloat)radius { _circleInnerRadius = MAX(0, radius); [self cyl_updateCircles]; }
- (void)setLineWidth:(CGFloat)lineWidth { _lineWidth = MAX(0, lineWidth); [self setNeedsLayout]; }
- (void)setVerticalDistance:(CGFloat)distance { _verticalDistance = MAX(0, distance); [self setNeedsLayout]; }
- (void)setTiltDistance:(CGFloat)distance { _tiltDistance = MAX(0, distance); [self setNeedsLayout]; }
- (void)setCircleColor:(UIColor *)color { _circleColor = color; [self cyl_updateCircles]; }
- (void)setCircleInnerColor:(UIColor *)color { _circleInnerColor = color; [self cyl_updateCircles]; }
- (void)setLineColor:(UIColor *)color { _lineColor = color; [self setNeedsLayout]; }

- (void)setPercentPosition:(CGPoint)percentPosition {
    _percentPosition = CGPointMake(MIN(1, MAX(0, percentPosition.x)), MIN(1, MAX(0, percentPosition.y)));
    [self setNeedsLayout];
}

- (void)setPercentX:(CGFloat)percentX percentY:(CGFloat)percentY {
    self.percentPosition = CGPointMake(percentX, percentY);
}

- (void)setLinesProgress:(CGFloat)linesProgress {
    _linesProgress = MIN(1, MAX(0, linesProgress));
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (CAShapeLayer *line in self.lineLayers) {
        line.strokeEnd = _linesProgress;
    }
    [CATransaction commit];
}

- (void)setTagAlpha:(CGFloat)tagAlpha {
    _tagAlpha = MIN(1, MAX(0, tagAlpha));
    for (UIView *view in self.itemViews) {
        view.alpha = _tagAlpha;
    }
}

- (void)setShowsRipple:(BOOL)showsRipple {
    _showsRipple = showsRipple;
    if (showsRipple && !self.rippleView) {
        self.rippleView = [[CYLImageTagRippleView alloc] initWithFrame:CGRectZero];
        [self insertSubview:self.rippleView atIndex:0];
    } else if (!showsRipple) {
        [self.rippleView removeFromSuperview];
        self.rippleView = nil;
    }
    self.rippleView.maximumRadius = self.rippleMaxRadius;
    self.rippleView.startAlpha = self.rippleAlpha;
    [self setNeedsLayout];
}

- (void)setRippleMaxRadius:(CGFloat)rippleMaxRadius {
    _rippleMaxRadius = MAX(0, rippleMaxRadius);
    self.rippleView.maximumRadius = _rippleMaxRadius;
    [self setNeedsLayout];
}

- (void)setRippleAlpha:(CGFloat)rippleAlpha {
    _rippleAlpha = MIN(1, MAX(0, rippleAlpha));
    self.rippleView.startAlpha = _rippleAlpha;
}

#pragma mark Tags

- (NSArray<CYLImageTag *> *)tags {
    return _tags;
}

- (void)setTags:(NSArray<CYLImageTag *> *)tags {
    _tags = [tags copy] ?: @[];
    [self reloadData];
}

- (NSArray<UIView<CYLImageTagItem> *> *)tagViews {
    return [self.itemViews copy];
}

- (void)reloadData {
    for (UIView *view in self.itemViews) {
        [view removeFromSuperview];
    }
    [self.itemViews removeAllObjects];
    id<CYLImageTagGroupViewDataSource> source = self.dataSource;
    NSInteger count = source ? [source numberOfTagsInGroupView:self] : (NSInteger)self.tags.count;
    for (NSInteger index = 0; index < MIN(count, (NSInteger)CYLImageTagGroupMaximumTagCount); index++) {
        UIView<CYLImageTagItem> *view = nil;
        if (source) {
            view = [source groupView:self viewForTagAtIndex:index];
        } else {
            CYLImageTag *tag = self.tags[index];
            CYLImageTagLabel *label = [[CYLImageTagLabel alloc] initWithFrame:CGRectZero];
            label.text = tag.title;
            label.accessibilityLabel = tag.title;
            label.tagDirection = tag.direction;
            if (self.tagLabelConfiguration) {
                self.tagLabelConfiguration(label, tag);
            }
            view = label;
        }
        if (!view) {
            continue;
        }
        view.alpha = self.tagAlpha;
        if (self.tagAccessibilityHint) {
            view.accessibilityHint = self.tagAccessibilityHint;
        }
        [self addSubview:view];
        [self.itemViews addObject:view];
    }
    [self cyl_updateAccessibility];
    [self setNeedsLayout];
}

#pragma mark Geometry

- (UIEdgeInsets)tagSpaceUsedForSizes:(NSArray<NSValue *> *)sizes {
    __block CGFloat left = self.circleRadius, top = self.circleRadius, right = self.circleRadius, bottom = self.circleRadius;
    CGFloat tallest = 0;
    for (NSValue *size in sizes) {
        tallest = MAX(tallest, size.CGSizeValue.height);
    }
    // Grown only when a tag is taller than the vertical distance (large text); the tilt grows by the same amount.
    CGFloat v = MAX(self.verticalDistance, tallest), t = self.tiltDistance + (v - self.verticalDistance);
    self.layoutVerticalDistance = v;
    self.layoutTiltDistance = t;
    [self.itemViews enumerateObjectsUsingBlock:^(UIView<CYLImageTagItem> *view, NSUInteger index, BOOL *stop) {
        CGSize size = sizes[index].CGSizeValue;
        switch (view.tagDirection) {
            case CYLImageTagDirectionRightTopStraight: right = MAX(right, t + size.width); top = MAX(top, size.height + t); break;
            case CYLImageTagDirectionRightTop: right = MAX(right, size.width); top = MAX(top, size.height + v); break;
            case CYLImageTagDirectionRightCenter: right = MAX(right, size.width); top = MAX(top, MAX(v, size.height)); break;
            case CYLImageTagDirectionRightBottom: right = MAX(right, size.width); bottom = MAX(bottom, v); break;
            case CYLImageTagDirectionRightBottomStraight: right = MAX(right, t + size.width); bottom = MAX(bottom, t); break;
            case CYLImageTagDirectionLeftTop: left = MAX(left, size.width); top = MAX(top, size.height + v); break;
            case CYLImageTagDirectionLeftTopStraight: left = MAX(left, size.width + t); top = MAX(top, size.height + t); break;
            case CYLImageTagDirectionLeftCenter: left = MAX(left, size.width); top = MAX(top, MAX(v, size.height)); break;
            case CYLImageTagDirectionLeftBottom: left = MAX(left, size.width); bottom = MAX(bottom, v); break;
            case CYLImageTagDirectionLeftBottomStraight: left = MAX(left, size.width + t); bottom = MAX(bottom, t); break;
            case CYLImageTagDirectionCenter: left = MAX(left, size.width / 2); bottom = MAX(bottom, size.height / 2); break;
        }
    }];
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (NSArray<NSValue *> *)cyl_itemSizes {
    NSMutableArray<NSValue *> *sizes = [NSMutableArray arrayWithCapacity:self.itemViews.count];
    for (UIView *view in self.itemViews) {
        // A tag never needs more than the width beside the dot.
        CGFloat width = MAX(44, CGRectGetWidth(self.bounds) - 2 * self.circleRadius - self.tiltDistance);
        [sizes addObject:[NSValue valueWithCGSize:[view sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)]]];
    }
    return sizes;
}

- (UIEdgeInsets)tagSpaceUsed {
    return [self tagSpaceUsedForSizes:[self cyl_itemSizes]];
}

- (CGPoint)originForTagOfSize:(CGSize)size direction:(CYLImageTagDirection)direction {
    CGFloat cx = self.centerPoint.x, cy = self.centerPoint.y;
    CGFloat v = MAX(self.verticalDistance, self.layoutVerticalDistance), t = MAX(self.tiltDistance, self.layoutTiltDistance);
    switch (direction) {
        case CYLImageTagDirectionRightTopStraight: return CGPointMake(cx + t, cy - t - size.height);
        case CYLImageTagDirectionRightTop: return CGPointMake(cx, cy - v - size.height);
        case CYLImageTagDirectionRightCenter: return CGPointMake(cx, cy - size.height);
        case CYLImageTagDirectionRightBottom: return CGPointMake(cx, cy + v - size.height);
        case CYLImageTagDirectionRightBottomStraight: return CGPointMake(cx + t, cy + t - size.height);
        case CYLImageTagDirectionLeftTop: return CGPointMake(cx - size.width, cy - v - size.height);
        case CYLImageTagDirectionLeftTopStraight: return CGPointMake(cx - size.width - t, cy - t - size.height);
        case CYLImageTagDirectionLeftCenter: return CGPointMake(cx - size.width, cy - size.height);
        case CYLImageTagDirectionLeftBottom: return CGPointMake(cx - size.width, cy + v - size.height);
        case CYLImageTagDirectionLeftBottomStraight: return CGPointMake(cx - size.width - t, cy + t - size.height);
        case CYLImageTagDirectionCenter: return CGPointMake(cx - size.width / 2, cy - size.height / 2);
    }
    return CGPointZero;
}

#pragma mark Layout and drawing

- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray<NSValue *> *sizes = [self cyl_itemSizes];
    UIEdgeInsets used = [self tagSpaceUsedForSizes:sizes];
    CGFloat width = CGRectGetWidth(self.bounds), height = CGRectGetHeight(self.bounds);
    CGFloat cx = width * self.percentPosition.x, cy = height * self.percentPosition.y;
    // TagViewGroup's checkBounds: move the dot inward when tags would leave the view.
    if (used.right > width - cx) cx -= used.right - (width - cx);
    if (used.left > cx) cx += used.left - cx;
    if (used.bottom > height - cy) cy -= used.bottom - (height - cy);
    if (used.top > cy) cy += used.top - cy;
    self.centerPoint = CGPointMake(cx, cy);
    for (CAShapeLayer *line in self.lineLayers) {
        [line removeFromSuperlayer];
    }
    [self.lineLayers removeAllObjects];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.itemViews enumerateObjectsUsingBlock:^(UIView<CYLImageTagItem> *view, NSUInteger index, BOOL *stop) {
        CGSize size = sizes[index].CGSizeValue;
        CGPoint origin = [self originForTagOfSize:size direction:view.tagDirection];
        view.frame = (CGRect){origin, size};
        if (view.tagDirection == CYLImageTagDirectionCenter) {
            return;
        }
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:self.centerPoint];
        CGRect frame = view.frame;
        BOOL left = CYLImageTagDirectionIsLeft(view.tagDirection);
        BOOL center = view.tagDirection == CYLImageTagDirectionLeftCenter || view.tagDirection == CYLImageTagDirectionRightCenter;
        if (!center) {
            [path addLineToPoint:CGPointMake(left ? CGRectGetMaxX(frame) : CGRectGetMinX(frame), CGRectGetMaxY(frame))];
        }
        [path addLineToPoint:CGPointMake(left ? CGRectGetMinX(frame) : CGRectGetMaxX(frame), CGRectGetMaxY(frame))];
        CAShapeLayer *line = [CAShapeLayer layer];
        line.path = path.CGPath;
        line.fillColor = nil;
        line.strokeColor = self.lineColor.CGColor;
        line.lineWidth = self.lineWidth;
        line.strokeEnd = self.linesProgress;
        [self.layer insertSublayer:line below:self.outerCircleLayer];
        [self.lineLayers addObject:line];
    }];
    if (self.rippleView) {
        CGFloat side = 2 * self.rippleMaxRadius;
        self.rippleView.frame = CGRectMake(cx - side / 2, cy - side / 2, side, side);
    }
    [self cyl_updateCircles];
    [CATransaction commit];
}

- (void)cyl_updateCircles {
    CGPoint c = self.centerPoint;
    self.outerCircleLayer.path = [UIBezierPath bezierPathWithArcCenter:c radius:self.circleRadius startAngle:0 endAngle:2 * M_PI clockwise:YES].CGPath;
    self.outerCircleLayer.fillColor = self.circleColor.CGColor;
    self.innerCircleLayer.path = [UIBezierPath bezierPathWithArcCenter:c radius:self.circleInnerRadius startAngle:0 endAngle:2 * M_PI clockwise:YES].CGPath;
    self.innerCircleLayer.fillColor = self.circleInnerColor.CGColor;
}

#pragma mark Accessibility

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (![previousTraitCollection.preferredContentSizeCategory isEqualToString:self.traitCollection.preferredContentSizeCategory]) {
        [self setNeedsLayout];
    }
}

- (NSArray *)accessibilityElements {
    if (self.groupHidden) {
        return @[];
    }
    NSMutableArray *elements = [NSMutableArray arrayWithObject:self.circleAccessibilityElement];
    if (self.tagAlpha > 0) {
        [elements addObjectsFromArray:self.itemViews];
    }
    return elements;
}

- (CGRect)cyl_circleAccessibilityFrame {
    CGFloat radius = MAX(self.circleRadius * 2, 22);
    return CGRectMake(self.centerPoint.x - radius, self.centerPoint.y - radius, 2 * radius, 2 * radius);
}

- (void)cyl_reportCircleTap {
    if ([self.delegate respondsToSelector:@selector(groupViewDidTapCircle:)]) {
        [self.delegate groupViewDidTapCircle:self];
    }
}

- (void)setDelegate:(id<CYLImageTagGroupViewDelegate>)delegate {
    _delegate = delegate;
    [self cyl_updateAccessibility];
}

- (void)setDraggable:(BOOL)draggable {
    _draggable = draggable;
    [self cyl_updateAccessibility];
}

- (void)setLongPressAccessibilityActionName:(NSString *)name {
    _longPressAccessibilityActionName = [name copy];
    [self cyl_updateAccessibility];
}

- (void)setTagAccessibilityHint:(NSString *)hint {
    _tagAccessibilityHint = [hint copy];
    for (UIView *view in self.itemViews) {
        view.accessibilityHint = hint;
    }
}

/// The dot's label ("标签组：<titles>") and its custom actions.
- (void)cyl_updateAccessibility {
    NSMutableArray<NSString *> *titles = [NSMutableArray array];
    for (UIView *view in self.itemViews) {
        // A data source's label view may rely on its text.
        NSString *title = view.accessibilityLabel.length > 0 ? view.accessibilityLabel
            : ([view isKindOfClass:[UILabel class]] ? ((UILabel *)view).text : nil);
        if (title.length > 0) {
            [titles addObject:title];
        }
    }
    NSListFormatter *list = [[NSListFormatter alloc] init];
    list.locale = [NSLocale localeWithLocaleIdentifier:[CYLMenuResources currentLanguage]];
    NSString *joined = [list stringFromItems:titles] ?: @"";
    self.circleAccessibilityElement.accessibilityLabel =
        [NSString stringWithFormat:CYLMenuLocalizedString(@"CYLImageTagGroup", @"The dot of a tag group; %@ is the list of its tags"), joined];

    NSMutableArray<UIAccessibilityCustomAction *> *actions = [NSMutableArray array];
    __weak __typeof(self) weakSelf = self;
    if ([self.delegate respondsToSelector:@selector(groupViewDidLongPress:)]) {
        NSString *name = self.longPressAccessibilityActionName.length > 0 ? self.longPressAccessibilityActionName
            : CYLMenuLocalizedString(@"CYLMenuLongPress", @"Does what a long press does");
        [actions addObject:[[UIAccessibilityCustomAction alloc] initWithName:name actionHandler:^BOOL(UIAccessibilityCustomAction *action) {
            [weakSelf.delegate groupViewDidLongPress:weakSelf];
            return YES;
        }]];
    }
    if (self.draggable) {
        NSArray *moves = @[@[@"CYLImageTagMoveUp", @0, @-1], @[@"CYLImageTagMoveDown", @0, @1],
                           @[@"CYLImageTagMoveLeft", @-1, @0], @[@"CYLImageTagMoveRight", @1, @0]];
        for (NSArray *move in moves) {
            CGFloat dx = [move[1] doubleValue], dy = [move[2] doubleValue];
            [actions addObject:[[UIAccessibilityCustomAction alloc] initWithName:CYLMenuLocalizedStringForKey(move[0])
                                                                   actionHandler:^BOOL(UIAccessibilityCustomAction *action) {
                return [weakSelf cyl_accessibilityMoveByX:dx y:dy];
            }]];
        }
    }
    self.circleAccessibilityElement.accessibilityCustomActions = actions;
}

/// 上移 / 下移 / 左移 / 右移: a drag by `accessibilityMoveStep`.
- (BOOL)cyl_accessibilityMoveByX:(CGFloat)dx y:(CGFloat)dy {
    CGPoint old = self.percentPosition;
    self.percentPosition = CGPointMake(old.x + dx * self.accessibilityMoveStep, old.y + dy * self.accessibilityMoveStep);
    if (CGPointEqualToPoint(old, self.percentPosition)) {
        return NO;
    }
    [self layoutIfNeeded];
    if ([self.delegate respondsToSelector:@selector(groupView:didDragToPercentPosition:)]) {
        [self.delegate groupView:self didDragToPercentPosition:self.percentPosition];
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.circleAccessibilityElement);
    return YES;
}

#pragma mark Touches

/// Only the dot and the tags take touches: groups lie over the picture and over each other.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.groupHidden) {
        return NO;
    }
    return [self cyl_isPointOnCircle:point] || [self cyl_tagIndexAtPoint:point] != NSNotFound;
}

- (BOOL)cyl_isPointOnCircle:(CGPoint)point {
    CGFloat radius = MAX(self.circleRadius * 2, 22);
    return hypot(point.x - self.centerPoint.x, point.y - self.centerPoint.y) <= radius;
}

- (NSUInteger)cyl_tagIndexAtPoint:(CGPoint)point {
    for (NSUInteger index = 0; index < self.itemViews.count; index++) {
        UIView<CYLImageTagItem> *view = self.itemViews[index];
        if (view.tagDirection != CYLImageTagDirectionCenter && CGRectContainsPoint(view.frame, point)) {
            return index;
        }
    }
    return NSNotFound;
}

- (void)cyl_handleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    NSUInteger index = [self cyl_tagIndexAtPoint:point];
    id<CYLImageTagGroupViewDelegate> delegate = self.delegate;
    if (index != NSNotFound) {
        if ([delegate respondsToSelector:@selector(groupView:didTapTagAtIndex:)]) {
            [delegate groupView:self didTapTagAtIndex:(NSInteger)index];
        }
    } else if ([delegate respondsToSelector:@selector(groupViewDidTapCircle:)]) {
        [delegate groupViewDidTapCircle:self];
    }
}

- (void)cyl_handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.delegate respondsToSelector:@selector(groupViewDidLongPress:)]) {
        [self.delegate groupViewDidLongPress:self];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && gestureRecognizer.view == self) {
        return self.draggable;
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (void)cyl_handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.dragOffset = CGPointMake(self.centerPoint.x - point.x, self.centerPoint.y - point.y);
        return;
    }
    if (recognizer.state != UIGestureRecognizerStateChanged && recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGFloat width = MAX(1, CGRectGetWidth(self.bounds)), height = MAX(1, CGRectGetHeight(self.bounds));
    self.percentPosition = CGPointMake((point.x + self.dragOffset.x) / width, (point.y + self.dragOffset.y) / height);
    [self layoutIfNeeded];
    if ([self.delegate respondsToSelector:@selector(groupView:didDragToPercentPosition:)]) {
        [self.delegate groupView:self didDragToPercentPosition:self.percentPosition];
    }
}

#pragma mark Animation

- (void)animateValueForKey:(NSString *)key values:(NSArray<NSNumber *> *)values duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    if (values.count == 0 || duration <= 0 || UIAccessibilityIsReduceMotionEnabled()) {
        if (values.lastObject != nil) [self setValue:values.lastObject forKey:key];
        if (completion) completion();
        return;
    }
    [self.displayLink invalidate];
    __block CFTimeInterval start = 0;
    __weak __typeof(self) weakSelf = self;
    self.displayStep = ^(CFTimeInterval now) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (start == 0) start = now;
        CGFloat t = MIN(1, (now - start) / duration);
        // Decelerating, as the sample's DecelerateInterpolator; piecewise linear between the values.
        CGFloat eased = 1 - (1 - t) * (1 - t);
        CGFloat position = eased * (CGFloat)(values.count - 1);
        NSUInteger index = MIN((NSUInteger)floor(position), values.count - 1);
        NSUInteger next = MIN(index + 1, values.count - 1);
        CGFloat fraction = position - index;
        CGFloat value = values[index].doubleValue + (values[next].doubleValue - values[index].doubleValue) * fraction;
        [self setValue:@(value) forKey:key];
        if (t >= 1) {
            [self.displayLink invalidate];
            self.displayLink = nil;
            self.displayStep = nil;
            if (completion) completion();
        }
    };
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(cyl_step:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)cyl_step:(CADisplayLink *)link {
    if (self.displayStep) self.displayStep(link.timestamp);
}

/// The dot grows and shrinks back, 0.4 s (the sample's circleRadiusAnimator).
- (void)cyl_bounceCircle:(void (^)(void))completion {
    CGFloat radius = self.circleRadius, inner = self.circleInnerRadius;
    [self animateValueForKey:CYLImageTagGroupKeyCircleInnerRadius values:@[@(MAX(0, inner - 3)), @(inner + 3), @(inner)] duration:0.4 completion:nil];
    // One display link drives one key: the outer ring follows the inner dot's timing.
    CADisplayLink *innerLink = self.displayLink;
    void (^innerStep)(CFTimeInterval) = self.displayStep;
    self.displayLink = nil;
    self.displayStep = nil;
    [self animateValueForKey:CYLImageTagGroupKeyCircleRadius values:@[@(MAX(0, radius - 3)), @(radius + 3), @(radius)] duration:0.4 completion:completion];
    void (^outerStep)(CFTimeInterval) = self.displayStep;
    if (innerStep && outerStep) {
        [innerLink invalidate];
        self.displayStep = ^(CFTimeInterval now) {
            innerStep(now);
            outerStep(now);
        };
    }
}

- (void)showAnimated:(BOOL)animated completion:(void (^)(void))completion {
    self.groupHidden = NO;
    self.hidden = NO;
    if (self.showAnimation && animated) {
        self.showAnimation(self, completion ?: ^{});
        return;
    }
    if (!animated || UIAccessibilityIsReduceMotionEnabled()) {
        self.linesProgress = 1;
        self.tagAlpha = 1;
        if (completion) completion();
        return;
    }
    self.linesProgress = 0;
    self.tagAlpha = 0;
    __weak __typeof(self) weakSelf = self;
    [self cyl_bounceCircle:^{
        [weakSelf animateValueForKey:CYLImageTagGroupKeyLinesProgress values:@[@0, @1] duration:0.3 completion:^{
            [weakSelf animateValueForKey:CYLImageTagGroupKeyTagAlpha values:@[@0, @1] duration:0.2 completion:completion];
        }];
    }];
}

- (void)hideAnimated:(BOOL)animated completion:(void (^)(void))completion {
    __weak __typeof(self) weakSelf = self;
    void (^finish)(void) = ^{
        weakSelf.groupHidden = YES;
        weakSelf.hidden = YES;
        if (completion) completion();
    };
    if (self.hideAnimation && animated) {
        self.hideAnimation(self, finish);
        return;
    }
    if (!animated || UIAccessibilityIsReduceMotionEnabled()) {
        finish();
        return;
    }
    [self cyl_bounceCircle:^{
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.tagAlpha = 0;
        } completion:nil];
        [weakSelf animateValueForKey:CYLImageTagGroupKeyLinesProgress values:@[@1, @0] duration:0.4 completion:finish];
    }];
}

- (void)dealloc {
    [_displayLink invalidate];
}

@end

//
//  CYLTagListCell.m
//  CollectionViewClassifyMenu
//

#import "CYLTagListCell.h"
#import "CYLMenuResources.h"

@interface CYLTagListCell ()
/// Covers the delete indicator, so that a tap on it deletes the tag instead of selecting it.
@property (nonatomic, strong) UIControl *deleteControl;
@end

@implementation CYLTagListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _button = [[CYLTagButton alloc] initWithFrame:self.contentView.bounds];
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // The collection view handles taps.
        _button.userInteractionEnabled = NO;
        [self.contentView addSubview:_button];
        _deleteControl = [[UIControl alloc] init];
        _deleteControl.hidden = YES;
        _deleteControl.accessibilityIdentifier = CYLTagListDeleteAccessibilityIdentifier;
        [_deleteControl addTarget:self action:@selector(cyl_delete) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteControl];
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self showRippleAtPoint:[touches.anyObject locationInView:self.button]];
}

- (void)showRippleAtPoint:(CGPoint)point {
    CYLMenuStyle *style = self.button.style;
    if (!style.rippleColor || UIAccessibilityIsReduceMotionEnabled()) {
        return;
    }
    // AndroidTagView's ripple: a circle from the touch point to the farthest corner, fading out.
    CGRect bounds = self.button.bounds;
    CGFloat dx = MAX(point.x, CGRectGetWidth(bounds) - point.x);
    CGFloat dy = MAX(point.y, CGRectGetHeight(bounds) - point.y);
    CGFloat radius = sqrt(dx * dx + dy * dy);
    CAShapeLayer *ripple = [CAShapeLayer layer];
    ripple.name = @"CYLTagRipple";
    ripple.frame = CGRectMake(point.x - radius, point.y - radius, 2 * radius, 2 * radius);
    ripple.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 2 * radius, 2 * radius)].CGPath;
    ripple.fillColor = style.rippleColor.CGColor;
    ripple.opacity = 0;
    [self.button.layer addSublayer:ripple];
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @0.05;
    scale.toValue = @1;
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @(MIN(1, MAX(0, style.rippleAlpha)));
    fade.toValue = @0;
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scale, fade];
    group.duration = style.rippleDuration > 0 ? style.rippleDuration : 1;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [ripple removeFromSuperlayer];
    }];
    [ripple addAnimation:group forKey:@"ripple"];
    [CATransaction commit];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    // Pressed: CYLMenuStyle.highlightedBackgroundColor.
    self.button.highlighted = highlighted;
}

- (void)setDeletable:(BOOL)deletable {
    _deletable = deletable;
    self.button.showsDeleteIndicator = deletable;
    self.deleteControl.hidden = !deletable;
    if (deletable) {
        UIAccessibilityCustomAction *action = [[UIAccessibilityCustomAction alloc] initWithName:CYLMenuLocalizedString(@"CYLMenuDeleteTag", @"Deletes a tag")
                                                                                         target:self
                                                                                       selector:@selector(cyl_deleteAction)];
        self.accessibilityCustomActions = @[action];
    } else {
        self.accessibilityCustomActions = nil;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.button layoutIfNeeded];
    self.deleteControl.frame = self.deletable ? [self.button convertRect:self.button.deleteIndicatorHitFrame toView:self.contentView] : CGRectZero;
}

- (void)cyl_delete {
    if (self.deleteHandler) {
        self.deleteHandler();
    }
}

- (BOOL)cyl_deleteAction {
    [self cyl_delete];
    return YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.deleteHandler = nil;
    self.deletable = NO;
}

- (void)configureWithTitle:(NSString *)title
                     image:(UIImage *)image
             selectedImage:(UIImage *)selectedImage
              animationURL:(NSURL *)animationURL
                     style:(CYLMenuStyle *)style
                  selected:(BOOL)selected
                   enabled:(BOOL)enabled {
    if (self.appliedStyle != style) {
        self.button.style = style;
        self.appliedStyle = style;
    }
    self.button.animationURL = animationURL;
    self.button.title = title;
    self.button.image = image;
    self.button.selectedImage = selectedImage;
    self.button.enabled = enabled;
    self.button.selected = selected;
    self.accessibilityLabel = title;
    // An icon with a meaning of its own (such as a "hot" icon) is read as the value.
    self.accessibilityValue = image.accessibilityLabel;
    self.accessibilityIdentifier = CYLTagListItemAccessibilityIdentifier;
    self.accessibilityHint = nil;
    UIAccessibilityTraits traits = UIAccessibilityTraitButton;
    if (selected) traits |= UIAccessibilityTraitSelected;
    if (!enabled) traits |= UIAccessibilityTraitNotEnabled;
    self.accessibilityTraits = traits;
}

@end

//
//  CYLTagFoldButton.m
//  CollectionViewClassifyMenu
//

#import "CYLTagFoldButton.h"
#import "CYLMenuStyle.h"

static CGFloat const kCYLTagFoldButtonIconSize = 12;
static CGFloat const kCYLTagFoldButtonMargin = 6;
static CGFloat const kCYLTagFoldButtonHeight = 28;

@interface CYLTagFoldButton ()
@property (nonatomic, copy, readwrite, nullable) CYLMenuFoldControl *foldControl;
@property (nonatomic, assign, readwrite, getter=isExpanded) BOOL expanded;
@end

@implementation CYLTagFoldButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;
        self.accessibilityIdentifier = CYLTagListFoldControlAccessibilityIdentifier;
    }
    return self;
}

/// A borderless tag: no background, the title then the icon, in `color`.
+ (CYLMenuStyle *)cyl_styleForFoldControl:(CYLMenuFoldControl *)control color:(UIColor *)color {
    CYLMenuStyle *style = [CYLMenuStyle defaultStyle];
    UIFont *font = control.font ?: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    UIColor *tint = control.color ?: color ?: [UIColor secondaryLabelColor];
    for (NSNumber *state in @[@(UIControlStateNormal), @(UIControlStateSelected), @(UIControlStateDisabled)]) {
        CYLTagAppearance *appearance = [style appearanceForState:state.unsignedIntegerValue];
        appearance.backgroundColor = [UIColor clearColor];
        appearance.borderWidth = 0;
        appearance.borderColor = nil;
        appearance.margin = kCYLTagFoldButtonMargin;
        appearance.font = font;
        appearance.textColor = tint;
        [style setIconColor:tint forState:state.unsignedIntegerValue];
    }
    style.imagePlacement = CYLTagImagePlacementTrailing;
    style.imageSize = CGSizeMake(kCYLTagFoldButtonIconSize, kCYLTagFoldButtonIconSize);
    style.imageTitleSpacing = 3;
    style.layoutCentered = YES;
    style.adjustsFontForContentSizeCategory = control.font == nil;
    style.itemHeight = kCYLTagFoldButtonHeight;
    return style;
}

- (void)applyFoldControl:(CYLMenuFoldControl *)foldControl color:(UIColor *)color expanded:(BOOL)expanded animated:(BOOL)animated {
    self.foldControl = foldControl;
    self.expanded = expanded;
    self.style = [[self class] cyl_styleForFoldControl:foldControl color:color];
    self.title = [foldControl titleWhenExpanded:expanded];
    self.image = [foldControl showsImageWhenExpanded:expanded] ? foldControl.image : nil;
    [self setNeedsLayout];
    // Just under π, so that it turns the same way back and forth.
    CGAffineTransform transform = (expanded && foldControl.rotatesImageWhenExpanded)
        ? CGAffineTransformMakeRotation((CGFloat)M_PI - 0.0001) : CGAffineTransformIdentity;
    if (animated && !UIAccessibilityIsReduceMotionEnabled()) {
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.transform = transform;
        }];
    } else {
        self.imageView.transform = transform;
    }
}

+ (CGSize)sizeForFoldControl:(CYLMenuFoldControl *)foldControl expanded:(BOOL)expanded traitCollection:(UITraitCollection *)traitCollection {
    CYLMenuStyle *style = [self cyl_styleForFoldControl:foldControl color:nil];
    UIImage *image = [foldControl showsImageWhenExpanded:expanded] ? foldControl.image : nil;
    CGFloat width = [self widthForTitle:[foldControl titleWhenExpanded:expanded] image:image style:style traitCollection:traitCollection];
    // At least a 44 pt wide touch target.
    return CGSizeMake(MAX(44, ceil(width)), MAX(kCYLTagFoldButtonHeight, [self heightForStyle:style traitCollection:traitCollection]));
}

@end

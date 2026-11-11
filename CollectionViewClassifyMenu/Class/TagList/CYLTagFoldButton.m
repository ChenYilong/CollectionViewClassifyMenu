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

/// The inline control: the tags' normal look in every state (it is never selected), the icon after the title.
+ (CYLMenuStyle *)cyl_inlineStyleForFoldControl:(CYLMenuFoldControl *)control itemStyle:(CYLMenuStyle *)itemStyle {
    CYLMenuStyle *style = [itemStyle copy];
    CYLTagAppearance *normal = itemStyle.normalAppearance;
    UIColor *tint = control.color ?: normal.iconColor ?: normal.textColor;
    for (NSNumber *state in @[@(UIControlStateSelected), @(UIControlStateDisabled)]) {
        CYLTagAppearance *appearance = [style appearanceForState:state.unsignedIntegerValue];
        appearance.backgroundColor = normal.backgroundColor;
        appearance.borderColor = normal.borderColor;
        appearance.borderWidth = normal.borderWidth;
        appearance.cornerRadius = normal.cornerRadius;
        appearance.margin = normal.margin;
        appearance.font = normal.font;
        appearance.textColor = normal.textColor;
    }
    for (NSNumber *state in @[@(UIControlStateNormal), @(UIControlStateSelected), @(UIControlStateDisabled)]) {
        [style setIconColor:tint forState:state.unsignedIntegerValue];
    }
    if (control.font) {
        for (CYLTagAppearance *appearance in @[style.normalAppearance, style.selectedAppearance, style.disabledAppearance]) {
            appearance.font = control.font;
        }
    }
    style.imagePlacement = CYLTagImagePlacementTrailing;
    style.imageSize = CGSizeMake(kCYLTagFoldButtonIconSize + 4, kCYLTagFoldButtonIconSize + 4);
    style.imageTitleSpacing = 3;
    style.layoutCentered = YES;
    style.numberOfItemsPerRow = 0;
    return style;
}

- (void)applyInlineFoldControl:(CYLMenuFoldControl *)foldControl itemStyle:(CYLMenuStyle *)itemStyle expanded:(BOOL)expanded animated:(BOOL)animated {
    [self cyl_applyFoldControl:foldControl style:[[self class] cyl_inlineStyleForFoldControl:foldControl itemStyle:itemStyle]
                      expanded:expanded animated:animated];
}

+ (CGSize)inlineSizeForFoldControl:(CYLMenuFoldControl *)foldControl itemStyle:(CYLMenuStyle *)itemStyle expanded:(BOOL)expanded traitCollection:(UITraitCollection *)traitCollection {
    CYLMenuStyle *style = [self cyl_inlineStyleForFoldControl:foldControl itemStyle:itemStyle];
    UIImage *image = [foldControl showsImageWhenExpanded:expanded] ? foldControl.image : nil;
    CGFloat height = [self heightForStyle:style traitCollection:traitCollection];
    CGFloat width = [self widthForTitle:[foldControl titleWhenExpanded:expanded] image:image style:style traitCollection:traitCollection];
    return CGSizeMake(MAX(height, ceil(width)), height);
}

- (void)applyFoldControl:(CYLMenuFoldControl *)foldControl color:(UIColor *)color expanded:(BOOL)expanded animated:(BOOL)animated {
    [self cyl_applyFoldControl:foldControl style:[[self class] cyl_styleForFoldControl:foldControl color:color]
                      expanded:expanded animated:animated];
}

- (void)cyl_applyFoldControl:(CYLMenuFoldControl *)foldControl style:(CYLMenuStyle *)style expanded:(BOOL)expanded animated:(BOOL)animated {
    self.foldControl = foldControl;
    self.expanded = expanded;
    self.style = style;
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

//
//  CYLTagButton.m
//  CollectionViewClassifyMenu
//

#import "CYLTagButton.h"
#import "CYLParameterConfiguration.h"

/// The class side of CYLTabBarController's `CYLTabBarItemAnimationFactory` (CYLTabBarItemAnimation subspec).
/// Found at runtime, so the component does not depend on CYLTabBarController; the libraries'
/// animators register themselves with the engine, as for tab bar items.
@protocol CYLTagAnimationFactory <NSObject>
+ (nullable UIView *)animationViewWithURL:(NSURL *)URL size:(CGSize)size contentMode:(UIViewContentMode)contentMode;
+ (nullable id)playerForView:(nullable UIView *)view;
@end

/// The methods of `CYLTabBarItemAnimationPlayer` the tag uses.
@protocol CYLTagAnimationPlayer <NSObject>
- (void)play;
- (void)showLastFrame;
- (void)stop;
@optional
@property (nonatomic, assign) CGFloat animationSpeed;
@property (nonatomic, assign) CGFloat progress;
@end

static Class<CYLTagAnimationFactory> CYLTagAnimationFactoryClass(void) {
    Class factory = NSClassFromString(@"CYLTabBarItemAnimationFactory");
    if ([factory respondsToSelector:@selector(animationViewWithURL:size:contentMode:)] &&
        [factory respondsToSelector:@selector(playerForView:)]) {
        return factory;
    }
    return Nil;
}

/// The y that centers something `size` tall between the top and bottom content insets, or in the whole tag when it
/// does not fit between them.
static CGFloat CYLTagCenteredY(CGFloat size, CGFloat contentTop, CGFloat contentHeight, CGFloat height) {
    return size <= contentHeight ? contentTop + floor((contentHeight - size) / 2) : floor((height - size) / 2);
}

static NSArray<NSNumber *> *CYLTagButtonStates(void) {
    return @[@(UIControlStateNormal), @(UIControlStateSelected), @(UIControlStateDisabled)];
}

@interface CYLTagButton ()
@property (nonatomic, strong, readwrite, nullable) UIView *animationView;
@property (nonatomic, strong, readwrite, nullable) id animationPlayer;
@property (nonatomic, assign) CGSize animationViewSize;
@property (nonatomic, strong) UIImageView *backgroundImageView;
/// The cross of CYLMenuStyle.deleteIndicatorLineWidth.
@property (nonatomic, strong) CAShapeLayer *crossLayer;
@property (nonatomic, assign, readwrite) CGRect deleteIndicatorHitFrame;
@end

@implementation CYLTagButton

@synthesize style = _style;

+ (BOOL)isAnimationEngineAvailable {
    return CYLTagAnimationFactoryClass() != Nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _style = [CYLMenuStyle defaultStyle];
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.hidden = YES;
        _deleteIndicatorLabel = [[UILabel alloc] init];
        _deleteIndicatorLabel.textAlignment = NSTextAlignmentCenter;
        _deleteIndicatorLabel.hidden = YES;
        _deleteIndicatorLabel.isAccessibilityElement = NO;
        [self addSubview:_backgroundImageView];
        [self addSubview:_imageView];
        [self addSubview:_titleLabel];
        [self addSubview:_deleteIndicatorLabel];
        _crossLayer = [CAShapeLayer layer];
        _crossLayer.fillColor = nil;
        _crossLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_crossLayer];
        self.layer.masksToBounds = YES;
    }
    return self;
}

#pragma mark Properties

- (CYLMenuStyle *)style {
    return _style;
}

- (void)setStyle:(CYLMenuStyle *)style {
    _style = [(style ?: [CYLMenuStyle defaultStyle]) copy];
    if (self.animationView && !CGSizeEqualToSize(self.animationViewSize, [self cyl_animationSize])) {
        [self cyl_reloadAnimationView];
    } else {
        [self cyl_updateAnimationState];
    }
    [self cyl_updateAppearance];
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    [self cyl_updateAppearance];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self cyl_updateAppearance];
}

- (void)setAnimationURL:(NSURL *)animationURL {
    if ((_animationURL == animationURL || [_animationURL isEqual:animationURL]) && (self.animationView || !animationURL)) {
        return;
    }
    _animationURL = animationURL;
    [self cyl_reloadAnimationView];
}

- (CGSize)cyl_animationSize {
    CGSize size = self.style.animationSize;
    return CGSizeEqualToSize(size, CGSizeZero) ? self.style.imageSize : size;
}

- (void)cyl_reloadAnimationView {
    [self.animationView removeFromSuperview];
    self.animationView = nil;
    self.animationPlayer = nil;
    Class<CYLTagAnimationFactory> factory = CYLTagAnimationFactoryClass();
    NSURL *URL = self.animationURL;
    // A file that does not exist shows the image (some engines would create an empty view).
    BOOL missingFile = URL.isFileURL && ![[NSFileManager defaultManager] fileExistsAtPath:URL.path];
    if (URL && factory && !missingFile) {
        CGSize size = [self cyl_animationSize];
        UIView *view = [factory animationViewWithURL:self.animationURL size:size contentMode:UIViewContentModeScaleAspectFit];
        if (view) {
            view.userInteractionEnabled = NO;
            [self addSubview:view];
            self.animationView = view;
            self.animationViewSize = size;
            self.animationPlayer = [factory playerForView:view];
        }
    }
    [self cyl_updateAnimationState];
    [self cyl_updateAppearance];
}

/// Selected: the last frame (a selected tab's icon); otherwise the first frame.
- (void)cyl_updateAnimationState {
    id<CYLTagAnimationPlayer> player = self.animationPlayer;
    if ([player respondsToSelector:@selector(setAnimationSpeed:)]) {
        player.animationSpeed = self.style.animationSpeed > 0 ? self.style.animationSpeed : 1;
    }
    if (self.isSelected) {
        [player showLastFrame];
    } else {
        [player stop];
        CGFloat resting = MIN(1, MAX(0, self.animationRestingProgress));
        if (resting > 0 && [player respondsToSelector:@selector(setProgress:)]) {
            player.progress = resting;
        }
    }
}

- (void)setAnimationRestingProgress:(CGFloat)animationRestingProgress {
    if (_animationRestingProgress == animationRestingProgress) {
        return;
    }
    _animationRestingProgress = animationRestingProgress;
    [self cyl_updateAnimationState];
}

- (void)playAnimation {
    id<CYLTagAnimationPlayer> player = self.animationPlayer;
    if (UIAccessibilityIsReduceMotionEnabled()) {
        // Reduce Motion: jump to the end state instead of playing.
        [self cyl_updateAnimationState];
        return;
    }
    [player play];
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    [self cyl_updateAppearance];
}

- (void)setSelected:(BOOL)selected {
    BOOL changed = selected != self.isSelected;
    [super setSelected:selected];
    if (changed) {
        [self cyl_updateAnimationState];
    }
    [self cyl_updateAppearance];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self cyl_updateAppearance];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self cyl_updateAppearance];
}

- (void)setShowsDeleteIndicator:(BOOL)showsDeleteIndicator {
    if (_showsDeleteIndicator == showsDeleteIndicator) {
        return;
    }
    _showsDeleteIndicator = showsDeleteIndicator;
    [self cyl_updateAppearance];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self cyl_updateAppearance];
}

#pragma mark Appearance

/// The state used for the appearance: disabled wins over selected (as on UIControl).
- (UIControlState)cyl_currentState {
    if (!self.isEnabled) {
        return UIControlStateDisabled;
    }
    return self.isSelected ? UIControlStateSelected : UIControlStateNormal;
}

- (void)cyl_updateAppearance {
    UIControlState state = [self cyl_currentState];
    CYLTagAppearance *appearance = [self.style appearanceForState:state];
    UIImage *image = (state == UIControlStateSelected && self.selectedImage) ? self.selectedImage : self.image;
    // An animated icon takes the icon slot.
    self.imageView.image = self.animationView ? nil : image;
    self.imageView.hidden = self.animationView != nil;
    self.animationView.alpha = state == UIControlStateDisabled ? 0.4 : 1;
    self.imageView.tintColor = [self.style iconColorForState:state];
    self.titleLabel.text = [self.style displayedTitleForTitle:self.title];
    self.titleLabel.font = [self.style titleFontForState:state traitCollection:self.traitCollection];
    self.titleLabel.textColor = appearance.textColor;

    UIColor *background = appearance.backgroundColor;
    if (self.isHighlighted && state != UIControlStateDisabled && self.style.highlightedBackgroundColor) {
        // Pressed, as android-tagview's layoutColorPress.
        background = self.style.highlightedBackgroundColor;
    }
    self.layer.backgroundColor = background.CGColor;
    self.backgroundImageView.image = appearance.backgroundImage;
    self.backgroundImageView.hidden = appearance.backgroundImage == nil || (self.isHighlighted && self.style.highlightedBackgroundColor);
    BOOL drawsCross = self.style.deleteIndicatorLineWidth > 0;
    self.deleteIndicatorLabel.hidden = !self.showsDeleteIndicator || drawsCross;
    self.deleteIndicatorLabel.text = self.showsDeleteIndicator && !drawsCross ? self.style.deleteIndicatorTitle : nil;
    self.crossLayer.hidden = !self.showsDeleteIndicator || !drawsCross;
    self.crossLayer.lineWidth = self.style.deleteIndicatorLineWidth;
    self.crossLayer.strokeColor = (self.style.deleteIndicatorColor ?: appearance.textColor).CGColor;
    CGFloat imageRadius = self.style.imageCornerRadius;
    self.imageView.layer.cornerRadius = imageRadius > 0 ? MIN(imageRadius, MIN(self.style.imageSize.width, self.style.imageSize.height) / 2) : 0;
    self.imageView.layer.masksToBounds = imageRadius > 0;
    if (imageRadius > 0) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    self.deleteIndicatorLabel.font = [self.style deleteIndicatorFontForState:state traitCollection:self.traitCollection];
    self.deleteIndicatorLabel.textColor = self.style.deleteIndicatorColor ?: appearance.textColor;
    UIColor *borderColor = appearance.borderColor;
    CGFloat borderWidth = borderColor ? appearance.borderWidth : 0;
    if (UIAccessibilityDarkerSystemColorsEnabled()) {
        // Increase Contrast: a visible outline in the text color.
        borderColor = state == UIControlStateSelected ? (appearance.borderColor ?: appearance.textColor) : appearance.textColor;
        borderWidth = MAX(1, appearance.borderWidth);
    }
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
    [self setNeedsLayout];
}

#pragma mark Measurement

+ (CGSize)cyl_iconSizeForImage:(UIImage *)image style:(CYLMenuStyle *)style {
    if (!image) {
        return CGSizeZero;
    }
    return CGSizeEqualToSize(style.imageSize, CGSizeZero) ? image.size : style.imageSize;
}

+ (CGSize)iconSizeForImage:(UIImage *)image animated:(BOOL)animated style:(CYLMenuStyle *)style {
    if (animated && [self isAnimationEngineAvailable]) {
        return CGSizeEqualToSize(style.animationSize, CGSizeZero) ? style.imageSize : style.animationSize;
    }
    return [self cyl_iconSizeForImage:image style:style];
}

+ (CGFloat)widthForTitle:(NSString *)title image:(UIImage *)image style:(CYLMenuStyle *)style traitCollection:(UITraitCollection *)traitCollection {
    return [self widthForTitle:title iconSize:[self cyl_iconSizeForImage:image style:style] style:style traitCollection:traitCollection];
}

+ (CGFloat)widthForTitle:(NSString *)title iconSize:(CGSize)iconSize style:(CYLMenuStyle *)style traitCollection:(UITraitCollection *)traitCollection {
    return [self widthForTitle:title iconSize:iconSize showsDeleteIndicator:NO style:style traitCollection:traitCollection];
}

/// The delete indicator's width and the space before it, in a state.
+ (CGFloat)cyl_deleteIndicatorWidthForState:(UIControlState)state style:(CYLMenuStyle *)style traitCollection:(UITraitCollection *)traitCollection {
    if (style.deleteIndicatorWidth > 0) {
        return style.deleteIndicatorWidth;
    }
    UIFont *font = [style deleteIndicatorFontForState:state traitCollection:traitCollection];
    if (style.deleteIndicatorLineWidth > 0) {
        return ceil(font.lineHeight * 0.75) + 2 * style.deleteIndicatorPadding;
    }
    return ceil([style.deleteIndicatorTitle sizeWithAttributes:@{NSFontAttributeName: font}].width);
}

+ (CGFloat)widthForTitle:(NSString *)title iconSize:(CGSize)iconSize showsDeleteIndicator:(BOOL)showsDeleteIndicator
                   style:(CYLMenuStyle *)style traitCollection:(UITraitCollection *)traitCollection {
    title = [style displayedTitleForTitle:title];
    CGFloat width = 0;
    for (NSNumber *state in CYLTagButtonStates()) {
        UIControlState controlState = state.unsignedIntegerValue;
        CYLTagAppearance *appearance = [style appearanceForState:controlState];
        CGFloat titleWidth = title.length > 0
            ? ceil([title sizeWithAttributes:@{NSFontAttributeName: [style titleFontForState:controlState traitCollection:traitCollection]}].width)
            : 0;
        CGFloat iconWidth = iconSize.width;
        CGFloat content = titleWidth + iconWidth;
        if (titleWidth > 0 && iconWidth > 0) {
            content += style.imageTitleSpacing;
        } else if (titleWidth > 0 && !style.layoutCentered && style.contentAlignment == CYLTagContentAlignmentCenter) {
            // The title keeps its place after an empty icon slot.
            content += style.imageSize.width + style.imageTitleSpacing;
        }
        if (showsDeleteIndicator) {
            content += style.imageTitleSpacing + [self cyl_deleteIndicatorWidthForState:controlState style:style traitCollection:traitCollection];
        }
        width = MAX(width, ceil(content + appearance.contentInsets.left + appearance.contentInsets.right));
    }
    return width;
}

+ (CGFloat)heightForStyle:(CYLMenuStyle *)style traitCollection:(UITraitCollection *)traitCollection {
    CGFloat height = style.itemHeight;
    for (NSNumber *state in CYLTagButtonStates()) {
        UIControlState controlState = state.unsignedIntegerValue;
        UIEdgeInsets insets = [style appearanceForState:controlState].contentInsets;
        UIFont *font = [style titleFontForState:controlState traitCollection:traitCollection];
        height = MAX(height, ceil(font.lineHeight) + insets.top + insets.bottom);
    }
    return height;
}

#pragma mark Layout

/// CYLFlatDesignTabBarButton's `_updateLayout`, with the icon and title side by side.
/// Bounds and center instead of frame, so that a transform (the fold chevron's 180° turn) is kept.
- (void)cyl_placeImageView:(CGRect)frame {
    self.imageView.bounds = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    self.imageView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CYLMenuStyle *style = self.style;
    UIControlState state = [self cyl_currentState];
    CYLTagAppearance *appearance = [style appearanceForState:state];
    UIEdgeInsets insets = appearance.contentInsets;
    self.backgroundImageView.frame = self.bounds;
    // The delete indicator at the trailing inset; the content lays out in what is left, as without it.
    CGFloat deleteWidth = 0;
    if (self.showsDeleteIndicator) {
        CGFloat indicatorWidth = [[self class] cyl_deleteIndicatorWidthForState:state style:style traitCollection:self.traitCollection];
        deleteWidth = indicatorWidth + style.imageTitleSpacing;
        BOOL leadingIndicator = style.deleteIndicatorPlacement == CYLTagDeleteIndicatorPlacementLeading;
        CGFloat indicatorX = leadingIndicator ? insets.left : MAX(insets.left, width - insets.right - indicatorWidth);
        CGRect indicator = CGRectMake(indicatorX, insets.top, indicatorWidth, MAX(0, height - insets.top - insets.bottom));
        self.deleteIndicatorLabel.frame = indicator;
        if (leadingIndicator) {
            CGFloat hitMaxX = MIN(width, CGRectGetMaxX(indicator) + style.imageTitleSpacing);
            self.deleteIndicatorHitFrame = CGRectMake(0, 0, hitMaxX, height);
        } else {
            CGFloat hitX = MAX(0, indicatorX - style.imageTitleSpacing);
            self.deleteIndicatorHitFrame = CGRectMake(hitX, 0, width - hitX, height);
        }
        // A drawn cross: a square centered in the area, inset by the padding.
        CGFloat side = MAX(0, MIN(CGRectGetWidth(indicator), CGRectGetHeight(indicator)) - 2 * style.deleteIndicatorPadding);
        if (style.deleteIndicatorLineWidth > 0 && style.deleteIndicatorWidth <= 0) {
            side = MAX(0, CGRectGetWidth(indicator) - 2 * style.deleteIndicatorPadding);
        }
        CGRect square = CGRectMake(CGRectGetMidX(indicator) - side / 2, CGRectGetMidY(indicator) - side / 2, side, side);
        UIBezierPath *cross = [UIBezierPath bezierPath];
        [cross moveToPoint:square.origin];
        [cross addLineToPoint:CGPointMake(CGRectGetMaxX(square), CGRectGetMaxY(square))];
        [cross moveToPoint:CGPointMake(CGRectGetMaxX(square), CGRectGetMinY(square))];
        [cross addLineToPoint:CGPointMake(CGRectGetMinX(square), CGRectGetMaxY(square))];
        self.crossLayer.frame = self.bounds;
        self.crossLayer.path = cross.CGPath;
    } else {
        self.deleteIndicatorLabel.frame = CGRectZero;
        self.deleteIndicatorHitFrame = CGRectZero;
        self.crossLayer.path = nil;
    }
    BOOL indicatorFirst = self.showsDeleteIndicator && style.deleteIndicatorPlacement == CYLTagDeleteIndicatorPlacementLeading;
    // The leading margin; `trailing` is the space after the content (the right inset and the delete indicator).
    CGFloat margin = insets.left + (indicatorFirst ? deleteWidth : 0);
    CGFloat trailing = insets.right + (indicatorFirst ? 0 : deleteWidth);
    CGFloat contentTop = insets.top;
    CGFloat contentHeight = MAX(0, height - insets.top - insets.bottom);
    width -= trailing - margin;
    BOOL animated = self.animationView != nil;
    BOOL showsImage = animated || self.imageView.image != nil;
    BOOL showsTitle = self.titleLabel.text.length > 0;
    CGSize iconSize = animated ? [self cyl_animationSize] : [[self class] cyl_iconSizeForImage:self.imageView.image style:style];
    CGFloat spacing = (showsImage && showsTitle) ? style.imageTitleSpacing : 0;

    CGFloat available = MAX(0, width - 2 * margin - (showsImage ? iconSize.width + spacing : 0));
    CGSize titleSize = showsTitle ? [self.titleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, height)] : CGSizeZero;
    CGFloat titleWidth = MIN(available, ceil(titleSize.width));
    CGFloat titleHeight = MIN(height, ceil(titleSize.height));

    CGFloat imageX = 0;
    CGFloat titleX = 0;
    BOOL leading = style.contentAlignment == CYLTagContentAlignmentLeading;
    if (showsImage && showsTitle) {
        CGFloat group = iconSize.width + spacing + titleWidth;
        // Centered, or from the leading margin (the title truncated above, so the icon after it stays visible).
        CGFloat start = leading ? margin : floor((width - group) / 2);
        if (style.imagePlacement == CYLTagImagePlacementTrailing) {
            titleX = start;
            imageX = titleX + titleWidth + spacing;
        } else {
            imageX = start;
            titleX = imageX + iconSize.width + spacing;
        }
    } else if (showsImage && leading) {
        imageX = margin;
    } else if (showsTitle && leading) {
        titleX = margin;
        titleWidth = MIN(titleWidth, MAX(0, width - 2 * margin));
    } else if (showsImage) {
        imageX = style.layoutCentered ? floor((width - iconSize.width) / 2) : margin;
    } else if (showsTitle) {
        titleX = style.layoutCentered ? floor((width - titleWidth) / 2) : margin + style.imageSize.width + style.imageTitleSpacing;
        titleWidth = MIN(titleWidth, MAX(0, width - margin - titleX));
    }

    if (showsTitle) {
        self.titleLabel.frame = CGRectMake(titleX + style.titlePositionAdjustment.horizontal,
                                           CYLTagCenteredY(titleHeight, contentTop, contentHeight, height) + style.titlePositionAdjustment.vertical,
                                           titleWidth, titleHeight);
    } else {
        self.titleLabel.frame = CGRectZero;
    }
    if (showsImage) {
        CGRect frame = CGRectMake(imageX + style.imagePositionAdjustment.horizontal,
                                  CYLTagCenteredY(iconSize.height, contentTop, contentHeight, height) + style.imagePositionAdjustment.vertical,
                                  iconSize.width, iconSize.height);
        // Only the size changes; x and y stay, as CYLFlatDesignTabBarItem.imageInsets.
        UIEdgeInsets imageInsets = style.imageInsets;
        frame.size.width = MAX(0, frame.size.width - imageInsets.left - imageInsets.right);
        frame.size.height = MAX(0, frame.size.height - imageInsets.top - imageInsets.bottom);
        if (animated) {
            self.animationView.frame = frame;
            [self cyl_placeImageView:CGRectZero];
        } else {
            [self cyl_placeImageView:frame];
        }
    } else {
        [self cyl_placeImageView:CGRectZero];
    }
    // 0 is automatic: a capsule, as for CYLBadgeAppearance.
    self.layer.cornerRadius = appearance.cornerRadius > 0
        ? (appearance.cornerRadius <= CYLTagCornerRadiusSquare ? 0 : MIN(appearance.cornerRadius, height / 2)) : height / 2;
}

@end

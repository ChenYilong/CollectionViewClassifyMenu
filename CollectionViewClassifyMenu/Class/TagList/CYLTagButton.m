//
//  CYLTagButton.m
//  CollectionViewClassifyMenu
//

#import "CYLTagButton.h"
#import "CYLParameterConfiguration.h"

static NSArray<NSNumber *> *CYLTagButtonStates(void) {
    return @[@(UIControlStateNormal), @(UIControlStateSelected), @(UIControlStateDisabled)];
}

@implementation CYLTagButton

@synthesize style = _style;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _style = [CYLMenuStyle defaultStyle];
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_imageView];
        [self addSubview:_titleLabel];
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

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    [self cyl_updateAppearance];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self cyl_updateAppearance];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
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
    self.imageView.image = image;
    self.imageView.tintColor = [self.style iconColorForState:state];
    self.titleLabel.text = self.title;
    self.titleLabel.font = [self.style titleFontForState:state traitCollection:self.traitCollection];
    self.titleLabel.textColor = appearance.textColor;

    self.layer.backgroundColor = appearance.backgroundColor.CGColor;
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

+ (CGFloat)widthForTitle:(NSString *)title image:(UIImage *)image style:(CYLMenuStyle *)style traitCollection:(UITraitCollection *)traitCollection {
    CGFloat width = 0;
    for (NSNumber *state in CYLTagButtonStates()) {
        UIControlState controlState = state.unsignedIntegerValue;
        CYLTagAppearance *appearance = [style appearanceForState:controlState];
        CGFloat titleWidth = title.length > 0
            ? ceil([title sizeWithAttributes:@{NSFontAttributeName: [style titleFontForState:controlState traitCollection:traitCollection]}].width)
            : 0;
        CGFloat iconWidth = [self cyl_iconSizeForImage:image style:style].width;
        CGFloat content = titleWidth + iconWidth;
        if (titleWidth > 0 && iconWidth > 0) {
            content += style.imageTitleSpacing;
        } else if (titleWidth > 0 && !style.layoutCentered) {
            // The title keeps its place after an empty icon slot.
            content += style.imageSize.width + style.imageTitleSpacing;
        }
        width = MAX(width, ceil(content + 2 * appearance.margin));
    }
    return width;
}

+ (CGFloat)heightForStyle:(CYLMenuStyle *)style traitCollection:(UITraitCollection *)traitCollection {
    CGFloat height = style.itemHeight;
    for (NSNumber *state in CYLTagButtonStates()) {
        height = MAX(height, CYLTagHeightForFont([style titleFontForState:state.unsignedIntegerValue traitCollection:traitCollection], style.itemHeight));
    }
    return height;
}

#pragma mark Layout

/// CYLFlatDesignTabBarButton's `_updateLayout`, with the icon and title side by side.
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CYLMenuStyle *style = self.style;
    CYLTagAppearance *appearance = [style appearanceForState:[self cyl_currentState]];
    CGFloat margin = appearance.margin;
    BOOL showsImage = self.imageView.image != nil;
    BOOL showsTitle = self.titleLabel.text.length > 0;
    CGSize iconSize = [[self class] cyl_iconSizeForImage:self.imageView.image style:style];
    CGFloat spacing = (showsImage && showsTitle) ? style.imageTitleSpacing : 0;

    CGFloat available = MAX(0, width - 2 * margin - (showsImage ? iconSize.width + spacing : 0));
    CGSize titleSize = showsTitle ? [self.titleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, height)] : CGSizeZero;
    CGFloat titleWidth = MIN(available, ceil(titleSize.width));
    CGFloat titleHeight = MIN(height, ceil(titleSize.height));

    CGFloat imageX = 0;
    CGFloat titleX = 0;
    if (showsImage && showsTitle) {
        CGFloat group = iconSize.width + spacing + titleWidth;
        imageX = floor((width - group) / 2);
        titleX = imageX + iconSize.width + spacing;
    } else if (showsImage) {
        imageX = style.layoutCentered ? floor((width - iconSize.width) / 2) : margin;
    } else if (showsTitle) {
        titleX = style.layoutCentered ? floor((width - titleWidth) / 2) : margin + style.imageSize.width + style.imageTitleSpacing;
        titleWidth = MIN(titleWidth, MAX(0, width - margin - titleX));
    }

    if (showsTitle) {
        self.titleLabel.frame = CGRectMake(titleX + style.titlePositionAdjustment.horizontal,
                                           floor((height - titleHeight) / 2) + style.titlePositionAdjustment.vertical,
                                           titleWidth, titleHeight);
    } else {
        self.titleLabel.frame = CGRectZero;
    }
    if (showsImage) {
        CGRect frame = CGRectMake(imageX + style.imagePositionAdjustment.horizontal,
                                  floor((height - iconSize.height) / 2) + style.imagePositionAdjustment.vertical,
                                  iconSize.width, iconSize.height);
        // Only the size changes; x and y stay, as CYLFlatDesignTabBarItem.imageInsets.
        UIEdgeInsets insets = style.imageInsets;
        frame.size.width = MAX(0, frame.size.width - insets.left - insets.right);
        frame.size.height = MAX(0, frame.size.height - insets.top - insets.bottom);
        self.imageView.frame = frame;
    } else {
        self.imageView.frame = CGRectZero;
    }
    // 0 is automatic: a capsule, as for CYLBadgeAppearance.
    self.layer.cornerRadius = appearance.cornerRadius > 0 ? MIN(appearance.cornerRadius, height / 2) : height / 2;
}

@end

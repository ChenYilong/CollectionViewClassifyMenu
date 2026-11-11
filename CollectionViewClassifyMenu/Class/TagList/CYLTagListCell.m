//
//  CYLTagListCell.m
//  CollectionViewClassifyMenu
//

#import "CYLTagListCell.h"

/// Space between the title and the badge, and the badge's horizontal padding.
static CGFloat const kCYLTagBadgeSpacing = 4;
static CGFloat const kCYLTagBadgePadding = 4;

@implementation CYLTagListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _button = [[CYLTagButton alloc] initWithFrame:self.contentView.bounds];
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // The collection view handles taps.
        _button.userInteractionEnabled = NO;
        [self.contentView addSubview:_button];
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.layer.cornerRadius = 3;
        _badgeLabel.layer.masksToBounds = YES;
        _badgeLabel.adjustsFontForContentSizeCategory = YES;
        _badgeLabel.font = [[self class] cyl_badgeFontForTraitCollection:nil];
        _badgeLabel.hidden = YES;
        // Read as the cell's value, not as an element of its own.
        _badgeLabel.isAccessibilityElement = NO;
        [self.contentView addSubview:_badgeLabel];
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;
    }
    return self;
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
    self.accessibilityIdentifier = CYLTagListItemAccessibilityIdentifier;
    self.accessibilityHint = nil;
    UIAccessibilityTraits traits = UIAccessibilityTraitButton;
    if (selected) traits |= UIAccessibilityTraitSelected;
    if (!enabled) traits |= UIAccessibilityTraitNotEnabled;
    self.accessibilityTraits = traits;
}

+ (UIFont *)cyl_badgeFontForTraitCollection:(UITraitCollection *)traitCollection {
    return [[UIFontMetrics metricsForTextStyle:UIFontTextStyleCaption2] scaledFontForFont:[UIFont boldSystemFontOfSize:11]
                                                          compatibleWithTraitCollection:traitCollection];
}

+ (CGSize)badgeSizeForText:(NSString *)text traitCollection:(UITraitCollection *)traitCollection {
    if (text.length == 0) {
        return CGSizeZero;
    }
    UIFont *font = [self cyl_badgeFontForTraitCollection:traitCollection];
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: font}];
    CGFloat height = ceil(font.lineHeight) + 2;
    return CGSizeMake(kCYLTagBadgeSpacing + MAX(height, ceil(size.width) + 2 * kCYLTagBadgePadding), height);
}

- (void)setBadgeText:(NSString *)text style:(CYLMenuStyle *)style {
    BOOL shows = text.length > 0;
    self.badgeLabel.hidden = !shows;
    self.badgeLabel.text = shows ? text : nil;
    self.badgeLabel.backgroundColor = style.badgeBackgroundColor;
    self.badgeLabel.textColor = style.badgeTextColor;
    self.accessibilityValue = shows ? text : nil;
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.badgeLabel.hidden = YES;
    self.badgeLabel.text = nil;
    self.accessibilityValue = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    if (self.badgeLabel.hidden) {
        self.button.frame = bounds;
        return;
    }
    // The tag as wide as its content (truncated when the badge needs the room), then the badge.
    CGSize badge = [[self class] badgeSizeForText:self.badgeLabel.text traitCollection:self.traitCollection];
    CGFloat natural = ceil([CYLTagButton widthForTitle:self.button.title image:self.button.image
                                                 style:self.button.style traitCollection:self.traitCollection]);
    CGFloat width = MAX(0, MIN(natural, CGRectGetWidth(bounds) - badge.width));
    self.button.frame = CGRectMake(0, 0, width, CGRectGetHeight(bounds));
    CGFloat badgeWidth = badge.width - kCYLTagBadgeSpacing;
    self.badgeLabel.frame = CGRectMake(width + kCYLTagBadgeSpacing, floor((CGRectGetHeight(bounds) - badge.height) / 2),
                                       badgeWidth, badge.height);
}

@end

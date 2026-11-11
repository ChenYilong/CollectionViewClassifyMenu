//
//  CYLTagAppearance.m
//  CollectionViewClassifyMenu
//

#import "CYLTagAppearance.h"

static CGFloat CYLTagSanitized(CGFloat value) {
    return (isfinite(value) && value > 0) ? value : 0;
}

const CGFloat CYLTagCornerRadiusSquare = 0.001;

@implementation CYLTagAppearance

@synthesize backgroundColor = _backgroundColor;
@synthesize textColor = _textColor;
@synthesize font = _font;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset {
    _backgroundColor = nil;
    _textColor = nil;
    _font = nil;
    _iconColor = nil;
    _cornerRadius = 3;
    _borderColor = nil;
    _borderWidth = 0;
    _contentInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    _backgroundImage = nil;
}

- (UIColor *)backgroundColor {
    return _backgroundColor ?: [UIColor whiteColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
}

- (UIColor *)textColor {
    return _textColor ?: [UIColor colorWithWhite:0.25 alpha:1];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
}

- (UIFont *)font {
    return _font ?: [UIFont systemFontOfSize:14];
}

- (void)setFont:(UIFont *)font {
    _font = font;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = CYLTagSanitized(cornerRadius);
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = CYLTagSanitized(borderWidth);
}

- (CGFloat)margin {
    return MAX(_contentInsets.left, _contentInsets.right);
}

- (void)setMargin:(CGFloat)margin {
    _contentInsets.left = CYLTagSanitized(margin);
    _contentInsets.right = _contentInsets.left;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = UIEdgeInsetsMake(CYLTagSanitized(contentInsets.top), CYLTagSanitized(contentInsets.left),
                                      CYLTagSanitized(contentInsets.bottom), CYLTagSanitized(contentInsets.right));
}

- (id)copyWithZone:(NSZone *)zone {
    CYLTagAppearance *copy = [[[self class] allocWithZone:zone] init];
    copy->_backgroundColor = _backgroundColor;
    copy->_textColor = _textColor;
    copy->_font = _font;
    copy->_iconColor = _iconColor;
    copy->_cornerRadius = _cornerRadius;
    copy->_borderColor = _borderColor;
    copy->_borderWidth = _borderWidth;
    copy->_contentInsets = _contentInsets;
    copy->_backgroundImage = _backgroundImage;
    return copy;
}

@end

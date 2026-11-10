//
//  CYLTagAppearance.m
//  CollectionViewClassifyMenu
//

#import "CYLTagAppearance.h"

static CGFloat CYLTagSanitized(CGFloat value) {
    return (isfinite(value) && value > 0) ? value : 0;
}

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
    _margin = 10;
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

- (void)setMargin:(CGFloat)margin {
    _margin = CYLTagSanitized(margin);
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
    copy->_margin = _margin;
    return copy;
}

@end

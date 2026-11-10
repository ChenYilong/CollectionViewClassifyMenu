//
//  CYLTagListCell.m
//  CollectionViewClassifyMenu
//

#import "CYLTagListCell.h"

@implementation CYLTagListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _button = [[CYLTagButton alloc] initWithFrame:self.contentView.bounds];
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // The collection view handles taps.
        _button.userInteractionEnabled = NO;
        [self.contentView addSubview:_button];
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
    UIAccessibilityTraits traits = UIAccessibilityTraitButton;
    if (selected) traits |= UIAccessibilityTraitSelected;
    if (!enabled) traits |= UIAccessibilityTraitNotEnabled;
    self.accessibilityTraits = traits;
}

@end

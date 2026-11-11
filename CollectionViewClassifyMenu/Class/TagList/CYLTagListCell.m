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

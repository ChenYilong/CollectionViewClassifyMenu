//
//  CYLTagFoldCell.m
//  CollectionViewClassifyMenu
//

#import "CYLTagFoldCell.h"

@implementation CYLTagFoldCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _foldButton = [[CYLTagFoldButton alloc] initWithFrame:self.contentView.bounds];
        _foldButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // The collection view handles taps; the cell is the accessibility element.
        _foldButton.userInteractionEnabled = NO;
        _foldButton.isAccessibilityElement = NO;
        [self.contentView addSubview:_foldButton];
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;
        self.accessibilityIdentifier = CYLTagListFoldControlAccessibilityIdentifier;
    }
    return self;
}

- (void)configureWithFoldControl:(CYLMenuFoldControl *)foldControl
                       itemStyle:(CYLMenuStyle *)itemStyle
                        expanded:(BOOL)expanded
                        animated:(BOOL)animated {
    [self.foldButton applyInlineFoldControl:foldControl itemStyle:itemStyle expanded:expanded animated:animated];
}

@end

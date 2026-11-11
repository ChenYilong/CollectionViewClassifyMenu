//
//  CYLTagCreateCell.m
//  CollectionViewClassifyMenu
//

#import "CYLTagCreateCell.h"
#import "CYLMenuResources.h"

@implementation CYLTagCreateCell

+ (UIImage *)plusImage {
    return CYLMenuImage(@"cyl_tag_plus") ?: [UIImage systemImageNamed:@"plus"];
}

+ (NSString *)titleForName:(NSString *)name {
    if (name.length == 0) {
        return CYLMenuLocalizedString(@"CYLMenuNewTag", @"Creates a tag");
    }
    return [NSString stringWithFormat:CYLMenuLocalizedString(@"CYLMenuNewTagNamed", @"Creates a tag with this name"), name];
}

+ (CYLMenuStyle *)styleWithStyle:(CYLMenuStyle *)style {
    CYLMenuStyle *outlined = [style copy];
    CYLTagAppearance *normal = outlined.normalAppearance;
    normal.backgroundColor = style.backgroundColor ?: [UIColor systemBackgroundColor];
    normal.borderColor = [UIColor separatorColor];
    normal.borderWidth = MAX(1.0 / MAX(1, UIScreen.mainScreen.scale), 1);
    normal.textColor = [UIColor secondaryLabelColor];
    [outlined setIconColor:[UIColor tertiaryLabelColor] forState:UIControlStateNormal];
    [outlined setTitleTextAttributes:nil forState:UIControlStateNormal];
    outlined.imagePlacement = CYLTagImagePlacementLeading;
    if (CGSizeEqualToSize(outlined.imageSize, CGSizeZero)) {
        outlined.imageSize = CGSizeMake(14, 14);
    }
    return outlined;
}

- (void)configureWithName:(NSString *)name style:(CYLMenuStyle *)style enabled:(BOOL)enabled {
    NSString *title = [[self class] titleForName:name];
    [self configureWithTitle:title image:[[self class] plusImage] selectedImage:nil animationURL:nil
                       style:style selected:NO enabled:enabled];
    // An action, not a tag: never "selected" for VoiceOver.
    self.accessibilityTraits = enabled ? UIAccessibilityTraitButton : (UIAccessibilityTraitButton | UIAccessibilityTraitNotEnabled);
    self.accessibilityIdentifier = CYLTagCreateItemAccessibilityIdentifier;
}

@end

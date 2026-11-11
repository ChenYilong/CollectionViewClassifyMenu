//
//  CYLTagListCell.h
//  CollectionViewClassifyMenu
//
//  The cell of CYLTagListView: it hosts one CYLTagButton (the tag view) and is the accessibility
//  element; the collection view handles taps. Subclasses draw special items, such as
//  CYLTagCreateCell ("+ 新建标签").
//

#import <UIKit/UIKit.h>
#import "CYLTagButton.h"
#import "CYLTagListAccessibility.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLTagListCell : UICollectionViewCell
@property (nonatomic, strong, readonly) CYLTagButton *button;
/*!
 * The list's style object last applied, so that a style is copied into the button only when it changes.
 */
@property (nonatomic, weak, nullable) CYLMenuStyle *appliedStyle;

- (void)configureWithTitle:(NSString *)title
                     image:(nullable UIImage *)image
             selectedImage:(nullable UIImage *)selectedImage
              animationURL:(nullable NSURL *)animationURL
                     style:(CYLMenuStyle *)style
                  selected:(BOOL)selected
                   enabled:(BOOL)enabled;

/*!
 * The badge after the title (`menuBadgeForItemAtIndexPath:`), such as "热"; hidden without a text.
 */
@property (nonatomic, strong, readonly) UILabel *badgeLabel;

/*!
 * Shows `text` as the badge in the colors of `style` (nil or empty hides it); the title is truncated to make room
 * for it, and VoiceOver reads it as the cell's value.
 */
- (void)setBadgeText:(nullable NSString *)text style:(CYLMenuStyle *)style;

/*!
 * The badge's size for `text`, including the space before it; CGSizeZero without a text.
 */
+ (CGSize)badgeSizeForText:(nullable NSString *)text traitCollection:(nullable UITraitCollection *)traitCollection;
@end

NS_ASSUME_NONNULL_END

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

/*!
 * Shows the delete indicator ("×") and makes it tappable; also adds a VoiceOver "Delete" action. NO by default.
 */
@property (nonatomic, assign) BOOL deletable;
/*!
 * Called when the delete indicator is tapped (or the VoiceOver action is used).
 */
@property (nonatomic, copy, nullable) void (^deleteHandler)(void);

/*!
 * Plays CYLMenuStyle's touch ripple (rippleColor) from `point`, in the tag's coordinates; a touch plays it too.
 */
- (void)showRippleAtPoint:(CGPoint)point;

/*!
 * Shows a tag: its title (also its accessibility label), icons, look and state. An icon's accessibilityLabel, when
 * it has one (such as a "hot" icon), is read by VoiceOver as the tag's value.
 */
- (void)configureWithTitle:(NSString *)title
                     image:(nullable UIImage *)image
             selectedImage:(nullable UIImage *)selectedImage
              animationURL:(nullable NSURL *)animationURL
                     style:(CYLMenuStyle *)style
                  selected:(BOOL)selected
                   enabled:(BOOL)enabled;
@end

NS_ASSUME_NONNULL_END

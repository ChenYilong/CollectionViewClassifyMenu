//
//  CYLTagCreateCell.h
//  CollectionViewClassifyMenu
//
//  "+ 新建标签": the cell of a CYLMenuItemTypeCreate item. A CYLTagListCell with the core's plus icon
//  (cyl_tag_plus in CYLClassifyMenuResources.bundle), the localized title "新建标签" or "新建标签：<name>"
//  (CYLMenuNewTag, CYLMenuNewTagNamed) and an outlined look derived from the list's style. It is never
//  selected.
//

#import "CYLTagListCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLTagCreateCell : CYLTagListCell

/*!
 * The plus icon of the core bundle (a template image, drawn in the icon color).
 */
+ (UIImage *)plusImage;
/*!
 * "新建标签" for an empty name, "新建标签：<name>" otherwise, in the component's language.
 */
+ (NSString *)titleForName:(nullable NSString *)name;
/*!
 * The outlined look of the item, from a list (or section) style: the list's background, a hairline
 * border and secondary text. The metrics stay the list's.
 */
+ (CYLMenuStyle *)styleWithStyle:(CYLMenuStyle *)style;

/*!
 * Shows "+ 新建标签" or "+ 新建标签：<name>" in `style` (already outlined).
 */
- (void)configureWithName:(nullable NSString *)name style:(CYLMenuStyle *)style enabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END

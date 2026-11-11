//
//  CYLImageTagView.h
//  CollectionViewClassifyMenu
//
//  A picture with groups of tags (TagViewGroup's sample TagImageView, in the core): set the image and the groups,
//  toggle the tags with an animation, or edit them: drag a group, tap a tag to turn it to the next direction.
//

#import <UIKit/UIKit.h>
#import "CYLImageTagGroupView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLImageTagView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, nullable) UIImage *image;

/*!
 * The groups, kept up to date while editing (getTagGroupModels). Setting it replaces them (setTagList).
 */
@property (nonatomic, copy) NSArray<CYLImageTagGroup *> *tagGroups;
- (void)addTagGroup:(CYLImageTagGroup *)group;
- (void)removeTagGroupAtIndex:(NSUInteger)index;
- (void)removeAllTagGroups;
/*!
 * The group views, in the order of `tagGroups`.
 */
@property (nonatomic, copy, readonly) NSArray<CYLImageTagGroupView *> *groupViews;

/*!
 * Edit mode (setEditMode): groups can be dragged, a tap on a tag turns it to the next direction, no ripples.
 * NO by default: groups show a ripple and toggle with an animation.
 */
@property (nonatomic, assign, getter=isEditing) BOOL editing;
/*!
 * Shows hidden groups and hides shown ones, animated (excuteTagsAnimation).
 */
- (void)toggleTagGroupsAnimated:(BOOL)animated;
/*!
 * Configures each group view after it is made (radii, colors, line lengths).
 */
@property (nonatomic, copy, nullable) void (^groupConfiguration)(CYLImageTagGroupView *groupView, NSUInteger groupIndex);

#pragma mark Events
/*!
 * A tap on the picture outside the tags (the sample toggles the tags).
 */
@property (nonatomic, copy, nullable) void (^imageTapHandler)(void);
@property (nonatomic, copy, nullable) void (^circleTapHandler)(NSUInteger groupIndex);
/*!
 * After the turn of the tag while editing.
 */
@property (nonatomic, copy, nullable) void (^tagTapHandler)(NSUInteger groupIndex, NSUInteger tagIndex, CYLImageTag *tag);
@property (nonatomic, copy, nullable) void (^longPressHandler)(NSUInteger groupIndex);
@property (nonatomic, copy, nullable) void (^dragHandler)(NSUInteger groupIndex, CGPoint percentPosition);

@end

NS_ASSUME_NONNULL_END

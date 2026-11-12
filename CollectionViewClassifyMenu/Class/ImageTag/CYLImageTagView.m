//
//  CYLImageTagView.m
//  CollectionViewClassifyMenu
//

#import "CYLImageTagView.h"
#import "CYLMenuResources.h"

/// The picture: an accessibility element whose activation is a tap on it.
@interface CYLImageTagPictureView : UIImageView
@property (nonatomic, copy, nullable) void (^activationHandler)(void);
@end

@implementation CYLImageTagPictureView

- (BOOL)accessibilityActivate {
    if (!self.activationHandler) {
        return NO;
    }
    self.activationHandler();
    return YES;
}

@end

@interface CYLImageTagView () <CYLImageTagGroupViewDelegate>
@property (nonatomic, strong) NSMutableArray<CYLImageTagGroup *> *groups;
@property (nonatomic, strong) NSMutableArray<CYLImageTagGroupView *> *views;
@end

@implementation CYLImageTagView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self cyl_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self cyl_commonInit];
    }
    return self;
}

- (void)cyl_commonInit {
    _groups = [NSMutableArray array];
    _views = [NSMutableArray array];
    CYLImageTagPictureView *picture = [[CYLImageTagPictureView alloc] initWithFrame:self.bounds];
    __weak __typeof(self) weakSelf = self;
    picture.activationHandler = ^{
        [weakSelf cyl_handleImageTap];
    };
    picture.isAccessibilityElement = YES;
    _imageView = picture;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_imageView];
    self.clipsToBounds = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cyl_handleImageTap)]];
}

/// The picture's label, traits and hint.
- (void)cyl_updatePictureAccessibility {
    UIImageView *picture = self.imageView;
    NSString *label = picture.image.accessibilityLabel;
    picture.accessibilityLabel = label.length > 0 ? label : CYLMenuLocalizedString(@"CYLImageTagPicture", @"A picture with tags");
    picture.accessibilityTraits = UIAccessibilityTraitImage | (self.imageTapHandler ? UIAccessibilityTraitButton : 0);
    picture.accessibilityHint = self.imageAccessibilityHint;
}

- (void)setImageTapHandler:(void (^)(void))handler {
    _imageTapHandler = [handler copy];
    [self cyl_updatePictureAccessibility];
}

- (void)setImageAccessibilityHint:(NSString *)hint {
    _imageAccessibilityHint = [hint copy];
    [self cyl_updatePictureAccessibility];
}

- (void)setLongPressAccessibilityActionName:(NSString *)name {
    _longPressAccessibilityActionName = [name copy];
    for (CYLImageTagGroupView *view in self.views) {
        view.longPressAccessibilityActionName = name;
    }
}

/// Edit mode: the tags turn on a tap, so they say so.
- (void)cyl_applyAccessibilityToGroupView:(CYLImageTagGroupView *)view {
    view.longPressAccessibilityActionName = self.longPressAccessibilityActionName;
    view.tagAccessibilityHint = self.editing ? CYLMenuLocalizedString(@"CYLImageTagTurnHint", @"Hint of a tag in edit mode") : nil;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    [self cyl_updatePictureAccessibility];
}

- (NSArray<CYLImageTagGroup *> *)tagGroups {
    return [self.groups copy];
}

- (void)setTagGroups:(NSArray<CYLImageTagGroup *> *)tagGroups {
    [self removeAllTagGroups];
    for (CYLImageTagGroup *group in tagGroups) {
        [self addTagGroup:group];
    }
}

#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self cyl_separateGroups];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setNeedsLayout];
}

/*!
 * Keeps groups from covering each other (large Dynamic Type sizes make tags taller): each group that overlaps an
 * earlier one moves up or down by the smallest distance that clears every earlier group and stays inside the view.
 * Only the display moves (`displayOffset`); `percentPosition` and the groups' data do not change. While editing,
 * groups stay where they are dragged.
 */
- (void)cyl_separateGroups {
    static const CGFloat spacing = 4;
    NSMutableArray<NSValue *> *placed = [NSMutableArray array];
    CGFloat height = CGRectGetHeight(self.bounds);
    for (CYLImageTagGroupView *view in self.views) {
        view.displayOffset = CGPointZero;
        [view layoutIfNeeded];
        if (self.editing || view.isGroupHidden) {
            [placed addObject:[NSValue valueWithCGRect:view.occupiedFrame]];
            continue;
        }
        CGRect frame = view.occupiedFrame;
        BOOL (^clear)(CGFloat) = ^BOOL(CGFloat dy) {
            CGRect moved = CGRectOffset(frame, 0, dy);
            if (CGRectGetMinY(moved) < 0 || CGRectGetMaxY(moved) > height) return NO;
            for (NSValue *value in placed) {
                if (CGRectIntersectsRect(CGRectInset(moved, 0, -spacing / 2), value.CGRectValue)) return NO;
            }
            return YES;
        };
        if (clear(0)) {
            [placed addObject:[NSValue valueWithCGRect:frame]];
            continue;
        }
        CGFloat best = CGFLOAT_MAX;
        for (NSValue *value in placed) {
            CGRect other = value.CGRectValue;
            for (NSNumber *candidate in @[@(CGRectGetMaxY(other) + spacing - CGRectGetMinY(frame)),
                                          @(CGRectGetMinY(other) - spacing - CGRectGetMaxY(frame))]) {
                CGFloat dy = candidate.doubleValue;
                if (fabs(dy) < fabs(best) && clear(dy)) best = dy;
            }
        }
        if (best != CGFLOAT_MAX) {
            view.displayOffset = CGPointMake(0, best);
            [view layoutIfNeeded];
        }
        [placed addObject:[NSValue valueWithCGRect:view.occupiedFrame]];
    }
}

- (NSArray<CYLImageTagGroupView *> *)groupViews {
    return [self.views copy];
}

- (void)addTagGroup:(CYLImageTagGroup *)group {
    CYLImageTagGroup *model = [group copy];
    CYLImageTagGroupView *view = [[CYLImageTagGroupView alloc] initWithFrame:self.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.delegate = self;
    view.tags = model.tags;
    view.percentPosition = model.percentPosition;
    view.draggable = self.editing;
    view.showsRipple = !self.editing;
    [self cyl_applyAccessibilityToGroupView:view];
    [self.groups addObject:model];
    [self.views addObject:view];
    if (self.groupConfiguration) {
        self.groupConfiguration(view, self.views.count - 1);
    }
    [self addSubview:view];
    [self setNeedsLayout];
}

- (void)removeTagGroupAtIndex:(NSUInteger)index {
    if (index >= self.views.count) {
        return;
    }
    [self.views[index] removeFromSuperview];
    [self.views removeObjectAtIndex:index];
    [self.groups removeObjectAtIndex:index];
}

- (void)removeAllTagGroups {
    for (UIView *view in self.views) {
        [view removeFromSuperview];
    }
    [self.views removeAllObjects];
    [self.groups removeAllObjects];
}

- (void)setEditing:(BOOL)editing {
    _editing = editing;
    [self setNeedsLayout];
    for (CYLImageTagGroupView *view in self.views) {
        view.draggable = editing;
        view.showsRipple = !editing;
        [self cyl_applyAccessibilityToGroupView:view];
    }
}

- (void)toggleTagGroupsAnimated:(BOOL)animated {
    for (CYLImageTagGroupView *view in self.views) {
        if (view.isGroupHidden) {
            [view showAnimated:animated completion:nil];
        } else {
            [view hideAnimated:animated completion:nil];
        }
    }
}

- (void)cyl_handleImageTap {
    if (self.imageTapHandler) {
        self.imageTapHandler();
    }
}

#pragma mark CYLImageTagGroupViewDelegate

- (void)groupViewDidTapCircle:(CYLImageTagGroupView *)groupView {
    NSUInteger index = [self.views indexOfObject:groupView];
    if (index != NSNotFound && self.circleTapHandler) {
        self.circleTapHandler(index);
    }
}

- (void)groupView:(CYLImageTagGroupView *)groupView didTapTagAtIndex:(NSInteger)tagIndex {
    NSUInteger index = [self.views indexOfObject:groupView];
    if (index == NSNotFound || tagIndex < 0 || tagIndex >= (NSInteger)self.groups[index].tags.count) {
        return;
    }
    CYLImageTag *tag = self.groups[index].tags[tagIndex];
    if (self.editing) {
        // The sample's onTagClicked: the next direction.
        tag.direction = CYLImageTagDirectionNext(tag.direction);
        groupView.tags = self.groups[index].tags;
        // The tag views were remade: keep VoiceOver on the turned tag.
        if (tagIndex < (NSInteger)groupView.tagViews.count) {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, groupView.tagViews[tagIndex]);
        }
    }
    if (self.tagTapHandler) {
        self.tagTapHandler(index, (NSUInteger)tagIndex, tag);
    }
}

- (void)groupViewDidLongPress:(CYLImageTagGroupView *)groupView {
    NSUInteger index = [self.views indexOfObject:groupView];
    if (index != NSNotFound && self.longPressHandler) {
        self.longPressHandler(index);
    }
}

- (void)groupView:(CYLImageTagGroupView *)groupView didDragToPercentPosition:(CGPoint)percentPosition {
    NSUInteger index = [self.views indexOfObject:groupView];
    if (index == NSNotFound) {
        return;
    }
    self.groups[index].percentPosition = percentPosition;
    if (self.dragHandler) {
        self.dragHandler(index, percentPosition);
    }
}

@end

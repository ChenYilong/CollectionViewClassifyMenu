//
//  CYLImageTagView.m
//  CollectionViewClassifyMenu
//

#import "CYLImageTagView.h"

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
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_imageView];
    self.clipsToBounds = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cyl_handleImageTap)]];
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
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
    [self.groups addObject:model];
    [self.views addObject:view];
    if (self.groupConfiguration) {
        self.groupConfiguration(view, self.views.count - 1);
    }
    [self addSubview:view];
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
    for (CYLImageTagGroupView *view in self.views) {
        view.draggable = editing;
        view.showsRipple = !editing;
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

//
//  CYLMenuFoldControl.m
//  CollectionViewClassifyMenu
//

#import "CYLMenuFoldControl.h"
#import "CYLMenuResources.h"

@implementation CYLMenuFoldControl

+ (instancetype)foldControlWithPosition:(CYLMenuFoldControlPosition)position content:(CYLMenuFoldControlContent)content {
    CYLMenuFoldControl *control = [[self alloc] init];
    control.position = position;
    control.content = content;
    return control;
}

+ (instancetype)noFoldControl {
    return [self foldControlWithPosition:CYLMenuFoldControlPositionNone content:CYLMenuFoldControlContentIcon];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _rotatesImageWhenExpanded = YES;
    }
    return self;
}

- (NSString *)title {
    return _title ?: CYLMenuLocalizedString(@"CYLMenuExpand", @"Expand a section");
}

- (NSString *)collapseTitle {
    return _collapseTitle ?: CYLMenuLocalizedString(@"CYLMenuCollapse", @"Collapse a section");
}

- (UIImage *)image {
    return _image ?: (CYLMenuImage(@"cyl_fold_chevron") ?: [UIImage systemImageNamed:@"chevron.down"]);
}

- (BOOL)usesDefaultImage {
    return _image == nil;
}

- (BOOL)showsImageWhenExpanded:(BOOL)expanded {
    return self.content != CYLMenuFoldControlContentTitle;
}

- (BOOL)showsTitleWhenExpanded:(BOOL)expanded {
    switch (self.content) {
        case CYLMenuFoldControlContentIconAndTitle: return !expanded;
        case CYLMenuFoldControlContentTitle: return YES;
        case CYLMenuFoldControlContentIcon: return NO;
    }
    return NO;
}

- (NSString *)titleWhenExpanded:(BOOL)expanded {
    if (![self showsTitleWhenExpanded:expanded]) {
        return nil;
    }
    return expanded ? self.collapseTitle : self.title;
}

- (id)copyWithZone:(NSZone *)zone {
    CYLMenuFoldControl *copy = [[[self class] allocWithZone:zone] init];
    copy.position = self.position;
    copy.content = self.content;
    copy->_title = [_title copy];
    copy->_collapseTitle = [_collapseTitle copy];
    copy->_image = _image;
    copy.color = self.color;
    copy.font = self.font;
    copy.rotatesImageWhenExpanded = self.rotatesImageWhenExpanded;
    return copy;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CYLMenuFoldControl class]]) {
        return NO;
    }
    CYLMenuFoldControl *other = object;
    return other.position == self.position && other.content == self.content &&
           [other.title isEqualToString:self.title] && [other.collapseTitle isEqualToString:self.collapseTitle] &&
           other.image == self.image && (other.color == self.color || [other.color isEqual:self.color]) &&
           (other.font == self.font || [other.font isEqual:self.font]) &&
           other.rotatesImageWhenExpanded == self.rotatesImageWhenExpanded;
}

- (NSUInteger)hash {
    return (NSUInteger)self.position * 31 + (NSUInteger)self.content;
}

@end

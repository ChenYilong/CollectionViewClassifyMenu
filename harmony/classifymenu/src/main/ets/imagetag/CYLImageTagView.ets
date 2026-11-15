/**
 * A picture with groups of tags on it (iOS CYLImageTagView; Android CYLImageTagView.kt), each group at a position
 * relative to the picture. In edit mode the groups can be dragged and a tap on a tag turns it to the next direction.
 *
 * `CYLImageTagView` holds the state and the API (as the iOS class); `CYLImageTagViewComponent` draws it.
 */
import { CYLImage, CYLPoint, CYLRect } from '../core/CYLTypes';
import { CYLMenuLocalizedString } from '../core/CYLMenuResources';
import { CYLImageTag, CYLImageTagDirections, CYLImageTagGeometry, CYLImageTagGroup } from './CYLImageTagModel';
import { CYLImageTagGroupView, CYLImageTagGroupViewComponent, CYLImageTagGroupViewDelegate } from './CYLImageTagGroupView';

const GROUP_SPACING: number = 4;

@Observed
export class CYLImageTagView implements CYLImageTagGroupViewDelegate {
  /** Bumped on every change the component draws. */
  revision: number = 0;

  private groups: CYLImageTagGroup[] = [];
  private views: CYLImageTagGroupView[] = [];
  private editingValue: boolean = false;
  private imageValue?: CYLImage;
  private longPressNameValue?: string;
  private width: number = 0;
  private height: number = 0;

  /** Configures each group view after it is made (radii, colors, line lengths). */
  groupConfiguration?: (groupView: CYLImageTagGroupView, index: number) => void;
  /** A tap on the picture outside the tags (the sample toggles the tags). */
  imageTapHandler?: () => void;
  /** A tap on the circle of the group at this index. */
  circleTapHandler?: (index: number) => void;
  /** After the turn of the tag while editing. */
  tagTapHandler?: (groupIndex: number, tagIndex: number, tag: CYLImageTag) => void;
  /** A long press on the group at this index. */
  longPressHandler?: (index: number) => void;
  /** The group at this index was dragged to a new position (relative to the picture). */
  dragHandler?: (index: number, percentPosition: CYLPoint) => void;
  /** The picture's screen reader hint, such as "轻点两下显示或隐藏标签". */
  imageAccessibilityHint?: string;
  /** The picture's screen reader label; undefined: "图片" (core string `CYLImageTagPicture`). */
  imageAccessibilityLabel?: string;

  /** `init()`: an empty view. */
  constructor() {
  }

  /** The picture. */
  get image(): CYLImage | undefined {
    return this.imageValue;
  }

  set image(value: CYLImage | undefined) {
    this.imageValue = value;
    this.revision++;
  }

  /** The groups, kept up to date while editing (getTagGroupModels). Setting it replaces them (setTagList). */
  get tagGroups(): CYLImageTagGroup[] {
    return this.groups;
  }

  set tagGroups(value: CYLImageTagGroup[]) {
    this.removeAllTagGroups();
    for (const group of value) {
      this.addTagGroup(group);
    }
  }

  /** The group views, in the order of `tagGroups`. */
  get groupViews(): CYLImageTagGroupView[] {
    return this.views;
  }

  /**
   * Edit mode (setEditMode): groups can be dragged, a tap on a tag turns it to the next direction, no ripples. False
   * by default: groups show a ripple and toggle with an animation.
   */
  get isEditing(): boolean {
    return this.editingValue;
  }

  set isEditing(value: boolean) {
    this.editingValue = value;
    for (const view of this.views) {
      view.isDraggable = value;
      view.showsRipple = !value;
      this.applyAccessibility(view);
    }
    this.layoutSubviews();
  }

  /** The name of every group's long-press action, such as "删除标签组" in edit mode. undefined: "长按". */
  get longPressAccessibilityActionName(): string | undefined {
    return this.longPressNameValue;
  }

  set longPressAccessibilityActionName(value: string | undefined) {
    this.longPressNameValue = value;
    for (const view of this.views) {
      view.longPressAccessibilityActionName = value;
    }
  }

  /** The picture's label. */
  get pictureAccessibilityLabel(): string {
    const label = this.imageAccessibilityLabel ?? '';
    return label.length === 0 ? CYLMenuLocalizedString('CYLImageTagPicture') : label;
  }

  // Groups

  /** Adds a copy of the group and its view on top of the others. */
  addTagGroup(group: CYLImageTagGroup): void {
    const model = group.copy();
    const view = new CYLImageTagGroupView(this.width, this.height);
    view.delegate = this;
    view.tags = model.tags;
    view.percentPosition = model.percentPosition;
    view.isDraggable = this.editingValue;
    view.showsRipple = !this.editingValue;
    this.applyAccessibility(view);
    this.groups.push(model);
    this.views.push(view);
    this.groupConfiguration?.(view, this.views.length - 1);
    this.layoutSubviews();
  }

  /** Removes the group at this index and its view; an index past the end does nothing. */
  removeTagGroup(index: number): void {
    if (index < 0 || index >= this.views.length) {
      return;
    }
    this.views[index].dispose();
    this.views.splice(index, 1);
    this.groups.splice(index, 1);
    this.revision++;
  }

  /** Removes every group and its view. */
  removeAllTagGroups(): void {
    for (const view of this.views) {
      view.dispose();
    }
    this.views = [];
    this.groups = [];
    this.revision++;
  }

  /** Shows hidden groups and hides shown ones, animated (excuteTagsAnimation). */
  toggleTagGroups(animated: boolean): void {
    for (const view of this.views) {
      if (view.isGroupHidden) {
        view.show(animated);
      } else {
        view.hide(animated);
      }
    }
  }

  // Layout

  /** The view's size; the component sets it. */
  setBounds(width: number, height: number): void {
    if (width === this.width && height === this.height) {
      return;
    }
    this.width = width;
    this.height = height;
    for (const view of this.views) {
      view.setBounds(width, height);
    }
    this.layoutSubviews();
  }

  /**
   * Keeps groups from covering each other: each group that overlaps an earlier one moves up or down by the smallest
   * distance that clears every earlier group and stays inside the view. Only the display moves (`displayOffset`).
   * While editing, groups stay where they are dragged.
   */
  layoutSubviews(): void {
    const placed: CYLRect[] = [];
    for (const view of this.views) {
      view.displayOffset = new CYLPoint(0, 0);
      view.layoutIfNeeded();
      if (this.editingValue || view.isGroupHidden) {
        placed.push(view.occupiedFrame);
        continue;
      }
      const dy = CYLImageTagGeometry.separationOffset(view.occupiedFrame, placed, this.height, GROUP_SPACING);
      if (dy !== 0) {
        view.displayOffset = new CYLPoint(0, dy);
      }
      placed.push(view.occupiedFrame);
    }
    this.revision++;
  }

  // CYLImageTagGroupViewDelegate

  groupViewDidTapCircle: (groupView: CYLImageTagGroupView) => void = (groupView: CYLImageTagGroupView) => {
    const index = this.views.indexOf(groupView);
    if (index >= 0) {
      this.circleTapHandler?.(index);
    }
  };

  /** `groupView(_:didTapTagAt:)`. */
  didTapTagAt: (groupView: CYLImageTagGroupView, tagIndex: number) => void =
    (groupView: CYLImageTagGroupView, tagIndex: number) => {
      const index = this.views.indexOf(groupView);
      if (index < 0 || tagIndex < 0 || tagIndex >= this.groups[index].tags.length) {
        return;
      }
      const tag = this.groups[index].tags[tagIndex];
      if (this.editingValue) {
        // The sample's onTagClicked: the next direction.
        tag.direction = CYLImageTagDirections.next(tag.direction);
        groupView.tags = this.groups[index].tags;
      }
      this.tagTapHandler?.(index, tagIndex, tag);
    };

  groupViewDidLongPress: (groupView: CYLImageTagGroupView) => void = (groupView: CYLImageTagGroupView) => {
    const index = this.views.indexOf(groupView);
    if (index >= 0) {
      this.longPressHandler?.(index);
    }
  };

  /** `groupView(_:didDragToPercentPosition:)`. */
  didDragToPercentPosition: (groupView: CYLImageTagGroupView, percentPosition: CYLPoint) => void =
    (groupView: CYLImageTagGroupView, percentPosition: CYLPoint) => {
      const index = this.views.indexOf(groupView);
      if (index < 0) {
        return;
      }
      this.groups[index].percentPosition = percentPosition;
      this.dragHandler?.(index, percentPosition);
    };

  /** Edit mode: the tags turn on a tap, so they say so. */
  private applyAccessibility(view: CYLImageTagGroupView): void {
    view.longPressAccessibilityActionName = this.longPressNameValue;
    view.tagAccessibilityHint = this.editingValue ? CYLMenuLocalizedString('CYLImageTagTurnHint') : undefined;
  }

  handleImageTap(): void {
    this.imageTapHandler?.();
  }
}

/** Draws a `CYLImageTagView`: the picture (aspect fill, clipped) with its groups on top. */
@Component
export struct CYLImageTagViewComponent {
  @ObjectLink tagView: CYLImageTagView;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.tagView.image ?? '')
        .objectFit(ImageFit.Cover)
        .width('100%')
        .height('100%')
        .id('CYLImageTagPicture')
        .accessibilityText(this.tagView.pictureAccessibilityLabel)
        .accessibilityDescription(this.tagView.imageAccessibilityHint ?? '')
        .onClick(() => this.tagView.handleImageTap())
      if (this.tagView.revision >= 0) {
        ForEach(this.tagView.groupViews, (group: CYLImageTagGroupView) => {
          CYLImageTagGroupViewComponent({ group: group })
        }, (group: CYLImageTagGroupView) => `${group.id}`)
      }
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.tagView.setBounds(Number(newValue.width), Number(newValue.height));
    })
  }
}

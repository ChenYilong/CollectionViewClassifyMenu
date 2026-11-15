/**
 * A group of tags around a dot on a picture (iOS CYLImageTagGroupView; TagViewGroup's TagViewGroup): the dot, a line
 * to each tag, the tags, an optional ripple, show / hide animations, taps, a long press and dragging.
 *
 * `CYLImageTagGroupView` holds the state and the API (as the iOS class); `CYLImageTagGroupViewComponent` draws it.
 */
import { CYLColor, CYLEdgeInsets, CYLPoint, CYLRect, CYLSize } from '../core/CYLTypes';
import { CYLMenuLocalizedString, CYLMenuResources } from '../core/CYLMenuResources';
import {
  CYLImageTag, CYLImageTagDefaults, CYLImageTagDirection, CYLImageTagGeometry, CYLImageTagItem, CYLImageTagLabel,
  CYLImageTagLayoutResult, CYLImageTagMetrics
} from './CYLImageTagModel';

/** A pulsing circle (TagViewGroup's RippleView): it grows to `maximumRadius` and fades out, once a second. */
@Observed
export class CYLImageTagRippleView {
  /** Always `center`: the ripple sits on the dot. */
  tagDirection: CYLImageTagDirection = CYLImageTagDirection.center;
  /** The largest radius of the circle. */
  maximumRadius: number = CYLImageTagDefaults.defaultRippleMaxRadius;
  /** The opacity at the start, 0...1. 100/255 by default. */
  startAlpha: number = 100 / 255;
  /** The circle's color, white by default. */
  color: string = CYLColor.WHITE;
  /** Whether it pulses. */
  isAnimating: boolean = true;

  sizeThatFits(): CYLSize {
    return new CYLSize(2 * this.maximumRadius, 2 * this.maximumRadius);
  }

  /** Starts pulsing. */
  startAnimating(): void {
    this.isAnimating = true;
  }

  /** Stops pulsing. */
  stopAnimating(): void {
    this.isAnimating = false;
  }
}

/** TagViewGroup's TagAdapter: the tags (`numberOfTags(in:)`, `groupView(_:viewForTagAt:)`). */
export interface CYLImageTagGroupViewDataSource {
  /** How many tags the group shows (at most `maximumTagCount`). */
  numberOfTags(groupView: CYLImageTagGroupView): number;
  /** The tag at `index`. */
  viewForTagAt(groupView: CYLImageTagGroupView, index: number): CYLImageTagItem;
}

/** TagViewGroup's OnTagGroupClickListener and OnTagGroupDragListener. Every method is optional. */
export interface CYLImageTagGroupViewDelegate {
  /** The dot was tapped (or activated with a screen reader). */
  groupViewDidTapCircle?: (groupView: CYLImageTagGroupView) => void;
  /** The tag at `index` was tapped (`groupView(_:didTapTagAt:)`). */
  didTapTagAt?: (groupView: CYLImageTagGroupView, index: number) => void;
  /** The group was long-pressed. */
  groupViewDidLongPress?: (groupView: CYLImageTagGroupView) => void;
  /** The user dragged the group (only while `isDraggable`) (`groupView(_:didDragToPercentPosition:)`). */
  didDragToPercentPosition?: (groupView: CYLImageTagGroupView, percentPosition: CYLPoint) => void;
}

/**
 * Animatable values of a group (TagViewGroup's CIRCLE_RADIUS, CIRCLE_INNER_RADIUS, LINES_RATIO, TAG_ALPHA), for
 * `animate`.
 */
export enum CYLImageTagGroupViewAnimatableValue {
  circleRadius = 0,
  circleInnerRadius = 1,
  linesProgress = 2,
  tagAlpha = 3
}

type CYLImageTagStep = (now: number) => void;

function clamp01(value: number): number {
  return Math.min(1, Math.max(0, value));
}

let nextGroupId: number = 0;

@Observed
export class CYLImageTagGroupView {
  static readonly defaultCircleRadius: number = CYLImageTagDefaults.defaultCircleRadius;
  static readonly defaultCircleInnerRadius: number = CYLImageTagDefaults.defaultCircleInnerRadius;
  static readonly defaultVerticalDistance: number = CYLImageTagDefaults.defaultVerticalDistance;
  static readonly defaultTiltDistance: number = CYLImageTagDefaults.defaultTiltDistance;
  static readonly defaultLineWidth: number = CYLImageTagDefaults.defaultLineWidth;
  static readonly maximumTagCount: number = CYLImageTagDefaults.maximumTagCount;
  static readonly defaultRippleMaxRadius: number = CYLImageTagDefaults.defaultRippleMaxRadius;

  /** A unique id (for ForEach keys and test ids). */
  readonly id: number = nextGroupId++;
  /** Bumped on every change the component draws. */
  revision: number = 0;

  private circleRadiusValue: number = CYLImageTagDefaults.defaultCircleRadius;
  private circleInnerRadiusValue: number = CYLImageTagDefaults.defaultCircleInnerRadius;
  private lineWidthValue: number = CYLImageTagDefaults.defaultLineWidth;
  private circleColorValue: string = CYLColor.white(0, 0x30 / 255);
  private circleInnerColorValue: string = CYLColor.WHITE;
  private lineColorValue: string = CYLColor.WHITE;
  private percentPositionValue: CYLPoint = new CYLPoint(0.5, 0.5);
  private displayOffsetValue: CYLPoint = new CYLPoint(0, 0);
  private tagsValue: CYLImageTag[] = [];
  private dataSourceValue?: CYLImageTagGroupViewDataSource;
  private tagLabelConfigurationValue?: (label: CYLImageTagLabel, tag: CYLImageTag) => void;
  private showsRippleValue: boolean = false;
  private rippleMaxRadiusValue: number = CYLImageTagDefaults.defaultRippleMaxRadius;
  private rippleAlphaValue: number = 100 / 255;
  private rippleViewValue?: CYLImageTagRippleView;
  private linesProgressValue: number = 1;
  private tagAlphaValue: number = 1;
  private isGroupHiddenValue: boolean = false;
  private delegateValue?: CYLImageTagGroupViewDelegate;
  private isDraggableValue: boolean = false;
  private longPressNameValue?: string;
  private tagHintValue?: string;
  private metrics: CYLImageTagMetrics = new CYLImageTagMetrics();
  private itemViews: CYLImageTagItem[] = [];
  private bounds: CYLSize = new CYLSize(0, 0);
  private result: CYLImageTagLayoutResult = new CYLImageTagLayoutResult(new CYLPoint(), new CYLPoint(), []);
  private timer: number = -1;
  private displayStep?: CYLImageTagStep;
  private dragStart: CYLPoint = new CYLPoint();

  /** A custom show animation (setShowAnimator): call the completion when done. */
  showAnimation?: (groupView: CYLImageTagGroupView, completion: () => void) => void;
  /** A custom hide animation (setHideAnimator): call the completion when done. */
  hideAnimation?: (groupView: CYLImageTagGroupView, completion: () => void) => void;
  /** How far one move up / down / left / right action moves the group, as a fraction of the view. 0.05. */
  accessibilityMoveStep: number = 0.05;

  constructor(width: number = 0, height: number = 0) {
    this.bounds = new CYLSize(width, height);
  }

  // Appearance

  /** The dot's outer radius (TagViewGroup's radius). */
  get circleRadius(): number {
    return this.circleRadiusValue;
  }

  set circleRadius(value: number) {
    this.circleRadiusValue = Math.max(0, value);
    this.metrics.circleRadius = this.circleRadiusValue;
    this.setNeedsLayout();
  }

  /** The dot's inner radius (inner_radius). */
  get circleInnerRadius(): number {
    return this.circleInnerRadiusValue;
  }

  set circleInnerRadius(value: number) {
    this.circleInnerRadiusValue = Math.max(0, value);
    this.revision++;
  }

  /** The line width (line_width). */
  get lineWidth(): number {
    return this.lineWidthValue;
  }

  set lineWidth(value: number) {
    this.lineWidthValue = Math.max(0, value);
    this.revision++;
  }

  /** The vertical distance of the lines (v_distance). */
  get verticalDistance(): number {
    return this.metrics.verticalDistance;
  }

  set verticalDistance(value: number) {
    this.metrics.verticalDistance = Math.max(0, value);
    this.setNeedsLayout();
  }

  /** The tilt distance of the slanted lines (tilt_distance). */
  get tiltDistance(): number {
    return this.metrics.tiltDistance;
  }

  set tiltDistance(value: number) {
    this.metrics.tiltDistance = Math.max(0, value);
    this.setNeedsLayout();
  }

  /** The ring's color: 0x30 black by default. */
  get circleColor(): string {
    return this.circleColorValue;
  }

  set circleColor(value: string) {
    this.circleColorValue = value;
    this.revision++;
  }

  /** The dot's color: white by default. */
  get circleInnerColor(): string {
    return this.circleInnerColorValue;
  }

  set circleInnerColor(value: string) {
    this.circleInnerColorValue = value;
    this.revision++;
  }

  /** The lines' color: white by default. */
  get lineColor(): string {
    return this.lineColorValue;
  }

  set lineColor(value: string) {
    this.lineColorValue = value;
    this.revision++;
  }

  // Position

  /**
   * The dot's place as fractions of the view's size (setPercent), clamped to 0...1; it moves inward when tags would
   * leave the view.
   */
  get percentPosition(): CYLPoint {
    return this.percentPositionValue;
  }

  set percentPosition(value: CYLPoint) {
    this.percentPositionValue = new CYLPoint(clamp01(value.x), clamp01(value.y));
    this.setNeedsLayout();
  }

  /** The dot's center, in the view's coordinates (getCenterPoint), after the last layout. */
  get centerPoint(): CYLPoint {
    return this.result.centerPoint;
  }

  /** Points added to the dot's place without changing `percentPosition`. Zero by default. */
  get displayOffset(): CYLPoint {
    return this.displayOffsetValue;
  }

  set displayOffset(value: CYLPoint) {
    if (value.x !== this.displayOffsetValue.x || value.y !== this.displayOffsetValue.y) {
      this.displayOffsetValue = value;
      this.setNeedsLayout();
    }
  }

  /** The area the group draws in: the dot and every tag, after the last layout. */
  get occupiedFrame(): CYLRect {
    return CYLImageTagGeometry.occupiedFrame(this.result.centerPoint, this.circleRadiusValue, this.tagFrames);
  }

  // Tags

  /** Tags shown with CYLImageTagLabel tags. Setting it replaces the data source's tags. */
  get tags(): CYLImageTag[] {
    return this.tagsValue;
  }

  set tags(value: CYLImageTag[]) {
    this.tagsValue = value;
    this.reloadData();
  }

  /** Custom tags instead (setTagAdapter); call `reloadData()` when they change. */
  get dataSource(): CYLImageTagGroupViewDataSource | undefined {
    return this.dataSourceValue;
  }

  set dataSource(value: CYLImageTagGroupViewDataSource | undefined) {
    this.dataSourceValue = value;
  }

  /** The tags, in order (getTagList), without the ripple. */
  get tagViews(): CYLImageTagItem[] {
    return this.itemViews;
  }

  /** Configures each CYLImageTagLabel the group makes (font, colors, insets). */
  get tagLabelConfiguration(): ((label: CYLImageTagLabel, tag: CYLImageTag) => void) | undefined {
    return this.tagLabelConfigurationValue;
  }

  set tagLabelConfiguration(value: ((label: CYLImageTagLabel, tag: CYLImageTag) => void) | undefined) {
    this.tagLabelConfigurationValue = value;
  }

  // Ripple

  /** A pulsing circle under the dot (addRipple, RippleView). False by default. */
  get showsRipple(): boolean {
    return this.showsRippleValue;
  }

  set showsRipple(value: boolean) {
    this.showsRippleValue = value;
    if (value && this.rippleViewValue === undefined) {
      this.rippleViewValue = new CYLImageTagRippleView();
    } else if (!value) {
      this.rippleViewValue = undefined;
    }
    if (this.rippleViewValue !== undefined) {
      this.rippleViewValue.maximumRadius = this.rippleMaxRadiusValue;
      this.rippleViewValue.startAlpha = this.rippleAlphaValue;
    }
    this.revision++;
  }

  /** The ripple's largest radius. */
  get rippleMaxRadius(): number {
    return this.rippleMaxRadiusValue;
  }

  set rippleMaxRadius(value: number) {
    this.rippleMaxRadiusValue = Math.max(0, value);
    if (this.rippleViewValue !== undefined) {
      this.rippleViewValue.maximumRadius = this.rippleMaxRadiusValue;
    }
    this.revision++;
  }

  /** The ripple's opacity at the start, 0...1, 100/255 by default (ripple_alpha 100). */
  get rippleAlpha(): number {
    return this.rippleAlphaValue;
  }

  set rippleAlpha(value: number) {
    this.rippleAlphaValue = clamp01(value);
    if (this.rippleViewValue !== undefined) {
      this.rippleViewValue.startAlpha = this.rippleAlphaValue;
    }
    this.revision++;
  }

  /** The ripple, while `showsRipple`. */
  get rippleView(): CYLImageTagRippleView | undefined {
    return this.rippleViewValue;
  }

  // Animation

  /** How much of each line is drawn, 0...1 (setLinesRatio). 1 by default. */
  get linesProgress(): number {
    return this.linesProgressValue;
  }

  set linesProgress(value: number) {
    this.linesProgressValue = clamp01(value);
    this.revision++;
  }

  /** The tags' opacity (setTagAlpha). 1 by default. */
  get tagAlpha(): number {
    return this.tagAlphaValue;
  }

  set tagAlpha(value: number) {
    this.tagAlphaValue = clamp01(value);
    this.revision++;
  }

  /** Whether the group is hidden by `hide(animated:)`. */
  get isGroupHidden(): boolean {
    return this.isGroupHiddenValue;
  }

  // Interaction

  /** Taps, the long press and drags. */
  get delegate(): CYLImageTagGroupViewDelegate | undefined {
    return this.delegateValue;
  }

  set delegate(value: CYLImageTagGroupViewDelegate | undefined) {
    this.delegateValue = value;
    this.revision++;
  }

  /** Lets the user drag the group (setOnTagGroupDragListener). False by default. */
  get isDraggable(): boolean {
    return this.isDraggableValue;
  }

  set isDraggable(value: boolean) {
    this.isDraggableValue = value;
    this.revision++;
  }

  // Accessibility

  /** The name of the long-press action of the dot, such as "删除标签组". undefined: "长按" (`CYLMenuLongPress`). */
  get longPressAccessibilityActionName(): string | undefined {
    return this.longPressNameValue;
  }

  set longPressAccessibilityActionName(value: string | undefined) {
    this.longPressNameValue = value;
    this.revision++;
  }

  /** The hint of every tag, such as "轻点两下改变方向" in edit mode. undefined by default. */
  get tagAccessibilityHint(): string | undefined {
    return this.tagHintValue;
  }

  set tagAccessibilityHint(value: string | undefined) {
    this.tagHintValue = value;
    for (const view of this.itemViews) {
      view.accessibilityHint = value;
    }
    this.revision++;
  }

  /** The dot's screen reader label: "标签组：<the tag titles>" (core string `CYLImageTagGroup`). */
  get circleAccessibilityLabel(): string {
    const titles: string[] = [];
    for (const view of this.itemViews) {
      let title = view.accessibilityLabel;
      if ((title === undefined || title.length === 0) && view instanceof CYLImageTagLabel) {
        title = (view as CYLImageTagLabel).text;
      }
      if (title !== undefined && title.length > 0) {
        titles.push(title);
      }
    }
    const joined = CYLImageTagGeometry.joinTitles(titles, CYLMenuResources.currentLanguage);
    return CYLMenuLocalizedString('CYLImageTagGroup').replace('%@', joined);
  }

  /** The name of the long-press action: `longPressAccessibilityActionName`, else "长按". */
  get longPressActionName(): string {
    const name = this.longPressNameValue;
    return name !== undefined && name.length > 0 ? name : CYLMenuLocalizedString('CYLMenuLongPress');
  }

  /** Move up / down / left / right: a drag by `accessibilityMoveStep`; false when the group cannot move. */
  accessibilityMove(dx: number, dy: number): boolean {
    const old = this.percentPositionValue;
    this.percentPosition = new CYLPoint(old.x + dx * this.accessibilityMoveStep, old.y + dy * this.accessibilityMoveStep);
    if (old.x === this.percentPositionValue.x && old.y === this.percentPositionValue.y) {
      return false;
    }
    this.delegateValue?.didDragToPercentPosition?.(this, this.percentPositionValue);
    return true;
  }

  // Tags

  /** Sets the dot's place as fractions of the view's size (setPercent). */
  setPercentPosition(percentX: number, percentY: number): void {
    this.percentPosition = new CYLPoint(percentX, percentY);
  }

  /** Makes the tags again, from the data source or from `tags`. */
  reloadData(): void {
    const items: CYLImageTagItem[] = [];
    const source = this.dataSourceValue;
    const count = source !== undefined ? source.numberOfTags(this) : this.tagsValue.length;
    const limit = Math.min(Math.max(0, count), CYLImageTagDefaults.maximumTagCount);
    for (let index = 0; index < limit; index++) {
      let view: CYLImageTagItem;
      if (source !== undefined) {
        view = source.viewForTagAt(this, index);
      } else {
        const tag = this.tagsValue[index];
        const label = new CYLImageTagLabel();
        label.text = tag.title;
        label.accessibilityLabel = tag.title;
        label.tagDirection = tag.direction;
        this.tagLabelConfigurationValue?.(label, tag);
        view = label;
      }
      if (this.tagHintValue !== undefined) {
        view.accessibilityHint = this.tagHintValue;
      }
      items.push(view);
    }
    this.itemViews = items;
    this.setNeedsLayout();
  }

  // Geometry (TagGroupUtils)

  /** The space the dot and the tags need on each side of the center (getTagViewUsed). */
  tagSpaceUsed(): CYLEdgeInsets {
    return CYLImageTagGeometry.tagSpaceUsed(this.metrics, this.directions, this.itemSizes());
  }

  /** The top-left corner of a tag of `size` in `direction` (getStartPoint). */
  originForTag(size: CYLSize, direction: CYLImageTagDirection): CYLPoint {
    return CYLImageTagGeometry.originForTag(this.metrics, this.result.centerPoint, size, direction);
  }

  // Layout

  /** The view's size; the component sets it. */
  setBounds(width: number, height: number): void {
    if (width !== this.bounds.width || height !== this.bounds.height) {
      this.bounds = new CYLSize(width, height);
      this.setNeedsLayout();
    }
  }

  get boundsSize(): CYLSize {
    return this.bounds;
  }

  /** Lays the dot, the tags and the lines out again (layoutSubviews). */
  layoutIfNeeded(): void {
    this.metrics.circleRadius = this.circleRadiusValue;
    this.result = CYLImageTagGeometry.layout(this.metrics, this.bounds.width, this.bounds.height,
      this.percentPositionValue, this.displayOffsetValue, this.directions, this.itemSizes());
    this.revision++;
  }

  private setNeedsLayout(): void {
    this.layoutIfNeeded();
  }

  /** The frames of the tags after the last layout. */
  get tagFrames(): CYLRect[] {
    return this.result.placements.map((p) => p.frame);
  }

  /** The drawn part of each tag's line (by `linesProgress`), as ArkUI Polyline points. */
  lineAt(index: number): number[][] {
    const placement = this.result.placements[index];
    if (placement === undefined) {
      return [];
    }
    return CYLImageTagGeometry.partialLine(placement.line, this.linesProgressValue)
      .map((p: CYLPoint): number[] => [p.x, p.y]);
  }

  /** The ripple's center after the last layout. */
  get rippleCenter(): CYLPoint {
    return this.result.rippleCenter;
  }

  private get directions(): CYLImageTagDirection[] {
    return this.itemViews.map((view: CYLImageTagItem) => view.tagDirection);
  }

  private itemSizes(): CYLSize[] {
    const width = CYLImageTagGeometry.tagWidthLimit(this.metrics, this.bounds.width);
    return this.itemViews.map((view: CYLImageTagItem) => view.sizeThatFits(width));
  }

  // Touches (called by the component)

  /** A tap on the tag at `index`, or on the dot when `index` is negative. */
  handleTap(index: number): void {
    if (index >= 0) {
      this.delegateValue?.didTapTagAt?.(this, index);
    } else {
      this.delegateValue?.groupViewDidTapCircle?.(this);
    }
  }

  handleLongPress(): void {
    this.delegateValue?.groupViewDidLongPress?.(this);
  }

  /** The pan began: the dot's center is kept under the finger's offset. */
  handlePanStart(): void {
    this.dragStart = this.result.centerPoint;
  }

  /** The pan moved by (`offsetX`, `offsetY`) since it began. */
  handlePanUpdate(offsetX: number, offsetY: number): void {
    if (!this.isDraggableValue) {
      return;
    }
    const width = Math.max(1, this.bounds.width);
    const height = Math.max(1, this.bounds.height);
    this.percentPosition = new CYLPoint((this.dragStart.x - this.displayOffsetValue.x + offsetX) / width,
      (this.dragStart.y - this.displayOffsetValue.y + offsetY) / height);
    this.delegateValue?.didDragToPercentPosition?.(this, this.percentPositionValue);
  }

  // Animation

  /** The current value of an animatable value. */
  value(animatable: CYLImageTagGroupViewAnimatableValue): number {
    switch (animatable) {
      case CYLImageTagGroupViewAnimatableValue.circleRadius:
        return this.circleRadius;
      case CYLImageTagGroupViewAnimatableValue.circleInnerRadius:
        return this.circleInnerRadius;
      case CYLImageTagGroupViewAnimatableValue.linesProgress:
        return this.linesProgress;
      default:
        return this.tagAlpha;
    }
  }

  private setValue(value: number, animatable: CYLImageTagGroupViewAnimatableValue): void {
    switch (animatable) {
      case CYLImageTagGroupViewAnimatableValue.circleRadius:
        this.circleRadius = value;
        break;
      case CYLImageTagGroupViewAnimatableValue.circleInnerRadius:
        this.circleInnerRadius = value;
        break;
      case CYLImageTagGroupViewAnimatableValue.linesProgress:
        this.linesProgress = value;
        break;
      default:
        this.tagAlpha = value;
        break;
    }
  }

  /**
   * Animates one value through `values`, decelerating (as an ObjectAnimator with a DecelerateInterpolator); with no
   * values or no duration (seconds) it jumps to the last value.
   */
  animate(animatable: CYLImageTagGroupViewAnimatableValue, values: number[], duration: number,
    completion?: () => void): void {
    if (values.length === 0 || duration <= 0) {
      if (values.length > 0) {
        this.setValue(values[values.length - 1], animatable);
      }
      completion?.();
      return;
    }
    this.run(this.makeStep(animatable, values, duration, completion));
  }

  private run(step: CYLImageTagStep): void {
    this.stopTimer();
    this.displayStep = step;
    this.timer = setInterval(() => {
      this.displayStep?.(Date.now() / 1000);
    }, 16);
  }

  private stopTimer(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  private makeStep(animatable: CYLImageTagGroupViewAnimatableValue, values: number[], duration: number,
    completion?: () => void): CYLImageTagStep {
    let start = 0;
    const last = values[values.length - 1];
    return (now: number) => {
      if (start === 0) {
        start = now;
      }
      const t = Math.min(1, (now - start) / duration);
      // Decelerating, as the sample's DecelerateInterpolator; piecewise linear between the values.
      const eased = 1 - (1 - t) * (1 - t);
      const position = eased * (values.length - 1);
      const index = Math.min(Math.floor(position), values.length - 1);
      const next = Math.min(index + 1, values.length - 1);
      const fraction = position - index;
      this.setValue(values[index] + (values[next] - values[index]) * fraction, animatable);
      if (t >= 1) {
        this.setValue(last, animatable);
        this.stopTimer();
        this.displayStep = undefined;
        completion?.();
      }
    };
  }

  /** The dot grows and shrinks back, 0.4 s (the sample's circleRadiusAnimator). */
  private bounceCircle(completion: () => void): void {
    const radius = this.circleRadius;
    const inner = this.circleInnerRadius;
    const innerStep = this.makeStep(CYLImageTagGroupViewAnimatableValue.circleInnerRadius,
      [Math.max(0, inner - 3), inner + 3, inner], 0.4);
    const outerStep = this.makeStep(CYLImageTagGroupViewAnimatableValue.circleRadius,
      [Math.max(0, radius - 3), radius + 3, radius], 0.4, completion);
    this.run((now: number) => {
      innerStep(now);
      outerStep(now);
    });
  }

  /**
   * Shows the group: the dot bounces, the lines grow, the tags fade in (the sample's show animator), or runs
   * `showAnimation` when set.
   */
  show(animated: boolean, completion?: () => void): void {
    this.isGroupHiddenValue = false;
    this.revision++;
    if (animated && this.showAnimation !== undefined) {
      this.showAnimation(this, () => completion?.());
      return;
    }
    if (!animated) {
      this.linesProgress = 1;
      this.tagAlpha = 1;
      completion?.();
      return;
    }
    this.linesProgress = 0;
    this.tagAlpha = 0;
    this.bounceCircle(() => {
      this.animate(CYLImageTagGroupViewAnimatableValue.linesProgress, [0, 1], 0.3, () => {
        this.animate(CYLImageTagGroupViewAnimatableValue.tagAlpha, [0, 1], 0.2, completion);
      });
    });
  }

  /**
   * Hides it: the dot bounces, then the lines and tags fade together (the sample's hide animator), or
   * `hideAnimation`.
   */
  hide(animated: boolean, completion?: () => void): void {
    const finish = () => {
      this.isGroupHiddenValue = true;
      this.revision++;
      completion?.();
    };
    if (animated && this.hideAnimation !== undefined) {
      this.hideAnimation(this, finish);
      return;
    }
    if (!animated) {
      finish();
      return;
    }
    this.bounceCircle(() => {
      const startAlpha = this.tagAlpha;
      let start = 0;
      this.run((now: number) => {
        if (start === 0) {
          start = now;
        }
        const t = Math.min(1, (now - start) / 0.4);
        const eased = 1 - (1 - t) * (1 - t);
        this.tagAlpha = startAlpha * (1 - eased);
        this.linesProgress = 1 - eased;
        if (t >= 1) {
          this.stopTimer();
          this.displayStep = undefined;
          finish();
        }
      });
    });
  }

  /** Stops a running animation (the component calls it when it disappears). */
  dispose(): void {
    this.stopTimer();
    this.displayStep = undefined;
  }
}

/** Draws a default tag. */
@Builder
function cylImageTagLabelBuilder(item: CYLImageTagItem) {
  if (item instanceof CYLImageTagLabel) {
    Text((item as CYLImageTagLabel).text)
      .fontSize((item as CYLImageTagLabel).fontSize)
      .fontWeight((item as CYLImageTagLabel).fontWeight)
      .fontColor((item as CYLImageTagLabel).textColor)
      .textShadow({ radius: (item as CYLImageTagLabel).shadowRadius, color: (item as CYLImageTagLabel).shadowColor })
      .padding({
        top: (item as CYLImageTagLabel).contentInsets.top,
        left: (item as CYLImageTagLabel).contentInsets.left,
        bottom: (item as CYLImageTagLabel).contentInsets.bottom,
        right: (item as CYLImageTagLabel).contentInsets.right
      })
      .width('100%')
      .height('100%')
  }
}

/** Draws a `CYLImageTagGroupView`: lay it over a picture (the size of its parent). */
@Component
export struct CYLImageTagGroupViewComponent {
  @ObjectLink group: CYLImageTagGroupView;
  @State private rippleScale: number = 0;
  @State private rippleOpacity: number = 0;

  aboutToDisappear(): void {
    this.group.dispose();
  }

  private startRipple(): void {
    const ripple = this.group.rippleView;
    if (ripple === undefined || !ripple.isAnimating) {
      return;
    }
    this.rippleScale = 0;
    this.rippleOpacity = ripple.startAlpha;
    this.getUIContext().animateTo({ duration: 1000, iterations: -1, curve: Curve.Linear }, () => {
      this.rippleScale = 1;
      this.rippleOpacity = 0;
    });
  }

  @Builder
  tagContent(item: CYLImageTagItem) {
    if (item.contentBuilder !== undefined) {
      item.contentBuilder.builder(item)
    } else {
      cylImageTagLabelBuilder(item)
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (!this.group.isGroupHidden && this.group.revision >= 0) {
        if (this.group.rippleView !== undefined) {
          Circle({ width: 2 * this.group.rippleMaxRadius, height: 2 * this.group.rippleMaxRadius })
            .fill(this.group.rippleView.color)
            .position({
              x: this.group.rippleCenter.x - this.group.rippleMaxRadius,
              y: this.group.rippleCenter.y - this.group.rippleMaxRadius
            })
            .scale({ x: this.rippleScale, y: this.rippleScale })
            .opacity(this.rippleOpacity)
            .hitTestBehavior(HitTestMode.None)
            .onAppear(() => this.startRipple())
        }
        ForEach(this.group.tagViews, (item: CYLImageTagItem, index: number) => {
          Polyline()
            .points(this.group.lineAt(index))
            .stroke(this.group.lineColor)
            .strokeWidth(this.group.lineWidth)
            .fillOpacity(0)
            .width('100%')
            .height('100%')
            .position({ x: 0, y: 0 })
            .hitTestBehavior(HitTestMode.None)
        }, (item: CYLImageTagItem, index: number) => `${this.group.id}-line-${index}-${this.group.revision}`)
        Circle({ width: 2 * this.group.circleRadius, height: 2 * this.group.circleRadius })
          .fill(this.group.circleColor)
          .position({
            x: this.group.centerPoint.x - this.group.circleRadius,
            y: this.group.centerPoint.y - this.group.circleRadius
          })
          .hitTestBehavior(HitTestMode.None)
        Circle({ width: 2 * this.group.circleInnerRadius, height: 2 * this.group.circleInnerRadius })
          .fill(this.group.circleInnerColor)
          .position({
            x: this.group.centerPoint.x - this.group.circleInnerRadius,
            y: this.group.centerPoint.y - this.group.circleInnerRadius
          })
          .hitTestBehavior(HitTestMode.None)
        // The dot's touch area: at least 22 vp around the center, as iOS.
        Column()
          .width(2 * Math.max(this.group.circleRadius * 2, 22))
          .height(2 * Math.max(this.group.circleRadius * 2, 22))
          .borderRadius(Math.max(this.group.circleRadius * 2, 22))
          .position({
            x: this.group.centerPoint.x - Math.max(this.group.circleRadius * 2, 22),
            y: this.group.centerPoint.y - Math.max(this.group.circleRadius * 2, 22)
          })
          .id(`CYLImageTagGroupCircle-${this.group.id}`)
          .accessibilityGroup(true)
          .accessibilityText(this.group.circleAccessibilityLabel)
          .gesture(GestureGroup(GestureMode.Exclusive,
            PanGesture({ distance: this.group.isDraggable ? 5 : 100000 })
              .onActionStart(() => this.group.handlePanStart())
              .onActionUpdate((event: GestureEvent) => this.group.handlePanUpdate(event.offsetX, event.offsetY)),
            LongPressGesture().onAction(() => this.group.handleLongPress()),
            TapGesture().onAction(() => this.group.handleTap(-1))
          ))
        ForEach(this.group.tagViews, (item: CYLImageTagItem, index: number) => {
          Stack() {
            this.tagContent(item)
          }
          .width(this.group.tagFrames[index]?.width ?? 0)
          .height(this.group.tagFrames[index]?.height ?? 0)
          .position({ x: this.group.tagFrames[index]?.x ?? 0, y: this.group.tagFrames[index]?.y ?? 0 })
          .opacity(this.group.tagAlpha)
          .id(`CYLImageTagGroupTag-${this.group.id}-${index}`)
          .accessibilityGroup(true)
          .accessibilityText(item.accessibilityLabel ?? '')
          .accessibilityDescription(item.accessibilityHint ?? '')
          .hitTestBehavior(item.tagDirection === CYLImageTagDirection.center || this.group.tagAlpha <= 0 ?
            HitTestMode.None : HitTestMode.Default)
          .gesture(GestureGroup(GestureMode.Exclusive,
            PanGesture({ distance: this.group.isDraggable ? 5 : 100000 })
              .onActionStart(() => this.group.handlePanStart())
              .onActionUpdate((event: GestureEvent) => this.group.handlePanUpdate(event.offsetX, event.offsetY)),
            LongPressGesture().onAction(() => this.group.handleLongPress()),
            TapGesture().onAction(() => this.group.handleTap(index))
          ))
        }, (item: CYLImageTagItem, index: number) => `${this.group.id}-tag-${index}-${this.group.revision}`)
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.group.setBounds(Number(newValue.width), Number(newValue.height));
    })
  }
}

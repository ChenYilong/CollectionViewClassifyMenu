/**
 * The view of a fold control (iOS CYLTagFoldButton.swift; Android CYLTagFoldButton.kt): a `CYLTagButton` without a
 * border or background, the title then the chevron. Expanded, it shows what the control shows expanded (only the
 * icon, turned 180°, or the collapse title). Draw it with `CYLTagButtonComponent`.
 */
import { CYLTagFoldMetrics } from '../components/CYLTagListState';
import { CYLMenuFoldControl } from '../core/CYLMenuFoldControl';
import { CYLMenuStyle } from '../core/CYLMenuStyle';
import { CYLSize } from '../core/CYLTypes';
import { CYLTagButton } from './CYLTagButton';

/** Seconds. */
const ROTATION_DURATION: number = 0.25;
/** Just under π, so that it turns the same way back and forth (degrees). */
const EXPANDED_ROTATION: number = (Math.PI - 0.0001) * 180 / Math.PI;

@Observed
export class CYLTagFoldButton extends CYLTagButton {
  private foldControlValue?: CYLMenuFoldControl;
  private expandedValue: boolean = false;

  /** The control last applied. */
  get foldControl(): CYLMenuFoldControl | undefined {
    return this.foldControlValue;
  }

  /** The state last applied. */
  get isExpanded(): boolean {
    return this.expandedValue;
  }

  /**
   * Shows `foldControl` in `color` (its own color wins) for the expanded or collapsed state; the icon turns with an
   * animation when `animated`.
   */
  applyFoldControl(foldControl: CYLMenuFoldControl, color: ResourceColor | undefined, expanded: boolean,
    animated: boolean): void {
    this.apply(foldControl, CYLTagFoldMetrics.style(foldControl, color), expanded, animated);
  }

  /**
   * The inline fold control (`CYLMenuFoldControlPosition.tail`): the same content, drawn like the tags of
   * `itemStyle` (its normal look), so it reads as the last tag; an icon-only control is a circle.
   */
  applyInlineFoldControl(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: boolean,
    animated: boolean): void {
    const style = CYLTagFoldMetrics.inlineStyle(foldControl, itemStyle);
    style.numberOfItemsPerRow = 0;
    this.apply(foldControl, style, expanded, animated);
  }

  /** The size of the inline fold control in that state: the tags' height, and at least as wide as it is high. */
  static inlineSize(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: boolean,
    fontScale: number = 1): CYLSize {
    return CYLTagFoldMetrics.inlineSize(foldControl, itemStyle, expanded, fontScale);
  }

  /** The size the control needs in that state (at least a 44 vp wide touch target). */
  static size(foldControl: CYLMenuFoldControl, expanded: boolean, fontScale: number = 1): CYLSize {
    return CYLTagFoldMetrics.size(foldControl, expanded, fontScale);
  }

  private apply(foldControl: CYLMenuFoldControl, style: CYLMenuStyle, expanded: boolean, animated: boolean): void {
    this.foldControlValue = foldControl;
    this.expandedValue = expanded;
    this.style = style;
    this.title = foldControl.titleWhenExpanded(expanded);
    this.image = foldControl.showsImage(expanded) ? foldControl.image : undefined;
    this.imageRotationDuration = animated ? ROTATION_DURATION * 1000 : 0;
    this.imageView.rotation = expanded && foldControl.rotatesImageWhenExpanded ? EXPANDED_ROTATION : 0;
    this.revision++;
  }
}

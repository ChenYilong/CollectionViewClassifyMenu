/**
 * The cell of the tag list (iOS CYLTagListCell.swift; Android CYLTagListCell.kt): one `CYLTagButton` (the tag view);
 * the cell is the accessibility element, a button whose label is the tag's title. It shows the style's touch ripple
 * and makes the delete indicator tappable.
 *
 * `CYLTagListCell` holds the state and the API; `CYLTagListCellComponent` draws it.
 */
import { CYLMenuLocalizedString } from '../core/CYLMenuResources';
import { CYLMenuStyle } from '../core/CYLMenuStyle';
import { CYLImage, CYLPoint } from '../core/CYLTypes';
import { CYLTagButton, CYLTagButtonComponent } from './CYLTagButton';
import { CYLTagListAccessibilityIdentifier } from './CYLTagListAccessibility';

/** A ripple to play: a circle from the touch point to the farthest corner, fading out. */
export class CYLTagRipple {
  x: number = 0;
  y: number = 0;
  radius: number = 0;
  color: string = '';
  alpha: number = 0;
  /** Seconds. */
  duration: number = 1;
}

@Observed
export class CYLTagListCell {
  /** Bumped on every change the component draws. */
  revision: number = 0;
  /** The tag view. The cell handles touches, so the button ignores them. */
  readonly button: CYLTagButton = new CYLTagButton();
  /** The list's style object last applied, so that a style is copied into the button only when it changes. */
  appliedStyle?: CYLMenuStyle;
  /** Called when the delete indicator is tapped. */
  deleteHandler?: () => void;
  /** The cell's screen reader label (the tag's title). */
  accessibilityLabel: string = '';
  accessibilityHint?: string;
  /** The component id (`CYLTagListAccessibilityIdentifier`). */
  accessibilityIdentifier: string = CYLTagListAccessibilityIdentifier.item;
  /** Whether the cell reads as selected. */
  accessibilitySelected: boolean = false;
  accessibilityEnabled: boolean = true;
  /** Set by the component to play ripples. */
  rippleListener?: (ripple: CYLTagRipple) => void;
  private deletableValue: boolean = false;

  /** Shows the delete indicator and makes it tappable. False by default. */
  get isDeletable(): boolean {
    return this.deletableValue;
  }

  set isDeletable(value: boolean) {
    this.deletableValue = value;
    this.button.showsDeleteIndicator = value;
    this.revision++;
  }

  /** The label of the delete indicator for screen readers. */
  get deleteAccessibilityLabel(): string {
    return CYLMenuLocalizedString('CYLMenuDeleteTag');
  }

  /** Pressed: `CYLMenuStyle.highlightedBackgroundColor`. */
  get isHighlighted(): boolean {
    return this.button.isHighlighted;
  }

  set isHighlighted(value: boolean) {
    this.button.isHighlighted = value;
  }

  /**
   * Plays `CYLMenuStyle`'s touch ripple (`rippleColor`) from `point`, in the tag's coordinates; a touch plays it
   * too.
   */
  showRipple(point: CYLPoint): void {
    const style = this.button.style;
    const rippleColor = style.rippleColor;
    if (rippleColor === undefined) {
      return;
    }
    // AndroidTagView's ripple: a circle from the touch point to the farthest corner, fading out.
    const bounds = this.button.bounds;
    const dx = Math.max(point.x, bounds.width - point.x);
    const dy = Math.max(point.y, bounds.height - point.y);
    const ripple = new CYLTagRipple();
    ripple.x = point.x;
    ripple.y = point.y;
    ripple.radius = Math.sqrt(dx * dx + dy * dy);
    ripple.color = rippleColor;
    ripple.alpha = Math.min(1, Math.max(0, style.rippleAlpha));
    ripple.duration = style.rippleDuration > 0 ? style.rippleDuration : 1;
    this.rippleListener?.(ripple);
  }

  /** Shows a tag: its title (also its accessibility label), icons, look and state. */
  configure(title: string, image: CYLImage | undefined, selectedImage: CYLImage | undefined,
    animationURL: string | undefined, style: CYLMenuStyle, isSelected: boolean, isEnabled: boolean): void {
    if (this.appliedStyle !== style) {
      this.button.style = style;
      this.appliedStyle = style;
    }
    this.button.animationURL = animationURL;
    this.button.title = title;
    this.button.image = image;
    this.button.selectedImage = selectedImage;
    this.button.isEnabled = isEnabled;
    this.button.isSelected = isSelected;
    this.accessibilityLabel = title;
    this.accessibilityIdentifier = CYLTagListAccessibilityIdentifier.item;
    this.accessibilityHint = undefined;
    this.accessibilitySelected = isSelected;
    this.accessibilityEnabled = isEnabled;
    this.revision++;
  }

  /** Clears what a reused cell must not keep (`prepareForReuse`). */
  prepareForReuse(): void {
    this.deleteHandler = undefined;
    this.isDeletable = false;
  }
}

/** Draws a `CYLTagListCell`; `onCellClick` gets the taps outside the delete indicator. */
@Component
export struct CYLTagListCellComponent {
  @ObjectLink cell: CYLTagListCell;
  cellWidth?: number;
  cellHeight?: number;
  onCellClick?: () => void;
  @State private rippleVisible: boolean = false;
  @State private rippleX: number = 0;
  @State private rippleY: number = 0;
  @State private rippleRadius: number = 0;
  @State private rippleColor: string = '';
  @State private rippleScale: number = 0.05;
  @State private rippleOpacity: number = 0;

  aboutToAppear(): void {
    this.cell.rippleListener = (ripple: CYLTagRipple) => this.play(ripple);
  }

  aboutToDisappear(): void {
    this.cell.rippleListener = undefined;
  }

  private play(ripple: CYLTagRipple): void {
    this.rippleX = ripple.x;
    this.rippleY = ripple.y;
    this.rippleRadius = ripple.radius;
    this.rippleColor = ripple.color;
    this.rippleScale = 0.05;
    this.rippleOpacity = ripple.alpha;
    this.rippleVisible = true;
    animateTo({
      duration: ripple.duration * 1000,
      curve: Curve.EaseOut,
      onFinish: () => {
        this.rippleVisible = false;
      }
    }, () => {
      this.rippleScale = 1;
      this.rippleOpacity = 0;
    });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      CYLTagButtonComponent({
        button: this.cell.button,
        tagWidth: this.cellWidth,
        tagHeight: this.cellHeight,
        interactive: false
      })
      if (this.rippleVisible) {
        Circle()
          .width(2 * this.rippleRadius)
          .height(2 * this.rippleRadius)
          .fill(this.rippleColor)
          .position({ x: this.rippleX - this.rippleRadius, y: this.rippleY - this.rippleRadius })
          .scale({ x: this.rippleScale, y: this.rippleScale })
          .opacity(this.rippleOpacity)
          .hitTestBehavior(HitTestMode.Transparent)
          .accessibilityLevel('no')
      }
      if (this.cell.revision >= 0 && this.cell.isDeletable) {
        Column()
          .width(this.cell.button.deleteIndicatorHitFrame.width)
          .height(this.cell.button.deleteIndicatorHitFrame.height)
          .position({ x: this.cell.button.deleteIndicatorHitFrame.x, y: this.cell.button.deleteIndicatorHitFrame.y })
          .id(CYLTagListAccessibilityIdentifier.deleteButton)
          .accessibilityText(this.cell.deleteAccessibilityLabel)
          .onClick(() => this.cell.deleteHandler?.())
      }
    }
    .clip(true)
    .id(this.cell.accessibilityIdentifier)
    .accessibilityGroup(true)
    .accessibilityText(this.cell.accessibilityLabel)
    .accessibilityDescription(this.cell.accessibilityHint ?? '')
    .accessibilitySelected(this.cell.accessibilitySelected)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.cell.isHighlighted = this.cell.accessibilityEnabled;
        if (event.touches.length > 0) {
          this.cell.showRipple(new CYLPoint(event.touches[0].x, event.touches[0].y));
        }
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.cell.isHighlighted = false;
      }
    })
    .onClick(() => this.onCellClick?.())
  }
}

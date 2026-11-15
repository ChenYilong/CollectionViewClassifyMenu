/**
 * One tag (iOS CYLTagButton.swift; Android CYLTagButton.kt): an icon and a title side by side (the icon after the
 * title with `imagePlacement`), in a box drawn from the style's appearance for the current state, with an optional
 * delete indicator and an optional animated (Lottie) icon.
 *
 * `CYLTagButton` holds the state, the layout and the API (as the iOS class); `CYLTagButtonComponent` draws it.
 */
import lottie, { AnimationItem } from '@ohos/lottie';
import { util } from '@kit.ArkTS';
import { CYLTagButtonMetrics } from '../components/CYLTagListState';
import { CYLMenuStyle, CYLTagContentAlignment, CYLTagDeleteIndicatorPlacement, CYLTagImagePlacement } from '../core/CYLMenuStyle';
import { CYLTagCornerRadiusSquare } from '../core/CYLTagAppearance';
import { CYLColor, CYLControlState, CYLEdgeInsets, CYLFont, CYLImage, CYLRect, CYLSize } from '../core/CYLTypes';

const DISABLED_ANIMATION_ALPHA: number = 0.4;

/**
 * A subview of the tag as last laid out (`imageView`, `titleLabel`, `deleteIndicatorLabel`): its frame in the tag's
 * coordinates and what it shows. The component draws each part from it.
 */
export class CYLTagButtonPart {
  frame: CYLRect = new CYLRect();
  isHidden: boolean = true;
  text?: string;
  font: CYLFont = CYLFont.systemFont(14);
  textColor: string = CYLColor.BLACK;
  image?: CYLImage;
  tintColor: string = CYLColor.BLACK;
  cornerRadius: number = 0;
  /** Degrees (the fold chevron's turn). */
  rotation: number = 0;
}

@Observed
export class CYLTagButton {
  /** Bumped on every change the component draws. */
  revision: number = 0;
  /** The icon (as laid out). */
  readonly imageView: CYLTagButtonPart = new CYLTagButtonPart();
  /** The title (as laid out). */
  readonly titleLabel: CYLTagButtonPart = new CYLTagButtonPart();
  /** The delete indicator (hidden unless `showsDeleteIndicator`, or while a cross is drawn). */
  readonly deleteIndicatorLabel: CYLTagButtonPart = new CYLTagButtonPart();
  /** The system font scale (iOS: the trait collection's content size category). */
  fontScale: number = 1;

  private titleValue?: string;
  private imageValue?: CYLImage;
  private selectedImageValue?: CYLImage;
  private animationURLValue?: string;
  private restingProgressValue: number = 0;
  private animationSpeedValue?: number;
  private animationLoopsValue: boolean = false;
  private showsDeleteIndicatorValue: boolean = false;
  private styleStorage: CYLMenuStyle = new CYLMenuStyle();
  private selectedValue: boolean = false;
  private enabledValue: boolean = true;
  private highlightedValue: boolean = false;
  private hitFrame: CYLRect = new CYLRect();
  private player?: AnimationItem;
  private boundsWidth: number = 0;
  private boundsHeight: number = 0;
  /** Bumped by `playAnimation()`. */
  playToken: number = 0;
  /** Bumped when the animated icon's view must be made again (a new file or size). */
  animationViewToken: number = 0;
  /** The two lines of the drawn cross ([x1, y1, x2, y2] each), or empty. */
  crossLines: number[][] = [];
  crossLineWidth: number = 0;
  crossColor: string = CYLColor.BLACK;
  showsCross: boolean = false;
  cornerRadius: number = 0;
  backgroundColor: string = CYLColor.CLEAR;
  backgroundImage?: ResourceStr;
  borderColor: string = CYLColor.CLEAR;
  borderWidth: number = 0;
  animationOpacity: number = 1;
  /** Milliseconds over which a change of `imageView.rotation` is animated (the fold chevron); 0: at once. */
  imageRotationDuration: number = 0;
  /** The animated icon's frame (when `animationURL` is set). */
  animationFrame: CYLRect = new CYLRect();

  constructor() {
    this.updateAppearance();
  }

  // MARK: - API

  get title(): string | undefined {
    return this.titleValue;
  }

  set title(value: string | undefined) {
    this.titleValue = value;
    this.updateAppearance();
  }

  get image(): CYLImage | undefined {
    return this.imageValue;
  }

  set image(value: CYLImage | undefined) {
    this.imageValue = value;
    this.updateAppearance();
  }

  /** Shown while selected; undefined keeps `image`. */
  get selectedImage(): CYLImage | undefined {
    return this.selectedImageValue;
  }

  set selectedImage(value: CYLImage | undefined) {
    this.selectedImageValue = value;
    this.updateAppearance();
  }

  /**
   * Animated icon (Lottie JSON: `asset:<rawfile>` or JSON text). Without it, or when the file cannot be loaded,
   * `image` is shown.
   */
  get animationURL(): string | undefined {
    return this.animationURLValue;
  }

  set animationURL(value: string | undefined) {
    if (value === this.animationURLValue) {
      return;
    }
    this.animationURLValue = value;
    this.reloadAnimationView();
  }

  /** The frame (0...1) of the animated icon shown while not selected. Default 0, the first frame. */
  get animationRestingProgress(): number {
    return this.restingProgressValue;
  }

  set animationRestingProgress(value: number) {
    if (value !== this.restingProgressValue) {
      this.restingProgressValue = value;
      this.updateAnimationState();
    }
  }

  /** The playback speed of the animated icon; undefined (the default) uses `style.animationSpeed`. */
  get animationSpeed(): number | undefined {
    return this.animationSpeedValue;
  }

  set animationSpeed(value: number | undefined) {
    this.animationSpeedValue = value;
    this.applyAnimationSpeed();
  }

  /** True repeats the animated icon after `playAnimation()`; false (the default) plays once. */
  get animationLoops(): boolean {
    return this.animationLoopsValue;
  }

  set animationLoops(value: boolean) {
    if (value === this.animationLoopsValue) {
      return;
    }
    this.animationLoopsValue = value;
    if (this.player !== undefined) {
      this.player.loop = value;
    }
  }

  /** The Lottie player of the animated icon (play, stop, frames), or undefined. */
  get animationPlayer(): AnimationItem | undefined {
    return this.player;
  }

  /** Shows the style's delete indicator ("×") after the title. False by default. */
  get showsDeleteIndicator(): boolean {
    return this.showsDeleteIndicatorValue;
  }

  set showsDeleteIndicator(value: boolean) {
    if (value !== this.showsDeleteIndicatorValue) {
      this.showsDeleteIndicatorValue = value;
      this.updateAppearance();
    }
  }

  /**
   * The area a tap on the delete indicator should cover, in the tag's coordinates: from the space before it to the
   * trailing edge, the tag's full height. Empty while it is hidden.
   */
  get deleteIndicatorHitFrame(): CYLRect {
    return this.hitFrame;
  }

  /** The style the tag is drawn with. Setting copies it; set it again after changing it. */
  get style(): CYLMenuStyle {
    return this.styleStorage;
  }

  set style(value: CYLMenuStyle) {
    const oldSize = this.animationSize;
    this.styleStorage = value.copy();
    const size = this.animationSize;
    if (this.animationURLValue !== undefined && (size.width !== oldSize.width || size.height !== oldSize.height)) {
      this.reloadAnimationView();
    } else {
      this.applyAnimationSpeed();
    }
    this.updateAppearance();
  }

  get isSelected(): boolean {
    return this.selectedValue;
  }

  set isSelected(value: boolean) {
    const changed = value !== this.selectedValue;
    this.selectedValue = value;
    if (changed) {
      this.updateAnimationState();
    }
    this.updateAppearance();
  }

  get isEnabled(): boolean {
    return this.enabledValue;
  }

  set isEnabled(value: boolean) {
    this.enabledValue = value;
    this.updateAppearance();
  }

  get isHighlighted(): boolean {
    return this.highlightedValue;
  }

  set isHighlighted(value: boolean) {
    this.highlightedValue = value;
    this.updateAppearance();
  }

  /** The animation engine (@ohos/lottie) is a dependency of the HAR, so it is always there. */
  static get isAnimationEngineAvailable(): boolean {
    return true;
  }

  /** Plays the animated icon from the start, as a tab icon plays when the tab is tapped. */
  playAnimation(): void {
    this.applyAnimationSpeed();
    if (this.player !== undefined) {
      this.player.loop = this.animationLoopsValue;
      this.player.goToAndPlay(0, true);
    }
    this.playToken++;
    this.revision++;
  }

  // MARK: - Measurement

  /** `width(forTitle:image:style:traitCollection:)`: the width a tag needs in every state. */
  static widthWithImage(title: string | undefined, image: CYLImage | undefined, style: CYLMenuStyle,
    fontScale: number = 1): number {
    return CYLTagButtonMetrics.widthWithImage(title, image, style, fontScale);
  }

  /** `width(forTitle:iconSize:showsDeleteIndicator:style:traitCollection:)`. */
  static width(title: string | undefined, iconSize: CYLSize, showsDeleteIndicator: boolean, style: CYLMenuStyle,
    fontScale: number = 1): number {
    return CYLTagButtonMetrics.width(title, iconSize, showsDeleteIndicator, style, fontScale);
  }

  /** `iconSize(for:animated:style:)`. */
  static iconSize(image: CYLImage | undefined, animated: boolean, style: CYLMenuStyle): CYLSize {
    return CYLTagButtonMetrics.iconSize(image, animated && CYLTagButton.isAnimationEngineAvailable, style);
  }

  /** `height(for:traitCollection:)`. */
  static height(style: CYLMenuStyle, fontScale: number = 1): number {
    return CYLTagButtonMetrics.height(style, fontScale);
  }

  /** The size the tag needs for its content (its width in every state and its height). */
  intrinsicSize(): CYLSize {
    const animated = this.animationURLValue !== undefined;
    const icon = CYLTagButton.iconSize(this.imageValue, animated, this.styleStorage);
    return new CYLSize(CYLTagButton.width(this.titleValue, icon, this.showsDeleteIndicatorValue, this.styleStorage,
      this.fontScale), CYLTagButton.height(this.styleStorage, this.fontScale));
  }

  /** The tag's size, from the component; lays the parts out again. */
  setBounds(width: number, height: number): void {
    if (width === this.boundsWidth && height === this.boundsHeight) {
      return;
    }
    this.boundsWidth = width;
    this.boundsHeight = height;
    this.layoutSubviews();
    this.revision++;
  }

  get bounds(): CYLRect {
    return new CYLRect(0, 0, this.boundsWidth, this.boundsHeight);
  }

  /** Called by the component once the animated icon is loaded (or undefined when it is gone). */
  setAnimationPlayer(player: AnimationItem | undefined): void {
    this.player = player;
    if (player !== undefined) {
      player.loop = this.animationLoopsValue;
      this.updateAnimationState();
    }
  }

  // MARK: - Private

  /** Disabled wins over selected. */
  get currentState(): number {
    if (!this.enabledValue) {
      return CYLControlState.DISABLED;
    }
    return this.selectedValue ? CYLControlState.SELECTED : CYLControlState.NORMAL;
  }

  get animationSize(): CYLSize {
    const size = this.styleStorage.animationSize;
    return size.width === 0 && size.height === 0 ? this.styleStorage.imageSize : size;
  }

  get resolvedAnimationSpeed(): number {
    const speed = this.animationSpeedValue ?? this.styleStorage.animationSpeed;
    return speed > 0 ? speed : 1;
  }

  private static centeredY(size: number, contentTop: number, contentHeight: number, height: number): number {
    return size <= contentHeight ? contentTop + Math.floor((contentHeight - size) / 2) : Math.floor((height - size) / 2);
  }

  /** CYLFlatDesignTabBarButton's `_updateLayout`, with the icon and title side by side. */
  protected layoutSubviews(): void {
    let width = this.boundsWidth;
    const height = this.boundsHeight;
    const style = this.styleStorage;
    const state = this.currentState;
    const insets = style.appearance(state).contentInsets;
    const deleteWidth = this.layOutDeleteIndicator(state, insets);
    const indicatorFirst = this.showsDeleteIndicatorValue &&
      style.deleteIndicatorPlacement === CYLTagDeleteIndicatorPlacement.leading;
    const margin = insets.left + (indicatorFirst ? deleteWidth : 0);
    const trailing = insets.right + (indicatorFirst ? 0 : deleteWidth);
    const contentTop = insets.top;
    const contentHeight = Math.max(0, height - insets.top - insets.bottom);
    width -= trailing - margin;
    const animated = this.animationURLValue !== undefined;
    const showsImage = animated || this.imageView.image !== undefined;
    const titleText = this.titleLabel.text ?? '';
    const showsTitle = titleText.length > 0;
    // With a zero `imageSize` iOS uses the image's own size, which ArkUI knows only once the image has loaded: the
    // icon slot is then empty and the image sizes itself (as in `CYLTagListView`).
    const iconSize = animated ? this.animationSize : CYLTagButtonMetrics.iconSize(this.imageView.image, false, style);
    const spacing = showsImage && showsTitle ? style.imageTitleSpacing : 0;
    const available = Math.max(0, width - 2 * margin - (showsImage ? iconSize.width + spacing : 0));
    const font = this.titleLabel.font;
    const measured = showsTitle ? CYLTagButtonMetrics.textMeasurer(titleText, font) : 0;
    let titleWidth = Math.min(available, Math.ceil(measured));
    const titleHeight = showsTitle ? Math.min(height, Math.ceil(CYLTagButtonMetrics.lineHeight(font))) : 0;

    let imageX = 0;
    let titleX = 0;
    const leading = style.contentAlignment === CYLTagContentAlignment.leading;
    if (showsImage && showsTitle) {
      const group = iconSize.width + spacing + titleWidth;
      const start = leading ? margin : Math.floor((width - group) / 2);
      if (style.imagePlacement === CYLTagImagePlacement.trailing) {
        titleX = start;
        imageX = titleX + titleWidth + spacing;
      } else {
        imageX = start;
        titleX = imageX + iconSize.width + spacing;
      }
    } else if (showsImage && leading) {
      imageX = margin;
    } else if (showsTitle && leading) {
      titleX = margin;
      titleWidth = Math.min(titleWidth, Math.max(0, width - 2 * margin));
    } else if (showsImage) {
      imageX = style.layoutCentered ? Math.floor((width - iconSize.width) / 2) : margin;
    } else if (showsTitle) {
      titleX = style.layoutCentered ? Math.floor((width - titleWidth) / 2) :
        margin + style.imageSize.width + style.imageTitleSpacing;
      titleWidth = Math.min(titleWidth, Math.max(0, width - margin - titleX));
    }

    this.titleLabel.frame = showsTitle ? new CYLRect(titleX + style.titlePositionAdjustment.horizontal,
      CYLTagButton.centeredY(titleHeight, contentTop, contentHeight, height) + style.titlePositionAdjustment.vertical,
      titleWidth, titleHeight) : new CYLRect();
    this.titleLabel.isHidden = !showsTitle;
    if (showsImage) {
      const imageInsets = style.imageInsets;
      // Only the size changes; x and y stay, as CYLFlatDesignTabBarItem.imageInsets.
      const frame = new CYLRect(imageX + style.imagePositionAdjustment.horizontal,
        CYLTagButton.centeredY(iconSize.height, contentTop, contentHeight, height) + style.imagePositionAdjustment.vertical,
        Math.max(0, iconSize.width - imageInsets.left - imageInsets.right),
        Math.max(0, iconSize.height - imageInsets.top - imageInsets.bottom));
      if (animated) {
        this.animationFrame = frame;
        this.imageView.frame = new CYLRect();
      } else {
        this.imageView.frame = frame;
      }
    } else {
      this.imageView.frame = new CYLRect();
    }
    // 0 is automatic: a capsule, as for CYLBadgeAppearance.
    const radius = style.appearance(state).cornerRadius;
    this.cornerRadius = radius > 0 ? (radius <= CYLTagCornerRadiusSquare ? 0 : Math.min(radius, height / 2)) : height / 2;
  }

  /**
   * The delete indicator at the trailing (or leading) inset, its hit area and its cross; returns the width it takes
   * with the space before it (0 while hidden).
   */
  private layOutDeleteIndicator(state: number, insets: CYLEdgeInsets): number {
    const style = this.styleStorage;
    const width = this.boundsWidth;
    const height = this.boundsHeight;
    if (!this.showsDeleteIndicatorValue) {
      this.deleteIndicatorLabel.frame = new CYLRect();
      this.hitFrame = new CYLRect();
      this.crossLines = [];
      return 0;
    }
    const indicatorWidth = CYLTagButtonMetrics.deleteIndicatorWidth(state, style, this.fontScale);
    const leadingIndicator = style.deleteIndicatorPlacement === CYLTagDeleteIndicatorPlacement.leading;
    const indicatorX = leadingIndicator ? insets.left : Math.max(insets.left, width - insets.right - indicatorWidth);
    const indicator = new CYLRect(indicatorX, insets.top, indicatorWidth, Math.max(0, height - insets.top - insets.bottom));
    this.deleteIndicatorLabel.frame = indicator;
    if (leadingIndicator) {
      this.hitFrame = new CYLRect(0, 0, Math.min(width, indicator.maxX + style.imageTitleSpacing), height);
    } else {
      const hitX = Math.max(0, indicatorX - style.imageTitleSpacing);
      this.hitFrame = new CYLRect(hitX, 0, width - hitX, height);
    }
    // A drawn cross: a square centered in the area, inset by the padding.
    let side = Math.max(0, Math.min(indicator.width, indicator.height) - 2 * style.deleteIndicatorPadding);
    if (style.deleteIndicatorLineWidth > 0 && style.deleteIndicatorWidth <= 0) {
      side = Math.max(0, indicator.width - 2 * style.deleteIndicatorPadding);
    }
    const midX = indicator.x + indicator.width / 2;
    const midY = indicator.y + indicator.height / 2;
    const minX = midX - side / 2;
    const minY = midY - side / 2;
    this.crossLines = [[minX, minY, minX + side, minY + side], [minX + side, minY, minX, minY + side]];
    return indicatorWidth + style.imageTitleSpacing;
  }

  private reloadAnimationView(): void {
    this.player = undefined;
    this.animationViewToken++;
    this.updateAnimationState();
    this.updateAppearance();
  }

  /** Selected: the last frame (a selected tab's icon); otherwise the first frame, or the resting progress. */
  private updateAnimationState(): void {
    this.applyAnimationSpeed();
    const player = this.player;
    if (player === undefined) {
      return;
    }
    const last = Math.max(0, player.totalFrames - 1);
    if (this.selectedValue) {
      player.goToAndStop(last, true);
    } else {
      const resting = Math.min(1, Math.max(0, this.restingProgressValue));
      player.goToAndStop(resting * last, true);
    }
  }

  private applyAnimationSpeed(): void {
    this.player?.setSpeed(this.resolvedAnimationSpeed);
  }

  protected updateAppearance(): void {
    const style = this.styleStorage;
    const state = this.currentState;
    const appearance = style.appearance(state);
    const animated = this.animationURLValue !== undefined;
    const icon = state === CYLControlState.SELECTED && this.selectedImageValue !== undefined ?
      this.selectedImageValue : this.imageValue;
    // An animated icon takes the icon slot.
    this.imageView.image = animated ? undefined : icon;
    this.imageView.isHidden = animated || icon === undefined;
    this.animationOpacity = state === CYLControlState.DISABLED ? DISABLED_ANIMATION_ALPHA : 1;
    this.imageView.tintColor = style.iconColor(state);
    this.titleLabel.text = style.displayedTitle(this.titleValue);
    this.titleLabel.font = style.titleFont(state, this.fontScale);
    this.titleLabel.textColor = appearance.textColor;

    const pressed = this.highlightedValue && state !== CYLControlState.DISABLED &&
      style.highlightedBackgroundColor !== undefined;
    // Pressed, as android-tagview's layoutColorPress.
    this.backgroundColor = pressed ? (style.highlightedBackgroundColor ?? CYLColor.CLEAR) : appearance.backgroundColor;
    this.backgroundImage = this.highlightedValue && style.highlightedBackgroundColor !== undefined ? undefined :
    appearance.backgroundImage;
    const drawsCross = style.deleteIndicatorLineWidth > 0;
    this.deleteIndicatorLabel.isHidden = !this.showsDeleteIndicatorValue || drawsCross;
    this.deleteIndicatorLabel.text = this.showsDeleteIndicatorValue && !drawsCross ? style.deleteIndicatorTitle : undefined;
    this.showsCross = this.showsDeleteIndicatorValue && drawsCross;
    this.crossLineWidth = style.deleteIndicatorLineWidth;
    this.crossColor = style.deleteIndicatorColor ?? appearance.textColor;
    const imageRadius = style.imageCornerRadius;
    this.imageView.cornerRadius = imageRadius > 0 ?
      Math.min(imageRadius, Math.min(style.imageSize.width, style.imageSize.height) / 2) : 0;
    this.deleteIndicatorLabel.font = style.deleteIndicatorFontFor(state, this.fontScale);
    this.deleteIndicatorLabel.textColor = style.deleteIndicatorColor ?? appearance.textColor;
    const borderColor = appearance.borderColor;
    this.borderColor = borderColor ?? CYLColor.CLEAR;
    this.borderWidth = borderColor !== undefined ? appearance.borderWidth : 0;
    this.layoutSubviews();
    this.revision++;
  }
}

/** Reads the Lottie JSON of an animation value: `asset:<path>` is a rawfile of the app; any other value is JSON text. */
function animationData(context: Context, source: string): Object | undefined {
  try {
    if (source.startsWith('asset:')) {
      const name = source.substring('asset:'.length).split('/').pop() ?? '';
      const bytes = context.resourceManager.getRawFileContentSync(name);
      return JSON.parse(util.TextDecoder.create('utf-8').decodeToString(bytes)) as Object;
    }
    return JSON.parse(source) as Object;
  } catch (e) {
    return undefined;
  }
}

/** The animated icon of a tag: a Lottie animation on a canvas, whose player the tag drives. */
@Component
struct CYLTagButtonAnimationIcon {
  source: string = '';
  button?: CYLTagButton;
  @Prop iconWidth: number = 0;
  @Prop iconHeight: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private item?: AnimationItem;

  private load(): void {
    const data = animationData(getContext(this), this.source);
    if (data === undefined) {
      return;
    }
    this.item = lottie.loadAnimation({
      container: this.context2D,
      renderer: 'canvas',
      loop: false,
      autoplay: false,
      animationData: data
    });
    this.button?.setAnimationPlayer(this.item);
  }

  aboutToDisappear(): void {
    if (this.button?.animationPlayer === this.item) {
      this.button?.setAnimationPlayer(undefined);
    }
    this.item?.destroy();
    this.item = undefined;
  }

  build() {
    Canvas(this.context2D)
      .width(this.iconWidth)
      .height(this.iconHeight)
      .accessibilityLevel('no')
      .onReady(() => this.load())
  }
}

/**
 * Draws a `CYLTagButton`. Without `tagWidth` / `tagHeight` it takes the tag's intrinsic size. `interactive` (the
 * default) shows the pressed look while touched; a cell that handles touches itself turns it off.
 */
@Component
export struct CYLTagButtonComponent {
  @ObjectLink button: CYLTagButton;
  tagWidth?: number;
  tagHeight?: number;
  interactive: boolean = true;
  onTagClick?: () => void;

  private part(p: CYLTagButtonPart): CYLRect {
    return p.frame;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.button.revision >= 0 && !this.button.titleLabel.isHidden) {
        Text(this.button.titleLabel.text ?? '')
          .fontSize(this.button.titleLabel.font.size)
          .fontWeight(this.button.titleLabel.font.weight)
          .fontColor(this.button.titleLabel.textColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(this.part(this.button.titleLabel).width)
          .height(this.part(this.button.titleLabel).height)
          .position({ x: this.part(this.button.titleLabel).x, y: this.part(this.button.titleLabel).y })
      }
      if (!this.button.imageView.isHidden && this.button.imageView.image !== undefined) {
        Image(this.button.imageView.image)
          .width(this.part(this.button.imageView).width > 0 ? this.part(this.button.imageView).width : undefined)
          .height(this.part(this.button.imageView).height > 0 ? this.part(this.button.imageView).height : undefined)
          .position({ x: this.part(this.button.imageView).x, y: this.part(this.button.imageView).y })
          .fillColor(this.button.imageView.tintColor)
          .objectFit(this.button.imageView.cornerRadius > 0 ? ImageFit.Cover : ImageFit.Contain)
          .borderRadius(this.button.imageView.cornerRadius)
          .clip(this.button.imageView.cornerRadius > 0)
          .rotate({ angle: this.button.imageView.rotation })
          .animation({ duration: this.button.imageRotationDuration })
          .accessibilityLevel('no')
      }
      if (this.button.animationURL !== undefined) {
        ForEach([this.button.animationViewToken], (token: number) => {
          CYLTagButtonAnimationIcon({
            source: this.button.animationURL ?? '',
            button: this.button,
            iconWidth: this.button.animationFrame.width,
            iconHeight: this.button.animationFrame.height
          })
            .position({ x: this.button.animationFrame.x, y: this.button.animationFrame.y })
            .opacity(this.button.animationOpacity)
        }, (token: number) => `${token}`)
      }
      if (!this.button.deleteIndicatorLabel.isHidden) {
        Text(this.button.deleteIndicatorLabel.text ?? '')
          .fontSize(this.button.deleteIndicatorLabel.font.size)
          .fontWeight(this.button.deleteIndicatorLabel.font.weight)
          .fontColor(this.button.deleteIndicatorLabel.textColor)
          .textAlign(TextAlign.Center)
          .width(this.part(this.button.deleteIndicatorLabel).width)
          .height(this.part(this.button.deleteIndicatorLabel).height)
          .position({ x: this.part(this.button.deleteIndicatorLabel).x, y: this.part(this.button.deleteIndicatorLabel).y })
          .accessibilityLevel('no')
      }
      if (this.button.showsCross) {
        ForEach(this.button.crossLines, (line: number[]) => {
          Line()
            .startPoint([line[0], line[1]])
            .endPoint([line[2], line[3]])
            .stroke(this.button.crossColor)
            .strokeWidth(this.button.crossLineWidth)
            .strokeLineCap(LineCapStyle.Round)
            .position({ x: 0, y: 0 })
            .width('100%')
            .height('100%')
            .accessibilityLevel('no')
        }, (line: number[]) => line.join(','))
      }
    }
    .width(this.tagWidth ?? this.button.intrinsicSize().width)
    .height(this.tagHeight ?? this.button.intrinsicSize().height)
    .backgroundColor(this.button.backgroundColor)
    .backgroundImage(this.button.backgroundImage)
    .backgroundImageSize(ImageSize.Cover)
    .border({ width: this.button.borderWidth, color: this.button.borderColor, radius: this.button.cornerRadius })
    .clip(true)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.button.setBounds(Number(newArea.width), Number(newArea.height));
    })
    .onTouch((event: TouchEvent) => {
      if (!this.interactive) {
        return;
      }
      if (event.type === TouchType.Down) {
        this.button.isHighlighted = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.button.isHighlighted = false;
      }
    })
    .onClick(() => this.onTagClick?.())
  }
}


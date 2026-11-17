/**
 * One tag (iOS CYLTagButton.swift; Android CYLTagButton.kt): an icon and a title side by side (the icon after, above or
 * below the title with `imagePlacement`), in a box drawn from the style's appearance for the current state, with an
 * optional delete indicator, an optional badge and an optional animated icon (Lottie, PAG, Rive, SVGA or GIF, by the
 * file's extension). It is also the one icon + title + animated icon component of the libraries built on this one (a
 * search bar item, a placeholder's icon): `new CYLTagButton(title, image, animationURL)` makes one for use on its own.
 *
 * `CYLTagButton` holds the state, the layout and the API (as the iOS class); `CYLTagButtonComponent` draws it, and
 * `CYLTagButtonHost` draws it inside an ArkUI V2 (`@ComponentV2`) parent. The icon may be a pixel image, a rawfile, a
 * pixel map or a system symbol (`$r('sys.symbol.camera')`, drawn with `SymbolGlyph`); every color takes a
 * `ResourceColor`, so theme colors (`$r('sys.color.font_primary')`) follow the color mode.
 */
import { CYLAnimatedIcon } from '../components/CYLAnimatedIcon';
import { CYLAnimationPlayer } from '../components/CYLAnimationPlayer';
import { CYLTagButtonMetrics } from '../components/CYLTagListState';
import {
  CYLMenuStyle, CYLTagContentAlignment, CYLTagDeleteIndicatorPlacement, CYLTagImagePlacement, CYLTagImagePlacementIsVertical
} from '../core/CYLMenuStyle';
import { CYLMenuLocalizedString } from '../core/CYLMenuResources';
import { CYLTagCornerRadiusSquare } from '../core/CYLTagAppearance';
import {
  CYLColor, CYLControlState, CYLEdgeInsets, CYLFont, CYLImage, CYLImageIsSymbol, CYLOffset, CYLRect, CYLSize
} from '../core/CYLTypes';

const DISABLED_ANIMATION_ALPHA: number = 0.4;
/**
 * The badge: a dot's diameter, the minimum height of a badge with text, its text's side padding and font size.
 */
const BADGE_DOT_DIAMETER: number = 8;
const BADGE_MINIMUM_HEIGHT: number = 16;
const BADGE_PADDING: number = 4;
const BADGE_FONT_SIZE: number = 11;
/**
 * The side of a system symbol drawn without an icon slot (a zero `imageSize`), SymbolGlyph's default font size.
 */
const SYMBOL_DEFAULT_SIDE: number = 16;
/**
 * `UIColor.systemRed`, the default `badgeColor`.
 */
export const CYLTagBadgeDefaultColor: string = '#FF3B30';

/**
 * A subview of the tag as last laid out (`imageView`, `titleLabel`, `deleteIndicatorLabel`): its frame in the tag's
 * coordinates and what it shows. The component draws each part from it.
 */
export class CYLTagButtonPart {
  frame: CYLRect = new CYLRect();
  isHidden: boolean = true;
  text?: string;
  font: CYLFont = CYLFont.systemFont(14);
  textColor: ResourceColor = CYLColor.BLACK;
  image?: CYLImage;
  tintColor: ResourceColor = CYLColor.BLACK;
  cornerRadius: number = 0;
  /**
   * Degrees (the fold chevron's turn).
   */
  rotation: number = 0;
}

@Observed
export class CYLTagButton {
  /**
   * Bumped on every change the component draws.
   */
  revision: number = 0;
  /**
   * The icon (as laid out).
   */
  readonly imageView: CYLTagButtonPart = new CYLTagButtonPart();
  /**
   * The title (as laid out).
   */
  readonly titleLabel: CYLTagButtonPart = new CYLTagButtonPart();
  /**
   * The delete indicator (hidden unless `showsDeleteIndicator`, or while a cross is drawn).
   */
  readonly deleteIndicatorLabel: CYLTagButtonPart = new CYLTagButtonPart();
  /**
   * The badge (hidden while `badgeValue` is undefined), at the top trailing corner of the icon.
   */
  readonly badgeLabel: CYLTagButtonPart = new CYLTagButtonPart();
  /**
   * The system font scale (iOS: the trait collection's content size category).
   */
  fontScale: number = 1;

  private titleValue?: string;
  private imageValue?: CYLImage;
  private selectedImageValue?: CYLImage;
  private animationURLValue?: string;
  private restingProgressValue: number = 0;
  private animationSpeedValue?: number;
  private animationLoopsValue: boolean = false;
  private showsDeleteIndicatorValue: boolean = false;
  private badgeValueStorage?: string;
  private badgeColorStorage: ResourceColor = CYLTagBadgeDefaultColor;
  private badgeTextColorStorage?: ResourceColor;
  private badgeFontStorage?: CYLFont;
  private badgeMinimumSizeStorage: CYLSize = CYLSize.ZERO;
  private badgeContentInsetsStorage: CYLEdgeInsets = new CYLEdgeInsets(1, BADGE_PADDING, 1, BADGE_PADDING);
  private badgePositionAdjustmentStorage: CYLOffset = CYLOffset.ZERO;
  private minimumSizeStorage: CYLSize = CYLSize.ZERO;
  private accessibilityLabelStorage?: string;
  private styleStorage: CYLMenuStyle = new CYLMenuStyle();
  private selectedValue: boolean = false;
  private enabledValue: boolean = true;
  private highlightedValue: boolean = false;
  private hitFrame: CYLRect = new CYLRect();
  private player?: CYLAnimationPlayer;
  /**
   * Called on every change the component draws (the tag list re-renders from the button).
   */
  changeHandler?: () => void;
  private boundsWidth: number = 0;
  private boundsHeight: number = 0;
  /**
   * Bumped by `playAnimation()`.
   */
  playToken: number = 0;
  /**
   * Bumped when the animated icon's view must be made again (a new file or size).
   */
  animationViewToken: number = 0;
  /**
   * The two lines of the drawn cross ([x1, y1, x2, y2] each), or empty.
   */
  crossLines: number[][] = [];
  crossLineWidth: number = 0;
  crossColor: ResourceColor = CYLColor.BLACK;
  showsCross: boolean = false;
  cornerRadius: number = 0;
  backgroundColor: ResourceColor = CYLColor.CLEAR;
  backgroundImage?: ResourceStr;
  borderColor: ResourceColor = CYLColor.CLEAR;
  borderWidth: number = 0;
  animationOpacity: number = 1;
  /**
   * Milliseconds over which a change of `imageView.rotation` is animated (the fold chevron); 0: at once.
   */
  imageRotationDuration: number = 0;
  /**
   * The animated icon's frame (when `animationURL` is set).
   */
  animationFrame: CYLRect = new CYLRect();

  /**
   * `init(frame:)` without arguments; `init(title:image:)` / `init(title:image:animationURL:)` with them: a tag for use
   * on its own (a search bar item, a toolbar button), drawn with the default style, sized to fit (`intrinsicSize()`).
   */
  constructor(title?: string, image?: CYLImage, animationURL?: string) {
    this.titleValue = title;
    this.imageValue = image;
    this.animationURLValue = animationURL;
    if (animationURL !== undefined) {
      this.animationViewToken++;
    }
    this.updateAppearance();
  }

  /**
   * `badgeValue`, as `UITabBarItem.badgeValue`: undefined (the default) hides the badge, '' shows a dot, any other text
   * ('3', '99+') a capsule with it, at the top trailing corner of the icon (of the title when there is no icon). The
   * screen reader reads it as the tag's value (`accessibilityValue`).
   */
  get badgeValue(): string | undefined {
    return this.badgeValueStorage;
  }

  set badgeValue(value: string | undefined) {
    if (value !== this.badgeValueStorage) {
      this.badgeValueStorage = value;
      this.updateAppearance();
    }
  }

  /**
   * `badgeColor`: the badge's background, any `ResourceColor` (a theme color follows the color mode); undefined
   * restores the default, system red.
   */
  get badgeColor(): ResourceColor | undefined {
    return this.badgeColorStorage;
  }

  set badgeColor(value: ResourceColor | undefined) {
    this.badgeColorStorage = value ?? CYLTagBadgeDefaultColor;
    this.updateAppearance();
  }

  /**
   * The badge's text color; undefined (the default) is white.
   */
  get badgeTextColor(): ResourceColor | undefined {
    return this.badgeTextColorStorage;
  }

  set badgeTextColor(value: ResourceColor | undefined) {
    this.badgeTextColorStorage = value;
    this.updateAppearance();
  }

  /**
   * The badge's font; undefined (the default) is 11 fp bold, scaled with `fontScale`.
   */
  get badgeFont(): CYLFont | undefined {
    return this.badgeFontStorage;
  }

  set badgeFont(value: CYLFont | undefined) {
    this.badgeFontStorage = value;
    this.updateAppearance();
  }

  /**
   * The smallest size of a badge with text; zero (the default) is 16 vp high and at least as wide (a dot stays 8 vp).
   */
  get badgeMinimumSize(): CYLSize {
    return this.badgeMinimumSizeStorage;
  }

  set badgeMinimumSize(value: CYLSize) {
    this.badgeMinimumSizeStorage = value;
    this.updateAppearance();
  }

  /**
   * The space around a badge's text (its left and right insets widen it, its top and bottom insets heighten it); the
   * default is 4 vp on the left and right, 1 vp above and below.
   */
  get badgeContentInsets(): CYLEdgeInsets {
    return this.badgeContentInsetsStorage;
  }

  set badgeContentInsets(value: CYLEdgeInsets) {
    this.badgeContentInsetsStorage = value;
    this.updateAppearance();
  }

  /**
   * Moves the badge from the icon's (or the title's) top trailing corner; it stays inside the tag.
   */
  get badgePositionAdjustment(): CYLOffset {
    return this.badgePositionAdjustmentStorage;
  }

  set badgePositionAdjustment(value: CYLOffset) {
    this.badgePositionAdjustmentStorage = value;
    this.updateAppearance();
  }

  /**
   * What the screen reader reads first: the label that was set, else the title.
   */
  get accessibilityLabel(): string | undefined {
    if (this.accessibilityLabelStorage !== undefined) {
      return this.accessibilityLabelStorage;
    }
    const displayed = this.styleStorage.displayedTitle(this.titleValue);
    return displayed.length > 0 ? displayed : undefined;
  }

  set accessibilityLabel(value: string | undefined) {
    this.accessibilityLabelStorage = value;
    this.changed();
  }

  /**
   * The badge as the screen reader reads it: its text, or "New" (localized) for a dot; undefined without a badge.
   */
  get accessibilityValue(): string | undefined {
    const badge = this.badgeValueStorage;
    if (badge === undefined) {
      return undefined;
    }
    return badge.length === 0 ? CYLMenuLocalizedString('CYLTagBadgeDot') : badge;
  }

  // MARK: - API

  get title(): string | undefined {
    return this.titleValue;
  }

  set title(value: string | undefined) {
    this.titleValue = value;
    this.updateAppearance();
  }

  /**
   * The icon: a pixel image, a rawfile, a pixel map, or a system symbol (`$r('sys.symbol.camera')`), which is drawn
   * with `SymbolGlyph` in the state's icon color (`CYLMenuStyle.iconColor(state)`).
   */
  get image(): CYLImage | undefined {
    return this.imageValue;
  }

  set image(value: CYLImage | undefined) {
    this.imageValue = value;
    this.updateAppearance();
  }

  /**
   * Shown while selected; undefined keeps `image`.
   */
  get selectedImage(): CYLImage | undefined {
    return this.selectedImageValue;
  }

  set selectedImage(value: CYLImage | undefined) {
    this.selectedImageValue = value;
    this.updateAppearance();
  }

  /**
   * Animated icon: `asset:<rawfile>` (`.json` Lottie, `.pag` PAG, `.riv` Rive, `.gif` GIF; options after `#`) or
   * Lottie JSON text. Without it, `image` is shown.
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

  /**
   * The frame (0...1) of the animated icon shown while not selected. Default 0, the first frame.
   */
  get animationRestingProgress(): number {
    return this.restingProgressValue;
  }

  set animationRestingProgress(value: number) {
    if (value !== this.restingProgressValue) {
      this.restingProgressValue = value;
      this.updateAnimationState();
    }
  }

  /**
   * The playback speed of the animated icon; undefined (the default) uses `style.animationSpeed`.
   */
  get animationSpeed(): number | undefined {
    return this.animationSpeedValue;
  }

  set animationSpeed(value: number | undefined) {
    this.animationSpeedValue = value;
    this.applyAnimationSpeed();
  }

  /**
   * True repeats the animated icon after `playAnimation()`; false (the default) plays once.
   */
  get animationLoops(): boolean {
    return this.animationLoopsValue;
  }

  set animationLoops(value: boolean) {
    if (value === this.animationLoopsValue) {
      return;
    }
    this.animationLoopsValue = value;
    if (this.player !== undefined) {
      this.player.loops = value;
    }
    this.changed();
  }

  /**
   * `animationView`: the live player of the animated icon (the engine's view or controller: `lottieItem`,
   * `pagController`, `riveView`, `gifFrames`), or undefined while there is none (no `animationURL`, not drawn yet).
   */
  get animationView(): CYLAnimationPlayer | undefined {
    return this.player;
  }

  /**
   * The player of the animated icon (`animationView`).
   */
  get animationPlayer(): CYLAnimationPlayer | undefined {
    return this.player;
  }

  /**
   * Shows the style's delete indicator ("×") after the title. False by default.
   */
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

  /**
   * The style the tag is drawn with. Setting copies it; set it again after changing it.
   */
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

  /**
   * The engines (@ohos/lottie, @tencent/libpag, @ohos/rive; GIF through ImageKit) are dependencies of the HAR.
   */
  static get isAnimationEngineAvailable(): boolean {
    return true;
  }

  /**
   * Plays the animated icon from the start, as a tab icon plays when the tab is tapped; called before the icon is
   * loaded (a tag shown for the first time), it plays once the icon is loaded.
   */
  playAnimation(): void {
    this.applyAnimationSpeed();
    if (this.player !== undefined) {
      this.player.loops = this.animationLoopsValue;
      this.player.play();
    } else if (this.animationURLValue !== undefined) {
      this.pendingPlay = true;
    }
    this.playToken++;
    this.changed();
  }

  // MARK: - Measurement

  /**
   * `width(forTitle:image:style:traitCollection:)`: the width a tag needs in every state.
   */
  static widthWithImage(title: string | undefined, image: CYLImage | undefined, style: CYLMenuStyle,
    fontScale: number = 1): number {
    return CYLTagButtonMetrics.widthWithImage(title, image, style, fontScale);
  }

  /**
   * `width(forTitle:iconSize:showsDeleteIndicator:style:traitCollection:)`.
   */
  static width(title: string | undefined, iconSize: CYLSize, showsDeleteIndicator: boolean, style: CYLMenuStyle,
    fontScale: number = 1): number {
    return CYLTagButtonMetrics.width(title, iconSize, showsDeleteIndicator, style, fontScale);
  }

  /**
   * `iconSize(for:animated:style:)`.
   */
  static iconSize(image: CYLImage | undefined, animated: boolean, style: CYLMenuStyle): CYLSize {
    return CYLTagButtonMetrics.iconSize(image, animated && CYLTagButton.isAnimationEngineAvailable, style);
  }

  /**
   * `height(for:traitCollection:)`.
   */
  static height(style: CYLMenuStyle, fontScale: number = 1): number {
    return CYLTagButtonMetrics.height(style, fontScale);
  }

  /**
   * `height(forTitle:iconSize:style:traitCollection:)`.
   */
  static heightForTitle(title: string | undefined, iconSize: CYLSize, style: CYLMenuStyle, fontScale: number = 1): number {
    return CYLTagButtonMetrics.heightForTitle(title, iconSize, style, fontScale);
  }

  /**
   * The smallest size `intrinsicSize()` returns, such as a touch target (36 x 36 for a search bar item); zero (the
   * default) adds nothing. The content is centered in the extra room.
   */
  get minimumSize(): CYLSize {
    return this.minimumSizeStorage;
  }

  set minimumSize(value: CYLSize) {
    this.minimumSizeStorage = value;
    this.changed();
  }

  /**
   * `intrinsicContentSize`: the size the tag needs for its content (its width in every state and its height), at
   * least `minimumSize`.
   */
  intrinsicSize(): CYLSize {
    const animated = this.animationURLValue !== undefined;
    const icon = CYLTagButton.iconSize(this.imageValue ?? this.selectedImageValue, animated, this.styleStorage);
    const width = CYLTagButton.width(this.titleValue, icon, this.showsDeleteIndicatorValue, this.styleStorage,
      this.fontScale);
    const height = CYLTagButton.heightForTitle(this.titleValue, icon, this.styleStorage, this.fontScale);
    const minimum = this.minimumSizeStorage;
    return new CYLSize(Math.max(width, minimum.width), Math.max(height, minimum.height));
  }

  /**
   * The tag's size, from the component; lays the parts out again.
   */
  setBounds(width: number, height: number): void {
    if (width === this.boundsWidth && height === this.boundsHeight) {
      return;
    }
    this.boundsWidth = width;
    this.boundsHeight = height;
    this.layoutSubviews();
    this.changed();
  }

  get bounds(): CYLRect {
    return new CYLRect(0, 0, this.boundsWidth, this.boundsHeight);
  }

  /**
   * Called by the component once the animated icon is loaded (or undefined when it is gone).
   */
  setAnimationPlayer(player: CYLAnimationPlayer | undefined): void {
    this.player = player;
    if (player !== undefined) {
      player.loops = this.animationLoopsValue;
      if (this.pendingPlay) {
        this.pendingPlay = false;
        this.applyAnimationSpeed();
        player.play();
      } else {
        this.updateAnimationState();
      }
    }
  }

  /**
   * Plays once the animated icon is loaded (a tap made it again).
   */
  pendingPlay: boolean = false;

  private changed(): void {
    this.revision++;
    this.changeHandler?.();
  }

  // MARK: - Private

  /**
   * Disabled wins over selected.
   */
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

  /**
   * CYLFlatDesignTabBarButton's `_updateLayout`, with the icon and title side by side.
   */
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
    let imageY = CYLTagButton.centeredY(iconSize.height, contentTop, contentHeight, height);
    let titleY = CYLTagButton.centeredY(titleHeight, contentTop, contentHeight, height);
    const leading = style.contentAlignment === CYLTagContentAlignment.leading;
    if (CYLTagImagePlacementIsVertical(style.imagePlacement)) {
      // Stacked: each centered (or at the leading margin), the group centered between the insets.
      titleWidth = Math.min(Math.ceil(measured), Math.max(0, width - 2 * margin));
      imageX = leading ? margin : Math.floor((width - iconSize.width) / 2);
      titleX = leading ? margin : Math.floor((width - titleWidth) / 2);
      const group = (showsImage ? iconSize.height : 0) + spacing + (showsTitle ? titleHeight : 0);
      const top = CYLTagButton.centeredY(group, contentTop, contentHeight, height);
      if (style.imagePlacement === CYLTagImagePlacement.bottom) {
        titleY = top;
        imageY = top + (showsTitle ? titleHeight + spacing : 0);
      } else {
        imageY = top;
        titleY = top + (showsImage ? iconSize.height + spacing : 0);
      }
    } else if (showsImage && showsTitle) {
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
      titleY + style.titlePositionAdjustment.vertical, titleWidth, titleHeight) : new CYLRect();
    this.titleLabel.isHidden = !showsTitle;
    if (showsImage) {
      const imageInsets = style.imageInsets;
      // Only the size changes; x and y stay, as CYLFlatDesignTabBarItem.imageInsets.
      const frame = new CYLRect(imageX + style.imagePositionAdjustment.horizontal,
        imageY + style.imagePositionAdjustment.vertical,
        Math.max(0, iconSize.width - imageInsets.left - imageInsets.right),
        Math.max(0, iconSize.height - imageInsets.top - imageInsets.bottom));
      if (animated) {
        this.animationFrame = frame;
        this.imageView.frame = new CYLRect();
      } else {
        this.imageView.frame = frame;
      }
      this.layOutBadge(frame);
    } else {
      this.imageView.frame = new CYLRect();
      this.layOutBadge(showsTitle ? this.titleLabel.frame :
        new CYLRect(insets.left, insets.top, Math.max(0, width - 2 * margin), contentHeight));
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

  /**
   * The badge at the top trailing corner of `anchor` (the icon, or the title): the center of its leading cap on the
   * corner, kept inside the tag (which clips its content).
   */
  private layOutBadge(anchor: CYLRect): void {
    const badge = this.badgeValueStorage;
    if (badge === undefined) {
      this.badgeLabel.frame = new CYLRect();
      return;
    }
    const isDot = badge.length === 0;
    const font = this.badgeLabel.font;
    const insets = this.badgeContentInsetsStorage;
    const minimum = this.badgeMinimumSizeStorage;
    const minimumHeight = minimum.height > 0 ? minimum.height : BADGE_MINIMUM_HEIGHT;
    const badgeHeight = isDot ? BADGE_DOT_DIAMETER :
      Math.max(minimumHeight, Math.ceil(CYLTagButtonMetrics.lineHeight(font)) + insets.top + insets.bottom);
    const textWidth = isDot ? 0 : Math.ceil(CYLTagButtonMetrics.textMeasurer(badge, font));
    const minimumWidth = minimum.width > 0 ? minimum.width : badgeHeight;
    const badgeWidth = isDot ? badgeHeight : Math.max(minimumWidth, textWidth + insets.left + insets.right);
    const offset = this.badgePositionAdjustmentStorage;
    const x = Math.max(0,
      Math.min(anchor.maxX - badgeHeight / 2 + offset.horizontal, this.boundsWidth - badgeWidth));
    const y = Math.max(0, Math.min(anchor.y - badgeHeight / 2 + offset.vertical, this.boundsHeight - badgeHeight));
    this.badgeLabel.frame = new CYLRect(x, y, badgeWidth, badgeHeight);
    this.badgeLabel.cornerRadius = badgeHeight / 2;
  }

  private reloadAnimationView(): void {
    this.player = undefined;
    this.animationViewToken++;
    this.updateAnimationState();
    this.updateAppearance();
  }

  /**
   * Selected: the last frame (a selected tab's icon); otherwise the first frame, or the resting progress.
   */
  private updateAnimationState(): void {
    this.applyAnimationSpeed();
    const player = this.player;
    if (player === undefined) {
      return;
    }
    if (player.isPlaying) {
      return;
    }
    player.stopAtProgress(this.selectedValue ? 1 : Math.min(1, Math.max(0, this.restingProgressValue)));
  }

  private applyAnimationSpeed(): void {
    if (this.player !== undefined) {
      this.player.speed = this.resolvedAnimationSpeed;
    }
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
    const badge = this.badgeValueStorage;
    this.badgeLabel.isHidden = badge === undefined;
    this.badgeLabel.text = badge !== undefined && badge.length > 0 ? badge : undefined;
    this.badgeLabel.font = this.badgeFontStorage ?? new CYLFont(BADGE_FONT_SIZE * this.fontScale, FontWeight.Bold);
    this.badgeLabel.textColor = this.badgeTextColorStorage ?? CYLColor.WHITE;
    this.badgeLabel.tintColor = this.badgeColorStorage;
    this.layoutSubviews();
    this.changed();
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

  // The parts are plain objects: reading `revision` first makes every attribute update when the button changes.
  private tl(): CYLTagButtonPart {
    return this.button.revision >= 0 ? this.button.titleLabel : this.button.titleLabel;
  }

  private iv(): CYLTagButtonPart {
    return this.button.revision >= 0 ? this.button.imageView : this.button.imageView;
  }

  private dl(): CYLTagButtonPart {
    return this.button.revision >= 0 ? this.button.deleteIndicatorLabel : this.button.deleteIndicatorLabel;
  }

  private bl(): CYLTagButtonPart {
    return this.button.revision >= 0 ? this.button.badgeLabel : this.button.badgeLabel;
  }

  private af(): CYLRect {
    return this.button.revision >= 0 ? this.button.animationFrame : this.button.animationFrame;
  }

  // A symbol is drawn at the icon slot's smaller side; without a slot (a zero `imageSize`), at the default 16 vp.
  private symbolSide(): number {
    const frame = this.part(this.iv());
    const side = Math.min(frame.width, frame.height);
    return side > 0 ? side : SYMBOL_DEFAULT_SIDE;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.button.revision >= 0 && !this.tl().isHidden) {
        Text(this.tl().text ?? '')
          .fontSize(this.tl().font.size)
          .fontWeight(this.tl().font.weight)
          .fontColor(this.tl().textColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(this.part(this.tl()).width)
          .height(this.part(this.tl()).height)
          .position({ x: this.part(this.tl()).x, y: this.part(this.tl()).y })
      }
      if (!this.iv().isHidden && this.iv().image !== undefined && CYLImageIsSymbol(this.iv().image)) {
        // A system symbol (`$r('sys.symbol.camera')`): `SymbolGlyph`, its font color the icon color of the state.
        SymbolGlyph(this.iv().image as Resource)
          .fontSize(this.symbolSide())
          .fontColor([this.iv().tintColor])
          .width(this.part(this.iv()).width > 0 ? this.part(this.iv()).width : this.symbolSide())
          .height(this.part(this.iv()).height > 0 ? this.part(this.iv()).height : this.symbolSide())
          .position({ x: this.part(this.iv()).x, y: this.part(this.iv()).y })
          .rotate({ angle: this.iv().rotation })
          .animation({ duration: this.button.imageRotationDuration })
          .accessibilityLevel('no')
      } else if (!this.iv().isHidden && this.iv().image !== undefined) {
        Image(this.iv().image)
          .width(this.part(this.iv()).width > 0 ? this.part(this.iv()).width : undefined)
          .height(this.part(this.iv()).height > 0 ? this.part(this.iv()).height : undefined)
          .position({ x: this.part(this.iv()).x, y: this.part(this.iv()).y })
          .fillColor(this.iv().tintColor)
          .objectFit(this.iv().cornerRadius > 0 ? ImageFit.Cover : ImageFit.Contain)
          .borderRadius(this.iv().cornerRadius)
          .clip(this.iv().cornerRadius > 0)
          .rotate({ angle: this.iv().rotation })
          .animation({ duration: this.button.imageRotationDuration })
          .accessibilityLevel('no')
      }
      if (this.button.animationURL !== undefined) {
        ForEach([this.button.animationViewToken], (token: number) => {
          CYLAnimatedIcon({
            source: this.button.animationURL ?? '',
            iconSize: this.af().width,
            iconHeight: this.af().height,
            onPlayer: (player: CYLAnimationPlayer | undefined) => {
              if (player !== undefined || this.button.animationPlayer !== undefined) {
                this.button.setAnimationPlayer(player);
              }
            }
          })
            .position({ x: this.af().x, y: this.af().y })
            .opacity(this.button.animationOpacity)
        }, (token: number) => `${token}`)
      }
      if (!this.dl().isHidden) {
        Text(this.dl().text ?? '')
          .fontSize(this.dl().font.size)
          .fontWeight(this.dl().font.weight)
          .fontColor(this.dl().textColor)
          .textAlign(TextAlign.Center)
          .width(this.part(this.dl()).width)
          .height(this.part(this.dl()).height)
          .position({ x: this.part(this.dl()).x, y: this.part(this.dl()).y })
          .accessibilityLevel('no')
      }
      if (!this.bl().isHidden) {
        // The badge: white text on `badgeColor` (the part's tint), a capsule or a dot.
        Text(this.bl().text ?? '')
          .fontSize(this.bl().font.size)
          .fontWeight(this.bl().font.weight)
          .fontColor(this.bl().textColor)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .backgroundColor(this.bl().tintColor)
          .borderRadius(this.bl().cornerRadius)
          .width(this.part(this.bl()).width)
          .height(this.part(this.bl()).height)
          .position({ x: this.part(this.bl()).x, y: this.part(this.bl()).y })
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
    .accessibilityGroup(true)
    .accessibilityText(this.button.accessibilityLabel ?? '')
    .accessibilityDescription(this.button.accessibilityValue ?? '')
    .onClick(() => this.onTagClick?.())
  }
}

/**
 * Draws a `CYLTagButton` inside an ArkUI V2 parent (`@ComponentV2`), which cannot link a V1 `@Observed` object
 * itself: the host holds the button as V1 state and links it to `CYLTagButtonComponent` (the bridge that
 * CYLSearchViewController uses for CYLTableViewPlaceHolder's V1 placeholders). The host keeps the button it was
 * created with: change that button's properties to redraw it, and give the host another key (a `ForEach` key) to draw
 * another button. Without `tagWidth` / `tagHeight` the tag takes its intrinsic size (`intrinsicSize()`).
 */
@Component
export struct CYLTagButtonHost {
  /**
   * The button to draw, passed once by the parent.
   */
  @State button: CYLTagButton = new CYLTagButton();
  /**
   * The width; undefined uses the button's intrinsic width.
   */
  tagWidth?: number;
  /**
   * The height; undefined uses the button's intrinsic height.
   */
  tagHeight?: number;
  /**
   * Shows the pressed look while touched (the default); off when the parent handles touches.
   */
  interactive: boolean = true;
  /**
   * Called on a tap.
   */
  onTagClick?: () => void;

  build() {
    CYLTagButtonComponent({
      button: this.button,
      tagWidth: this.tagWidth,
      tagHeight: this.tagHeight,
      interactive: this.interactive,
      onTagClick: this.onTagClick
    })
  }
}

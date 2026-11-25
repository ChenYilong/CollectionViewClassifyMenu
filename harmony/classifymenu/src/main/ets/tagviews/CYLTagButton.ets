/**
 * One tag (iOS CYLTagButton.swift; Android CYLTagButton.kt): an icon and a title side by side (the icon after, above or
 * below the title with `imagePlacement`), in a box drawn from the style's appearance for the current state, with an
 * optional delete indicator, an optional badge and an optional animated icon (Lottie, PAG, Rive, SVGA or GIF, by the
 * file's extension). It is also the one icon + title + animated icon component of the libraries built on this one (a
 * search bar item, a placeholder's icon): `new CYLTagButton(title, image, animationURL)` makes one for use on its own.
 *
 * The animated icon is CYLTabBarController's shared component, `CYLAnimatedItemView` (`CYLTagAnimatedIcon`): iOS and
 * Android subclass it, and ArkTS structs cannot subclass, so the tag wraps it in its icon slot and keeps its own
 * layout, measuring, title, delete indicator and badge. The library depends on no animation library: the app registers
 * the types it plays (`CYLAnimatedItemEngines.register(type)`) and the views that play them
 * (`CYLTagAnimationBuilder.register(builder)`); a type nobody registered shows the static image, or the placeholder.
 *
 * `CYLTagButton` holds the state, the layout and the API (as the iOS class); `CYLTagButtonComponent` draws it, and
 * `CYLTagButtonHost` draws it inside an ArkUI V2 (`@ComponentV2`) parent. The icon may be a pixel image, a rawfile, a
 * pixel map or a system symbol (`$r('sys.symbol.camera')`, drawn with `SymbolGlyph`); every color takes a
 * `ResourceColor`, so theme colors (`$r('sys.color.font_primary')`) follow the color mode.
 */
import {
  CYLAnimatedItemEngines, CYLAnimatedItemStackItem, CYLAnimatedItemStackModel, CYLAnimatedItemStackView, cylIconColorFilter
} from 'cylanimateditem';
import { CYLAnimatedItemBackgroundModifier, CYLAnimatedItemBackgroundStyle } from 'cylanimateditem';
import { CYLAnimationPlayer } from '../components/CYLAnimationPlayer';
import {
  CYLTagAnimatedIcon, cylTagAnimatedIconOuterHeight, cylTagAnimatedIconOuterWidth, cylTagAnimationImage
} from '../components/CYLTagAnimatedIcon';
import { CYLTagButtonMetrics } from '../components/CYLTagListState';
import {
  CYLMenuStyle, CYLTagBackgroundStyle, CYLTagContentAlignment, CYLTagDeleteIndicatorPlacement, CYLTagImagePlacement, CYLTagImagePlacementIsVertical,
  CYLTagTitleMaxLines
} from '../core/CYLMenuStyle';
import { CYLMenuLocalizedString } from '../core/CYLMenuResources';
import { CYLUIContext } from '../core/CYLUIContext';
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
  /**
   * Whether the style sets an icon color for the state (`CYLMenuStyle.setIconColor`): then bitmap icons are tinted
   * too, as template images are on iOS; without one, a bitmap keeps its own colors (an original image).
   */
  tintsImage: boolean = false;
  cornerRadius: number = 0;
  /**
   * Degrees (the fold chevron's turn).
   */
  rotation: number = 0;
  /**
   * The most lines of a title (`CYLMenuStyle.titleMaxLines`): 1 by default, `CYLTagTitleMaxLines.unlimited` for as many
   * as it needs.
   */
  maxLines: number = CYLTagTitleMaxLines.single;
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
  private showsRenameIndicatorValue: boolean = false;
  private renameHitFrame: CYLRect = new CYLRect();
  private editingIndicatorsModel?: CYLAnimatedItemStackModel;
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
  /**
   * `CYLMenuStyle.deleteIndicatorImage` and its frame in the tag: a square inside the indicator, the padding beside it,
   * not above it, so a one-line tag keeps the full line height for it.
   */
  deleteIndicatorImage?: CYLImage = undefined;
  deleteIndicatorImageFrame: CYLRect = new CYLRect();
  /**
   * `CYLMenuStyle.elevation`: a shadow under the tag (vp); the tag stops clipping its content then.
   */
  elevation: number = 0;
  crossLineWidth: number = 0;
  crossColor: ResourceColor = CYLColor.BLACK;
  showsCross: boolean = false;
  /** The frames of the two editing icons (the edit icon, then the cross) while `showsRenameIndicator`, or empty. */
  editingIconFrames: CYLRect[] = [];
  /** The frame of `editingIndicatorsView` (the two icon slots and the space between them), or empty. */
  editingIndicatorsFrame: CYLRect = new CYLRect();
  /** The color of the editing icons (`CYLMenuStyle.deleteIndicatorColor`, else the text color). */
  editingIconColor: ResourceColor = CYLColor.BLACK;
  cornerRadius: number = 0;
  /** The appearance's radius as it is (the capsule constant by default): `cylanimateditem` implements the capsule. */
  appearanceCornerRadius: number = 0;
  /** A selected Liquid Glass tag keeps its full color (tint alpha 1, still glass); -1 is the modifier's default share. */
  glassTintAlpha: number = -1;
  /**
   * What a glass tag with no explicit background color hands to `CYLAnimatedItemBackgroundModifier`: a transparent color means
   * "no color", and the glass draws its frosted default tint (225, 222, 220 at 0.5; white at 0.14 in dark mode).
   */
  static readonly GLASS_DEFAULT_TINT: ResourceColor = Color.Transparent;

  /**
   * The color a glass tag hands to the modifier: the explicit color, or `GLASS_DEFAULT_TINT` ("no color") when there is none
   * or it is fully transparent (a cleared color means "unset" under glass, as on iOS).
   */
  static glassTintColor(explicitColor: ResourceColor | undefined): ResourceColor {
    if (explicitColor === undefined || explicitColor === Color.Transparent || explicitColor === CYLColor.CLEAR) {
      return CYLTagButton.GLASS_DEFAULT_TINT;
    }
    return explicitColor;
  }
  backgroundColor: ResourceColor = CYLColor.CLEAR;
  /**
   * The background, radius and border are `cylanimateditem`'s (`CYLAnimatedItemBackgroundModifier`, the interface of
   * `CYLAnimatedItemView.itemBackgroundStyle…`): the style; the radius is `cornerRadius` (the appearance's, the capsule constant by default).
   */
  itemBackgroundStyle: CYLAnimatedItemBackgroundStyle = CYLAnimatedItemBackgroundStyle.flat;
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
   * The static image under the animated icon while it loads and after it fails (`CYLAnimatedItemView.image`), or ''.
   */
  animationImage: ResourceStr = '';
  /**
   * The color `CYLAnimatedItemView` tints the animated icon's static image with (`iconColor`: `animationImage` /
   * `animationSelectedImage` while the animation loads and after it fails): the state's `CYLMenuStyle.iconColor` when
   * the style sets one, as the tag's own static icon is tinted; '' (the image's own colors) otherwise or without an
   * animation.
   */
  animationIconColor: ResourceColor = '';
  /**
   * The static image under the animated icon while selected (`CYLAnimatedItemView.selectedImage`), or ''.
   */
  animationSelectedImage: ResourceStr = '';

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
   * Animated icon: `asset:<rawfile>` (`.json` Lottie, `.pag` PAG, `.riv` Rive, `.gif` GIF, `.svga` SVGA; options after
   * `#`), drawn by `CYLAnimatedItemView` with the view the app registered for its type. Without it, `image` is shown;
   * with it, `image` (`selectedImage` while selected) shows while it loads, after it fails and when no engine of its
   * type is registered (a pixel map or a symbol cannot: the component's placeholder shows instead).
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

  /** `resetAnimationSpeed()`: follows `style.animationSpeed` again. */
  resetAnimationSpeed(): void {
    this.animationSpeed = undefined;
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
   * `animationView`: the live player of the animated icon, the one the app's animation view handed over with
   * `CYLTagAnimationContext.ready(player)` (the example's players expose `lottieItem`, `pagController`,
   * `gifFrames`, `svgaMovie`), or undefined while there is none (no `animationURL`, not drawn yet, no engine). It is
   * always undefined for a type drawn by a component-level builder (Rive): that one is driven through
   * `CYLAnimatedItemView`'s own props.
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
   * `showsRenameIndicator`: shows a rename indicator (an edit icon, `sys.symbol.square_and_pencil`) before the delete
   * indicator, for a tag that can be renamed in editing mode; with `showsDeleteIndicator`, the two icons are drawn by
   * `editingIndicatorsView` instead of the style's indicator. False by default.
   */
  get showsRenameIndicator(): boolean {
    return this.showsRenameIndicatorValue;
  }

  set showsRenameIndicator(value: boolean) {
    if (value !== this.showsRenameIndicatorValue) {
      this.showsRenameIndicatorValue = value;
      this.updateAppearance();
    }
  }

  /** `renameIndicatorHitFrame`: the area a tap on the rename indicator covers, the tag's full height; empty while hidden. */
  get renameIndicatorHitFrame(): CYLRect {
    return this.renameHitFrame;
  }

  /**
   * `editingIndicatorsView`: the two editing icons while `showsRenameIndicator` (the edit icon, then the cross): the
   * model of a CYLTabBarController `CYLAnimatedItemStackView` laid out in a row (`axis` 'horizontal'),
   * `CYLMenuStyle.editingIndicatorSpacing` apart, tinted with the indicator color (`iconColor`).
   */
  get editingIndicatorsView(): CYLAnimatedItemStackModel {
    if (this.editingIndicatorsModel === undefined) {
      const rename = new CYLAnimatedItemStackItem('', $r('sys.symbol.square_and_pencil'));
      rename.accessibilityText = CYLMenuLocalizedString('CYLMenuRenameTag');
      const remove = new CYLAnimatedItemStackItem('', $r('sys.symbol.xmark'));
      remove.accessibilityText = CYLMenuLocalizedString('CYLMenuDeleteTag');
      const model = new CYLAnimatedItemStackModel([rename, remove]);
      model.axis = 'horizontal';
      model.contentMargin = 0;
      this.editingIndicatorsModel = model;
    }
    return this.editingIndicatorsModel;
  }

  /** Whether the two editing icons replace the delete indicator. */
  get showsEditingIcons(): boolean {
    return this.showsDeleteIndicatorValue && this.showsRenameIndicatorValue;
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
   * Whether the app registered an animation engine (`CYLAnimatedItemEngines.register(type)`). The library depends on
   * no animation library; the example registers Lottie, PAG, Rive, SVGA and GIF.
   */
  static get isAnimationEngineAvailable(): boolean {
    return CYLAnimatedItemEngines.registeredTypes().length > 0;
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
  static widthWithRenameIndicator(title: string | undefined, iconSize: CYLSize, showsDeleteIndicator: boolean,
    showsRenameIndicator: boolean, style: CYLMenuStyle, fontScale: number = 1): number {
    return CYLTagButtonMetrics.width(title, iconSize, showsDeleteIndicator, style, fontScale, showsRenameIndicator);
  }

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
    const width = CYLTagButtonMetrics.width(this.titleValue, icon, this.showsDeleteIndicatorValue, this.styleStorage,
      this.fontScale, this.showsRenameIndicatorValue);
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
   * The animated icon of a builder-drawn type has loaded: a `playAnimation()` made before that replays now.
   */
  itemDidLoad(): void {
    if (this.pendingPlay) {
      this.pendingPlay = false;
      this.playToken++;
      this.changed();
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
    // Left and right at least the shape's inset (14 on a drawn Liquid Glass tag, 0 on flat), as the measured width counted it.
    const appearanceInsets = style.appearance(state).contentInsets;
    const sideInset: number = CYLTagButtonMetrics.contentInset(style);
    const insets = new CYLEdgeInsets(appearanceInsets.top, Math.max(appearanceInsets.left, sideInset), appearanceInsets.bottom,
      Math.max(appearanceInsets.right, sideInset));
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
    if (showsImage && style.fillsTagHeight(iconSize)) {
      this.layOutTagHeightImage(showsTitle, titleText, margin, trailing, insets, animated);
      return;
    }
    const spacing = showsImage && showsTitle ? style.imageTitleSpacing : 0;
    const available = Math.max(0, width - 2 * margin - (showsImage ? iconSize.width + spacing : 0));
    const font = this.titleLabel.font;
    const measured = showsTitle ? CYLTagButtonMetrics.textMeasurer(titleText, font) : 0;
    let titleWidth = Math.min(available, Math.ceil(measured));
    // A wrapping title (`CYLMenuStyle.titleWraps`) is measured at the width it can have; otherwise on one line.
    const lineHeight = style.titleWraps ? CYLTagButtonMetrics.wrappedTextHeight(titleText, font, available,
      style.titleMaxLines) :
      CYLTagButtonMetrics.lineHeight(font);
    const titleHeight = showsTitle ? Math.min(height, Math.ceil(lineHeight)) : 0;

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
    // Points, limited to half the height: 0 is square, half the height or more a capsule.
    const radius = style.appearance(state).cornerRadius;
    this.cornerRadius = Math.min(radius, height / 2);
  }

  /**
   * `CYLMenuStyle.imageFillsTagHeight`: the image (or animated icon) a circle as tall as the tag at its leading edge,
   * the title after it, from the leading margin; the delete indicator is already in place.
   */
  private layOutTagHeightImage(showsTitle: boolean, titleText: string, margin: number, trailing: number,
    insets: CYLEdgeInsets, animated: boolean): void {
    const style = this.styleStorage;
    const height = this.boundsHeight;
    const indicatorFirst = margin > insets.left;
    const frame = new CYLRect(indicatorFirst ? margin - insets.left : 0, 0, height, height);
    if (animated) {
      this.animationFrame = frame;
      this.imageView.frame = new CYLRect();
    } else {
      this.imageView.frame = frame;
    }
    this.imageView.cornerRadius = height / 2;
    this.layOutBadge(frame);
    this.titleLabel.isHidden = !showsTitle;
    if (showsTitle) {
      const x = frame.x + frame.width + style.imageTitleSpacing;
      const font = this.titleLabel.font;
      let titleHeight = Math.min(height, Math.ceil(CYLTagButtonMetrics.lineHeight(font)));
      const contentHeight = Math.max(0, height - insets.top - insets.bottom);
      const measured = Math.ceil(CYLTagButtonMetrics.textMeasurer(titleText, font));
      const room = Math.max(0, this.boundsWidth - trailing - x);
      if (style.titleWraps) {
        titleHeight = Math.min(height, Math.ceil(CYLTagButtonMetrics.wrappedTextHeight(titleText, font, room,
          style.titleMaxLines)));
      }
      this.titleLabel.frame = new CYLRect(x + style.titlePositionAdjustment.horizontal,
        CYLTagButton.centeredY(titleHeight, insets.top, contentHeight, height) + style.titlePositionAdjustment.vertical,
        Math.min(measured, Math.max(0, this.boundsWidth - trailing - x)), titleHeight);
    } else {
      this.titleLabel.frame = new CYLRect();
    }
    const radius = style.appearance(this.currentState).cornerRadius;
    this.cornerRadius = Math.min(radius, height / 2);
  }

  /**
   * The delete indicator at the trailing (or leading) inset, its hit area and its cross; returns the width it takes
   * with the space before it (0 while hidden).
   */
  private layOutDeleteIndicator(state: number, insets: CYLEdgeInsets): number {
    const style = this.styleStorage;
    const width = this.boundsWidth;
    const height = this.boundsHeight;
    this.renameHitFrame = new CYLRect();
    this.editingIconFrames = [];
    if (!this.showsDeleteIndicatorValue) {
      this.deleteIndicatorLabel.frame = new CYLRect();
      this.hitFrame = new CYLRect();
      this.crossLines = [];
      return 0;
    }
    if (this.showsRenameIndicatorValue) {
      return this.layOutEditingIndicators(state, insets);
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
    // The image: a square inside the indicator, the padding beside it, not above it, so a one-line tag keeps the full
    // line height for it (iOS 00760142: with the padding above too it vanished on a one-line tag).
    const imageSide = Math.max(0, Math.min(indicator.width - 2 * style.deleteIndicatorPadding, indicator.height));
    this.deleteIndicatorImageFrame = new CYLRect(indicator.x + (indicator.width - imageSide) / 2,
      indicator.y + (indicator.height - imageSide) / 2, imageSide, imageSide);
    return indicatorWidth + style.imageTitleSpacing;
  }

  /**
   * The two editing icons (iOS 3af1b7cd): each slot the title's cap height x 1.25 with the glyph filling it,
   * `editingIndicatorSpacing` between them, `editingIndicatorInsets` around them; the rename hit area runs to the
   * middle of the space between them, the delete one from there.
   */
  private layOutEditingIndicators(state: number, insets: CYLEdgeInsets): number {
    const style = this.styleStorage;
    const width = this.boundsWidth;
    const height = this.boundsHeight;
    const side = CYLTagButtonMetrics.editingIconSide(state, style, this.fontScale);
    const spacing = Math.max(0, style.editingIndicatorSpacing);
    const m = style.editingIndicatorInsets;
    const left = Math.max(0, m.left);
    const right = Math.max(0, m.right);
    const top = Math.max(0, m.top);
    const bottom = Math.max(0, m.bottom);
    const total = left + 2 * side + spacing + right;
    const leading = style.deleteIndicatorPlacement === CYLTagDeleteIndicatorPlacement.leading;
    const x = leading ? insets.left : Math.max(insets.left, width - insets.right - total);
    const outerHeight = Math.max(0, height - insets.top - insets.bottom);
    const areaY = insets.top + top;
    const areaHeight = Math.max(0, outerHeight - top - bottom);
    const glyph = Math.max(0, Math.min(side, areaHeight));
    const model = this.editingIndicatorsView;
    // Each glyph is centered in its slot: the space between the glyphs is the spacing plus what the slots add.
    model.spacing = spacing + (side - glyph);
    model.items.forEach((item: CYLAnimatedItemStackItem) => {
      item.iconSize = glyph;
      item.spacingBefore = -1;
    });
    const glyphY = areaY + (areaHeight - glyph) / 2;
    const firstX = x + left;
    this.editingIndicatorsFrame = new CYLRect(firstX, areaY, 2 * side + spacing, areaHeight);
    this.editingIconFrames = [new CYLRect(firstX + (side - glyph) / 2, glyphY, glyph, glyph),
      new CYLRect(firstX + side + spacing + (side - glyph) / 2, glyphY, glyph, glyph)];
    this.deleteIndicatorLabel.frame = new CYLRect();
    this.crossLines = [];
    const middle = firstX + side + spacing / 2;
    if (leading) {
      this.renameHitFrame = new CYLRect(0, 0, middle, height);
      this.hitFrame = new CYLRect(middle, 0, Math.max(0, x + total + style.imageTitleSpacing - middle), height);
    } else {
      const start = Math.max(0, x - style.imageTitleSpacing);
      this.renameHitFrame = new CYLRect(start, 0, Math.max(0, middle - start), height);
      this.hitFrame = new CYLRect(middle, 0, Math.max(0, width - middle), height);
    }
    return total + style.imageTitleSpacing;
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
    // An animated icon takes the icon slot: CYLAnimatedItemView draws the static image under it.
    this.imageView.image = animated ? undefined : icon;
    this.imageView.isHidden = animated || icon === undefined;
    this.animationImage = animated ? cylTagAnimationImage(this.imageValue) : '';
    this.animationSelectedImage = animated ? cylTagAnimationImage(this.selectedImageValue) : '';
    this.animationOpacity = state === CYLControlState.DISABLED ? DISABLED_ANIMATION_ALPHA : 1;
    this.imageView.tintColor = style.iconColor(state);
    this.imageView.tintsImage = style.appearance(state).iconColor !== undefined;
    this.animationIconColor = animated && this.imageView.tintsImage ? this.imageView.tintColor : '';
    this.titleLabel.text = style.displayedTitle(this.titleValue);
    this.titleLabel.font = style.titleFont(state, this.fontScale);
    this.titleLabel.textColor = appearance.textColor;

    const pressed = this.highlightedValue && state !== CYLControlState.DISABLED &&
      style.highlightedBackgroundColor !== undefined;
    // Pressed, as android-tagview's layoutColorPress.
    // Liquid Glass: the state's background color tints the glass (CYLAnimatedItemBackgroundModifier, see build()). Where glass is
    // drawn only an EXPLICIT color tints it: an unset background (the built-in default, which would hide the backdrop) hands no
    // color, so the modifier uses the glass's frosted default tint. The pressed color is always explicit. Flat (also where the
    // system draws no glass) keeps the effective color.
    const glass = style.resolvedBackgroundStyle() === CYLTagBackgroundStyle.liquidGlass;
    const explicitBackground: ResourceColor | undefined = pressed ? style.highlightedBackgroundColor :
    appearance.explicitBackgroundColor;
    const stateBackground: ResourceColor = glass ? CYLTagButton.glassTintColor(explicitBackground) :
      (pressed ? (style.highlightedBackgroundColor ?? CYLColor.CLEAR) : appearance.backgroundColor);
    this.itemBackgroundStyle = glass ? CYLAnimatedItemBackgroundStyle.liquidGlass : CYLAnimatedItemBackgroundStyle.flat;
    this.appearanceCornerRadius = appearance.cornerRadius;
    this.glassTintAlpha = state === CYLControlState.SELECTED ? 1 : -1;
    this.backgroundColor = stateBackground;
    this.backgroundImage = this.highlightedValue && style.highlightedBackgroundColor !== undefined ? undefined :
    appearance.backgroundImage;
    // With the rename indicator, the two editing icons are drawn instead of the style's indicator.
    const editingIcons = this.showsDeleteIndicatorValue && this.showsRenameIndicatorValue;
    const indicatorImage: CYLImage | undefined = editingIcons ? undefined : style.deleteIndicatorImage;
    const drawsCross = style.deleteIndicatorLineWidth > 0 && indicatorImage === undefined && !editingIcons;
    this.editingIconColor = style.deleteIndicatorColor ?? appearance.textColor;
    if (editingIcons) {
      const color = this.editingIconColor;
      this.editingIndicatorsView.iconColor = typeof color === 'string' ? color : '';
    }
    this.deleteIndicatorLabel.isHidden = !this.showsDeleteIndicatorValue || drawsCross || indicatorImage !== undefined ||
      editingIcons;
    this.deleteIndicatorLabel.text = this.showsDeleteIndicatorValue && !drawsCross && indicatorImage === undefined &&
      !editingIcons ?
    style.deleteIndicatorTitle : undefined;
    this.showsCross = this.showsDeleteIndicatorValue && drawsCross;
    this.deleteIndicatorImage = this.showsDeleteIndicatorValue ? indicatorImage : undefined;
    // A wrapping title (`CYLMenuStyle.titleWraps`) takes as many lines as it needs.
    this.titleLabel.maxLines = style.titleMaxLines;
    this.elevation = Math.max(0, style.elevation);
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

  /**
   * A tag drawn on its own (no tag list or controller around it) still measures its title with the window's text
   * metrics: without them the width came from an estimate, far too narrow for CJK titles ("SVG…").
   */
  aboutToAppear(): void {
    CYLUIContext.remember(this.getUIContext());
  }

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
          // `CYLMenuStyle.titleMaxLines` lines at most (`CYLTagTitleMaxLines.unlimited`: as many as the title needs).
          .maxLines(this.tl().maxLines)
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
          // Bitmaps too, when the style sets an icon color (see `tintsImage`): an orange PNG on an orange selected tag
          // stayed orange and invisible (HarmonyOS issue Y2). A drawing color filter (`ColorFilter`) applies to every
          // image source; the matrix form had no effect after `fillColor` on the emulator. The filter is the shared
          // component's (`cylIconColorFilter`, `CYLAnimatedItemView.iconColor`), as for the animated icon's static image.
          .colorFilter(new ColorFilter(cylIconColorFilter(this.iv().tintsImage ? this.iv().tintColor : '')))
          .objectFit(this.iv().cornerRadius > 0 ? ImageFit.Cover : ImageFit.Contain)
          .borderRadius(this.iv().cornerRadius)
          .clip(this.iv().cornerRadius > 0)
          .rotate({ angle: this.iv().rotation })
          .animation({ duration: this.button.imageRotationDuration })
          .accessibilityLevel('no')
      }
      if (this.button.animationURL !== undefined) {
        // CYLAnimatedItemView (in CYLTagAnimatedIcon) is larger than the icon (its padding and 44 vp minimum height):
        // centered on the icon's frame, the tag clipping the transparent rest.
        ForEach([this.button.animationViewToken], (token: number) => {
          CYLTagAnimatedIcon({
            animationURL: this.button.animationURL ?? '',
            image: this.button.animationImage,
            selectedImage: this.button.animationSelectedImage,
            iconColor: this.button.animationIconColor,
            isSelected: this.button.isSelected,
            iconWidth: this.af().width,
            iconHeight: this.af().height,
            animationSpeed: this.button.resolvedAnimationSpeed,
            animationLoops: this.button.animationLoops,
            animationRestartToken: this.button.playToken,
            onItemLoaded: () => this.button.itemDidLoad(),
            onPlayer: (player: CYLAnimationPlayer | undefined) => {
              if (player !== undefined || this.button.animationPlayer !== undefined) {
                this.button.setAnimationPlayer(player);
              }
            },
            onTap: () => this.onTagClick?.()
          })
            .position({
              x: this.af().x + (this.af().width - cylTagAnimatedIconOuterWidth(this.af().width, this.af().height)) / 2,
              y: this.af().y + (this.af().height - cylTagAnimatedIconOuterHeight(this.af().width, this.af().height)) / 2
            })
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
      if (this.button.deleteIndicatorImage !== undefined && CYLImageIsSymbol(this.button.deleteIndicatorImage)) {
        // `CYLMenuStyle.deleteIndicatorImage` as a system symbol ($r('sys.symbol.xmark_circle_fill')), in the indicator color.
        SymbolGlyph(this.button.deleteIndicatorImage as Resource)
          .fontSize(this.button.deleteIndicatorImageFrame.height)
          .fontColor([this.dl().textColor])
          .width(this.button.deleteIndicatorImageFrame.width)
          .height(this.button.deleteIndicatorImageFrame.height)
          .position({ x: this.button.deleteIndicatorImageFrame.x, y: this.button.deleteIndicatorImageFrame.y })
          .accessibilityLevel('no')
      } else if (this.button.deleteIndicatorImage !== undefined) {
        // `CYLMenuStyle.deleteIndicatorImage`: the image in place of the cross.
        Image(this.button.deleteIndicatorImage)
          .objectFit(ImageFit.Contain)
          .width(this.button.deleteIndicatorImageFrame.width)
          .height(this.button.deleteIndicatorImageFrame.height)
          .position({ x: this.button.deleteIndicatorImageFrame.x, y: this.button.deleteIndicatorImageFrame.y })
          .accessibilityLevel('no')
      }
      if (this.button.showsEditingIcons) {
        // `editingIndicatorsView`: CYLTabBarController's stack view in a row; the cell's hit areas take the taps.
        Column() {
          CYLAnimatedItemStackView({ model: this.button.editingIndicatorsView })
        }
        .width(this.button.editingIndicatorsFrame.width)
        .height(this.button.editingIndicatorsFrame.height)
        .position({ x: this.button.editingIndicatorsFrame.x, y: this.button.editingIndicatorsFrame.y })
        .hitTestBehavior(HitTestMode.None)
        .accessibilityLevel('no-hide-descendants')
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
    // Background, radius and border (the tint over the glass for Liquid Glass): cylanimateditem's one interface.
    .attributeModifier(new CYLAnimatedItemBackgroundModifier(this.button.itemBackgroundStyle, this.button.backgroundColor,
      this.button.appearanceCornerRadius, this.button.borderWidth, this.button.borderColor, this.button.glassTintAlpha))
    .backgroundImage(this.button.backgroundImage)
    .backgroundImageSize(ImageSize.Cover)
    // `CYLMenuStyle.elevation`: a shadow under the tag (offset down by half of it, blurred by it); the tag stops
    // clipping its content then, since the shadow is outside its bounds.
    .shadow(this.button.elevation > 0 ?
      { radius: this.button.elevation / 2, color: '#40000000', offsetX: 0, offsetY: this.button.elevation / 2 } :
      { radius: 0, color: Color.Transparent })
    .clip(this.button.elevation <= 0)
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
    // No click handler without onTagClick: a parent that handles the tap itself (a row around the tag) receives it.
    .onClick(this.onTagClick === undefined ? undefined : () => this.onTagClick?.())
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

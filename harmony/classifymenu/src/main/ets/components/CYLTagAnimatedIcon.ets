/**
 * A tag's animated icon on CYLTabBarController's shared icon + title component, `CYLAnimatedItemView` (module
 * `cylanimateditem`, vendored at commit 4635ef7 in `harmony/cylanimateditem`). ArkTS structs cannot subclass, so the
 * tag wraps the component instead of subclassing it as iOS and Android do: `CYLTagAnimatedIcon` draws the icon slot of
 * a `CYLTagButton` with it, and the display priority (the animation once loaded; the static image while it loads and
 * after it fails; the placeholder only without a static image), the failure fallbacks and the debug warning for a type
 * nobody registered are the component's.
 *
 * The library depends on no animation library. The app registers the types it plays with
 * `CYLAnimatedItemEngines.register(type)` and one view builder with `CYLTagAnimationBuilder.register(builder)`; the
 * builder gets a `CYLTagAnimationContext` and calls `ready(player)` once its view plays (or `onFailed()`), so that the
 * tag can drive the player (play, speed, loop, resting progress, the last frame while selected).
 */
import { CYLAnimatedItemAnimationContext, CYLAnimatedItemView } from 'cylanimateditem';
import { CYLAnimationPlayer, CYLAnimationSource } from './CYLAnimationPlayer';
import { CYLImage, CYLImageIsSymbol } from '../core/CYLTypes';

/**
 * What the app's animation builder gets for a tag's icon: `CYLAnimatedItemView`'s context (`url`, `size`,
 * `selected`, `onLoaded`, `onFailed`) plus the parsed value, the icon's width and height and the tag's player hook.
 */
export class CYLTagAnimationContext extends CYLAnimatedItemAnimationContext {
  /**
   * The value parsed: the rawfile path, its options and its type.
   */
  source: CYLAnimationSource = new CYLAnimationSource();
  /**
   * The icon's width in vp (the tag's animation size).
   */
  width: number = 0;
  /**
   * The icon's height in vp (the tag's animation size).
   */
  height: number = 0;
  /**
   * Gives the tag its player (`CYLTagButton.animationView`), or undefined when the view goes away.
   */
  onPlayer: (player: CYLAnimationPlayer | undefined) => void = () => {
  };

  /**
   * The view plays: hands `player` to the tag and shows the animation over the static image.
   */
  ready(player: CYLAnimationPlayer): void {
    this.onPlayer(player);
    this.onLoaded();
  }
}

/**
 * The builder that draws nothing: the default until the app registers one.
 */
@Builder
function cylNoTagAnimation(context: CYLTagAnimationContext) {
}

let cylTagAnimationBuilder: WrappedBuilder<[CYLTagAnimationContext]> = wrapBuilder(cylNoTagAnimation);

/**
 * The app's animation views for every tag (`CYLAnimatedItemView.animationBuilder`), registered once, as the engines
 * are registered with `CYLAnimatedItemEngines.register(type)`: tags sit deep inside the library's views, so the builder
 * is registered instead of being passed down through each of them.
 */
export class CYLTagAnimationBuilder {
  /**
   * Registers the builder that draws an animation view for a `CYLTagAnimationContext`
   * (`CYLTagAnimationBuilder.register(wrapBuilder(myAnimationView))`, `myAnimationView` a global `@Builder`).
   */
  static register(builder: WrappedBuilder<[CYLTagAnimationContext]>): void {
    cylTagAnimationBuilder = builder;
  }

  /**
   * The registered builder, or one that draws nothing.
   */
  static get current(): WrappedBuilder<[CYLTagAnimationContext]> {
    return cylTagAnimationBuilder;
  }
}

/**
 * The padding `CYLAnimatedItemView` puts around its content, and its smallest height (a 44 vp touch target).
 */
const CYL_ITEM_PADDING: number = 4;
const CYL_ITEM_MINIMUM_HEIGHT: number = 44;

/**
 * The width of a `CYLTagAnimatedIcon` drawing an icon of `width` x `height` (0: `width`): its square side plus the
 * component's padding. A parent centers it on the icon's frame.
 */
export function cylTagAnimatedIconOuterWidth(width: number, height: number): number {
  return Math.max(width, height > 0 ? height : width) + 2 * CYL_ITEM_PADDING;
}

/**
 * The height of a `CYLTagAnimatedIcon` drawing an icon of `width` x `height` (0: `width`): its square side plus the
 * component's padding, at least the component's 44 vp minimum height. A parent centers it on the icon's frame.
 */
export function cylTagAnimatedIconOuterHeight(width: number, height: number): number {
  return Math.max(CYL_ITEM_MINIMUM_HEIGHT, cylTagAnimatedIconOuterWidth(width, height));
}

/**
 * An image `CYLAnimatedItemView` can draw as the static image of `CYLTagAnimatedIcon`: a resource or a path; '' for a
 * pixel map or a system symbol, which it cannot draw (the placeholder shows instead while the animation loads).
 */
export function cylTagAnimationImage(image: CYLImage | undefined): ResourceStr {
  if (image === undefined || CYLImageIsSymbol(image)) {
    return '';
  }
  if (typeof image === 'string') {
    return image as string;
  }
  const resource = image as Resource;
  return resource.bundleName !== undefined ? resource : '';
}

/**
 * The animated icon of a tag: a `CYLAnimatedItemView` with no title. Its outer size is
 * `cylTagAnimatedIconOuterWidth` x `cylTagAnimatedIconOuterHeight` (the component's padding and 44 vp minimum height
 * around the icon), so the parent places it centered on the icon's frame; the tag clips the transparent rest. It takes
 * no touches (it is disabled, so the tag's tap, long press and drag work over the icon; a tap that still reaches it
 * calls `onTap`) and is hidden from screen readers (the tag is one element).
 */
@Component
export struct CYLTagAnimatedIcon {
  /**
   * `asset:<rawfile>` with its options after `#`.
   */
  @Prop animationURL: string = '';
  /**
   * The static image under the animation while it loads and after it fails (`cylTagAnimationImage(image)`).
   */
  @Prop image: ResourceStr = '';
  /**
   * The static image while selected; '' keeps `image`.
   */
  @Prop selectedImage: ResourceStr = '';
  @Prop isSelected: boolean = false;
  @Prop iconWidth: number = 0;
  /**
   * 0: `iconWidth`.
   */
  @Prop iconHeight: number = 0;
  /**
   * The player once the view plays, undefined when it goes away.
   */
  onPlayer?: (player: CYLAnimationPlayer | undefined) => void;
  /**
   * A tap on the icon (the tag's own tap).
   */
  onTap?: () => void;
  /**
   * The app's animation views (`CYLTagAnimationBuilder.register`), read when the icon is made.
   */
  private animationViews: WrappedBuilder<[CYLTagAnimationContext]> = CYLTagAnimationBuilder.current;

  /**
   * The icon's side in `CYLAnimatedItemView`, which draws a square icon: the larger of the two sides.
   */
  side(): number {
    return Math.max(this.iconWidth, this.resolvedHeight());
  }

  resolvedHeight(): number {
    return this.iconHeight > 0 ? this.iconHeight : this.iconWidth;
  }

  outerWidth(): number {
    return cylTagAnimatedIconOuterWidth(this.iconWidth, this.iconHeight);
  }

  outerHeight(): number {
    return cylTagAnimatedIconOuterHeight(this.iconWidth, this.iconHeight);
  }

  /**
   * The tag's context for the component's context: the same callbacks, plus the value, the sizes and the player hook.
   */
  tagContext(context: CYLAnimatedItemAnimationContext): CYLTagAnimationContext {
    const tagContext = new CYLTagAnimationContext();
    tagContext.url = context.url;
    tagContext.size = context.size;
    tagContext.selected = context.selected;
    tagContext.onLoaded = context.onLoaded;
    tagContext.onFailed = context.onFailed;
    tagContext.source = CYLAnimationSource.parse(context.url);
    tagContext.width = this.iconWidth;
    tagContext.height = this.resolvedHeight();
    tagContext.onPlayer = (player: CYLAnimationPlayer | undefined) => this.onPlayer?.(player);
    return tagContext;
  }

  @Builder
  tagAnimation(context: CYLAnimatedItemAnimationContext) {
    Stack() {
      this.animationViews.builder(this.tagContext(context))
    }
    .width(this.side())
    .height(this.side())
    .accessibilityLevel('no')
  }

  build() {
    Stack() {
      CYLAnimatedItemView({
        animationUrl: this.animationURL,
        image: this.image,
        selectedImage: this.selectedImage,
        isItemSelected: this.isSelected,
        iconSize: this.side(),
        spacing: 0,
        animationBuilder: (context: CYLAnimatedItemAnimationContext): void => {
          this.tagAnimation(context)
        },
        onItemTap: () => this.onTap?.()
      })
    }
    .width(this.outerWidth())
    .height(this.outerHeight())
    .enabled(false)
    .accessibilityLevel('no-hide-descendants')
  }
}

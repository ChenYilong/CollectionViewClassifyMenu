/**
 * A tag's animated icon on CYLTabBarController's shared icon + title component, `CYLAnimatedItemView` (module
 * `cylanimateditem`, vendored at commit fe5c3ae in `harmony/cylanimateditem`). ArkTS structs cannot subclass, so the
 * tag wraps the component instead of subclassing it as iOS and Android do: `CYLTagAnimatedIcon` draws the icon slot of
 * a `CYLTagButton` with it, and the display priority (the animation once loaded; the static image while it loads and
 * after it fails; the placeholder only without a static image), the failure fallbacks and the debug warning for a type
 * nobody registered are the component's.
 *
 * The library depends on no animation library. The app registers the types it plays with
 * `CYLAnimatedItemEngines.register(type)` and one view builder with `CYLTagAnimationBuilder.register(builder)`; the
 * builder gets a `CYLTagAnimationContext` and calls `ready(player)` once its view plays (or `onFailed()`), so that the
 * tag can drive the player (play, speed, loop, resting progress, the last frame while selected).
 *
 * A type whose engine module ships a builder for `CYLAnimatedItemView` itself (CYLTabBarController's
 * `CYLRiveAnimationBuilder` in `cylanimateditemrive`) needs no app view: the app registers that builder with
 * `CYLTagAnimationBuilder.registerItemBuilder(CYLAnimationEngine.RIVE, wrapBuilder(CYLRiveAnimationBuilder))`, the
 * icon hands it the component's context with the file as a rawfile path, and the tag passes its playback straight to
 * the component's `animationSpeed`, `animationLoops` and `animationRestartToken` props. The library still imports no
 * engine module.
 */
import {
  CYLAnimatedItemAnimationContext, CYLAnimatedItemEngineViews, CYLAnimatedItemPlayer, CYLAnimatedItemSource, CYLAnimatedItemView
} from 'cylanimateditem';
import {
  CYLAnimatedItemPlayerAdapter, CYLAnimationEngine, CYLAnimationPlayer, CYLAnimationSource, cylAnimationEngine
} from './CYLAnimationPlayer';
import { CYLImage, CYLImageIsSymbol } from '../core/CYLTypes';
import { CYLUIContext } from '../core/CYLUIContext';

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

const cylTagItemBuilders: Map<CYLAnimationEngine, WrappedBuilder<[CYLAnimatedItemAnimationContext]>> =
  new Map<CYLAnimationEngine, WrappedBuilder<[CYLAnimatedItemAnimationContext]>>();

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

  /**
   * Registers a builder for `CYLAnimatedItemView` itself that plays every file of `engine`, instead of the app's tag
   * builder: for Rive, `registerItemBuilder(CYLAnimationEngine.RIVE, wrapBuilder(CYLRiveAnimationBuilder))` with
   * CYLTabBarController's `cylanimateditemrive` (register the type too, with `cylRegisterRiveEngine(context)`). It gets the
   * component's context (`url` a rawfile path with the options after `#`, `size`, `selected`, `loops`, `restartToken`,
   * `onLoaded`, `onFailed`, `onEnded`, `setRestartHandler`); the tag passes its playback to the component's own props.
   */
  static registerItemBuilder(engine: CYLAnimationEngine, builder: WrappedBuilder<[CYLAnimatedItemAnimationContext]>): void {
    cylTagItemBuilders.set(engine, builder);
  }

  /**
   * The component-level builder registered for `engine`, if any.
   */
  static itemBuilder(engine: CYLAnimationEngine): WrappedBuilder<[CYLAnimatedItemAnimationContext]> | undefined {
    return cylTagItemBuilders.get(engine);
  }
}

/**
 * The URL a component-level builder gets for a tag's value: `asset:<rawfile>#options` becomes `<rawfile>#options`, with
 * the rawfile that exists (`path`, else its last component, as `CYLAnimationSource.existingRawFilePath`).
 */
export function cylTagItemBuilderURL(source: CYLAnimationSource, existingPath: string): string {
  const pairs: string[] = [];
  source.options.forEach((value: string, key: string) => {
    pairs.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`);
  });
  return pairs.length === 0 ? existingPath : `${existingPath}#${pairs.join('&')}`;
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
 * pixel map, which it cannot draw (the placeholder shows instead while the animation loads). A system symbol is returned as
 * its resource: the item draws it as a `SymbolGlyph`.
 */
export function cylTagAnimationImage(image: CYLImage | undefined): ResourceStr {
  if (image === undefined) {
    return '';
  }
  if (CYLImageIsSymbol(image)) {
    // A system symbol: the item draws it as a `SymbolGlyph` in its icon colour (`CYLAnimatedItemView.cylFallbackImage`), like the static path.
    return image as Resource;
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
  /**
   * The tag's icon colour CHANNELS (the item's subclass-explicit and subclass built-in levels, never the integrator-owned
   * `iconColor`): the explicit colour tints the static image and the animation (the tag's `animationIconColor`); '' keeps the
   * image's own colors. The item resolves and adapts them on dark glass.
   */
  @Prop subclassIconColor: ResourceColor = '';
  @Prop subclassSelectedIconColor: ResourceColor = '';
  @Prop builtInIconColor: ResourceColor = '';
  @Prop builtInSelectedIconColor: ResourceColor = '';
  /**
   * The playback speed passed to `CYLAnimatedItemView.animationSpeed` for a file drawn by a component-level builder.
   */
  @Prop animationSpeed: number = 1;
  /**
   * Whether a file drawn by a component-level builder repeats (`CYLAnimatedItemView.animationLoops`).
   */
  @Prop animationLoops: boolean = false;
  /**
   * Bumped to replay a file drawn by a component-level builder from progress 0
   * (`CYLAnimatedItemView.animationRestartToken`).
   */
  @Prop animationRestartToken: number = 0;
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
   * A file drawn by a component-level builder has loaded.
   */
  onItemLoaded?: () => void;
  /**
   * The app's animation views (`CYLTagAnimationBuilder.register`), read when the icon is made.
   */
  private animationViews: WrappedBuilder<[CYLTagAnimationContext]> = CYLTagAnimationBuilder.current;
  /**
   * The component-level builder for this file's type (`CYLTagAnimationBuilder.registerItemBuilder`), read when the icon
   * is made; undefined: the app's tag builder draws it.
   */
  private itemBuilder?: WrappedBuilder<[CYLAnimatedItemAnimationContext]>;
  private itemURL: string = '';

  aboutToAppear(): void {
    const source = CYLAnimationSource.parse(this.animationURL);
    if (source.inlineJSON !== undefined) {
      return;
    }
    this.itemBuilder = CYLTagAnimationBuilder.itemBuilder(cylAnimationEngine(source.path));
    if (this.itemBuilder === undefined) {
      return;
    }
    let existing = source.path;
    try {
      existing = source.existingRawFilePath(CYLUIContext.hostContext(this.getUIContext()));
    } catch (e) {
      // No host context (a host test): keep the path as written.
    }
    this.itemURL = cylTagItemBuilderURL(source, existing);
  }

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

  /**
   * The component's context for `itemBuilder`: the same values, telling the tag when the file has loaded.
   */
  itemContext(context: CYLAnimatedItemAnimationContext): CYLAnimatedItemAnimationContext {
    const itemContext = new CYLAnimatedItemAnimationContext();
    itemContext.url = context.url;
    itemContext.size = context.size;
    itemContext.selected = context.selected;
    itemContext.speed = context.speed;
    itemContext.loops = context.loops;
    itemContext.restartToken = context.restartToken;
    itemContext.onFailed = context.onFailed;
    itemContext.setRestartHandler = context.setRestartHandler;
    itemContext.onLoaded = () => {
      context.onLoaded();
      this.onItemLoaded?.();
    };
    itemContext.onEnded = () => {
      context.onEnded();
    };
    return itemContext;
  }

  @Builder
  tagAnimation(context: CYLAnimatedItemAnimationContext) {
    Stack() {
      if (this.itemBuilder !== undefined) {
        this.itemBuilder.builder(this.itemContext(context))
      } else {
        this.animationViews.builder(this.tagContext(context))
      }
    }
    .width(this.side())
    .height(this.side())
    .accessibilityLevel('no')
  }

  /**
   * Whether CYLTabBarController's component plays this icon itself: an engine registered a view for its type
   * (`CYLAnimatedItemGIF.register()`, `CYLAnimatedItemLottie.register()`, `CYLAnimatedItemPAG.register()`, ...). The tag
   * still drives the player (`drivesAnimationPlayback` false); other types keep the app's builder
   * (`CYLTagAnimationBuilder`). A type with a component-level builder (`registerItemBuilder`, e.g. Rive) is not played by
   * an engine view: its item builder comes first.
   */
  usesEngineView(): boolean {
    if (this.itemBuilder !== undefined) {
      return false;
    }
    return CYLAnimatedItemEngineViews.hasView(CYLAnimatedItemSource.parse(this.animationURL).type);
  }

  build() {
    Stack() {
      if (this.usesEngineView()) {
        CYLAnimatedItemView({
          animationUrl: this.animationURL,
          image: this.image,
          selectedImage: this.selectedImage,
          isItemSelected: this.isSelected,
          // A selected tag rests on the LAST frame of its animation (iOS: showsLastFrameWhenSelected = true).
          showsLastFrameWhenSelected: true,
          subclassIconColor: this.subclassIconColor,
          subclassSelectedIconColor: this.subclassSelectedIconColor,
          builtInIconColor: this.builtInIconColor,
          builtInSelectedIconColor: this.builtInSelectedIconColor,
          iconSize: this.side(),
          spacing: 0,
          drivesAnimationPlayback: false,
          onAnimationPlayer: (player: CYLAnimatedItemPlayer | undefined) => {
            this.onPlayer?.(player === undefined ? undefined : new CYLAnimatedItemPlayerAdapter(player));
          },
          onItemTap: () => this.onTap?.()
        })
      } else {
        CYLAnimatedItemView({
          animationUrl: this.itemBuilder !== undefined ? this.itemURL : this.animationURL,
          image: this.image,
          selectedImage: this.selectedImage,
          isItemSelected: this.isSelected,
          // A selected tag rests on the LAST frame of its animation (iOS: showsLastFrameWhenSelected = true).
          showsLastFrameWhenSelected: true,
          subclassIconColor: this.subclassIconColor,
          subclassSelectedIconColor: this.subclassSelectedIconColor,
          builtInIconColor: this.builtInIconColor,
          builtInSelectedIconColor: this.builtInSelectedIconColor,
          iconSize: this.side(),
          spacing: 0,
          animationSpeed: this.itemBuilder !== undefined ? this.animationSpeed : 1,
          animationLoops: this.itemBuilder !== undefined ? this.animationLoops : false,
          animationRestartToken: this.itemBuilder !== undefined ? this.animationRestartToken : 0,
          animationBuilder: (context: CYLAnimatedItemAnimationContext): void => {
            this.tagAnimation(context)
          },
          onItemTap: () => this.onTap?.()
        })
      }
    }
    .width(this.outerWidth())
    .height(this.outerHeight())
    .enabled(false)
    .accessibilityLevel('no-hide-descendants')
  }
}

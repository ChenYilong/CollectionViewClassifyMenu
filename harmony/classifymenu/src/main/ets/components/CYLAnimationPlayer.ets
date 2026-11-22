/**
 * The engine-free side of a tag's animated icon: the animation value (`CYLAnimationSource`), its type by extension
 * (`CYLAnimationEngine`, `cylAnimationEngine`) and the handle a tag drives (`CYLAnimationPlayer`: play from the start,
 * stop at a progress, speed, loop). The library depends on no animation library: the icon is CYLTabBarController's
 * `CYLAnimatedItemView` (`CYLTagAnimatedIcon`), and the app supplies the views and players that play each type (the
 * example's `CYLLottiePlayer`, `CYLPAGPlayer`, `CYLRivePlayer`, `CYLGIFPlayer` and `CYLSVGAPlayer`), registered with
 * `CYLAnimatedItemEngines.register(type)` and `CYLTagAnimationBuilder.register(builder)`.
 *
 * The value is `asset:<rawfile path>` (or Lottie JSON text); options (`cylAddingAnimationOptions`) follow `#` as
 * "name=value&...". A player that cannot do something reports it with `supportsSpeed` / `supportsLoops` /
 * `supportsProgress` and treats the call as a no-op.
 */

import { CYLAnimatedItemPlayer } from 'cylanimateditem';

/**
 * The type of an animation file, by its extension. `cylAnimatedItemTypeOf` (CYLAnimatedItemEngines) names the same
 * types "Lottie", "PAG", "Rive", "GIF" and "SVGA".
 */
export enum CYLAnimationEngine {
  LOTTIE = 'lottie',
  PAG = 'pag',
  RIVE = 'rive',
  GIF = 'gif',
  SVGA = 'svga'
}

/**
 * An animation value split into its rawfile path (or inline JSON) and its options.
 */
export class CYLAnimationSource {
  /** The rawfile path after `asset:`, or '' for inline JSON. */
  path: string = '';
  /** Inline Lottie JSON text (a value that is not `asset:`). */
  inlineJSON?: string;
  options: Map<string, string> = new Map<string, string>();
  engine: CYLAnimationEngine = CYLAnimationEngine.LOTTIE;

  static parse(value: string): CYLAnimationSource {
    const s = new CYLAnimationSource();
    const trimmed = value.trim();
    if (!trimmed.startsWith('asset:') && (trimmed.startsWith('{') || trimmed.startsWith('['))) {
      s.inlineJSON = trimmed;
      return s;
    }
    let path = trimmed.startsWith('asset:') ? trimmed.substring('asset:'.length) : trimmed;
    const hash = path.indexOf('#');
    if (hash >= 0) {
      path.substring(hash + 1).split('&').forEach((pair: string) => {
        const eq = pair.indexOf('=');
        if (eq > 0) {
          s.options.set(decodeURIComponent(pair.substring(0, eq)), decodeURIComponent(pair.substring(eq + 1)));
        }
      });
      path = path.substring(0, hash);
    }
    s.path = path;
    s.engine = cylAnimationEngine(path);
    return s;
  }

  /** The directory of `path` with a trailing '/', or ''. */
  get directory(): string {
    const slash = this.path.lastIndexOf('/');
    return slash >= 0 ? this.path.substring(0, slash + 1) : '';
  }

  /** The last path component (the Flutter and React Native examples write `asset:assets/<file>`). */
  get fileName(): string {
    return this.path.split('/').pop() ?? '';
  }

  /** The rawfile's bytes: `path`, else its last component. */
  rawFileContent(context: Context): Uint8Array | undefined {
    const candidates: string[] = this.path === this.fileName ? [this.path] : [this.path, this.fileName];
    for (const name of candidates) {
      try {
        return context.resourceManager.getRawFileContentSync(name);
      } catch (e) {
        // Try the next name.
      }
    }
    return undefined;
  }

  /** The rawfile path that exists: `path`, else its last component. */
  existingRawFilePath(context: Context): string {
    try {
      context.resourceManager.getRawFdSync(this.path);
      context.resourceManager.closeRawFdSync(this.path);
      return this.path;
    } catch (e) {
      return this.fileName;
    }
  }
}

/**
 * The engine of an animation file, by its extension (anything else: Lottie JSON).
 */
export function cylAnimationEngine(url: string): CYLAnimationEngine {
  const path = url.split('#')[0].split('?')[0].toLowerCase();
  if (path.endsWith('.pag')) {
    return CYLAnimationEngine.PAG;
  }
  if (path.endsWith('.riv')) {
    return CYLAnimationEngine.RIVE;
  }
  if (path.endsWith('.gif')) {
    return CYLAnimationEngine.GIF;
  }
  if (path.endsWith('.svga')) {
    return CYLAnimationEngine.SVGA;
  }
  return CYLAnimationEngine.LOTTIE;
}

/**
 * `CYLTagButton.animationView` on HarmonyOS: the live player of an animated icon, a handle to the engine's view or
 * controller. The base class plays nothing; the app's engine views subclass it (the example's `CYLLottiePlayer`
 * exposes `lottieItem`, `CYLPAGPlayer` `pagController`, `CYLGIFPlayer` `gifFrames`,
 * `CYLSVGAPlayer` `svgaMovie`) and hand it to the tag with `CYLTagAnimationContext.ready(player)`.
 */
export class CYLAnimationPlayer {
  readonly engine: CYLAnimationEngine;
  readonly source: CYLAnimationSource;
  protected speedValue: number = 1;
  protected loopsValue: boolean = false;

  constructor(engine: CYLAnimationEngine, source: CYLAnimationSource) {
    this.engine = engine;
    this.source = source;
  }

  get supportsSpeed(): boolean {
    return true;
  }

  get supportsLoops(): boolean {
    return true;
  }

  get supportsProgress(): boolean {
    return true;
  }

  get speed(): number {
    return this.speedValue;
  }

  /** Applied at once, also while playing. */
  set speed(value: number) {
    this.speedValue = value > 0 ? value : 1;
    this.applySpeed();
  }

  get loops(): boolean {
    return this.loopsValue;
  }

  /** Applied at once: turning it off lets the pass in progress finish. */
  set loops(value: boolean) {
    this.loopsValue = value;
    this.applyLoops();
  }

  get isPlaying(): boolean {
    return false;
  }

  /** The progress (0...1), or undefined when the engine has none. */
  get progress(): number | undefined {
    return undefined;
  }

  /** Plays from progress 0. */
  play(): void {
  }

  /** Stops at `progress` (0...1): the resting progress, or 1 (the last frame) while selected. */
  stopAtProgress(progress: number): void {
  }

  /** Releases the engine's resources. */
  destroy(): void {
  }

  protected applySpeed(): void {
  }

  protected applyLoops(): void {
  }
}

/**
 * The `CYLAnimationPlayer` of an icon played by CYLTabBarController's engine views (`CYLAnimatedItemView`'s default engine
 * view: GIF and SVGA in `cylanimateditem`, Lottie, PAG and Rive in `cylanimateditem_lottie` / `_pag` / `_rive`): it hands
 * every call to the component's `CYLAnimatedItemPlayer` (`itemPlayer`), so `CYLTagButton.animationView` keeps its type.
 * The engine view owns the player's lifetime: `destroy()` does nothing here.
 */
export class CYLAnimatedItemPlayerAdapter extends CYLAnimationPlayer {
  /**
   * The component's player (`CYLAnimatedItemLottiePlayer` exposes `lottieItem`, `CYLAnimatedItemPAGPlayer` `pagController`,
   * `CYLAnimatedItemGIFPlayer` `gifFrames`, ...).
   */
  readonly itemPlayer: CYLAnimatedItemPlayer;

  constructor(player: CYLAnimatedItemPlayer) {
    super(cylAnimationEngine(player.source.path), CYLAnimationSource.parse(player.source.url));
    this.itemPlayer = player;
    this.speedValue = player.speed;
    this.loopsValue = player.loops;
  }

  get supportsSpeed(): boolean {
    return this.itemPlayer.supportsSpeed;
  }

  get supportsLoops(): boolean {
    return this.itemPlayer.supportsLoops;
  }

  get supportsProgress(): boolean {
    return this.itemPlayer.supportsProgress;
  }

  get isPlaying(): boolean {
    return this.itemPlayer.isPlaying;
  }

  get progress(): number | undefined {
    return this.itemPlayer.progress;
  }

  play(): void {
    this.itemPlayer.play();
  }

  stopAtProgress(progress: number): void {
    this.itemPlayer.stopAtProgress(progress);
  }

  destroy(): void {
  }

  protected applySpeed(): void {
    this.itemPlayer.speed = this.speedValue;
  }

  protected applyLoops(): void {
    this.itemPlayer.loops = this.loopsValue;
  }
}

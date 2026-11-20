/**
 * The animation engine of this React Native for OpenHarmony shell. The core (`@cyl/classifymenu`) draws tag icons with
 * CYLTabBarController's `CYLAnimatedItemView` and depends on no animation library; each app registers the engines it
 * ships. The shell's tags play Lottie (the `tab_*.json` rawfiles), so it registers Lottie only, with the player and the
 * view of `harmony/entry`'s `CYLExampleAnimationPlayers.ets` / `CYLExampleAnimationViews.ets` (@ohos/lottie).
 */
import lottie, { AnimationItem } from '@ohos/lottie';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import {
  CYLAnimatedItemEngines, CYLAnimationEngine, CYLAnimationPlayer, CYLAnimationSource, CYLTagAnimationBuilder,
  CYLTagAnimationContext, CYLUIContext
} from '@cyl/classifymenu';

/** Lottie: `AnimationItem`. */
class CYLLottiePlayer extends CYLAnimationPlayer {
  readonly lottieItem: AnimationItem;
  /** The progress asked for before the animation finished loading, applied once it has. */
  private pendingProgress?: number;

  constructor(source: CYLAnimationSource, item: AnimationItem) {
    super(CYLAnimationEngine.LOTTIE, source);
    this.lottieItem = item;
    item.addEventListener('DOMLoaded', () => {
      const progress = this.pendingProgress;
      this.pendingProgress = undefined;
      if (progress !== undefined && this.lottieItem.isPaused) {
        this.stopAtProgress(progress);
      }
    });
  }

  get isPlaying(): boolean {
    return !this.lottieItem.isPaused;
  }

  get progress(): number | undefined {
    const last = Math.max(1, this.lottieItem.totalFrames - 1);
    return Math.min(1, Math.max(0, this.lottieItem.currentFrame / last));
  }

  play(): void {
    this.pendingProgress = undefined;
    this.lottieItem.loop = this.loopsValue;
    this.lottieItem.setSpeed(this.speedValue);
    this.lottieItem.goToAndPlay(0, true);
  }

  stopAtProgress(progress: number): void {
    if (this.lottieItem.totalFrames <= 0) {
      this.pendingProgress = progress;
      return;
    }
    const last = Math.max(0, this.lottieItem.totalFrames - 1);
    this.lottieItem.goToAndStop(Math.min(1, Math.max(0, progress)) * last, true);
  }

  destroy(): void {
    this.lottieItem.destroy();
  }

  protected applySpeed(): void {
    this.lottieItem.setSpeed(this.speedValue);
  }

  protected applyLoops(): void {
    this.lottieItem.loop = this.loopsValue;
  }
}

function lottieData(context: Context, source: CYLAnimationSource): Object | undefined {
  try {
    if (source.inlineJSON !== undefined) {
      return JSON.parse(source.inlineJSON) as Object;
    }
    const bytes = source.rawFileContent(context);
    if (bytes === undefined) {
      return undefined;
    }
    return JSON.parse(util.TextDecoder.create('utf-8').decodeToString(bytes)) as Object;
  } catch (e) {
    return undefined;
  }
}

/** Lottie on a canvas; image assets are rawfiles next to the JSON file, or at the rawfile root. */
@Component
struct CYLRNLottieIconView {
  animationContext: CYLTagAnimationContext = new CYLTagAnimationContext();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private player?: CYLLottiePlayer;

  private load(): void {
    const context = CYLUIContext.hostContext(this.getUIContext());
    const source = this.animationContext.source;
    const data = lottieData(context, source);
    if (data === undefined) {
      this.animationContext.onFailed();
      return;
    }
    const directory = source.directory;
    const item: AnimationItem = lottie.loadAnimation({
      container: this.context2D,
      renderer: 'canvas',
      loop: false,
      autoplay: false,
      animationData: data,
      imageAssetDelegate: (imagePath: string, callback: (err: BusinessError, data: image.PixelMap) => void) => {
        const name = imagePath.split('/').pop() ?? imagePath;
        for (const candidate of [directory + imagePath, directory + name, name]) {
          try {
            const bytes = context.resourceManager.getRawFileContentSync(candidate);
            const imageSource = image.createImageSource(bytes.buffer as ArrayBuffer);
            imageSource.createPixelMap().then((pixelMap: image.PixelMap) => {
              imageSource.release();
              callback(new Error() as BusinessError, pixelMap);
            });
            return;
          } catch (e) {
            // Try the next location.
          }
        }
      }
    });
    this.player = new CYLLottiePlayer(source, item);
    this.animationContext.ready(this.player);
  }

  aboutToDisappear(): void {
    const player = this.player;
    this.player = undefined;
    if (player !== undefined) {
      this.animationContext.onPlayer(undefined);
      player.destroy();
    }
  }

  build() {
    Canvas(this.context2D)
      .width(this.animationContext.width)
      .height(this.animationContext.height)
      .accessibilityLevel('no')
      .onReady(() => this.load())
  }
}

@Builder
function cylRNAnimationBuilder(context: CYLTagAnimationContext) {
  CYLRNLottieIconView({ animationContext: context })
}

const CYL_RN_ANIMATION_BUILDER: WrappedBuilder<[CYLTagAnimationContext]> = wrapBuilder(cylRNAnimationBuilder);

/** Registers Lottie with `CYLAnimatedItemEngines` and its view with the core; once, before any tag is shown. */
export function cylRegisterRNAnimationEngines(): void {
  CYLAnimatedItemEngines.register('Lottie');
  CYLTagAnimationBuilder.register(CYL_RN_ANIMATION_BUILDER);
}

import { CYLUIContext } from '../core/CYLUIContext';
/**
 * The animated icon of a tag (iOS: the view of `CYLTabBarItemAnimationFactory`): the engine is chosen by the file's
 * extension (`CYLAnimationEngine`). The icon applies `speed` and `loops` at once, also while playing, plays from
 * progress 0 when `playToken` changes (`CYLTagListController.playAll()`, a tap), and otherwise rests on the last frame
 * while `selected`, or on `restingProgress`. Engine limits: `CYLAnimationPlayer`.
 */
import lottie, { AnimationItem } from '@ohos/lottie';
import { PAGFile, PAGView, PAGViewController } from '@tencent/libpag';
import { initializeRive, RiveAnimationView } from '@ohos/rive';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import {
  CYLAnimationEngine, CYLAnimationPlayer, CYLAnimationSource, CYLGIFPlayer, CYLLottiePlayer, CYLPAGPlayer,
  CYLRivePlayer
} from './CYLAnimationPlayer';

let riveInitialized: boolean = false;

function ensureRive(): boolean {
  if (!riveInitialized) {
    try {
      initializeRive();
      riveInitialized = true;
    } catch (e) {
      return false;
    }
  }
  return true;
}

/** The Lottie JSON of a source. */
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

/** Lottie: a canvas. Image assets (`u` + `p`) are rawfiles next to the JSON file, or at the rawfile root. */
@Component
struct CYLLottieIconView {
  source: CYLAnimationSource = new CYLAnimationSource();
  @Prop iconWidth: number = 0;
  @Prop iconHeight: number = 0;
  onPlayer?: (player: CYLAnimationPlayer) => void;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private load(): void {
    const context = CYLUIContext.hostContext(this.getUIContext());
    const data = lottieData(context, this.source);
    if (data === undefined) {
      return;
    }
    const directory = this.source.directory;
    const item: AnimationItem = lottie.loadAnimation({
      container: this.context2D,
      renderer: 'canvas',
      loop: false,
      autoplay: false,
      animationData: data,
      imageAssetDelegate: (imagePath: string, callback: (err: BusinessError, data: image.PixelMap) => void) => {
        const name = imagePath.split('/').pop() ?? imagePath;
        const candidates: string[] = [directory + imagePath, directory + name, name];
        for (const candidate of candidates) {
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
    this.onPlayer?.(new CYLLottiePlayer(this.source, item));
  }

  build() {
    Canvas(this.context2D)
      .width(this.iconWidth)
      .height(this.iconHeight)
      .accessibilityLevel('no')
      .onReady(() => this.load())
  }
}

/** PAG: libpag's `PAGView`. */
@Component
struct CYLPAGIconView {
  source: CYLAnimationSource = new CYLAnimationSource();
  @Prop iconWidth: number = 0;
  @Prop iconHeight: number = 0;
  onPlayer?: (player: CYLAnimationPlayer) => void;
  @State controller: PAGViewController = new PAGViewController();

  aboutToAppear(): void {
    const context = CYLUIContext.hostContext(this.getUIContext());
    const file = PAGFile.LoadFromAssets(context.resourceManager, this.source.existingRawFilePath(context));
    if (file === null) {
      return;
    }
    this.controller.setComposition(file);
    this.onPlayer?.(new CYLPAGPlayer(this.source, this.controller));
  }

  build() {
    Stack() {
      PAGView({ controller: this.controller })
    }
    .width(this.iconWidth)
    .height(this.iconHeight)
    .accessibilityLevel('no')
  }
}

/** Rive: @ohos/rive's `RiveAnimationView`, with the item's artboard, state machine or animation. */
@Component
struct CYLRiveIconView {
  source: CYLAnimationSource = new CYLAnimationSource();
  @Prop iconWidth: number = 0;
  @Prop iconHeight: number = 0;
  onPlayer?: (player: CYLAnimationPlayer) => void;
  private available: boolean = ensureRive();

  build() {
    Stack() {
      if (this.available) {
        RiveAnimationView({
          riveResource: `@rawfile/${this.source.existingRawFilePath(CYLUIContext.hostContext(this.getUIContext()))}`,
          riveArtboard: this.source.options.get('artboard') ?? '',
          riveStateMachine: this.source.options.get('stateMachine') ?? '',
          riveAnimation: this.source.options.get('animation') ?? '',
          riveAutoPlay: false,
          riveFit: 'contain',
          touchPassThrough: true,
          onReady: (view: RiveAnimationView) => {
            this.onPlayer?.(new CYLRivePlayer(this.source, view));
          }
        })
      }
    }
    .width(this.iconWidth)
    .height(this.iconHeight)
    .hitTestBehavior(HitTestMode.None)
    .accessibilityLevel('no')
  }
}

/** GIF: the frames ImageKit decodes, shown by the player. */
@Component
struct CYLGIFIconView {
  source: CYLAnimationSource = new CYLAnimationSource();
  @Prop iconWidth: number = 0;
  @Prop iconHeight: number = 0;
  onPlayer?: (player: CYLAnimationPlayer) => void;
  @State frame: image.PixelMap | undefined = undefined;

  aboutToAppear(): void {
    const bytes = this.source.rawFileContent(CYLUIContext.hostContext(this.getUIContext()));
    if (bytes === undefined) {
      return;
    }
    const imageSource = image.createImageSource(bytes.buffer as ArrayBuffer);
    imageSource.getDelayTimeList().then((delays: number[]) => {
      imageSource.createPixelMapList().then((frames: image.PixelMap[]) => {
        imageSource.release();
        const player = new CYLGIFPlayer(this.source, frames, delays);
        player.onFrame = (f: image.PixelMap) => {
          this.frame = f;
        };
        this.frame = frames.length > 0 ? frames[0] : undefined;
        this.onPlayer?.(player);
      });
    }).catch(() => {
      imageSource.release();
    });
  }

  build() {
    Stack() {
      if (this.frame !== undefined) {
        Image(this.frame)
          .width(this.iconWidth)
          .height(this.iconHeight)
          .objectFit(ImageFit.Contain)
      }
    }
    .width(this.iconWidth)
    .height(this.iconHeight)
    .accessibilityLevel('no')
  }
}

@Component
export struct CYLAnimatedIcon {
  @Prop source: string = '';
  @Prop iconSize: number = 18;
  /** 0: `iconSize`. */
  @Prop iconHeight: number = 0;
  @Prop @Watch('applySpeed') speed: number = 1;
  @Prop @Watch('applyLoops') loops: boolean = false;
  @Prop @Watch('replay') playToken: number = 0;
  @Prop @Watch('applyRestingState') selected: boolean = false;
  @Prop @Watch('applyRestingState') restingProgress: number = 0;
  /** Plays once loaded (the icon was made for a tap); otherwise it rests. */
  autoplay: boolean = false;
  /** The player once loaded (`CYLTagButton.animationView`), undefined when the icon goes away. */
  onPlayer?: (player: CYLAnimationPlayer | undefined) => void;
  private parsed: CYLAnimationSource = new CYLAnimationSource();
  private player?: CYLAnimationPlayer;

  aboutToAppear(): void {
    this.parsed = CYLAnimationSource.parse(this.source);
  }

  aboutToDisappear(): void {
    const player = this.player;
    this.player = undefined;
    if (player !== undefined) {
      this.onPlayer?.(undefined);
      player.destroy();
    }
  }

  private ready(player: CYLAnimationPlayer): void {
    this.player = player;
    player.speed = this.speed;
    player.loops = this.loops;
    if (this.autoplay) {
      player.play();
    } else {
      this.applyRestingState();
    }
    this.onPlayer?.(player);
  }

  private applySpeed(): void {
    if (this.player !== undefined) {
      this.player.speed = this.speed;
    }
  }

  private applyLoops(): void {
    if (this.player !== undefined) {
      this.player.loops = this.loops;
    }
  }

  private replay(): void {
    this.player?.play();
  }

  /** Selected: the last frame; otherwise the resting progress (not while playing). */
  private applyRestingState(): void {
    const player = this.player;
    if (player === undefined || player.isPlaying) {
      return;
    }
    player.stopAtProgress(this.selected ? 1 : Math.min(1, Math.max(0, this.restingProgress)));
  }

  build() {
    Stack() {
      if (this.parsed.engine === CYLAnimationEngine.PAG) {
        CYLPAGIconView({
          source: this.parsed, iconWidth: this.iconSize, iconHeight: this.resolvedHeight(),
          onPlayer: (p: CYLAnimationPlayer) => this.ready(p)
        })
      } else if (this.parsed.engine === CYLAnimationEngine.RIVE) {
        CYLRiveIconView({
          source: this.parsed, iconWidth: this.iconSize, iconHeight: this.resolvedHeight(),
          onPlayer: (p: CYLAnimationPlayer) => this.ready(p)
        })
      } else if (this.parsed.engine === CYLAnimationEngine.GIF) {
        CYLGIFIconView({
          source: this.parsed, iconWidth: this.iconSize, iconHeight: this.resolvedHeight(),
          onPlayer: (p: CYLAnimationPlayer) => this.ready(p)
        })
      } else {
        CYLLottieIconView({
          source: this.parsed, iconWidth: this.iconSize, iconHeight: this.resolvedHeight(),
          onPlayer: (p: CYLAnimationPlayer) => this.ready(p)
        })
      }
    }
    .width(this.iconSize)
    .height(this.resolvedHeight())
    .accessibilityLevel('no')
  }

  private resolvedHeight(): number {
    return this.iconHeight > 0 ? this.iconHeight : this.iconSize;
  }
}

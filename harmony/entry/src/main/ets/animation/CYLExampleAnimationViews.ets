/**
 * The example's animation views (moved here from the library, which depends on no animation library): the app side
 * of CYLTabBarController's `CYLAnimatedItemView`. `cylRegisterExampleAnimationEngines()` registers the types the
 * example plays (`CYLAnimatedItemEngines.register('Lottie')`, 'PAG', 'Rive', 'SVGA', 'GIF') and the builder that draws
 * them (`CYLTagAnimationBuilder.register`); every tag's animated icon then shows `CYLExampleAnimationView`, which picks
 * the engine by the file's extension, hands its player to the tag (`CYLTagAnimationContext.ready`) once it plays, and
 * calls `onFailed()` when the file cannot play, so the component shows the static image or the placeholder again.
 */
import lottie, { AnimationItem } from '@ohos/lottie';
import { PAGFile, PAGView, PAGViewController } from '@tencent/libpag';
import { CYLRiveAnimationBuilder, cylRegisterRiveEngine } from 'cylanimateditemrive';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import {
  CYLAnimatedItemEngines, CYLAnimationEngine, CYLAnimationPlayer, CYLAnimationSource, CYLTagAnimationBuilder,
  CYLTagAnimationContext, CYLUIContext
} from '@cyl/classifymenu';
import {
  CYLGIFPlayer, CYLLottiePlayer, CYLPAGPlayer, CYLSVGAPlayer
} from './CYLExampleAnimationPlayers';
import { CYLSVGAMovie, CYLSVGAShape, CYLSVGAShapeType, CYLSVGATransform } from './svga/CYLSVGAMovie';

/**
 * Whether Rive plays. Kept as a switch: set to false to leave Rive items on their static image if @ohos/rive crashes
 * again (issue Z1): the Rive builder is then not registered.
 */
export const CYL_RIVE_ENABLED: boolean = true;

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
  onFailed?: () => void;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private load(): void {
    const context = CYLUIContext.hostContext(this.getUIContext());
    const data = lottieData(context, this.source);
    if (data === undefined) {
      this.onFailed?.();
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
  onFailed?: () => void;
  @State controller: PAGViewController = new PAGViewController();

  aboutToAppear(): void {
    const context = CYLUIContext.hostContext(this.getUIContext());
    const file = PAGFile.LoadFromAssets(context.resourceManager, this.source.existingRawFilePath(context));
    if (file === null) {
      this.onFailed?.();
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

/** GIF: the frames ImageKit decodes, shown by the player. */
@Component
struct CYLGIFIconView {
  source: CYLAnimationSource = new CYLAnimationSource();
  @Prop iconWidth: number = 0;
  @Prop iconHeight: number = 0;
  onPlayer?: (player: CYLAnimationPlayer) => void;
  onFailed?: () => void;
  @State frame: image.PixelMap | undefined = undefined;

  aboutToAppear(): void {
    const bytes = this.source.rawFileContent(CYLUIContext.hostContext(this.getUIContext()));
    if (bytes === undefined) {
      this.onFailed?.();
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
      this.onFailed?.();
    });
  }

  build() {
    Stack() {
      if (this.frame !== undefined) {
        Image(this.frame)
          .accessibilityLevel('no')
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

/**
 * SVGA: the movie decoded by `CYLSVGAMovie`, each frame drawn on a Canvas. Bitmap sprites with alpha, layout,
 * transform and clip path, and vector shapes (path, rectangle, ellipse with fill and stroke) are drawn; mattes
 * (`matteKey`) and audio are not.
 */
@Component
struct CYLSVGAIconView {
  source: CYLAnimationSource = new CYLAnimationSource();
  @Prop iconWidth: number = 0;
  @Prop iconHeight: number = 0;
  onPlayer?: (player: CYLAnimationPlayer) => void;
  onFailed?: () => void;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private movie?: CYLSVGAMovie;
  private bitmaps: Map<string, image.PixelMap> = new Map<string, image.PixelMap>();
  private frame: number = 0;
  private canvasReady: boolean = false;

  aboutToAppear(): void {
    const bytes = this.source.rawFileContent(CYLUIContext.hostContext(this.getUIContext()));
    if (bytes === undefined) {
      this.onFailed?.();
      return;
    }
    let movie: CYLSVGAMovie;
    try {
      movie = CYLSVGAMovie.decode(bytes);
    } catch (error) {
      console.error(`[CYLClassifyMenuExample] SVGA ${this.source.path}: ${error}`);
      this.onFailed?.();
      return;
    }
    const keys: string[] = Array.from(movie.images.keys());
    const decodes: Promise<void>[] = keys.map((key: string): Promise<void> => {
      const data = movie.images.get(key) ?? new Uint8Array(0);
      const buffer = data.buffer.slice(data.byteOffset, data.byteOffset + data.byteLength) as ArrayBuffer;
      const imageSource = image.createImageSource(buffer);
      return imageSource.createPixelMap().then((pixelMap: image.PixelMap) => {
        this.bitmaps.set(key, pixelMap);
        imageSource.release();
      }).catch(() => {
        imageSource.release();
      });
    });
    Promise.all(decodes).then(() => {
      this.movie = movie;
      const player = new CYLSVGAPlayer(this.source, movie);
      player.onFrame = (index: number) => {
        this.frame = index;
        this.draw();
      };
      this.draw();
      this.onPlayer?.(player);
    });
  }

  aboutToDisappear(): void {
    this.bitmaps.forEach((pixelMap: image.PixelMap) => {
      pixelMap.release();
    });
    this.bitmaps.clear();
  }

  private applyTransform(t: CYLSVGATransform | undefined): void {
    if (t !== undefined) {
      this.context.transform(t.a, t.b, t.c, t.d, t.tx, t.ty);
    }
  }

  private drawShape(shape: CYLSVGAShape): void {
    const ctx = this.context;
    const path = shape.type === CYLSVGAShapeType.SHAPE ? new Path2D(shape.d) : new Path2D();
    if (shape.type === CYLSVGAShapeType.RECT) {
      path.rect(shape.rect.x, shape.rect.y, shape.rect.width, shape.rect.height);
    } else if (shape.type === CYLSVGAShapeType.ELLIPSE) {
      path.ellipse(shape.rect.x, shape.rect.y, shape.rect.width, shape.rect.height, 0, 0, Math.PI * 2);
    }
    ctx.save();
    this.applyTransform(shape.transform);
    if (shape.fill !== '') {
      ctx.fillStyle = shape.fill;
      ctx.fill(path);
    }
    if (shape.stroke !== '' && shape.strokeWidth > 0) {
      ctx.strokeStyle = shape.stroke;
      ctx.lineWidth = shape.strokeWidth;
      ctx.lineCap = shape.lineCap as CanvasLineCap;
      ctx.lineJoin = shape.lineJoin as CanvasLineJoin;
      if (shape.miterLimit > 0) {
        ctx.miterLimit = shape.miterLimit;
      }
      ctx.setLineDash(shape.lineDash);
      ctx.stroke(path);
    }
    ctx.restore();
  }

  /** Draws the current frame, scaled to fit the icon (aspect fit, centered). */
  private draw(): void {
    const movie = this.movie;
    if (movie === undefined || !this.canvasReady) {
      return;
    }
    const ctx = this.context;
    const width = this.iconWidth;
    const height = this.iconHeight;
    ctx.resetTransform();
    ctx.clearRect(0, 0, width, height);
    if (movie.viewBoxWidth <= 0 || movie.viewBoxHeight <= 0) {
      return;
    }
    const scale = Math.min(width / movie.viewBoxWidth, height / movie.viewBoxHeight);
    const x = (width - movie.viewBoxWidth * scale) / 2;
    const y = (height - movie.viewBoxHeight * scale) / 2;
    for (const sprite of movie.sprites) {
      const frame = this.frame < sprite.frames.length ? sprite.frames[this.frame] : undefined;
      if (frame === undefined || frame.alpha <= 0 || sprite.imageKey.endsWith('.matte')) {
        continue;
      }
      ctx.save();
      ctx.setTransform(scale, 0, 0, scale, x, y);
      this.applyTransform(frame.transform);
      ctx.globalAlpha = Math.min(1, frame.alpha);
      if (frame.clipPath !== '') {
        ctx.clip(new Path2D(frame.clipPath));
      }
      const bitmap = this.bitmaps.get(sprite.imageKey);
      if (bitmap !== undefined) {
        ctx.drawImage(bitmap, frame.layout.x, frame.layout.y, frame.layout.width, frame.layout.height);
      }
      for (const shape of frame.shapes) {
        this.drawShape(shape);
      }
      ctx.restore();
    }
  }

  build() {
    Canvas(this.context)
      .width(this.iconWidth)
      .height(this.iconHeight)
      .onReady(() => {
        this.canvasReady = true;
        this.draw();
      })
      .accessibilityLevel('no')
  }
}

/**
 * Animated icons are created one at a time, CREATE_INTERVAL ms apart: the animation screen created all of them in one
 * frame, decoding every GIF / SVGA / PAG / image on the main thread at once, and froze (appfreeze THREAD_BLOCK_6S in
 * ImageSourceNapi::Constructor; issue Z5).
 */
const CREATE_INTERVAL: number = 50;
const createQueue: (() => void)[] = [];
let createTimer: number = -1;

function enqueueCreate(create: () => void): void {
  createQueue.push(create);
  if (createTimer < 0) {
    createTimer = setInterval(() => {
      const next = createQueue.shift();
      next?.();
      if (createQueue.length === 0) {
        clearInterval(createTimer);
        createTimer = -1;
      }
    }, CREATE_INTERVAL);
  }
}

function dequeueCreate(create: () => void): void {
  const index = createQueue.indexOf(create);
  if (index >= 0) {
    createQueue.splice(index, 1);
  }
}

/**
 * The animation view of one tag icon: the engine view of the file's type, created in its turn (see CREATE_INTERVAL).
 * Its player goes to the tag (`CYLTagAnimationContext.ready`), which plays it, stops it at its resting progress or its
 * last frame, and applies the speed and the loop; a file that cannot play calls `onFailed()`.
 */
@Component
struct CYLExampleAnimationView {
  animationContext: CYLTagAnimationContext = new CYLTagAnimationContext();
  private player?: CYLAnimationPlayer;

  aboutToAppear(): void {
    enqueueCreate(this.create);
  }

  /** Its turn in the creation queue (see CREATE_INTERVAL). */
  @State private created: boolean = false;
  private create: () => void = () => {
    this.created = true;
  };

  aboutToDisappear(): void {
    dequeueCreate(this.create);
    const player = this.player;
    this.player = undefined;
    if (player !== undefined) {
      this.animationContext.onPlayer(undefined);
      player.destroy();
    }
  }

  private ready(player: CYLAnimationPlayer): void {
    this.player = player;
    this.animationContext.ready(player);
  }

  private failed(): void {
    this.animationContext.onFailed();
  }

  build() {
    Stack() {
      if (!this.created) {
        // Waiting for its turn: the component shows the static image (or the placeholder) meanwhile.
      } else if (this.animationContext.source.engine === CYLAnimationEngine.PAG) {
        CYLPAGIconView({
          source: this.animationContext.source,
          iconWidth: this.animationContext.width,
          iconHeight: this.animationContext.height,
          onPlayer: (p: CYLAnimationPlayer) => this.ready(p), onFailed: () => this.failed()
        })
      } else if (this.animationContext.source.engine === CYLAnimationEngine.SVGA) {
        CYLSVGAIconView({
          source: this.animationContext.source,
          iconWidth: this.animationContext.width,
          iconHeight: this.animationContext.height,
          onPlayer: (p: CYLAnimationPlayer) => this.ready(p), onFailed: () => this.failed()
        })
      } else if (this.animationContext.source.engine === CYLAnimationEngine.GIF) {
        CYLGIFIconView({
          source: this.animationContext.source,
          iconWidth: this.animationContext.width,
          iconHeight: this.animationContext.height,
          onPlayer: (p: CYLAnimationPlayer) => this.ready(p), onFailed: () => this.failed()
        })
      } else {
        CYLLottieIconView({
          source: this.animationContext.source,
          iconWidth: this.animationContext.width,
          iconHeight: this.animationContext.height,
          onPlayer: (p: CYLAnimationPlayer) => this.ready(p), onFailed: () => this.failed()
        })
      }
    }
    .width(this.animationContext.width)
    .height(this.animationContext.height)
    .accessibilityLevel('no')
  }
}

/**
 * `CYLAnimatedItemView.animationBuilder` for every tag: the example's animation view.
 */
@Builder
function cylExampleAnimationBuilder(context: CYLTagAnimationContext) {
  CYLExampleAnimationView({ animationContext: context })
}

const CYL_EXAMPLE_ANIMATION_BUILDER: WrappedBuilder<[CYLTagAnimationContext]> =
  wrapBuilder(cylExampleAnimationBuilder);

/**
 * Registers the engines the example plays with CYLTabBarController's `CYLAnimatedItemEngines` (Lottie, PAG, Rive, SVGA,
 * GIF; Rive through `cylRegisterRiveEngine(context)` of the shared `cylanimateditemrive` module) and the views that play them with the library (`CYLTagAnimationBuilder`; Rive with CYLTabBarController's `CYLRiveAnimationBuilder`, no view of the example). Called once, before any tag is shown
 * (`EntryAbility.onCreate`).
 */
export function cylRegisterExampleAnimationEngines(context?: common.Context): void {
  CYLAnimatedItemEngines.register('Lottie');
  CYLAnimatedItemEngines.register('PAG');
  if (CYL_RIVE_ENABLED) {
    // Rive needs no view of the example: CYLTabBarController's CYLRiveAnimationBuilder plays it, and the tags drive its
    // loop and replay through CYLAnimatedItemView (CYLTagAnimationBuilder.registerItemBuilder).
    cylRegisterRiveEngine(context);
    CYLTagAnimationBuilder.registerItemBuilder(CYLAnimationEngine.RIVE, wrapBuilder(CYLRiveAnimationBuilder));
  }
  CYLAnimatedItemEngines.register('SVGA');
  CYLAnimatedItemEngines.register('GIF');
  CYLTagAnimationBuilder.register(CYL_EXAMPLE_ANIMATION_BUILDER);
}

import lottie, { AnimationItem } from '@ohos/lottie';
import { util } from '@kit.ArkTS';

/**
 * Reads the Lottie JSON of an item's `animation` value: `asset:<path>` is a rawfile of the app, at that path
 * (Flutter: `flutter_assets/<key>`) or else by its last path component; any other value is JSON text.
 */
function rawFile(context: Context, path: string): Uint8Array | undefined {
  try {
    return path.length > 0 ? context.resourceManager.getRawFileContentSync(path) : undefined;
  } catch (error) {
    return undefined;
  }
}

function animationData(context: Context, source: string): Object | undefined {
  try {
    if (source.startsWith('asset:')) {
      const path = source.substring('asset:'.length);
      const bytes = rawFile(context, path) ?? rawFile(context, path.split('/').pop() ?? '');
      if (bytes === undefined) {
        return undefined;
      }
      const text = util.TextDecoder.create('utf-8').decodeToString(bytes);
      return JSON.parse(text) as Object;
    }
    return JSON.parse(source) as Object;
  } catch (e) {
    return undefined;
  }
}

/**
 * The animated icon of a tag: a Lottie animation on a canvas, at `speed`, looping when `loops`, played again from
 * progress 0 whenever `playToken` changes (`CYLTagListController.playAll()`).
 */
@Component
export struct CYLLottieIcon {
  @Prop source: string = '';
  @Prop iconSize: number = 18;
  @Prop @Watch('applySpeed') speed: number = 1;
  @Prop @Watch('applyLoops') loops: boolean = false;
  @Prop @Watch('replay') playToken: number = 0;
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
      loop: this.loops,
      autoplay: true,
      animationData: data
    });
    this.item.setSpeed(this.speed);
  }

  private applySpeed(): void {
    this.item?.setSpeed(this.speed);
  }

  private applyLoops(): void {
    if (this.item !== undefined) {
      this.item.loop = this.loops;
      if (this.loops) {
        this.item.play();
      }
    }
  }

  private replay(): void {
    this.item?.goToAndPlay(0, true);
  }

  aboutToDisappear(): void {
    this.item?.destroy();
    this.item = undefined;
  }

  build() {
    Canvas(this.context2D)
      .width(this.iconSize)
      .height(this.iconSize)
      .accessibilityLevel('no')
      .onReady(() => this.load())
  }
}

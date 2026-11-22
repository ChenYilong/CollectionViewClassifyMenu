/**
 * The example's animation players, one per engine (moved here from the library, which depends on no animation
 * library): `.json` Lottie (@ohos/lottie), `.pag` PAG (@tencent/libpag), `.riv` Rive (@ohos/rive), `.gif` GIF (frames
 * decoded by ImageKit), `.svga` SVGA (decoded by `CYLSVGAMovie`, drawn on a Canvas). Each subclasses the library's
 * `CYLAnimationPlayer`, the handle a `CYLTagButton` drives (`animationView`), and is handed to the tag by the views in
 * `CYLExampleAnimationViews.ets` through `CYLTagAnimationContext.ready(player)`.
 *
 * What each engine can do (the rest is a no-op, reported by `supportsSpeed` / `supportsLoops` / `supportsProgress`):
 * - Lottie: speed, loop, play from the start, any progress (resting progress, the last frame while selected).
 * - PAG: speed, loop, play from the start, any progress: libpag has no playback speed on HarmonyOS, so the player
 *   drives the progress itself (`setProgress` + `flush` on a timer).
 * - GIF: speed, loop, play from the start, any progress (the player shows the decoded frames on its own timer).
 * - SVGA: speed, loop, play from the start, any progress (2.x files; the player draws the frame for its own timer).
 * - Rive: play from the start (reset, then the state machine's trigger / boolean input, or the animation), loop for
 *   a linear animation (`Loop.LOOP`); @ohos/rive exposes no playback speed and no progress for a state machine.
 */
import { AnimationItem } from '@ohos/lottie';
import { PAGViewController } from '@tencent/libpag';
import { Loop, Direction, RiveAnimationView } from '@ohos/rive';
import { image } from '@kit.ImageKit';
import { CYLAnimationEngine, CYLAnimationPlayer, CYLAnimationSource } from '@cyl/classifymenu';
import { CYLSVGAMovie } from './svga/CYLSVGAMovie';

/** Lottie: `AnimationItem`. */
export class CYLLottiePlayer extends CYLAnimationPlayer {
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

const TICK_MS: number = 16;

/** A player that advances its own progress on a timer (PAG, GIF): speed, loop and progress for engines without. */
class CYLTimedPlayer extends CYLAnimationPlayer {
  protected progressValue: number = 0;
  private timer: number = -1;
  private lastTick: number = 0;

  get isPlaying(): boolean {
    return this.timer >= 0;
  }

  get progress(): number | undefined {
    return this.progressValue;
  }

  /** The duration of one pass at speed 1, in milliseconds. */
  protected get durationMs(): number {
    return 0;
  }

  /** Shows `progressValue`. */
  protected render(): void {
  }

  play(): void {
    this.stopTimer();
    this.progressValue = 0;
    this.render();
    if (this.durationMs <= 0) {
      return;
    }
    this.lastTick = Date.now();
    this.timer = setInterval(() => this.tick(), TICK_MS);
  }

  stopAtProgress(progress: number): void {
    this.stopTimer();
    this.progressValue = Math.min(1, Math.max(0, progress));
    this.render();
  }

  destroy(): void {
    this.stopTimer();
  }

  private tick(): void {
    const now = Date.now();
    const elapsed = now - this.lastTick;
    this.lastTick = now;
    let p = this.progressValue + elapsed * this.speedValue / this.durationMs;
    if (p >= 1) {
      if (this.loopsValue) {
        p = p % 1;
      } else {
        p = 1;
        this.stopTimer();
      }
    }
    this.progressValue = p;
    this.render();
  }

  private stopTimer(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }
}

/** PAG: `PAGViewController`, its progress driven by the player (libpag has no speed on HarmonyOS). */
export class CYLPAGPlayer extends CYLTimedPlayer {
  readonly pagController: PAGViewController;

  constructor(source: CYLAnimationSource, controller: PAGViewController) {
    super(CYLAnimationEngine.PAG, source);
    this.pagController = controller;
  }

  protected get durationMs(): number {
    return this.pagController.duration() / 1000;
  }

  protected render(): void {
    this.pagController.setProgress(this.progressValue);
    this.pagController.flush();
  }

  destroy(): void {
    super.destroy();
    this.pagController.release();
  }
}

/** GIF: the frames decoded by ImageKit, shown one at a time by the icon (`onFrame`). */
export class CYLGIFPlayer extends CYLTimedPlayer {
  readonly gifFrames: image.PixelMap[];
  /** Milliseconds each frame stays. */
  readonly gifDelays: number[];
  private total: number = 0;
  private shownIndex: number = -1;
  onFrame?: (frame: image.PixelMap) => void;

  constructor(source: CYLAnimationSource, frames: image.PixelMap[], delays: number[]) {
    super(CYLAnimationEngine.GIF, source);
    this.gifFrames = frames;
    this.gifDelays = frames.map((f: image.PixelMap, i: number): number => {
      const d = i < delays.length ? delays[i] : 100;
      return d > 0 ? d : 100;
    });
    this.total = this.gifDelays.reduce((sum: number, d: number) => sum + d, 0);
  }

  protected get durationMs(): number {
    return this.total;
  }

  /** The frame shown at `progress`: 1 is the last frame. */
  frameIndex(progress: number): number {
    if (this.gifFrames.length === 0) {
      return -1;
    }
    if (progress >= 1) {
      return this.gifFrames.length - 1;
    }
    let t = progress * this.total;
    for (let i = 0; i < this.gifDelays.length; i++) {
      if (t < this.gifDelays[i]) {
        return i;
      }
      t -= this.gifDelays[i];
    }
    return this.gifFrames.length - 1;
  }

  protected render(): void {
    const index = this.frameIndex(this.progressValue);
    if (index >= 0 && index !== this.shownIndex) {
      this.shownIndex = index;
      this.onFrame?.(this.gifFrames[index]);
    }
  }

  destroy(): void {
    super.destroy();
    this.onFrame = undefined;
    this.gifFrames.forEach((f: image.PixelMap) => {
      f.release();
    });
  }
}

/** SVGA: the decoded movie, its frame drawn by the icon's canvas (`onFrame`). */
export class CYLSVGAPlayer extends CYLTimedPlayer {
  readonly svgaMovie: CYLSVGAMovie;
  private shownIndex: number = -1;
  onFrame?: (index: number) => void;

  constructor(source: CYLAnimationSource, movie: CYLSVGAMovie) {
    super(CYLAnimationEngine.SVGA, source);
    this.svgaMovie = movie;
  }

  protected get durationMs(): number {
    return this.svgaMovie.durationMs;
  }

  /** The frame shown now. */
  get frameIndex(): number {
    return this.svgaMovie.frameIndex(this.progressValue);
  }

  protected render(): void {
    const index = this.frameIndex;
    if (index >= 0 && index !== this.shownIndex) {
      this.shownIndex = index;
      this.onFrame?.(index);
    }
  }

  destroy(): void {
    super.destroy();
    this.onFrame = undefined;
  }
}

/**
 * Rive: `RiveAnimationView`. The options of CYLTabBarController's Rive examples: `stateMachine` with `triggerInput`
 * (fired on play) or `input` (a boolean, true on play and while selected), `animation`, `artboard`; `legacy` plays
 * the file's first animation.
 */
export class CYLRivePlayer extends CYLAnimationPlayer {
  readonly riveView: RiveAnimationView;
  private playing: boolean = false;

  constructor(source: CYLAnimationSource, view: RiveAnimationView) {
    super(CYLAnimationEngine.RIVE, source);
    this.riveView = view;
  }

  /** @ohos/rive has no playback speed. */
  get supportsSpeed(): boolean {
    return false;
  }

  /** Only a linear animation loops (`Loop.LOOP`); a state machine runs its own states. */
  get supportsLoops(): boolean {
    return this.stateMachine === undefined;
  }

  /** @ohos/rive exposes no progress. */
  get supportsProgress(): boolean {
    return false;
  }

  get isPlaying(): boolean {
    try {
      return this.riveView.isPlaying();
    } catch (e) {
      return this.playing;
    }
  }

  private get stateMachine(): string | undefined {
    return this.source.options.get('stateMachine');
  }

  play(): void {
    try {
      const machine = this.stateMachine;
      const loop = this.loopsValue ? Loop.LOOP : Loop.ONESHOT;
      this.riveView.reset();
      // @ohos/rive 1.0.4's reset() selects the file's first artboard: select the named one again (a file with several
      // artboards, such as icons.riv, would otherwise play its first artboard on every item).
      const artboard = this.source.options.get('artboard');
      if (artboard !== undefined && this.riveView.getArtboardName() !== artboard) {
        this.riveView.setArtboardName(artboard);
      }
      if (machine !== undefined) {
        this.riveView.play(machine, loop, Direction.AUTO, true);
        const trigger = this.source.options.get('triggerInput');
        const input = this.source.options.get('input');
        if (trigger !== undefined) {
          this.riveView.fireState(machine, trigger);
        } else if (input !== undefined) {
          this.riveView.setBooleanState(machine, input, true);
        }
      } else {
        const animation = this.source.options.get('animation');
        if (animation !== undefined) {
          this.riveView.play(animation, loop, Direction.AUTO, false);
        } else {
          this.riveView.play(undefined, loop);
        }
      }
      this.playing = true;
    } catch (e) {
      this.playing = false;
    }
  }

  /** Selected (1): the boolean input on; otherwise off. Rive has no frame to stop at. */
  stopAtProgress(progress: number): void {
    const machine = this.stateMachine;
    const input = this.source.options.get('input');
    if (machine !== undefined && input !== undefined) {
      try {
        this.riveView.setBooleanState(machine, input, progress >= 1);
      } catch (e) {
        // The file is not loaded yet.
      }
    }
  }

  destroy(): void {
    try {
      this.riveView.stop();
    } catch (e) {
      // Already gone.
    }
  }

  protected applyLoops(): void {
    if (this.stateMachine !== undefined || !this.isPlaying) {
      return;
    }
    // A linear animation picks up the new loop mode by playing on from where it is.
    try {
      const animation = this.source.options.get('animation');
      this.riveView.play(animation, this.loopsValue ? Loop.LOOP : Loop.ONESHOT, Direction.AUTO, false, false);
    } catch (e) {
      // Not loaded yet.
    }
  }
}

/**
 * The example's animation players for the types CYLTabBarController's component does not play yet: `.riv` Rive
 * (@ohos/rive) and `.svga` SVGA (decoded by `CYLSVGAMovie`, drawn on a Canvas). Lottie, PAG and GIF moved to the
 * component (`cylanimateditem_lottie`, `cylanimateditem_pag`, `cylanimateditem`). Each subclasses the library's
 * `CYLAnimationPlayer`, the handle a `CYLTagButton` drives (`animationView`), and is handed to the tag by the views in
 * `CYLExampleAnimationViews.ets` through `CYLTagAnimationContext.ready(player)`.
 *
 * - SVGA: speed, loop, play from the start, any progress (2.x files; the player draws the frame for its own timer).
 * - Rive: play from the start (reset, then the state machine's trigger / boolean input, or the animation), loop for
 *   a linear animation (`Loop.LOOP`); @ohos/rive exposes no playback speed and no progress for a state machine.
 */
import { Loop, Direction, RiveAnimationView } from '@ohos/rive';
import { CYLAnimationEngine, CYLAnimationPlayer, CYLAnimationSource } from '@cyl/classifymenu';
import { CYLSVGAMovie } from './svga/CYLSVGAMovie';

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

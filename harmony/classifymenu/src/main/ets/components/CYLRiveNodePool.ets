/**
 * Keeps Rive views alive instead of disposing them.
 *
 * @ohos/rive 1.0.4 (the newest) crashes in `libohos_rive.so` when a `RiveAnimationView` is disposed while its EGL
 * surface is torn down on the worker thread (`EGLWorkerImpl::destroy` → `eglDestroySurface` → a null pointer). A tag
 * list rebuilds an item whenever its layout, selection or speed changes, which disposed and created Rive views many
 * times a second and crashed the animated icons screen within seconds. Each Rive view is therefore built once in a
 * `BuilderNode`, shown through a `NodeContainer`, and returned to this pool (detached, not disposed) when its icon
 * goes away; the next icon of the same file, options and size takes it again. The pool holds at most one view per
 * icon on screen at a time.
 */
import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI';
import { RiveAnimationView } from '@ohos/rive';

/** What a pooled Rive view is built with. */
export class CYLRiveNodeParams {
  resource: string = '';
  artboard: string = '';
  stateMachine: string = '';
  animation: string = '';
  width: number = 0;
  height: number = 0;
  /** Set when the view is ready (once per pooled view). */
  onReady: (view: RiveAnimationView) => void = () => {
  };
}

@Builder
function cylRiveNodeBuilder(params: CYLRiveNodeParams) {
  Stack() {
    RiveAnimationView({
      riveResource: params.resource,
      riveArtboard: params.artboard,
      riveStateMachine: params.stateMachine,
      riveAnimation: params.animation,
      riveAutoPlay: false,
      riveFit: 'contain',
      touchPassThrough: true,
      onReady: (view: RiveAnimationView) => params.onReady(view)
    })
  }
  .width(params.width)
  .height(params.height)
}

/** One pooled view: its node, the view once ready, and whether an icon shows it now. */
class CYLRivePoolEntry {
  key: string = '';
  node?: BuilderNode<[CYLRiveNodeParams]>;
  view?: RiveAnimationView;
  inUse: boolean = false;
  readyListeners: ((view: RiveAnimationView) => void)[] = [];
}

const POOL: CYLRivePoolEntry[] = [];

/**
 * The `NodeController` of one Rive icon: it takes a free pooled view for its key (or builds one) and gives it back
 * when the icon disappears.
 */
export class CYLRiveNodeController extends NodeController {
  private params: CYLRiveNodeParams;
  private entry?: CYLRivePoolEntry;
  private onReady: (view: RiveAnimationView) => void;

  constructor(params: CYLRiveNodeParams, onReady: (view: RiveAnimationView) => void) {
    super();
    this.params = params;
    this.onReady = onReady;
  }

  private static key(p: CYLRiveNodeParams): string {
    return [p.resource, p.artboard, p.stateMachine, p.animation, p.width, p.height].join('|');
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.entry === undefined) {
      const key = CYLRiveNodeController.key(this.params);
      let entry = POOL.find((e: CYLRivePoolEntry) => e.key === key && !e.inUse);
      if (entry === undefined) {
        const created = new CYLRivePoolEntry();
        created.key = key;
        const params = this.params;
        params.onReady = (view: RiveAnimationView) => {
          created.view = view;
          created.readyListeners.forEach((listener: (v: RiveAnimationView) => void) => listener(view));
        };
        created.node = new BuilderNode<[CYLRiveNodeParams]>(uiContext);
        created.node.build(wrapBuilder(cylRiveNodeBuilder), params);
        POOL.push(created);
        entry = created;
      }
      entry.inUse = true;
      entry.readyListeners = [this.onReady];
      this.entry = entry;
      if (entry.view !== undefined) {
        // A reused view is ready already: hand it over at once, back at its first frame.
        entry.view.reset();
        this.onReady(entry.view);
      }
    }
    return this.entry.node?.getFrameNode() ?? null;
  }

  /** Gives the view back to the pool (detached, not disposed). */
  release(): void {
    if (this.entry !== undefined) {
      this.entry.inUse = false;
      this.entry.readyListeners = [];
      this.entry = undefined;
    }
  }
}

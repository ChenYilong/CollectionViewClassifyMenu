/**
 * `CYLMenuGestureState.shared`: whether any tag list has a drag (reordering) or a word picker smear in progress, so a
 * container can hold its own scrolling meanwhile without knowing the host's delegate (an ArkTS builder gives no event
 * bubbling). Every `CYLTagListState` reports here as its gestures start and end, besides calling its delegate's
 * `menuDidChangeReordering` / `menuDidChangeSmearing`.
 *
 * A container (e.g. a search page's content `Scroll`) listens while it is shown:
 *
 *   aboutToAppear():    CYLMenuGestureState.shared.addListener(this.onGesture)
 *   aboutToDisappear(): CYLMenuGestureState.shared.removeListener(this.onGesture)
 *   Scroll(...).enableScrollInteraction(!this.gestureActive)
 *
 * Each tag list's share is kept apart (a list removed in the middle of a drag clears its own share), so the state is
 * active while at least one list has a gesture.
 */
export class CYLMenuGestureState {
  /** The one state every tag list reports to. */
  static readonly shared: CYLMenuGestureState = new CYLMenuGestureState();

  private owners: Set<number> = new Set<number>();
  private listeners: Array<(active: boolean) => void> = [];

  /** Whether any tag list has a drag or a smear in progress. */
  get isActive(): boolean {
    return this.owners.size > 0;
  }

  /** Calls `listener(active)` whenever `isActive` changes (not on every report). */
  addListener(listener: (active: boolean) => void): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  removeListener(listener: (active: boolean) => void): void {
    this.listeners = this.listeners.filter((l: (active: boolean) => void) => l !== listener);
  }

  /** A tag list (`owner`, its id) reports whether it has a gesture in progress. */
  setActive(owner: number, active: boolean): void {
    const before = this.isActive;
    if (active) {
      this.owners.add(owner);
    } else {
      this.owners.delete(owner);
    }
    const after = this.isActive;
    if (after !== before) {
      this.listeners.slice().forEach((listener: (active: boolean) => void) => listener(after));
    }
  }
}

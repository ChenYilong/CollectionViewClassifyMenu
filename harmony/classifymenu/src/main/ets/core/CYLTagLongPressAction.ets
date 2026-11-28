// What a long press on an item does (CYLTagListView.longPressAction). The list owns the gesture; an action owns the
// behavior: reordering, a callout with the item's subtitle, or the host's own code. The events (`menuDidLongPressItem`,
// `tagLongPressHandler`) stay notifications: they are reported by the built-in actions and never change the behavior.
//
//   list.longPressAction = CYLTagLongPressActions.first([CYLTagLongPressActions.reorder, CYLTagLongPressActions.callout]);
//   list.longPressAction = CYLTagLongPressActions.handler((host, indexPath) => host.showCallout('My text', indexPath));
//
// The default is `first([reorder, report])`: reordering where the list can reorder, else the long press is reported,
// exactly as before this API existed.
import { CYLIndexPath } from '../components/CYLTagListModel';

/** The list as an action sees it: the primitives the built-in and the custom actions are made of. */
export interface CYLTagLongPressHost {
  /** The item's subtitle from the data source (`menuSubtitleForItem`), or undefined. */
  subtitleForItem(indexPath: CYLIndexPath): string | undefined;

  /** Shows a small callout with an arrow, pointing at the item, with `text`. Replaces a callout that is showing. */
  showCallout(text: string, indexPath: CYLIndexPath): void;

  /** Hides the callout. */
  dismissCallout(): void;

  /** Whether the list can reorder its items now (`allowsReordering` or editing, and a data source that moves items). */
  canReorderItem(indexPath: CYLIndexPath): boolean;

  /** Starts reordering with the item picked up (a selected item's drag is reported). */
  beginReordering(indexPath: CYLIndexPath): void;

  /**
   * Ends reordering: the data source moves the item to `destination` when `moved`; a press that did not move is
   * reported as a long press.
   */
  endReordering(destination: CYLIndexPath | undefined, moved: boolean): void;

  /** Ends reordering without moving anything. */
  cancelReordering(): void;

  /** Reports a long press: `menuDidLongPressItem`, then `tagLongPressHandler`. */
  reportLongPress(indexPath: CYLIndexPath): void;
}

/** What a long press on an item does. */
export interface CYLTagLongPressAction {
  /** Whether this action takes the press on this item (reorder: the list can reorder; callout: the item has a subtitle). */
  canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean;

  /** The press was recognized. Returns true to follow the finger; `end` or `cancel` then arrive. */
  begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean;

  /** The finger lifted over `destination` (undefined: outside the list); `moved` tells whether it left the item. */
  end?(host: CYLTagLongPressHost, destination: CYLIndexPath | undefined, moved: boolean): void;

  /** The gesture was cancelled. */
  cancel?(host: CYLTagLongPressHost): void;
}

/** A custom long-press behavior: a closure. */
export type CYLTagLongPressHandler = (host: CYLTagLongPressHost, indexPath: CYLIndexPath) => void;

class CYLTagReorderAction implements CYLTagLongPressAction {
  canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    return host.canReorderItem(indexPath);
  }

  begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    host.beginReordering(indexPath);
    return true;
  }

  end(host: CYLTagLongPressHost, destination: CYLIndexPath | undefined, moved: boolean): void {
    host.endReordering(destination, moved);
  }

  cancel(host: CYLTagLongPressHost): void {
    host.cancelReordering();
  }
}

class CYLTagReportAction implements CYLTagLongPressAction {
  canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    return true;
  }

  begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    host.reportLongPress(indexPath);
    return false;
  }
}

class CYLTagCalloutAction implements CYLTagLongPressAction {
  canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    const subtitle = host.subtitleForItem(indexPath);
    return subtitle !== undefined && subtitle.length > 0;
  }

  begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    const subtitle = host.subtitleForItem(indexPath);
    if (subtitle !== undefined && subtitle.length > 0) {
      host.showCallout(subtitle, indexPath);
    }
    host.reportLongPress(indexPath);
    return false;
  }
}

class CYLTagNoneAction implements CYLTagLongPressAction {
  canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    return true;
  }

  begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    return false;
  }
}

class CYLTagHandlerAction implements CYLTagLongPressAction {
  private handler: CYLTagLongPressHandler;

  constructor(handler: CYLTagLongPressHandler) {
    this.handler = handler;
  }

  canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    return true;
  }

  begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    this.handler(host, indexPath);
    return false;
  }
}

/** The first action of a list whose `canBegin` passes takes the press; it also receives the end and the cancel. */
class CYLTagFirstAction implements CYLTagLongPressAction {
  private actions: CYLTagLongPressAction[];
  private chosen: CYLTagLongPressAction | undefined = undefined;

  constructor(actions: CYLTagLongPressAction[]) {
    this.actions = actions;
  }

  canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    return this.actions.some((action: CYLTagLongPressAction): boolean => action.canBegin(host, indexPath));
  }

  begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    this.chosen = undefined;
    for (const action of this.actions) {
      if (action.canBegin(host, indexPath)) {
        const follows = action.begin(host, indexPath);
        this.chosen = follows ? action : undefined;
        return follows;
      }
    }
    return false;
  }

  end(host: CYLTagLongPressHost, destination: CYLIndexPath | undefined, moved: boolean): void {
    const action = this.chosen;
    this.chosen = undefined;
    if (action !== undefined && action.end !== undefined) {
      action.end(host, destination, moved);
    }
  }

  cancel(host: CYLTagLongPressHost): void {
    const action = this.chosen;
    this.chosen = undefined;
    if (action !== undefined && action.cancel !== undefined) {
      action.cancel(host);
    }
  }
}

/** The built-in long-press actions, and the ways to combine them or write your own. */
export class CYLTagLongPressActions {
  /** Picks the item up to reorder it, where the list can reorder (the data source moves the item). */
  static readonly reorder: CYLTagLongPressAction = new CYLTagReorderAction();

  /** Only reports the long press (`menuDidLongPressItem`, `tagLongPressHandler`). */
  static readonly report: CYLTagLongPressAction = new CYLTagReportAction();

  /** Shows the item's subtitle in a callout with an arrow, where the item has one, and reports the long press. */
  static readonly callout: CYLTagLongPressAction = new CYLTagCalloutAction();

  /** Does nothing (not even a report). */
  static readonly none: CYLTagLongPressAction = new CYLTagNoneAction();

  /** Runs `handler` instead of a built-in behavior; it can use the host's primitives, such as `showCallout`. */
  static handler(handler: CYLTagLongPressHandler): CYLTagLongPressAction {
    return new CYLTagHandlerAction(handler);
  }

  /** The first of `actions` that can begin takes the press, as "reorder where editable, a callout elsewhere". */
  static first(actions: CYLTagLongPressAction[]): CYLTagLongPressAction {
    return new CYLTagFirstAction(actions);
  }

  /** The default of a list: `first([reorder, report])`, the behavior before this API existed. */
  static makeDefault(): CYLTagLongPressAction {
    return new CYLTagFirstAction([CYLTagLongPressActions.reorder, CYLTagLongPressActions.report]);
  }
}

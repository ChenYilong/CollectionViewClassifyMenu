import { describe, it, expect } from '@ohos/hypium';
import {
  CYLFont, CYLIndexPath, CYLMenuDataSource, CYLMenuDelegate, CYLMenuStyle, CYLTagListState, CYLTextMeasurer, CYLTagLongPressAction,
  CYLTagLongPressActions, CYLTagLongPressHost, CALLOUT_GAP, CALLOUT_ESTIMATED_HEIGHT
} from '@cyl/classifymenu';

const CALLOUT_TARGET_TOP: number = 200;
const CALLOUT_TARGET_BOTTOM: number = 240;
const CALLOUT_HEIGHT: number = 40;
const CALLOUT_BOTTOM_LIMIT: number = 800;

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;

function path(item: number): CYLIndexPath {
  return { section: 0, item: item };
}

function list(text: string): CYLTagListState {
  const state = new CYLTagListState();
  state.style = CYLMenuStyle.wordPicker();
  state.setTagsWithCharactersOfText(text);
  state.setLayoutWidth(390);
  return state;
}

/** Records the long presses the delegate is told about. */
class CYLLongPressRecorder implements CYLMenuDelegate {
  items: number[] = [];
  menuDidLongPressItem = (menu: Object, indexPath: CYLIndexPath): void => {
    this.items.push(indexPath.item);
  };
}

/** Three items, the second with a subtitle. */
class CYLSubtitleSource implements CYLMenuDataSource {
  numberOfSectionsInMenu(): number {
    return 1;
  }

  menuNumberOfItemsInSection(section: number): number {
    return 3;
  }

  menuTitleForSection(section: number): string {
    return 'S';
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return ['x', 'y', 'z'][indexPath.item];
  }

  menuSubtitleForItem = (indexPath: CYLIndexPath): string | undefined => indexPath.item === 1 ? 'about y' : undefined;
}

/** A custom action that follows the finger, to check the end and the cancel reach the action that began. */
class CYLFollowingAction implements CYLTagLongPressAction {
  log: string[] = [];

  canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    return indexPath.item === 1;
  }

  begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): boolean {
    this.log.push(`begin ${indexPath.item}`);
    return true;
  }

  end(host: CYLTagLongPressHost, destination: CYLIndexPath | undefined, moved: boolean): void {
    this.log.push(`end ${destination === undefined ? 'none' : destination.item} ${moved}`);
  }

  cancel(host: CYLTagLongPressHost): void {
    this.log.push('cancel');
  }
}

/**
 * The long-press action of a list (CYLTagListState.longPressAction): the default keeps today's behavior (reordering where
 * the list can reorder, else the long press is reported), and the built-in, combined and custom actions replace it.
 */
export default function tagLongPressActionTest() {
  describe('CYLTagLongPressAction', () => {
    let saved: CYLTextMeasurer = FIXED;

    it('theDefaultReportsALongPressWhenTheListCannotReorder', 0, () => {
      const state = list('ABC');
      const recorder = new CYLLongPressRecorder();
      state.menuDelegate = recorder;
      const tagged: number[] = [];
      state.tagLongPressHandler = (index: number) => {
        tagged.push(index);
      };
      expect(state.beginLongPress(path(1))).assertFalse();
      state.endLongPress(undefined, false);
      expect(recorder.items.join(',')).assertEqual('1');
      expect(tagged.join(',')).assertEqual('1');
    });

    it('theDefaultReordersWhereTheListCanReorder', 0, () => {
      const state = list('ABC');
      const recorder = new CYLLongPressRecorder();
      state.menuDelegate = recorder;
      state.allowsReordering = true;
      expect(state.beginLongPress(path(1))).assertTrue();
      // A press that does not move is still reported when it ends, as before.
      state.endLongPress(path(1), false);
      expect(recorder.items.join(',')).assertEqual('1');
    });

    it('noneAndHandlerReplaceTheBuiltInBehavior', 0, () => {
      const state = list('ABC');
      const recorder = new CYLLongPressRecorder();
      state.menuDelegate = recorder;
      state.allowsReordering = true;
      state.longPressAction = CYLTagLongPressActions.none;
      expect(state.beginLongPress(path(0))).assertFalse();
      expect(recorder.items.length).assertEqual(0);
      const seen: string[] = [];
      state.longPressAction = CYLTagLongPressActions.handler((host: CYLTagLongPressHost, indexPath: CYLIndexPath) => {
        seen.push(`handler ${indexPath.item} ${host.canReorderItem(indexPath)}`);
      });
      expect(state.beginLongPress(path(2))).assertFalse();
      // No built-in action ran: the list did not reorder and nothing was reported.
      expect(seen.join('|')).assertEqual('handler 2 true');
      expect(state.isReordering).assertFalse();
      expect(recorder.items.length).assertEqual(0);
    });

    it('firstGivesThePressToTheFirstActionThatCanBeginAndItsEndAndCancel', 0, () => {
      const state = list('ABC');
      const recorder = new CYLLongPressRecorder();
      state.menuDelegate = recorder;
      const following = new CYLFollowingAction();
      state.longPressAction = CYLTagLongPressActions.first([following, CYLTagLongPressActions.report]);
      // Item 0: the first action cannot begin, the second reports it.
      expect(state.beginLongPress(path(0))).assertFalse();
      expect(recorder.items.join(',')).assertEqual('0');
      expect(following.log.length).assertEqual(0);
      // Item 1: the first action follows the finger, then gets the end.
      expect(state.beginLongPress(path(1))).assertTrue();
      state.endLongPress(path(2), true);
      expect(state.beginLongPress(path(1))).assertTrue();
      state.cancelLongPress();
      expect(following.log.join('|')).assertEqual('begin 1|end 2 true|begin 1|cancel');
      expect(recorder.items.join(',')).assertEqual('0');
    });

    it('theCalloutShowsTheSubtitleOfTheDataSourceAndTapDismissesIt', 0, () => {
      const state = list('ABC');
      const recorder = new CYLLongPressRecorder();
      state.menuDelegate = recorder;
      state.menuDataSource = new CYLSubtitleSource();
      state.longPressAction = CYLTagLongPressActions.first([CYLTagLongPressActions.callout]);
      // An item without a subtitle: no callout, and nothing else takes the press.
      expect(state.beginLongPress(path(0))).assertFalse();
      expect(state.calloutIndexPath === undefined).assertTrue();
      expect(recorder.items.length).assertEqual(0);
      // An item with one: the callout points at it and the long press is reported too.
      expect(state.beginLongPress(path(1))).assertFalse();
      expect(state.calloutText).assertEqual('about y');
      expect(state.calloutIndexPath?.item).assertEqual(1);
      expect(recorder.items.join(',')).assertEqual('1');
      // The subtitle is also the item's accessibility hint when the data source gives none.
      expect(state.accessibilityHintForItem(path(1))).assertEqual('about y');
      // A tap dismisses it.
      state.tapItem(path(0));
      expect(state.calloutIndexPath === undefined).assertTrue();
      expect(state.calloutText).assertEqual('');
    });

    it('aConfigurationNamesTheLongPressActionAndTheSubtitle', 0, () => {
      const configuration = JSON.parse(
        '{"longPressAction":"callout","sections":[{"title":"S","items":[{"title":"a","subtitle":"about a"},"b"]}]}'
      ) as Record<string, Object>;
      const state = CYLTagListState.withConfiguration(configuration);
      state.setLayoutWidth(390);
      const recorder = new CYLLongPressRecorder();
      state.menuDelegate = recorder;
      expect(state.beginLongPress(path(0))).assertFalse();
      expect(state.calloutText).assertEqual('about a');
      state.dismissCallout();
      // "callout" alone still reports the long press of a tag without a subtitle.
      expect(state.beginLongPress(path(1))).assertFalse();
      expect(state.calloutIndexPath === undefined).assertTrue();
      expect(recorder.items.join(',')).assertEqual('0,1');
      const none = CYLTagListState.withConfiguration(
        JSON.parse('{"longPressAction":"none","sections":[{"items":["a"]}]}') as Record<string, Object>);
      expect(none.beginLongPress(path(0))).assertFalse();
    });

    it('aCustomHandlerCanShowItsOwnCalloutText', 0, () => {
      const state = list('ABC');
      state.longPressAction = CYLTagLongPressActions.handler((host: CYLTagLongPressHost, indexPath: CYLIndexPath) => {
        host.showCallout(`item ${indexPath.item}`, indexPath);
      });
      expect(state.beginLongPress(path(2))).assertFalse();
      expect(state.calloutText).assertEqual('item 2');
      state.longPressAction = CYLTagLongPressActions.none;
      expect(state.calloutIndexPath === undefined).assertTrue();
    });

    it('settingAnotherActionCancelsAPressInProgress', 0, () => {
      const state = list('ABC');
      state.allowsReordering = true;
      expect(state.beginLongPress(path(1))).assertTrue();
      expect(state.isReordering).assertTrue();
      state.longPressAction = CYLTagLongPressActions.none;
      expect(state.isReordering).assertFalse();
    });

    it('theCalloutGoesAboveWhenItFitsAndNothingIsCovered', 0, () => {
      expect(CYLTagListState.calloutPlacesBelow(CALLOUT_TARGET_TOP, CALLOUT_TARGET_BOTTOM, CALLOUT_HEIGHT, 0,
        CALLOUT_BOTTOM_LIMIT, undefined, undefined)).assertFalse();
      // A header far above the bubble is not covered.
      expect(CYLTagListState.calloutPlacesBelow(CALLOUT_TARGET_TOP, CALLOUT_TARGET_BOTTOM, CALLOUT_HEIGHT, 0,
        CALLOUT_BOTTOM_LIMIT, 0, 20)).assertFalse();
    });

    it('theCalloutGoesBelowWhenItDoesNotFitAbove', 0, () => {
      expect(CYLTagListState.calloutPlacesBelow(10, 50, CALLOUT_HEIGHT, 0, CALLOUT_BOTTOM_LIMIT, undefined, undefined))
        .assertTrue();
    });

    it('theCalloutGoesBelowWhenItWouldCoverTheHeaderAndFitsBelow', 0, () => {
      // The bubble above spans 156..196 (top = 200 - 40 - 4); the header band 150..190 overlaps it.
      expect(CYLTagListState.calloutPlacesBelow(CALLOUT_TARGET_TOP, CALLOUT_TARGET_BOTTOM, CALLOUT_HEIGHT, 0,
        CALLOUT_BOTTOM_LIMIT, 150, 190)).assertTrue();
      // Neither side is free of the header and below does not fit: above.
      expect(CYLTagListState.calloutPlacesBelow(CALLOUT_TARGET_TOP, CALLOUT_TARGET_BOTTOM, CALLOUT_HEIGHT, 0,
        CALLOUT_TARGET_BOTTOM + CALLOUT_GAP, 150, 190)).assertFalse();
      // An empty header covers nothing.
      expect(CYLTagListState.calloutPlacesBelow(CALLOUT_TARGET_TOP, CALLOUT_TARGET_BOTTOM, CALLOUT_HEIGHT, 0,
        CALLOUT_BOTTOM_LIMIT, 160, 160)).assertFalse();
    });

    it('anUnknownItemNeverAsksForBelow', 0, () => {
      const state = list('ABC');
      expect(state.calloutPlacesBelowItem(path(99), CALLOUT_ESTIMATED_HEIGHT)).assertFalse();
      expect(state.calloutPlacesBelowItem({ section: 9, item: 0 })).assertFalse();
    });
  });
}

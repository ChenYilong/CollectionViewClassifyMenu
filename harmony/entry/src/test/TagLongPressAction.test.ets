import { describe, it, expect } from '@ohos/hypium';
import {
  CYLFont, CYLIndexPath, CYLMenuDelegate, CYLMenuStyle, CYLTagListState, CYLTextMeasurer, CYLTagLongPressAction,
  CYLTagLongPressActions, CYLTagLongPressHost
} from '@cyl/classifymenu';

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

    it('settingAnotherActionCancelsAPressInProgress', 0, () => {
      const state = list('ABC');
      state.allowsReordering = true;
      expect(state.beginLongPress(path(1))).assertTrue();
      expect(state.isReordering).assertTrue();
      state.longPressAction = CYLTagLongPressActions.none;
      expect(state.isReordering).assertFalse();
    });
  });
}

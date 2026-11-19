import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLFont, CYLIndexPath, CYLMenuDelegate, CYLMenuSelectionMode, CYLMenuStyle, CYLTagButtonMetrics, CYLTagListCell,
  CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;

/** The word picker demo's message in English (the example's tables give it per language). */
const MESSAGE = 'Hi, I\'m Alex from Design 👋';

function path(item: number): CYLIndexPath {
  return { section: 0, item: item };
}

class CYLSelectionRecorder implements CYLMenuDelegate {
  changes: number = 0;
  menuDidChangeSelectedItems = (menu: Object, indexPaths: CYLIndexPath[]): void => {
    this.changes++;
  };
}

function wordPicker(text: string): CYLTagListState {
  const list = new CYLTagListState();
  list.style = CYLMenuStyle.wordPicker();
  list.selectionMode = CYLMenuSelectionMode.multiple;
  list.allowsSmearSelection = true;
  list.setTagsWithCharactersOfText(text);
  list.setLayoutWidth(390);
  return list;
}

/**
 * The word picker (选词填入, iOS cf5d9f7e / 251131c5): one cell per character, 9 per row, the picked text in text order,
 * smear selection (begin on the touched-down item, extend to the item under the finger, deselect from a selected one).
 */
export default function tagListWordPickerTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagListWordPicker', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('cellsAndPickedText', 0, () => {
      const list = wordPicker(MESSAGE);
      const titles = list.tags.map((tag) => tag.title);
      expect(titles.join('')).assertEqual(MESSAGE);
      // 26 characters: the emoji is one cell (two UTF-16 units).
      expect(titles.length).assertEqual(MESSAGE.length - 1);
      expect(titles.includes('👋')).assertTrue();
      expect(list.selectionMode).assertEqual(CYLMenuSelectionMode.multiple);
      const style = CYLMenuStyle.wordPicker();
      expect(style.numberOfItemsPerRow).assertEqual(9);
      expect(style.itemHeight).assertEqual(40);
      // The name, wherever it stands in this language's message.
      const start = MESSAGE.indexOf('Alex');
      const first = MESSAGE.substring(0, start).length;
      list.selectItemsFrom(path(first + 3), path(first));
      expect(list.selectedText).assertEqual('Alex');
      list.deselectAllItems();
      expect(list.selectedText).assertEqual('');
      // A space cell is read as "Space".
      const cell = new CYLTagListCell();
      cell.configure(' ', undefined, undefined, undefined, style, false, true);
      expect(cell.accessibilityLabel.trim().length > 0).assertTrue();
    });

    it('severalSmearsAddUp', 0, () => {
      // Owner's check (iOS testSeveralSmearsAddUp): each smear adds its range to the selection it began with.
      const list = wordPicker(MESSAGE);
      const alex = MESSAGE.indexOf('Alex');
      list.beginSmear(path(alex));
      list.smearTo(path(alex + 2));
      list.smearTo(path(alex + 3));
      list.endSmear();
      expect(list.selectedText).assertEqual('Alex');
      const design = MESSAGE.indexOf(' Design');
      list.beginSmear(path(design));
      list.smearTo(path(design + 6));
      list.endSmear();
      expect(list.selectedText).assertEqual('Alex Design');
      list.beginSmear(path(alex));
      list.smearTo(path(alex + 3));
      list.endSmear();
      expect(list.selectedText).assertEqual(' Design');
    });

    it('smearSelectsAndDeselectsARange', 0, () => {
      const list = wordPicker('ABCDEFGHIJKL');
      const recorder = new CYLSelectionRecorder();
      list.menuDelegate = recorder;
      list.beginSmear(path(2));
      list.smearTo(path(4));
      list.smearTo(path(10));
      list.endSmear();
      expect(list.selectedText).assertEqual('CDEFGHIJK');
      expect(recorder.changes >= 2).assertTrue();
      list.beginSmear(path(0));
      list.smearTo(path(1));
      list.endSmear();
      expect(list.selectedText).assertEqual('ABCDEFGHIJK');
      list.beginSmear(path(5));
      list.smearTo(path(7));
      list.endSmear();
      expect(list.selectedText).assertEqual('ABCDEIJK');
      list.selectionMode = CYLMenuSelectionMode.single;
      list.deselectAllItems();
      list.beginSmear(path(0));
      list.smearTo(path(3));
      list.endSmear();
      expect(list.selectedIndexPaths.length <= 1).assertTrue();
      expect(list.canSmearFrom(path(0))).assertFalse();
    });
  });
}

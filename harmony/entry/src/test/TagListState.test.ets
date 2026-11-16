import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLFont, CYLIndexPath, CYLMenuSelectionMode, CYLTag, CYLTagButtonMetrics, CYLTagListItemFrame, CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;

function path(section: number, item: number): CYLIndexPath {
  return { section: section, item: item };
}

function titles(list: CYLTagListState): string[] {
  return list.tags.map((t: CYLTag) => t.title);
}

/**
 * CYLTagListState, the model behind CYLTagListView (iOS: CYLTagListView's tags, selection, folding and layout API).
 */
export default function tagListStateTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagListState', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('editsTagsAsTheAndroidTagViewAPI', 0, () => {
      const list = new CYLTagListState();
      list.addTagsWithTitles(['a', 'b', 'c']);
      list.addTagWithTitle('d');
      list.insertTagWithTitle('x', 1);
      expect(titles(list).join(',')).assertEqual('a,x,b,c,d');
      list.removeTag(0);
      list.removeTags([0, 2]);
      expect(titles(list).join(',')).assertEqual('b,d');
      list.setTagsWithTitles(['p', 'q']);
      expect(titles(list).join(',')).assertEqual('p,q');
      list.removeAllTags();
      expect(list.tags.length).assertEqual(0);
    });

    it('selectsOnePerSectionInSingleMode', 0, () => {
      const list = new CYLTagListState();
      list.addTagsWithTitles(['a', 'b', 'c']);
      list.selectionMode = CYLMenuSelectionMode.single;
      list.selectItem(path(0, 0));
      list.selectItem(path(0, 2));
      expect(list.selectedIndexPaths.length).assertEqual(1);
      expect(list.isSelected(path(0, 2))).assertTrue();
      expect(list.selectedTitles.join(',')).assertEqual('c');
    });

    it('selectsManyInMultipleMode', 0, () => {
      const list = new CYLTagListState();
      list.addTagsWithTitles(['a', 'b', 'c']);
      list.selectionMode = CYLMenuSelectionMode.multiple;
      list.toggleSelection(path(0, 0));
      list.toggleSelection(path(0, 1));
      expect(list.selectedIndexPaths.length).assertEqual(2);
      list.toggleSelection(path(0, 0));
      expect(list.selectedTitles.join(',')).assertEqual('b');
      list.deselectAllItems();
      expect(list.selectedIndexPaths.length).assertEqual(0);
    });

    it('selectsOnlyByToggleInNoneMode', 0, () => {
      const list = new CYLTagListState();
      list.addTagsWithTitles(['a', 'b']);
      list.selectionMode = CYLMenuSelectionMode.none;
      // selectItem (a tap) keeps nothing selected; toggleSelection still selects, as documented.
      list.selectItem(path(0, 0));
      expect(list.selectedIndexPaths.length).assertEqual(0);
      list.toggleSelection(path(0, 0));
      list.toggleSelection(path(0, 1));
      expect(list.selectedIndexPaths.length).assertEqual(2);
    });

    it('ignoresInvalidIndexPaths', 0, () => {
      const list = new CYLTagListState();
      list.addTagsWithTitles(['a']);
      expect(list.isValid(path(0, 0))).assertTrue();
      expect(list.isValid(path(0, 5))).assertFalse();
      expect(list.isValid(path(3, 0))).assertFalse();
      list.selectionMode = CYLMenuSelectionMode.multiple;
      list.selectItem(path(0, 5));
      expect(list.selectedIndexPaths.length).assertEqual(0);
    });

    it('wrapsRowsAndGrowsWithTheContent', 0, () => {
      const list = new CYLTagListState();
      list.addTagsWithTitles(['one', 'two']);
      const short = list.heightThatFitsWidth(320);
      list.addTagsWithTitles(['three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve']);
      const long = list.heightThatFitsWidth(320);
      expect(long > short).assertTrue();
      // A narrower list needs more rows.
      expect(list.heightThatFitsWidth(160) > long).assertTrue();
    });

    it('keepsItemsInsideTheWidth', 0, () => {
      const list = new CYLTagListState();
      list.addTagsWithTitles(['alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta']);
      list.setLayoutWidth(200);
      const sections = list.layoutSections();
      expect(sections.length).assertEqual(1);
      let checked = 0;
      sections[0].items.forEach((frame: CYLTagListItemFrame) => {
        expect(frame.x >= 0).assertTrue();
        expect(frame.x + frame.width <= 200 + 0.5).assertTrue();
        checked++;
      });
      expect(checked).assertEqual(8);
    });

    it('neverLaysTagsOutWithNoWidth', 0, () => {
      // Regression (B11): laid out before its width was known, every tag was clamped to width 0 (a hairline).
      const list = new CYLTagListState();
      list.addTagsWithTitles(['首页', '消息', '搜索']);
      const early = list.layoutSections();
      expect(early[0].items.length).assertEqual(3);
      // The tag's own width: its padding alone is wider than 20 vp (the bug gave 1 vp).
      early[0].items.forEach((frame: CYLTagListItemFrame) => {
        expect(frame.width > 20).assertTrue();
      });
      // The real width measures again and keeps every tag inside it.
      list.setLayoutWidth(320);
      list.layoutSections()[0].items.forEach((frame: CYLTagListItemFrame) => {
        expect(frame.width > 20).assertTrue();
        expect(frame.x + frame.width <= 320 + 0.5).assertTrue();
      });
    });

    it('movesAnItem', 0, () => {
      const list = new CYLTagListState();
      list.addTagsWithTitles(['a', 'b', 'c']);
      list.selectionMode = CYLMenuSelectionMode.multiple;
      list.selectItem(path(0, 0));
      // Without allowsReordering nothing moves.
      list.moveItem(path(0, 0), path(0, 2));
      expect(titles(list).join(',')).assertEqual('a,b,c');
      list.allowsReordering = true;
      list.moveItem(path(0, 0), path(0, 2));
      expect(titles(list).join(',')).assertEqual('b,c,a');
      // The selection moves with the item.
      expect(list.isSelected(path(0, 2))).assertTrue();
      expect(list.isSelected(path(0, 0))).assertFalse();
    });
  });
}

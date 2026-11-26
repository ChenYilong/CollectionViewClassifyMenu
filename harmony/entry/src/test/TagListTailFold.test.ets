import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLFont, CYLIndexPath, CYLMenuDataSource, CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition,
  CYLTagButtonMetrics, CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;

/** Same-length titles ("Tag 00"), so every tag has the same width and the row count follows from the tag count. */
class CYLTailFoldSource implements CYLMenuDataSource {
  titles: string[] = [];

  constructor(count: number) {
    for (let i = 0; i < count; i++) {
      this.titles.push(`Tag ${i < 10 ? '0' : ''}${i}`);
    }
  }

  numberOfSectionsInMenu = (): number => 1;
  menuNumberOfItemsInSection = (section: number): number => this.titles.length;
  menuTitleForSection = (section: number): string => 'Section';
  menuTitleForItem = (indexPath: CYLIndexPath): string => this.titles[indexPath.item];
}

function makeTailList(count: number): CYLTagListState {
  const list = new CYLTagListState();
  list.menuDataSource = new CYLTailFoldSource(count);
  list.setLayoutWidth(320);
  list.showsSectionHeaders = false;
  list.defaultVisibleRows = 2;
  list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.icon);
  list.reloadMenuData();
  return list;
}

function isFoldCell(list: CYLTagListState, item: number): boolean {
  return list.isInlineFoldCell({ section: 0, item: item });
}

/**
 * The tail fold control only appears when the tags need more than defaultVisibleRows rows (iOS CYLTagListFoldingTests,
 * Android CYLTagListTailFoldTest).
 */
export default function tagListTailFoldTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagListTailFold', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('hasNoFoldCellWhenTheTagsFitInFewerRowsThanDefaultVisibleRows', 0, () => {
      const list = makeTailList(TAGS_IN_ONE_ROW);
      expect(list.numberOfRows(0)).assertEqual(1);
      expect(list.canFoldSection(0)).assertFalse();
      expect(list.showsInlineFoldCell(0)).assertFalse();
      expect(list.numberOfDisplayedItems(0)).assertEqual(TAGS_IN_ONE_ROW);
      expect(isFoldCell(list, TAGS_IN_ONE_ROW)).assertFalse();
    });

    it('hasNoFoldCellWhenTheTagsFitExactlyDefaultVisibleRows', 0, () => {
      const list = makeTailList(TAGS_IN_TWO_ROWS);
      expect(list.numberOfRows(0)).assertEqual(2);
      expect(list.canFoldSection(0)).assertFalse();
      expect(list.showsInlineFoldCell(0)).assertFalse();
      expect(list.numberOfVisibleItems(0)).assertEqual(TAGS_IN_TWO_ROWS);
      expect(list.numberOfDisplayedItems(0)).assertEqual(TAGS_IN_TWO_ROWS);
      expect(isFoldCell(list, TAGS_IN_TWO_ROWS)).assertFalse();
    });

    it('endsWithTheFoldCellWhenTheTagsNeedOneRowMoreThanDefaultVisibleRows', 0, () => {
      const list = makeTailList(TAGS_IN_THREE_ROWS);
      expect(list.numberOfRows(0)).assertEqual(3);
      expect(list.canFoldSection(0)).assertTrue();
      expect(list.isSectionExpanded(0)).assertFalse();
      const visible = list.numberOfVisibleItems(0);
      expect(visible < TAGS_IN_THREE_ROWS).assertTrue();
      expect(list.numberOfDisplayedItems(0)).assertEqual(visible + 1);
      expect(isFoldCell(list, visible)).assertTrue();
      expect(isFoldCell(list, visible - 1)).assertFalse();
      list.setExpanded(true, 0);
      expect(list.isSectionExpanded(0)).assertTrue();
      expect(list.numberOfVisibleItems(0)).assertEqual(TAGS_IN_THREE_ROWS);
      expect(list.numberOfDisplayedItems(0)).assertEqual(TAGS_IN_THREE_ROWS + 1);
      expect(isFoldCell(list, TAGS_IN_THREE_ROWS)).assertTrue();
      expect(isFoldCell(list, TAGS_IN_THREE_ROWS - 1)).assertFalse();
      list.toggleSection(0);
      expect(list.isSectionExpanded(0)).assertFalse();
      expect(list.numberOfDisplayedItems(0)).assertEqual(visible + 1);
      expect(isFoldCell(list, visible)).assertTrue();
    });

    it('showsNoHeaderFoldControlWhenTheTagsFitDefaultVisibleRowsAndNoWidthIsKnownYet', 0, () => {
      const list = new CYLTagListState();
      list.menuDataSource = new CYLTailFoldSource(TAGS_IN_TWO_ROWS);
      list.defaultVisibleRows = 2;
      list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.headerTrailing, CYLMenuFoldControlContent.icon);
      list.reloadMenuData();
      // No width yet: the layout is unknown, so no section can need a fold.
      expect(list.showsHeaderFoldControl(0)).assertFalse();
      list.setLayoutWidth(320);
      expect(list.numberOfRows(0)).assertEqual(2);
      expect(list.showsHeaderFoldControl(0)).assertFalse();
      list.setLayoutWidth(0);
      expect(list.showsHeaderFoldControl(0)).assertFalse();
    });

    it('showsTheHeaderFoldControlOnlyWhenTheRowsExceedDefaultVisibleRows', 0, () => {
      const list = new CYLTagListState();
      list.menuDataSource = new CYLTailFoldSource(TAGS_IN_THREE_ROWS);
      list.defaultVisibleRows = 2;
      list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.headerTrailing, CYLMenuFoldControlContent.icon);
      list.setLayoutWidth(320);
      list.reloadMenuData();
      expect(list.showsHeaderFoldControl(0)).assertTrue();
      list.setLayoutWidth(640);
      expect(list.numberOfRows(0)).assertEqual(2);
      expect(list.showsHeaderFoldControl(0)).assertFalse();
    });
  });
}

const TAGS_IN_ONE_ROW: number = 2;
const TAGS_IN_TWO_ROWS: number = 6;
const TAGS_IN_THREE_ROWS: number = 7;

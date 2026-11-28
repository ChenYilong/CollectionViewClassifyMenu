import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLFont, CYLIndexPath, CYLMenuDataSource, CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition,
  CYLMenuStyle, CYLTagButtonMetrics, CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
let TAGS: number = 12;
let TALL_ITEM: number = 1;

/** Tags "Tag 00"…; the tag at `TALL_ITEM` has its own, taller style (a custom tag or icon height). */
class CYLRowHeightSource implements CYLMenuDataSource {
  titles: string[] = [];
  tall: CYLMenuStyle = new CYLMenuStyle();

  constructor() {
    for (let i = 0; i < TAGS; i++) {
      this.titles.push(`Tag ${i < 10 ? '0' : ''}${i}`);
    }
    this.tall.itemHeight = 80;
  }

  numberOfSectionsInMenu = (): number => 1;
  menuNumberOfItemsInSection = (section: number): number => this.titles.length;
  menuTitleForSection = (section: number): string => 'Section';
  menuTitleForItem = (indexPath: CYLIndexPath): string => this.titles[indexPath.item];
  menuStyleForItem = (indexPath: CYLIndexPath): CYLMenuStyle | undefined =>
    indexPath.item === TALL_ITEM ? this.tall : undefined;
}

/** 40 tags; every tag from `tallFrom` on has its own, taller style. */
class CYLTallFromSource implements CYLMenuDataSource {
  tallFrom: number = Number.MAX_VALUE;
  tall: CYLMenuStyle = new CYLMenuStyle();

  constructor() {
    this.tall.itemHeight = 80;
  }

  numberOfSectionsInMenu = (): number => 1;
  menuNumberOfItemsInSection = (section: number): number => 40;
  menuTitleForSection = (section: number): string => 'Section';
  menuTitleForItem = (indexPath: CYLIndexPath): string => `Tag ${indexPath.item < 10 ? '0' : ''}${indexPath.item}`;
  menuStyleForItem = (indexPath: CYLIndexPath): CYLMenuStyle | undefined =>
    indexPath.item >= this.tallFrom ? this.tall : undefined;
}

function makeList(): CYLTagListState {
  TAGS = 12;
  TALL_ITEM = 1;
  const list = new CYLTagListState();
  list.menuDataSource = new CYLRowHeightSource();
  list.setLayoutWidth(320);
  list.showsSectionHeaders = false;
  list.reloadMenuData();
  return list;
}

/** The distinct tag heights of each row (keyed by the row's top). */
function rowHeights(list: CYLTagListState): Map<number, Set<number>> {
  const result = new Map<number, Set<number>>();
  list.layoutSections()[0].items.forEach((cell) => {
    const heights = result.get(cell.y) ?? new Set<number>();
    heights.add(cell.height);
    result.set(cell.y, heights);
  });
  return result;
}

/** Every row is as tall as its tallest tag, and `maxItemHeight` limits it (iOS CYLTagListLayoutTests, Android CYLTagListRowHeightTest). */
export default function tagListRowHeightTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagListRowHeight', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('everyTagOfARowIsAsTallAsTheRowsTallest', 0, () => {
      const list = makeList();
      expect(list.maxItemHeight).assertEqual(Number.MAX_VALUE);
      rowHeights(list).forEach((heights: Set<number>) => expect(heights.size).assertEqual(1));
      const cells = list.layoutSections()[0].items;
      expect(cells[0].height).assertEqual(cells[TALL_ITEM].height);
      expect(cells[0].height > list.itemHeight).assertTrue();
    });

    it('maxItemHeightLimitsEveryTag', 0, () => {
      const list = makeList();
      list.maxItemHeight = 30;
      rowHeights(list).forEach((heights: Set<number>) => {
        expect(heights.size).assertEqual(1);
        expect(heights.has(30)).assertTrue();
      });
    });

    it('theTailFoldCellIsAsTallAsItsRowAndLimitedByMaxItemHeight', 0, () => {
      TAGS = 40;
      TALL_ITEM = 0;
      const list = new CYLTagListState();
      list.menuDataSource = new CYLRowHeightSource();
      list.setLayoutWidth(320);
      list.showsSectionHeaders = false;
      list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.icon);
      list.defaultVisibleRows = 1;
      list.reloadMenuData();
      const cells = list.layoutSections()[0].items;
      const fold = cells.filter((c) => c.isFoldCell)[0];
      expect(fold !== undefined).assertTrue();
      expect(fold.height).assertEqual(cells[0].height);
      list.maxItemHeight = 30;
      const limited = list.layoutSections()[0].items;
      expect(limited.filter((c) => c.isFoldCell)[0].height <= 30).assertTrue();
    });

    it('tagsPushedOutByTheTailFoldCellDoNotSetTheRowHeight', 0, () => {
      for (let width = 120; width <= 400; width += 7) {
        const source = new CYLTallFromSource();
        const list = new CYLTagListState();
        list.menuDataSource = source;
        list.setLayoutWidth(width);
        list.showsSectionHeaders = false;
        list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.icon);
        list.defaultVisibleRows = 1;
        list.reloadMenuData();
        const visible = list.numberOfVisibleItems(0);
        if (visible >= 40) {
          continue;
        }
        const before = list.heightThatFitsWidth(width);
        // Every hidden tag taller: none is shown, so no shown row changes its height.
        source.tallFrom = visible;
        list.reloadMenuData();
        expect(list.numberOfVisibleItems(0)).assertEqual(visible);
        expect(list.heightThatFitsWidth(width)).assertEqual(before);
        const cells = list.layoutSections()[0].items;
        const fold = cells.filter((c) => c.isFoldCell)[0];
        cells.forEach((c) => expect(c.height).assertEqual(fold.height));
      }
    });
  });
}

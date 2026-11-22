import { describe, it, expect } from '@ohos/hypium';
import {
  CYLClassifyMenuCellFrame, CYLClassifyMenuViewController, CYLFilterBaseController, CYLIndexPath, CYLMenuDataSource, CYLMenuDelegate, CYLMultipleFilterController
} from '@cyl/classifymenu';

/** A menu of sections; the first item of each section is "全部" (exclusive) when `exclusiveAll`. */
class TestMenu implements CYLMenuDataSource {
  sections: string[][];
  names: string[];
  menuItemIsExclusive?: (indexPath: CYLIndexPath) => boolean;

  constructor(names: string[], sections: string[][], exclusiveAll: boolean) {
    this.names = names;
    this.sections = sections;
    if (exclusiveAll) {
      this.menuItemIsExclusive = (p: CYLIndexPath): boolean => p.item === 0;
    }
  }

  numberOfSectionsInMenu(): number {
    return this.sections.length;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.sections[section].length;
  }

  menuTitleForSection(section: number): string {
    return this.names[section];
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.sections[indexPath.section][indexPath.item];
  }
}

function keys(paths: CYLIndexPath[]): string {
  return paths.map((p: CYLIndexPath) => `${p.section}-${p.item}`).join(',');
}

const MANY: string[] = ['川菜', '粤菜', '湘菜', '东北菜', '西北菜', '火锅', '自助餐', '小吃快餐', '日本料理', '韩国料理',
  '西餐', '烧烤', '海鲜', '素菜', '面包甜点', '咖啡厅'];

/**
 * CYLClassifyMenuViewController (single-choice menu with "more" folding) and CYLMultipleFilterController (multiple
 * choice with exclusive "全部" items), as iOS CollectionViewClassifyMenu's two menus.
 */
export default function classifyAndFilterTest() {
  describe('CYLClassifyMenu', () => {
    it('readsTheDataSourceAndReportsTaps', 0, () => {
      const menu = new CYLClassifyMenuViewController();
      menu.menuDataSource = new TestMenu(['吃', '玩'], [['川菜', '粤菜'], ['KTV']], false);
      const tapped: string[] = [];
      const delegate: CYLMenuDelegate = {
        menuDidSelectItem: (m: Object, p: CYLIndexPath) => tapped.push(`${p.section}-${p.item}`)
      };
      menu.menuDelegate = delegate;
      menu.setCollectionWidth(320);
      expect(menu.numberOfSections()).assertEqual(2);
      menu.didSelectItemAt({ section: 1, item: 0 });
      expect(tapped.join(',')).assertEqual('1-0');
      // Taps do not change the selection: the delegate sets it.
      expect(menu.selectedIndexPath === undefined).assertTrue();
      menu.selectedIndexPath = { section: 1, item: 0 };
      expect(menu.selectedIndexPath?.section).assertEqual(1);
    });

    it('foldsLongSectionsToTheDefaultRows', 0, () => {
      const menu = new CYLClassifyMenuViewController();
      menu.menuDataSource = new TestMenu(['吃'], [MANY], false);
      menu.setCollectionWidth(320);
      expect(menu.defaultVisibleRows).assertEqual(1);
      const folded = menu.numberOfItemsInSection(0);
      expect(folded < MANY.length).assertTrue();
      menu.defaultVisibleRows = 2;
      expect(menu.numberOfItemsInSection(0) > folded).assertTrue();
      const layout = menu.layout();
      expect(layout.headers.length).assertEqual(1);
      expect(layout.cells.length).assertEqual(menu.numberOfItemsInSection(0));
      expect(layout.collectionHeight > 0).assertTrue();
      layout.cells.forEach((c: CYLClassifyMenuCellFrame) => {
        expect(c.frame.x + c.frame.width <= 320 + 0.5).assertTrue();
      });
    });
  });

  describe('CYLMultipleFilter', () => {
    it('startsWithEachSectionsAllSelected', 0, () => {
      const filter = new CYLMultipleFilterController();
      filter.menuDataSource = new TestMenu(['地区', '菜品'], [['全部', '北京', '上海'], ['全部', '川菜', '粤菜']], true);
      filter.reloadMenuData();
      expect(keys(filter.selectedIndexPaths())).assertEqual('0-0,1-0');
    });

    it('replacesAllAndFallsBackToIt', 0, () => {
      const filter = new CYLMultipleFilterController();
      filter.menuDataSource = new TestMenu(['地区'], [['全部', '北京', '上海']], true);
      filter.reloadMenuData();
      filter.didSelectItemAt({ section: 0, item: 1 });
      filter.didSelectItemAt({ section: 0, item: 2 });
      expect(keys(filter.selectedIndexPaths())).assertEqual('0-1,0-2');
      filter.didSelectItemAt({ section: 0, item: 0 });
      expect(keys(filter.selectedIndexPaths())).assertEqual('0-0');
      filter.didSelectItemAt({ section: 0, item: 1 });
      filter.didSelectItemAt({ section: 0, item: 1 });
      // Nothing left: back to "全部".
      expect(keys(filter.selectedIndexPaths())).assertEqual('0-0');
    });

    it('confirmsAndRestores', 0, () => {
      const filter = new CYLMultipleFilterController();
      filter.menuDataSource = new TestMenu(['地区'], [['全部', '北京', '上海']], true);
      const confirmed: string[] = [];
      filter.menuDelegate = {
        menuDidConfirmSelectedItems: (m: Object, paths: CYLIndexPath[]) => confirmed.push(keys(paths))
      };
      filter.reloadMenuData();
      filter.didSelectItemAt({ section: 0, item: 2 });
      filter.confirmButtonClicked();
      filter.restoreButtonClicked();
      expect(confirmed.join('|')).assertEqual('0-2|0-0');
    });

    it('rejectsConflictingSelections', 0, () => {
      const filter = new CYLMultipleFilterController();
      filter.menuDataSource = new TestMenu(['地区'], [['全部', '北京', '上海']], true);
      filter.reloadMenuData();
      filter.setSelectedIndexPaths([{ section: 0, item: 1 }, { section: 0, item: 2 }]);
      expect(keys(filter.selectedIndexPaths())).assertEqual('0-1,0-2');
      let conflict = false;
      try {
        filter.setSelectedIndexPaths([{ section: 0, item: 0 }, { section: 0, item: 1 }]);
      } catch (e) {
        conflict = true;
      }
      expect(conflict).assertTrue();
      let outside = false;
      try {
        filter.setSelectedIndexPaths([{ section: 3, item: 0 }]);
      } catch (e) {
        outside = true;
      }
      expect(outside).assertTrue();
      // A rejected call leaves the selection as it was.
      expect(keys(filter.selectedIndexPaths())).assertEqual('0-1,0-2');
    });

    it('theBackKeyClosesTheNewestFilterPanel', 0, () => {
      const first = new CYLFilterBaseController();
      const second = new CYLFilterBaseController();
      expect(CYLFilterBaseController.hideShowingPanelForBackPress()).assertFalse();
      first.show();
      second.show();
      // Back closes the newest panel only, then the older one, then reports that none is left (the page goes back).
      expect(CYLFilterBaseController.hideShowingPanelForBackPress()).assertTrue();
      expect(second.isShowing).assertFalse();
      expect(first.isShowing).assertTrue();
      expect(CYLFilterBaseController.hideShowingPanelForBackPress()).assertTrue();
      expect(first.isShowing).assertFalse();
      expect(CYLFilterBaseController.hideShowingPanelForBackPress()).assertFalse();
      // A panel closed by Apply is no longer on screen for the back key.
      first.show();
      first.confirmButtonClicked();
      expect(CYLFilterBaseController.hideShowingPanelForBackPress()).assertFalse();
    });
  });
}

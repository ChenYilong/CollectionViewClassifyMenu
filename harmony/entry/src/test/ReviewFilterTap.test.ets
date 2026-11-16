import { describe, it, expect } from '@ohos/hypium';
import { CYLIndexPath, CYLMenuSelectionMode, CYLTagListState } from '@cyl/classifymenu';
import {
  CYLExampleMenuItem, CYLExampleMenuSection, CYLExampleMenuSource
} from '../main/ets/demos/shell/CYLExampleMenuSource';

function keys(paths: CYLIndexPath[]): string {
  return paths.map((p: CYLIndexPath) => `${p.section}-${p.item}`).join(',');
}

/** The review list's filter (CYLReviewListPage): multiple choice, an exclusive 全部 first, preselected. */
export default function reviewFilterTapTest() {
  describe('ReviewFilterTap', () => {
    it('aTapOnGoodReplacesAll', 0, () => {
      const titles = ['全部', '好评(9)', '中评(1)', '差评(0)'];
      const items = titles.map((title: string, i: number) => {
        const item = new CYLExampleMenuItem(title);
        item.isExclusive = i === 0;
        item.isEnabled = i !== 3;
        return item;
      });
      const view = new CYLTagListState();
      view.selectionMode = CYLMenuSelectionMode.multiple;
      view.menuDataSource = new CYLExampleMenuSource([new CYLExampleMenuSection('评价', items)]);
      view.reloadMenuData();
      view.selectedIndexPaths = [{ section: 0, item: 0 }];
      expect(keys(view.selectedIndexPaths)).assertEqual('0-0');
      view.tapItem({ section: 0, item: 1 });
      expect(keys(view.selectedIndexPaths)).assertEqual('0-1');
      view.tapItem({ section: 0, item: 3 });
      expect(keys(view.selectedIndexPaths)).assertEqual('0-1');
    });
  });
}

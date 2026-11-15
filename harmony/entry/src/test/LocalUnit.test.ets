import { describe, it, expect } from '@ohos/hypium';
import { CYLTagListController, CYLTagSection, CYLTagSelection, foldedHeight, parseConfiguration } from '@cyl/classifymenu';
import { placesQuery } from '../main/ets/data/PlacesDatabase';

export default function localUnitTest() {
  describe('CYLTagList', () => {
    it('parsesTheSharedConfiguration', 0, () => {
      const config = parseConfiguration('{"selectionMode":"multiple","defaultVisibleRows":2,"style":{"itemHeight":36,' +
        '"selected":{"textColor":"#FF0000"}},"sections":[{"title":"A","items":[{"title":"全部","exclusive":true},{"title":"x"}]}],' +
        '"selected":[{"section":0,"item":1}]}');
      expect(config.selectionMode).assertEqual('multiple');
      expect(config.defaultVisibleRows).assertEqual(2);
      expect(config.style.itemHeight).assertEqual(36);
      expect(config.style.selected.textColor).assertEqual('#FF0000');
      expect(config.style.selected.borderColor).assertEqual('#2AB9A0');
      expect(config.sections[0].items[0].exclusive).assertTrue();
      expect(config.selected.length).assertEqual(1);
      expect(parseConfiguration('{"selectionMode":"bogus"}').selectionMode).assertEqual('none');
    });

    it('singleSelectionTogglesOneItem', 0, () => {
      const one: CYLTagSection[] = [{ items: [{ title: 'a' }, { title: 'b' }] }];
      const s = new CYLTagSelection('single', one);
      s.toggle({ section: 0, item: 0 });
      s.toggle({ section: 0, item: 1 });
      expect(s.selected.length).assertEqual(1);
      expect(s.isSelected({ section: 0, item: 1 })).assertTrue();
      s.toggle({ section: 0, item: 1 });
      expect(s.selected.length).assertEqual(0);
    });

    it('exclusiveItemClearsItsSection', 0, () => {
      const sections: CYLTagSection[] = [{ items: [{ title: '全部', exclusive: true }, { title: 'a' }, { title: 'b' }] },
        { items: [{ title: '全部', exclusive: true }, { title: 'c' }] }];
      const s = new CYLTagSelection('multiple', sections);
      s.toggle({ section: 0, item: 1 });
      s.toggle({ section: 0, item: 2 });
      s.toggle({ section: 1, item: 1 });
      expect(s.selected.length).assertEqual(3);
      s.toggle({ section: 0, item: 0 });
      expect(s.selected.length).assertEqual(2);
      expect(s.isSelected({ section: 1, item: 1 })).assertTrue();
      s.toggle({ section: 0, item: 1 });
      expect(s.isSelected({ section: 0, item: 0 })).assertFalse();
      expect(new CYLTagSelection('none', sections).toggle({ section: 0, item: 1 })).assertFalse();
    });

    it('readsAnimationsAndPlaysAll', 0, () => {
      const config = parseConfiguration('{"style":{"imageSize":"{24, 24}"},"sections":[{"items":[' +
        '{"title":"Home","animation":"asset:assets/tab_home_animate.json"},{"title":"x"}]}]}');
      expect(config.style.imageSize).assertEqual(24);
      expect(config.sections[0].items[0].animation).assertEqual('asset:assets/tab_home_animate.json');
      expect(config.sections[0].items[1].animation).assertUndefined();
      expect(parseConfiguration('{}').style.imageSize).assertEqual(18);
      let plays = 0;
      const controller = new CYLTagListController();
      controller.playAll();
      controller.attach(() => plays++);
      controller.playAll();
      expect(plays).assertEqual(1);
    });

    it('foldsToRows', 0, () => {
      expect(foldedHeight(2, 36, 8)).assertEqual(80);
      expect(foldedHeight(0, 36, 8)).assertEqual(-1);
    });

    it('placesQueryBindsValues', 0, () => {
      const q = placesQuery('川菜', ['上海'], ['a', 'b']);
      expect(q.sql).assertEqual('SELECT name, region, rating, price FROM places WHERE tag = ? AND region IN (?) AND tag IN (?, ?) ORDER BY rating DESC, id');
      expect(q.args.join(',')).assertEqual('川菜,上海,a,b');
      expect(placesQuery(null, [], []).sql.includes('WHERE')).assertFalse();
    });
  });
}

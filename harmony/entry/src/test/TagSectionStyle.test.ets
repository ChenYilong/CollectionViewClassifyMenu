import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLFont, CYLIndexPath, CYLMenuDataSource, CYLTagButtonMetrics, CYLTagListItemFrame, CYLTagListSectionFrame,
  CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const LIST_WIDTH: number = 320;

/** Three sections of tags with titles of different lengths, so rows break at different places. */
class CYLSectionStyleSource implements CYLMenuDataSource {
  sections: string[][] = [
    ['Alpha', 'Bravo', 'Charlie', 'Delta', 'Echo', 'Foxtrot', 'Golf', 'Hotel'],
    ['One', 'Two', 'Three'],
    ['A much longer tag title', 'Short', 'Another quite long title', 'Mid length', 'Tiny', 'X']
  ];

  numberOfSectionsInMenu = (): number => this.sections.length;
  menuNumberOfItemsInSection = (section: number): number => this.sections[section].length;
  menuTitleForSection = (section: number): string => `Section ${section}`;
  menuTitleForItem = (indexPath: CYLIndexPath): string => this.sections[indexPath.section][indexPath.item];
}

function makeList(): CYLTagListState {
  const list = new CYLTagListState();
  list.menuDataSource = new CYLSectionStyleSource();
  list.setLayoutWidth(LIST_WIDTH);
  list.reloadMenuData();
  return list;
}

/** Every frame of the list's layout as one string: section y / header / footer / height, then each item x y w h. */
function snapshot(list: CYLTagListState): string {
  const parts: string[] = [`content ${list.contentHeight}`];
  list.layoutSections().forEach((s: CYLTagListSectionFrame) => {
    parts.push(`s${s.section} y${s.y} hh${s.headerHeight} fh${s.footerHeight} h${s.height}`);
    s.items.forEach((c: CYLTagListItemFrame) => parts.push(`${c.item}:${c.x},${c.y},${c.width},${c.height}`));
  });
  return parts.join(' | ');
}

/** The frames of the list built before the section style existed, captured from the code of that time. */
const DEFAULT_FRAMES: string =
  'content 458 | s0 y0 hh36 fh0 h166 | 0:16,46,70,30 | 1:96,46,70,30 | 2:176,46,90,30 | 3:16,86,70,30 | 4:96,86,60,30 | 5:166,86,90,30 | 6:16,126,60,30 | 7:86,126,70,30 | s1 y166 hh36 fh0 h86 | 0:16,212,50,30 | 1:76,212,50,30 | 2:136,212,70,30 | s2 y252 hh36 fh0 h206 | 0:16,298,250,30 | 1:16,338,70,30 | 2:16,378,260,30 | 3:16,418,120,30 | 4:146,418,60,30 | 5:216,418,30,30';

export default function tagSectionStyleTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagSectionStyle', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('aDefaultStyleGivesTheFramesOfBeforeTheSectionStyle', 0, () => {
      expect(snapshot(makeList())).assertEqual(DEFAULT_FRAMES);
    });
  });
}

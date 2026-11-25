import { describe, it, expect } from '@ohos/hypium';
import {
  CYLIndexPath, CYLMenuFoldControlPosition, CYLMenuSelectionMode, CYLTagListState
} from '@cyl/classifymenu';
import {
  CYLQueryScenario, CYLQueryScenariosSource, SCENARIO_DEFAULT_VISIBLE_ROWS, SCENARIO_TITLE_MAX_LINES,
  cylConfigureScenarioList, scenarioSections, scenarioTitle
} from '../main/ets/demos/menu/CYLQueryScenariosSource';

const FIRST_SECTION: number = 0;
const MENU_SECTION: number = 1;
const SEARCH_SECTION: number = 2;
const THREE_SECTIONS: number = 3;
const THREE_ROWS: number = 3;

function path(section: number, item: number): CYLIndexPath {
  return { section: section, item: item };
}

/** The plus button's tag list (CYLQueryScenariosPage): sections, titles, details, fold and the tap. */
export default function queryScenariosSourceTest() {
  describe('QueryScenariosSource', () => {
    it('oneSectionPerGroupEachWithATitle', 0, () => {
      const source = new CYLQueryScenariosSource();
      expect(source.numberOfSectionsInMenu()).assertEqual(THREE_SECTIONS);
      expect(source.menuNumberOfItemsInSection(FIRST_SECTION)).assertEqual(THREE_ROWS);
      for (let section = 0; section < THREE_SECTIONS; section++) {
        expect(source.menuTitleForSection(section).length > 0).assertTrue();
      }
      expect(source.menuTitleForItem(path(MENU_SECTION, 0))).assertEqual(scenarioTitle(CYLQueryScenario.menuLinkage));
    })

    it('theDetailIsTheSubtitleAndAnIconIsSet', 0, () => {
      const source = new CYLQueryScenariosSource();
      const sections = scenarioSections();
      expect(source.menuSubtitleForItem?.(path(SEARCH_SECTION, 0))).assertEqual(sections[SEARCH_SECTION].detail);
      expect(source.menuSubtitleForItem?.(path(FIRST_SECTION, 1))).assertEqual(sections[FIRST_SECTION].detail);
      expect(source.menuImageForItem?.(path(FIRST_SECTION, 2)) !== undefined).assertTrue();
    })

    it('theListFoldsTapsAndWraps', 0, () => {
      const source = new CYLQueryScenariosSource();
      const list = new CYLTagListState();
      const opened: CYLQueryScenario[] = [];
      cylConfigureScenarioList(list, source, (scenario: CYLQueryScenario) => {
        opened.push(scenario);
      }, (height: number) => {
      });
      expect(list.defaultVisibleRows).assertEqual(SCENARIO_DEFAULT_VISIBLE_ROWS);
      expect(list.foldControl.position).assertEqual(CYLMenuFoldControlPosition.headerTrailing);
      expect(list.selectionMode).assertEqual(CYLMenuSelectionMode.none);
      expect(list.style.titleMaxLines).assertEqual(SCENARIO_TITLE_MAX_LINES);
      expect(list.style.numberOfItemsPerRow).assertEqual(0);
      list.tapItem(path(FIRST_SECTION, 1));
      list.tapItem(path(SEARCH_SECTION, 0));
      expect(opened.join(',')).assertEqual(`${CYLQueryScenario.reviewsMemory},${CYLQueryScenario.searchDiscover}`);
      expect(list.selectedIndexPaths.length).assertEqual(0);
    })
  })
}

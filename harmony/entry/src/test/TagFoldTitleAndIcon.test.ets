import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLConfiguration, CYLFont, CYLHeaderFoldMaxWidthFraction, CYLHeaderTitleMaxLines, CYLIndexPath, CYLMenuConfiguration,
  CYLMenuDataSource, CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlKey, CYLMenuFoldControlPosition,
  CYLMenuStyle, CYLSectionStyle, CYLSize, CYLTagButtonMetrics, CYLTagListSectionFrame, CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const LIST_WIDTH: number = 320;
/** The default section insets, left and right. */
const SIDE_INSET: number = 16;
/** 28 characters are 280 vp wide: one line in the 288 vp a plain header has, two lines beside a fold control. */
const SECTION_TITLE: string = 'x'.repeat(28);
const FOLDABLE_TAGS: number = 8;
const UNFOLDABLE_TAGS: number = 1;
const SECOND_SECTION: number = 1;
const MORE_TITLE: string = 'More';
/** Longer than "More", so the two states of a title-and-icon-always control differ in text width. */
const LESS_TITLE: string = 'Collapse all';
/** 30 characters are 300 vp wide: more than 40% of the 320 vp header. */
const LONG_FOLD_TITLE: string = 'y'.repeat(30);
const RAW_TITLE_AND_ICON: number = 3;
const HEADER_FOLD_ROWS: number = 1;

/** Section 0 can fold (8 tags), section 1 cannot (1 tag); both have the same long title. */
class CYLFoldTitleSource implements CYLMenuDataSource {
  numberOfSectionsInMenu = (): number => 2;
  menuNumberOfItemsInSection = (section: number): number => section === 0 ? FOLDABLE_TAGS : UNFOLDABLE_TAGS;
  menuTitleForSection = (section: number): string => SECTION_TITLE;
  menuTitleForItem = (indexPath: CYLIndexPath): string => `Tag ${indexPath.item < 10 ? '0' : ''}${indexPath.item}`;
}

function plainStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.sectionStyle = CYLSectionStyle.plain;
  style.headerMaxLines = CYLHeaderTitleMaxLines.unlimited;
  return style;
}

function makeControl(position: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent): CYLMenuFoldControl {
  const control = new CYLMenuFoldControl(position, content);
  control.title = MORE_TITLE;
  control.collapseTitle = LESS_TITLE;
  return control;
}

function makeList(control: CYLMenuFoldControl | undefined): CYLTagListState {
  const list = new CYLTagListState();
  list.style = plainStyle();
  list.menuDataSource = new CYLFoldTitleSource();
  list.setLayoutWidth(LIST_WIDTH);
  list.defaultVisibleRows = HEADER_FOLD_ROWS;
  if (control !== undefined) {
    list.foldControl = control;
  }
  list.reloadMenuData();
  return list;
}

function contentOf(value: string | number): CYLMenuFoldControl {
  const configuration: CYLConfiguration = {};
  configuration[CYLMenuFoldControlKey.content] = value as Object;
  const control = new CYLMenuFoldControl(CYLMenuFoldControlPosition.footer, CYLMenuFoldControlContent.icon);
  CYLMenuConfiguration.applyToFoldControl(control, configuration);
  return control;
}

/**
 * The fourth fold control content, `titleAndIcon` (raw value 3): "More ⌄" folded, "Less ⌃" expanded (the iOS
 * CYLTitleAndIconFoldControlTests). The text measurer is fixed (10 vp per character).
 */
export default function tagFoldTitleAndIconTest() {
  describe('CYLTagFoldTitleAndIcon', () => {
    let saved: CYLTextMeasurer = CYLTagButtonMetrics.textMeasurer;

    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('theRawValuesAreZeroToThree', 0, () => {
      expect(CYLMenuFoldControlContent.iconAndTitle as number).assertEqual(0);
      expect(CYLMenuFoldControlContent.title as number).assertEqual(1);
      expect(CYLMenuFoldControlContent.icon as number).assertEqual(2);
      expect(CYLMenuFoldControlContent.titleAndIcon as number).assertEqual(RAW_TITLE_AND_ICON);
    });

    it('everyContentSaysWhatItShowsInBothStates', 0, () => {
      const position = CYLMenuFoldControlPosition.footer;
      const both = makeControl(position, CYLMenuFoldControlContent.titleAndIcon);
      expect(both.showsImage(false)).assertTrue();
      expect(both.showsImage(true)).assertTrue();
      expect(both.showsTitle(false)).assertTrue();
      expect(both.showsTitle(true)).assertTrue();
      expect(both.titleWhenExpanded(false)).assertEqual(MORE_TITLE);
      expect(both.titleWhenExpanded(true)).assertEqual(LESS_TITLE);
      // Unchanged: icon and title folded, only the turned icon expanded.
      const iconAndTitle = makeControl(position, CYLMenuFoldControlContent.iconAndTitle);
      expect(iconAndTitle.showsImage(true)).assertTrue();
      expect(iconAndTitle.showsTitle(false)).assertTrue();
      expect(iconAndTitle.showsTitle(true)).assertFalse();
      expect(iconAndTitle.titleWhenExpanded(true)).assertUndefined();
      // Unchanged: the title only, the collapse title expanded.
      const title = makeControl(position, CYLMenuFoldControlContent.title);
      expect(title.showsImage(false)).assertFalse();
      expect(title.showsTitle(true)).assertTrue();
      expect(title.titleWhenExpanded(false)).assertEqual(MORE_TITLE);
      expect(title.titleWhenExpanded(true)).assertEqual(LESS_TITLE);
      // Unchanged: the icon only.
      const icon = makeControl(position, CYLMenuFoldControlContent.icon);
      expect(icon.showsImage(false)).assertTrue();
      expect(icon.showsTitle(false)).assertFalse();
      expect(icon.showsTitle(true)).assertFalse();
      expect(icon.titleWhenExpanded(false)).assertUndefined();
    });

    it('theDefaultTitlesAreTheLocalizedMoreAndCollapse', 0, () => {
      const control = new CYLMenuFoldControl(CYLMenuFoldControlPosition.footer, CYLMenuFoldControlContent.titleAndIcon);
      expect(control.titleWhenExpanded(false)).assertEqual(control.title);
      expect(control.titleWhenExpanded(true)).assertEqual(control.collapseTitle);
      expect(control.title.length > 0).assertTrue();
      expect(control.collapseTitle.length > 0).assertTrue();
      expect(control.title !== control.collapseTitle).assertTrue();
    });

    it('theConfigurationStringTitleAndIconAlwaysIsTheNewContent', 0, () => {
      expect(contentOf('titleAndIconAlways').content).assertEqual(CYLMenuFoldControlContent.titleAndIcon);
      expect(contentOf('TITLEANDICONALWAYS').content).assertEqual(CYLMenuFoldControlContent.titleAndIcon);
      expect(contentOf(RAW_TITLE_AND_ICON).content).assertEqual(CYLMenuFoldControlContent.titleAndIcon);
    });

    it('theOlderAliasesKeepMeaningIconAndTitle', 0, () => {
      expect(contentOf('iconAndTitle').content).assertEqual(CYLMenuFoldControlContent.iconAndTitle);
      expect(contentOf('titleAndIcon').content).assertEqual(CYLMenuFoldControlContent.iconAndTitle);
      expect(contentOf('title').content).assertEqual(CYLMenuFoldControlContent.title);
      expect(contentOf('icon').content).assertEqual(CYLMenuFoldControlContent.icon);
    });

    it('aRawValueAboveTheLastContentIsIgnored', 0, () => {
      expect(contentOf(RAW_TITLE_AND_ICON + 1).content).assertEqual(CYLMenuFoldControlContent.icon);
    });

    it('theTailControlHasTheSameSizeFoldedAndExpanded', 0, () => {
      const list = makeList(makeControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.titleAndIcon));
      const folded = list.inlineFoldSize(0, false);
      const expanded = list.inlineFoldSize(0, true);
      expect(folded.width).assertEqual(expanded.width);
      expect(folded.height).assertEqual(expanded.height);
      // The icon and title control takes the longer text: "Collapse all" is wider than "More".
      const iconAndTitle = makeList(makeControl(CYLMenuFoldControlPosition.tail,
        CYLMenuFoldControlContent.iconAndTitle));
      expect(folded.width >= iconAndTitle.inlineFoldSize(0, false).width).assertTrue();
    });

    it('theHeaderAndFooterControlsHaveTheSameSizeFoldedAndExpanded', 0, () => {
      [CYLMenuFoldControlPosition.footer, CYLMenuFoldControlPosition.headerTrailing].forEach(
        (position: CYLMenuFoldControlPosition) => {
          const list = makeList(makeControl(position, CYLMenuFoldControlContent.titleAndIcon));
          const folded: CYLSize = list.foldSize(false);
          const expanded: CYLSize = list.foldSize(true);
          expect(folded.width).assertEqual(expanded.width);
          expect(folded.height).assertEqual(expanded.height);
        });
      // The old icon-and-title control does change its width: the expanded one has no title.
      const old = makeList(makeControl(CYLMenuFoldControlPosition.footer, CYLMenuFoldControlContent.iconAndTitle));
      expect(old.foldSize(false).width >= old.foldSize(true).width).assertTrue();
    });

    it('theTitleAndIconControlIsAsWideAsItsLongerTitleNeeds', 0, () => {
      const both = makeList(makeControl(CYLMenuFoldControlPosition.footer, CYLMenuFoldControlContent.titleAndIcon));
      const titleOnly = makeList(makeControl(CYLMenuFoldControlPosition.footer, CYLMenuFoldControlContent.title));
      // Expanded, the title-only control shows "Collapse all" without an icon; the control with the icon is wider.
      expect(both.foldSize(false).width >= titleOnly.foldSize(true).width).assertTrue();
    });

    it('anUnfoldableSectionHeaderReservesNothingForTheControl', 0, () => {
      const folded = makeList(makeControl(CYLMenuFoldControlPosition.headerTrailing,
        CYLMenuFoldControlContent.titleAndIcon));
      const none = makeList(undefined);
      expect(folded.canFoldSection(0)).assertTrue();
      expect(folded.canFoldSection(SECOND_SECTION)).assertFalse();
      expect(folded.showsHeaderFoldControl(0)).assertTrue();
      expect(folded.showsHeaderFoldControl(SECOND_SECTION)).assertFalse();
      // The unfoldable section's header is as it is without a fold control, in height and in the title's room (the
      // 28 character title stays on one line); the foldable section's title lost room to the control and wraps.
      expect(folded.headerHeight(SECOND_SECTION)).assertEqual(none.headerHeight(SECOND_SECTION));
      expect(folded.headerHeight(0) > none.headerHeight(0)).assertTrue();
      const frames: CYLTagListSectionFrame[] = folded.layoutSections();
      expect(frames[0].headerFoldX !== undefined).assertTrue();
      expect(frames[SECOND_SECTION].headerFoldX).assertUndefined();
      expect(frames[SECOND_SECTION].headerHeight).assertEqual(none.layoutSections()[SECOND_SECTION].headerHeight);
    });

    it('anUnfoldableSectionHeaderReservesNothingEvenWhenTheTitlesAreHidden', 0, () => {
      const folded = makeList(makeControl(CYLMenuFoldControlPosition.headerTrailing,
        CYLMenuFoldControlContent.titleAndIcon));
      folded.showsSectionHeaders = false;
      folded.reloadMenuData();
      expect(folded.headerHeight(SECOND_SECTION)).assertEqual(0);
      expect(folded.headerHeight(0) > 0).assertTrue();
    });

    it('theHeaderControlIsAtMostFortyPercentOfTheHeader', 0, () => {
      const control = makeControl(CYLMenuFoldControlPosition.headerTrailing, CYLMenuFoldControlContent.titleAndIcon);
      control.title = LONG_FOLD_TITLE;
      const list = makeList(control);
      const limit = LIST_WIDTH * CYLHeaderFoldMaxWidthFraction;
      expect(CYLHeaderFoldMaxWidthFraction).assertEqual(0.4);
      // The control itself is wider than the limit; in the header it is cut to it, and the title gives way.
      expect(list.foldSize(false).width > limit).assertTrue();
      expect(list.headerFoldSize(false).width).assertEqual(limit);
      expect(list.headerFoldSize(true).width <= limit).assertTrue();
      expect(list.headerFoldSize(false).height).assertEqual(list.foldSize(false).height);
      expect(list.layoutSections()[0].headerFoldX).assertEqual(LIST_WIDTH - SIDE_INSET - limit);
    });

    it('aShortHeaderControlKeepsItsOwnWidth', 0, () => {
      const list = makeList(makeControl(CYLMenuFoldControlPosition.headerTrailing,
        CYLMenuFoldControlContent.titleAndIcon));
      expect(list.headerFoldSize(false).width).assertEqual(list.foldSize(false).width);
      expect(list.foldSize(false).width <= LIST_WIDTH * CYLHeaderFoldMaxWidthFraction).assertTrue();
    });
  });
}

import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import { CYLLiquidGlass } from 'cylanimateditem';
import {
  CYLColor, CYLColorKey, CYLControlState, CYLEdgeInsets, CYLFont, CYLHeaderSeparatorStyle, CYLIndexPath, CYLMenuDataSource, CYLMenuFoldControl,
  CYLMenuFoldControlContent, CYLMenuFoldControlPosition, CYLMenuStyle, CYLRect, CYLSectionStyle, CYLSectionStyleColors,
  CYLSectionStyleMetrics, CYLTagBackgroundStyle, CYLTagButtonMetrics, CYLTintLuminanceThreshold, CYLTagListItemFrame, CYLTagListSectionFrame, CYLTagListState,
  CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const LIST_WIDTH: number = 320;
/** Wide enough for four 70 vp tags in a plain row (310 vp of column), not for four inside a padded card (286 vp). */
const WIDE_WIDTH: number = 342;
const SIDE_INSET: number = 16;
const TOP_INSET: number = 10;
const CARD_PADDING: number = 12;
const DEFAULT_HEADER_INSET: number = 16;
const TAGS_IN_SHORT_SECTION: number = 3;
const EIGHT_TAGS: number = 8;
const RED: string = '#FFFF0000';
const BLUE: string = '#FF0000FF';

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
  list.style = plainStyle();
  list.menuDataSource = new CYLSectionStyleSource();
  list.setLayoutWidth(LIST_WIDTH);
  list.reloadMenuData();
  return list;
}

/** The list of a default style: nothing set, so the rounded section card is on. */
function makeDefaultList(): CYLTagListState {
  const list = new CYLTagListState();
  list.menuDataSource = new CYLSectionStyleSource();
  list.setLayoutWidth(LIST_WIDTH);
  list.reloadMenuData();
  return list;
}

/** The opt-out: a style with no card, so every frame is the one of the time before the section style. */
function plainStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.sectionStyle = CYLSectionStyle.plain;
  return style;
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

/** Two sections of three tags of the same width (70 vp): one row each at any width used here. */
class CYLShortSectionsSource implements CYLMenuDataSource {
  numberOfSectionsInMenu = (): number => 2;
  menuNumberOfItemsInSection = (section: number): number => TAGS_IN_SHORT_SECTION;
  menuTitleForSection = (section: number): string => `Section ${section}`;
  menuTitleForItem = (indexPath: CYLIndexPath): string => `Tag ${indexPath.item}`;
}

/** Eight tags of the same width (70 vp): four fit a plain row at WIDE_WIDTH, only three fit a padded card's row. */
class CYLEightTagsSource implements CYLMenuDataSource {
  numberOfSectionsInMenu = (): number => 1;
  menuNumberOfItemsInSection = (section: number): number => EIGHT_TAGS;
  menuTitleForSection = (section: number): string => 'Section';
  menuTitleForItem = (indexPath: CYLIndexPath): string => `Tag ${indexPath.item}`;
}

function listWith(source: CYLMenuDataSource, style: CYLMenuStyle, width: number): CYLTagListState {
  const list = new CYLTagListState();
  list.style = style;
  list.menuDataSource = source;
  list.setLayoutWidth(width);
  list.reloadMenuData();
  return list;
}

function groupedStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.sectionStyle = CYLSectionStyle.insetGrouped;
  return style;
}

function configured(styleJson: string): CYLMenuStyle {
  return CYLTagListState.withConfiguration(
    JSON.parse(`{"style":${styleJson},"sections":[{"items":["a"]}]}`) as Record<string, Object>).style;
}

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

    it('theDefaultStyleIsTheRoundedSectionCard', 0, () => {
      const style = new CYLMenuStyle();
      expect(style.sectionStyle).assertEqual(CYLSectionStyle.insetGrouped);
      expect(style.isInsetGrouped).assertTrue();
      const list = makeDefaultList();
      expect(list.style.sectionStyle).assertEqual(CYLSectionStyle.insetGrouped);
      list.layoutSections().forEach((s: CYLTagListSectionFrame) => {
        const card = s.card as CYLRect;
        expect(card !== undefined).assertTrue();
        expect(card.x).assertEqual(SIDE_INSET);
        expect(card.width).assertEqual(LIST_WIDTH - 2 * SIDE_INSET);
        // The tags sit inside the card, so the first one starts one card padding after the column's edge.
        expect(s.items[0].x).assertEqual(SIDE_INSET + CARD_PADDING);
      });
      // Nothing was set, yet the frames are those of the explicit insetGrouped style and not the plain ones.
      const grouped = listWith(new CYLSectionStyleSource(), groupedStyle(), LIST_WIDTH);
      expect(snapshot(list)).assertEqual(snapshot(grouped));
      expect(snapshot(list) === DEFAULT_FRAMES).assertFalse();
      expect(list.contentHeight > makeList().contentHeight).assertTrue();
    });

    it('theDefaultDividerBandAndCardBackgroundStyleStayOff', 0, () => {
      const style = new CYLMenuStyle();
      expect(style.headerSeparatorStyle).assertEqual(CYLHeaderSeparatorStyle.none);
      expect(style.headerBackgroundColor === undefined).assertTrue();
      expect(style.sectionBackgroundStyle).assertEqual(CYLTagBackgroundStyle.flat);
      makeDefaultList().layoutSections().forEach((s: CYLTagListSectionFrame) => {
        expect(s.headerSeparator === undefined).assertTrue();
        expect(s.headerBand === undefined).assertTrue();
      });
    });

    it('theGroupedBackgroundRuleAppliesToADefaultList', 0, () => {
      // An app that never set backgroundColor gets the grouped background under the default card.
      expect(new CYLTagListState().style.resolvedBackgroundColor()).assertEqual(CYLSectionStyleColors.groupedBackground);
      expect(new CYLMenuStyle().resolvedBackgroundColor()).assertEqual(CYLSectionStyleColors.groupedBackground);
      // An app that set one keeps it, and the plain opt-out keeps today's white.
      const set = new CYLMenuStyle();
      set.backgroundColor = RED;
      expect(set.resolvedBackgroundColor()).assertEqual(RED);
      expect(plainStyle().resolvedBackgroundColor()).assertEqual(CYLColor.WHITE);
    });

    it('thePlainOptOutGivesTheFramesOfBeforeTheSectionStyle', 0, () => {
      const list = makeList();
      expect(snapshot(list)).assertEqual(DEFAULT_FRAMES);
      // The header: today's inset on both sides, and no card, band or divider.
      list.layoutSections().forEach((s: CYLTagListSectionFrame) => {
        expect(s.headerInsetLeft).assertEqual(DEFAULT_HEADER_INSET);
        expect(s.headerInsetRight).assertEqual(DEFAULT_HEADER_INSET);
        expect(s.card === undefined).assertTrue();
        expect(s.headerBand === undefined).assertTrue();
        expect(s.headerSeparator === undefined).assertTrue();
      });
      // The default list background is the system background resource (white in light mode, black in dark mode).
      expect(list.style.resolvedBackgroundColor()).assertEqual(CYLSectionStyleColors.listBackground);
    });

    it('theCardContainsEveryTagFrameOfItsSection', 0, () => {
      const list = listWith(new CYLSectionStyleSource(), groupedStyle(), LIST_WIDTH);
      list.layoutSections().forEach((s: CYLTagListSectionFrame) => {
        const card = s.card as CYLRect;
        expect(card !== undefined).assertTrue();
        expect(card.x).assertEqual(SIDE_INSET);
        expect(card.width).assertEqual(LIST_WIDTH - 2 * SIDE_INSET);
        expect(s.items.length > 0).assertTrue();
        s.items.forEach((c: CYLTagListItemFrame) => {
          expect(c.x >= card.x + CARD_PADDING).assertTrue();
          expect(c.x + c.width <= card.maxX - CARD_PADDING).assertTrue();
          expect(c.y >= card.y + CARD_PADDING).assertTrue();
          expect(c.y + c.height <= card.maxY - CARD_PADDING).assertTrue();
        });
        // The card sits below the header and ends inside the section.
        expect(card.y).assertEqual(s.y + s.headerHeight + TOP_INSET);
        expect(card.maxY <= s.y + s.height).assertTrue();
      });
    });

    it('rowsAreCountedAtTheReducedWidthSoTagsWrapEarlierInsideAPaddedCard', 0, () => {
      const plain = listWith(new CYLEightTagsSource(), plainStyle(), WIDE_WIDTH);
      const grouped = listWith(new CYLEightTagsSource(), groupedStyle(), WIDE_WIDTH);
      expect(plain.numberOfRows(0)).assertEqual(2);
      expect(grouped.numberOfRows(0)).assertEqual(3);
      expect(plain.tagColumn(0).width).assertEqual(WIDE_WIDTH - 2 * SIDE_INSET);
      expect(grouped.tagColumn(0).width).assertEqual(WIDE_WIDTH - 2 * SIDE_INSET - 2 * CARD_PADDING);
      expect(grouped.tagColumn(0).x).assertEqual(SIDE_INSET + CARD_PADDING);
    });

    it('theCardPaddingAddsTopAndBottomToTheSectionHeightAndTheContentHeight', 0, () => {
      const plain = listWith(new CYLShortSectionsSource(), plainStyle(), WIDE_WIDTH);
      const grouped = listWith(new CYLShortSectionsSource(), groupedStyle(), WIDE_WIDTH);
      expect(grouped.numberOfRows(0)).assertEqual(plain.numberOfRows(0));
      expect(grouped.contentHeight).assertEqual(plain.contentHeight + 2 * 2 * CARD_PADDING);
      expect(grouped.heightThatFitsWidth(WIDE_WIDTH)).assertEqual(grouped.contentHeight);
      expect(plain.heightThatFitsWidth(WIDE_WIDTH)).assertEqual(plain.contentHeight);
    });

    it('theHeaderTitleXEqualsTheTagsLeadingXUnderInsetGrouped', 0, () => {
      const list = listWith(new CYLSectionStyleSource(), groupedStyle(), LIST_WIDTH);
      list.layoutSections().forEach((s: CYLTagListSectionFrame) => {
        expect(s.headerInsetLeft).assertEqual(s.items[0].x);
        expect(s.headerInsetLeft).assertEqual(SIDE_INSET + CARD_PADDING);
        expect(s.headerInsetRight).assertEqual(SIDE_INSET + CARD_PADDING);
      });
    });

    it('aPlainHeaderWithABandInsetsItsTitleFromTheBand', 0, () => {
      const style = plainStyle();
      style.headerBackgroundColor = CYLSectionStyleColors.headerBand;
      const list = listWith(new CYLSectionStyleSource(), style, LIST_WIDTH);
      list.layoutSections().forEach((s: CYLTagListSectionFrame) => {
        const band = s.headerBand as CYLRect;
        expect(band.x).assertEqual(SIDE_INSET);
        expect(band.y).assertEqual(s.y);
        expect(band.width).assertEqual(LIST_WIDTH - 2 * SIDE_INSET);
        expect(band.height).assertEqual(s.headerHeight);
        expect(s.headerInsetLeft).assertEqual(SIDE_INSET + CYLSectionStyleMetrics.headerBandPadding);
        expect(s.card === undefined).assertTrue();
      });
      // A band moves no tag.
      expect(snapshot(list)).assertEqual(DEFAULT_FRAMES);
    });

    it('theDividerSitsAtTheHeaderBottomAndAddsNoHeight', 0, () => {
      const style = plainStyle();
      style.headerSeparatorStyle = CYLHeaderSeparatorStyle.line;
      const list = listWith(new CYLSectionStyleSource(), style, LIST_WIDTH);
      expect(snapshot(list)).assertEqual(DEFAULT_FRAMES);
      list.layoutSections().forEach((s: CYLTagListSectionFrame) => {
        const line = s.headerSeparator as CYLRect;
        expect(line.height).assertEqual(CYLSectionStyleMetrics.separatorThickness);
        expect(line.y + line.height).assertEqual(s.y + s.headerHeight);
        // The same left and right as the card and the band: the column's edges, not the title's x.
        expect(line.x).assertEqual(SIDE_INSET);
        expect(line.maxX).assertEqual(LIST_WIDTH - SIDE_INSET);
      });
      style.headerSeparatorInsets = new CYLEdgeInsets(0, 40, 0, 8);
      list.style = style;
      const inset = list.layoutSections()[0].headerSeparator as CYLRect;
      expect(inset.x).assertEqual(SIDE_INSET + 40);
      expect(inset.maxX).assertEqual(LIST_WIDTH - SIDE_INSET - 8);
    });

    it('theTagsFoldAtTheReducedWidth', 0, () => {
      const plain = plainStyle();
      const grouped = groupedStyle();
      [plain, grouped].forEach((style: CYLMenuStyle) => {
        const list = new CYLTagListState();
        list.style = style;
        list.menuDataSource = new CYLEightTagsSource();
        list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.headerTrailing,
          CYLMenuFoldControlContent.icon);
        list.defaultVisibleRows = 2;
        list.setLayoutWidth(WIDE_WIDTH);
        list.reloadMenuData();
        // Two rows fit exactly in a plain section; three rows inside a card need the fold.
        expect(list.canFoldSection(0)).assertEqual(style === grouped);
      });
    });

    it('unsetColorsResolveToTheColorModeAwareDefaults', 0, () => {
      const style = new CYLMenuStyle();
      expect(style.sectionBackgroundColor === undefined).assertTrue();
      expect(style.headerBackgroundColor === undefined).assertTrue();
      expect(style.headerSeparatorColor === undefined).assertTrue();
      // The named resources hold the light and the dark values (resources/base and resources/dark).
      expect(style.resolvedSectionBackgroundColor()).assertEqual(CYLSectionStyleColors.card);
      expect(style.resolvedHeaderSeparatorColor()).assertEqual(CYLSectionStyleColors.separator);
      style.sectionBackgroundColor = RED;
      style.headerSeparatorColor = BLUE;
      expect(style.resolvedSectionBackgroundColor()).assertEqual(RED);
      expect(style.resolvedHeaderSeparatorColor()).assertEqual(BLUE);
    });

    it('insetGroupedUsesTheGroupedBackgroundOnlyWhenTheAppNeverSetOne', 0, () => {
      expect(groupedStyle().resolvedBackgroundColor()).assertEqual(CYLSectionStyleColors.groupedBackground);
      const set = groupedStyle();
      set.backgroundColor = CYLColor.CLEAR;
      expect(set.resolvedBackgroundColor()).assertEqual(CYLColor.CLEAR);
      expect(set.copy().resolvedBackgroundColor()).assertEqual(CYLColor.CLEAR);
      expect(groupedStyle().copy().resolvedBackgroundColor()).assertEqual(CYLSectionStyleColors.groupedBackground);
      expect(plainStyle().resolvedBackgroundColor()).assertEqual(CYLSectionStyleColors.listBackground);
    });

    it('theDefaultListBackgroundIsTheModeFollowingResourceAndASetColorWins', 0, () => {
      const style = plainStyle();
      // Unset: the named resource (resources/base white, resources/dark black), never a string baked at build time.
      expect(typeof style.resolvedBackgroundColor() === 'string').assertFalse();
      expect(style.resolvedBackgroundColor()).assertEqual(CYLSectionStyleColors.listBackground);
      expect(style.backgroundColor).assertEqual(CYLSectionStyleColors.listBackground);
      expect(style.isBackgroundColorSet).assertFalse();
      expect(style.copy().resolvedBackgroundColor()).assertEqual(CYLSectionStyleColors.listBackground);
      expect(CYLColorKey(CYLSectionStyleColors.listBackground) === CYLColorKey(CYLSectionStyleColors.groupedBackground)).assertFalse();
      // A resource background gives the system-mode tint, which flips with the resource.
      expect(CYLColorKey(style.resolvedTintColor())).assertEqual(CYLColorKey(CYLSectionStyleColors.systemTint));
      // A set color, a clear one included, wins and is copied.
      style.backgroundColor = CYLColor.CLEAR;
      expect(style.isBackgroundColorSet).assertTrue();
      expect(style.resolvedBackgroundColor()).assertEqual(CYLColor.CLEAR);
      expect(style.copy().resolvedBackgroundColor()).assertEqual(CYLColor.CLEAR);
      style.backgroundColor = RED;
      expect(style.resolvedBackgroundColor()).assertEqual(RED);
    });

    it('copyKeepsTheSectionStyle', 0, () => {
      const style = groupedStyle();
      style.sectionCornerRadius = 6;
      style.headerCornerRadius = 4;
      style.headerBackgroundColor = RED;
      style.headerSeparatorStyle = CYLHeaderSeparatorStyle.line;
      style.headerSeparatorThickness = 2;
      style.headerSeparatorInsets = new CYLEdgeInsets(0, 3, 0, 5);
      const c = style.copy();
      expect(c.sectionStyle).assertEqual(CYLSectionStyle.insetGrouped);
      expect(c.sectionCornerRadius).assertEqual(6);
      expect(c.headerCornerRadius).assertEqual(4);
      expect(c.headerBackgroundColor).assertEqual(RED);
      expect(c.headerSeparatorStyle).assertEqual(CYLHeaderSeparatorStyle.line);
      expect(c.headerSeparatorThickness).assertEqual(2);
      expect((c.headerSeparatorInsets as CYLEdgeInsets).right).assertEqual(5);
      expect(new CYLMenuStyle().sectionCornerRadius).assertEqual(CYLSectionStyleMetrics.cardCornerRadius);
      expect(new CYLMenuStyle().sectionContentInsets.left).assertEqual(CYLSectionStyleMetrics.cardPadding);
    });

    it('theCardBackgroundStyleIsFlatByDefaultAndCopyKeepsIt', 0, () => {
      const style = new CYLMenuStyle();
      expect(style.sectionBackgroundStyle).assertEqual(CYLTagBackgroundStyle.flat);
      expect(style.resolvedSectionBackgroundStyle()).assertEqual(CYLTagBackgroundStyle.flat);
      style.sectionBackgroundStyle = CYLTagBackgroundStyle.liquidGlass;
      expect(style.copy().sectionBackgroundStyle).assertEqual(CYLTagBackgroundStyle.liquidGlass);
      expect(groupedStyle().copy().sectionBackgroundStyle).assertEqual(CYLTagBackgroundStyle.flat);
    });

    it('theCardBackgroundStyleKeyParses', 0, () => {
      expect(configured('{"sectionBackgroundStyle":"liquidGlass"}').sectionBackgroundStyle)
        .assertEqual(CYLTagBackgroundStyle.liquidGlass);
      expect(configured('{"sectionBackgroundStyle":"LIQUIDGLASS"}').sectionBackgroundStyle)
        .assertEqual(CYLTagBackgroundStyle.liquidGlass);
      expect(configured('{"sectionBackgroundStyle":"flat"}').sectionBackgroundStyle)
        .assertEqual(CYLTagBackgroundStyle.flat);
      expect(configured('{"sectionBackgroundStyle":"bogus"}').sectionBackgroundStyle)
        .assertEqual(CYLTagBackgroundStyle.flat);
      expect(configured('{}').sectionBackgroundStyle).assertEqual(CYLTagBackgroundStyle.flat);
    });

    it('glassFallsBackToFlatWhereNoGlassIsDrawnAndTheGeometryNeverChanges', 0, () => {
      const glass = groupedStyle();
      glass.sectionBackgroundStyle = CYLTagBackgroundStyle.liquidGlass;
      const flat = groupedStyle();
      const savedOverride = CYLLiquidGlass.activeOverride;
      try {
        CYLLiquidGlass.activeOverride = false;
        expect(glass.resolvedSectionBackgroundStyle()).assertEqual(CYLTagBackgroundStyle.flat);
        expect(glass.resolvedSectionBackgroundColor()).assertEqual(CYLSectionStyleColors.card);
        const inactive = snapshot(listWith(new CYLSectionStyleSource(), glass, LIST_WIDTH));
        expect(inactive).assertEqual(snapshot(listWith(new CYLSectionStyleSource(), flat, LIST_WIDTH)));
        CYLLiquidGlass.activeOverride = true;
        expect(glass.resolvedSectionBackgroundStyle()).assertEqual(CYLTagBackgroundStyle.liquidGlass);
        expect(snapshot(listWith(new CYLSectionStyleSource(), glass, LIST_WIDTH))).assertEqual(inactive);
        const glassList = listWith(new CYLSectionStyleSource(), glass, LIST_WIDTH);
        const flatList = listWith(new CYLSectionStyleSource(), flat, LIST_WIDTH);
        glassList.layoutSections().forEach((s: CYLTagListSectionFrame, i: number) => {
          const a = s.card as CYLRect;
          const b = flatList.layoutSections()[i].card as CYLRect;
          expect(`${a.x},${a.y},${a.width},${a.height}`).assertEqual(`${b.x},${b.y},${b.width},${b.height}`);
        });
      } finally {
        CYLLiquidGlass.activeOverride = savedOverride;
      }
    });

    it('theGlassCardTintIsTheAppColorElseTheModeAwareDefault', 0, () => {
      const style = groupedStyle();
      style.sectionBackgroundStyle = CYLTagBackgroundStyle.liquidGlass;
      const savedOverride = CYLLiquidGlass.activeOverride;
      try {
        CYLLiquidGlass.activeOverride = true;
        // Unset: the resource tint (resources/base light, resources/dark dark), not a string baked at build time.
        expect(style.resolvedSectionBackgroundColor()).assertEqual(CYLSectionStyleColors.glassTint);
        expect(CYLSectionStyleColors.glassTint === CYLSectionStyleColors.card).assertFalse();
        // Set: the app's color wins in both modes.
        style.sectionBackgroundColor = RED;
        expect(style.resolvedSectionBackgroundColor()).assertEqual(RED);
        expect(style.copy().resolvedSectionBackgroundColor()).assertEqual(RED);
      } finally {
        CYLLiquidGlass.activeOverride = savedOverride;
      }
    });

    it('everyUnsetColorIsItsOwnModeAwareResourceAndASetColorWins', 0, () => {
      // Each named color is one ResourceColor, so the system picks its resources/base value in light mode and its
      // resources/dark value in dark mode while the list is shown; no unset color is a string.
      const named: ResourceColor[] = [CYLSectionStyleColors.card, CYLSectionStyleColors.headerBand,
        CYLSectionStyleColors.groupedBackground, CYLSectionStyleColors.separator, CYLSectionStyleColors.glassTint];
      named.forEach((color: ResourceColor) => expect(typeof color === 'string' || typeof color === 'number').assertFalse());
      const style = groupedStyle();
      expect(style.resolvedBackgroundColor()).assertEqual(CYLSectionStyleColors.groupedBackground);
      expect(style.resolvedSectionBackgroundColor()).assertEqual(CYLSectionStyleColors.card);
      expect(style.resolvedHeaderSeparatorColor()).assertEqual(CYLSectionStyleColors.separator);
      expect(style.headerBackgroundColor === undefined).assertTrue();
      style.backgroundColor = RED;
      style.sectionBackgroundColor = BLUE;
      style.headerBackgroundColor = RED;
      style.headerSeparatorColor = BLUE;
      expect(style.resolvedBackgroundColor()).assertEqual(RED);
      expect(style.resolvedSectionBackgroundColor()).assertEqual(BLUE);
      expect(style.headerBackgroundColor).assertEqual(RED);
      expect(style.resolvedHeaderSeparatorColor()).assertEqual(BLUE);
    });

    it('theConfigurationKeysParse', 0, () => {
      const style = configured('{"sectionStyle":"insetGrouped","sectionBackgroundColor":"#112233",' +
        '"sectionCornerRadius":6,"sectionContentInsets":[1,2,3,4],"headerBackgroundColor":"#EFEFF4",' +
        '"headerCornerRadius":5,"headerContentInsets":[0,7,0,9],"headerSeparatorStyle":"line",' +
        '"headerSeparatorColor":"#FF0000","headerSeparatorThickness":1,"headerSeparatorInsets":[0,3,0,5]}');
      expect(style.sectionStyle).assertEqual(CYLSectionStyle.insetGrouped);
      expect(style.sectionBackgroundColor).assertEqual('#FF112233');
      expect(style.sectionCornerRadius).assertEqual(6);
      expect(style.sectionContentInsets.top).assertEqual(1);
      expect(style.sectionContentInsets.right).assertEqual(4);
      expect(style.headerBackgroundColor).assertEqual('#FFEFEFF4');
      expect(style.headerCornerRadius).assertEqual(5);
      expect(style.headerContentInsets.left).assertEqual(7);
      expect(style.headerSeparatorStyle).assertEqual(CYLHeaderSeparatorStyle.line);
      expect(style.headerSeparatorColor).assertEqual('#FFFF0000');
      expect(style.headerSeparatorThickness).assertEqual(1);
      expect((style.headerSeparatorInsets as CYLEdgeInsets).left).assertEqual(3);
      // Names are case-insensitive, raw values work, and an unknown value keeps the default.
      expect(configured('{"sectionStyle":"INSETGROUPED"}').sectionStyle).assertEqual(CYLSectionStyle.insetGrouped);
      expect(configured('{"sectionStyle":0}').sectionStyle).assertEqual(CYLSectionStyle.plain);
      // The opt-out key, and the default when the key is missing.
      expect(configured('{"sectionStyle":"plain"}').sectionStyle).assertEqual(CYLSectionStyle.plain);
      expect(configured('{"sectionStyle":"PLAIN"}').sectionStyle).assertEqual(CYLSectionStyle.plain);
      expect(configured('{}').sectionStyle).assertEqual(CYLSectionStyle.insetGrouped);
      expect(configured('{"sectionStyle":"bogus","headerSeparatorStyle":"bogus"}').sectionStyle)
        .assertEqual(CYLSectionStyle.insetGrouped);
      expect(configured('{"headerSeparatorStyle":"bogus"}').headerSeparatorStyle)
        .assertEqual(CYLHeaderSeparatorStyle.none);
    });

    it('theDefaultTintFollowsTheLuminanceOfTheListBackground', 0, () => {
      const system = $r('sys.color.font_primary');
      const light = new CYLMenuStyle();
      light.backgroundColor = '#FFF2F2F7';
      const dark = new CYLMenuStyle();
      dark.backgroundColor = '#FF101010';
      // Dark on a light list and light on a dark one, whatever the system mode (these are fixed colors, not resources).
      expect(light.resolvedTintColor()).assertEqual(CYLColor.BLACK);
      expect(dark.resolvedTintColor()).assertEqual(CYLColor.WHITE);
      expect(light.resolvedHeaderTextColor()).assertEqual(CYLColor.BLACK);
      expect(dark.resolvedFoldControlColor()).assertEqual(CYLColor.WHITE);
      expect(dark.resolvedMoreButtonColor()).assertEqual(CYLColor.WHITE);
      expect(CYLMenuStyle.tintOn('#FF808080')).assertEqual(CYLColor.BLACK);
      expect(CYLMenuStyle.tintOn('#FF404040')).assertEqual(CYLColor.WHITE);
      expect(CYLTintLuminanceThreshold > 0 && CYLTintLuminanceThreshold < 1).assertTrue();
      // Unset under insetGrouped: the grouped background is a resource that follows the mode, so does the tint.
      const grouped = new CYLMenuStyle();
      grouped.sectionStyle = CYLSectionStyle.insetGrouped;
      expect(CYLColorKey(grouped.resolvedTintColor())).assertEqual(CYLColorKey(system));
    });

    it('anUnsetTintOnATransparentListKeepsTheResourceDefaults', 0, () => {
      const system = CYLColorKey($r('sys.color.font_primary'));
      const style = new CYLMenuStyle();
      style.backgroundColor = CYLColor.CLEAR;
      expect(CYLColorKey(style.resolvedTintColor())).assertEqual(system);
      expect(CYLColorKey(style.resolvedHeaderTextColor())).assertEqual(system);
      expect(CYLColorKey(style.resolvedFoldControlColor())).assertEqual(system);
      expect(CYLColorKey(style.resolvedMoreButtonColor())).assertEqual(system);
      expect(CYLColorKey(style.headerTextColor)).assertEqual(system);
      expect(CYLColorKey(style.foldControlColor)).assertEqual(system);
      expect(CYLColorKey(style.moreButtonColor)).assertEqual(system);
    });

    it('aSetTintColorWinsAndIndividualColorsWinOverIt', 0, () => {
      const style = new CYLMenuStyle();
      style.backgroundColor = '#FFFFFFFF';
      style.tintColor = RED;
      expect(style.resolvedTintColor()).assertEqual(RED);
      expect(style.resolvedHeaderTextColor()).assertEqual(RED);
      expect(style.resolvedFoldControlColor(true)).assertEqual(RED);
      expect(style.resolvedMoreButtonColor()).assertEqual(RED);
      // A color set on one view wins over the tint for that view only.
      style.headerTextColor = BLUE;
      style.moreButtonColor = '#FF00FF00';
      expect(style.resolvedHeaderTextColor()).assertEqual(BLUE);
      expect(style.resolvedMoreButtonColor()).assertEqual('#FF00FF00');
      expect(style.resolvedFoldControlColor()).assertEqual(RED);
      // Without a tint the individually set colors still win over the luminance default.
      const plain = new CYLMenuStyle();
      plain.backgroundColor = '#FF000000';
      plain.foldControlColor = BLUE;
      expect(plain.resolvedFoldControlColor()).assertEqual(BLUE);
      expect(plain.resolvedHeaderTextColor()).assertEqual(CYLColor.WHITE);
    });

    it('theBandColorIsTheBackgroundOfTheTintUnderABand', 0, () => {
      const style = new CYLMenuStyle();
      style.backgroundColor = '#FFFFFFFF';
      style.headerBackgroundColor = '#FF202020';
      expect(style.resolvedTintColor(false)).assertEqual(CYLColor.BLACK);
      expect(style.resolvedTintColor(true)).assertEqual(CYLColor.WHITE);
      expect(style.resolvedHeaderTextColor(true)).assertEqual(CYLColor.WHITE);
      // A band on a dark list with a light band color.
      const reverse = new CYLMenuStyle();
      reverse.backgroundColor = '#FF000000';
      reverse.headerBackgroundColor = '#FFEFEFF4';
      expect(reverse.resolvedTintColor(false)).assertEqual(CYLColor.WHITE);
      expect(reverse.resolvedTintColor(true)).assertEqual(CYLColor.BLACK);
      // No band set: the list background decides, whatever `onBand` says.
      expect(CYLColorKey(plainStyle().resolvedTintColor(true))).assertEqual(CYLColorKey(CYLSectionStyleColors.systemTint));
    });

    it('theFoldChevronIsDrawnInTheResolvedTint', 0, () => {
      // The chevron icon is the fold control's image, tinted with the style's resolved fold color (the value the view reads).
      const control = new CYLMenuFoldControl();
      expect(control.usesDefaultImage).assertTrue();
      const style = plainStyle();
      const onDefault = CYLTagFoldMetrics.style(control, style.resolvedFoldControlColor());
      // Unset list background: the mode-following system tint, so the chevron is light in dark mode.
      expect(CYLColorKey(onDefault.iconColor(CYLControlState.NORMAL)))
        .assertEqual(CYLColorKey(CYLSectionStyleColors.systemTint));
      expect(CYLColorKey(onDefault.appearance(CYLControlState.NORMAL).textColor))
        .assertEqual(CYLColorKey(onDefault.iconColor(CYLControlState.NORMAL)));
      // A set tint wins for the text and the chevron alike.
      style.tintColor = RED;
      const tinted = CYLTagFoldMetrics.style(control, style.resolvedFoldControlColor());
      expect(tinted.iconColor(CYLControlState.NORMAL)).assertEqual(RED);
      // The control's own color still wins.
      control.color = BLUE;
      expect(CYLTagFoldMetrics.style(control, style.resolvedFoldControlColor()).iconColor(CYLControlState.NORMAL))
        .assertEqual(BLUE);
    });

    it('theTintColorKeyParsesAndCopyKeepsIt', 0, () => {
      expect(configured('{"tintColor":"#112233"}').tintColor).assertEqual('#FF112233');
      expect(configured('{}').tintColor).assertUndefined();
      const style = new CYLMenuStyle();
      style.tintColor = RED;
      style.headerTextColor = BLUE;
      const copy = style.copy();
      expect(copy.tintColor).assertEqual(RED);
      expect(copy.headerTextColor).assertEqual(BLUE);
      // A color the app never set stays unset in the copy, so the tint still applies there.
      const unset = new CYLMenuStyle();
      unset.tintColor = RED;
      expect(unset.copy().resolvedFoldControlColor()).assertEqual(RED);
    });
  });
}

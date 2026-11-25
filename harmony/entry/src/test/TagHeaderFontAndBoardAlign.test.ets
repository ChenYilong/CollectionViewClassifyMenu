import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLDefaultHeaderFontSize, CYLDefaultHeaderFontWeight, CYLFont, CYLIndexPath, CYLLayoutDirection, CYLMenuDataSource,
  CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition, CYLMenuStyle, CYLRect, CYLSectionStyle,
  CYLEdgeInsets, CYLTagButtonMetrics, CYLTagListItemFrame, CYLTagListSectionFrame, CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const LIST_WIDTH: number = 320;
/** The default section insets, left and right. */
const SIDE_INSET: number = 16;
const CARD_PADDING: number = 12;
/** A board inset other than the default, for the override tests. */
const WIDE_BOARD_INSET: number = 20;
const NEGATIVE_INSET: number = 5;
/** The first version's numbers in a 320 list with the default section insets: board 16 ... 304, content 28 ... 292. */
const BOARD_LEFT: number = 16;
const BOARD_RIGHT: number = 304;
const CONTENT_LEFT: number = 28;
const CONTENT_RIGHT: number = 292;
const CONTENT_TOP: number = 7;
const CONTENT_BOTTOM: number = 9;
const CONTENT_LEADING: number = 30;
const CONTENT_TRAILING: number = 40;
const EIGHT_TAGS: number = 8;
const HEADER_FONT_SIZE: number = 17;
const OLD_HEADER_FONT_SIZE: number = 14;
const HEADER_VERTICAL_PADDING: number = 12;
const DEFAULT_HEADER_HEIGHT: number = 36;
const LARGE_FONT_SCALE: number = 2.0;

class CYLBoardSource implements CYLMenuDataSource {
  numberOfSectionsInMenu = (): number => 1;
  menuNumberOfItemsInSection = (section: number): number => EIGHT_TAGS;
  menuTitleForSection = (section: number): string => 'Section';
  menuTitleForItem = (indexPath: CYLIndexPath): string => `Tag ${indexPath.item < 10 ? '0' : ''}${indexPath.item}`;
}

function styleOf(sectionStyle: CYLSectionStyle): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.sectionStyle = sectionStyle;
  return style;
}

/** A foldable list (one visible row of eight tags) whose fold control sits in the header at `position`. */
function foldList(sectionStyle: CYLSectionStyle, position: CYLMenuFoldControlPosition,
  direction: CYLLayoutDirection): CYLTagListState {
  const list = new CYLTagListState();
  list.style = styleOf(sectionStyle);
  list.menuDataSource = new CYLBoardSource();
  list.layoutDirection = direction;
  list.setLayoutWidth(LIST_WIDTH);
  list.defaultVisibleRows = 1;
  list.foldControl = new CYLMenuFoldControl(position, CYLMenuFoldControlContent.title);
  list.reloadMenuData();
  return list;
}

/** A list of eight tags (no fold control) with the style as given. */
function boardList(style: CYLMenuStyle, direction: CYLLayoutDirection): CYLTagListState {
  const list = new CYLTagListState();
  list.style = style;
  list.menuDataSource = new CYLBoardSource();
  list.layoutDirection = direction;
  list.setLayoutWidth(LIST_WIDTH);
  list.reloadMenuData();
  return list;
}

/** Every frame number of a section that depends on the horizontal board inset, as one comparable string. */
function frameKey(frame: CYLTagListSectionFrame): string {
  const card = frame.card;
  const parts: string[] = [`h${frame.height} t${frame.headerTitleLeadingX} l${frame.headerInsetLeft} r${frame.headerInsetRight}`,
    `c${card?.x},${card?.y},${card?.width},${card?.height}`];
  frame.items.forEach((c: CYLTagListItemFrame) => {
    parts.push(`${c.x},${c.y},${c.width},${c.height}`);
  });
  return parts.join('|');
}

function firstSection(list: CYLTagListState): CYLTagListSectionFrame {
  return list.layoutSections()[0];
}

/** The one-line header height of a style with no minimum height, so that only the font decides it. */
function lineOnlyHeader(font: CYLFont | undefined): number {
  const style = styleOf(CYLSectionStyle.plain);
  style.headerHeight = 0;
  if (font !== undefined) {
    style.headerFont = font;
  }
  const list = new CYLTagListState();
  list.style = style;
  list.menuDataSource = new CYLBoardSource();
  list.setLayoutWidth(LIST_WIDTH);
  list.reloadMenuData();
  return list.headerHeight();
}

/**
 * The section header is a header (17 semibold by default) and is always aligned with the tags (one content column; the
 * board is drawn around it, `sectionBoardInset` unset is 12, 0 hugs); the plain style keeps the column's edges.
 */
export default function tagHeaderFontAndBoardAlignTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagHeaderFontAndBoardAlign', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('theDefaultHeaderFontIsSeventeenSemibold', 0, () => {
      const style = new CYLMenuStyle();
      expect(CYLDefaultHeaderFontSize).assertEqual(HEADER_FONT_SIZE);
      expect(style.headerFont.size).assertEqual(HEADER_FONT_SIZE);
      expect(style.headerFont.weight).assertEqual(CYLDefaultHeaderFontWeight);
      // Heavier than regular and the font a header scales from.
      expect(style.headerFont.weight === FontWeight.Normal).assertFalse();
      expect(style.headerFontFor(1).size).assertEqual(HEADER_FONT_SIZE);
      expect(style.copy().headerFont.size).assertEqual(HEADER_FONT_SIZE);
      expect(style.copy().headerFont.weight).assertEqual(CYLDefaultHeaderFontWeight);
      // An app's own header font wins.
      style.headerFont = CYLFont.systemFont(OLD_HEADER_FONT_SIZE);
      expect(style.headerFontFor(1).size).assertEqual(OLD_HEADER_FONT_SIZE);
      expect(style.headerFontFor(1).weight).assertEqual(FontWeight.Normal);
    });

    it('theHeaderGrowsForTheLargerFontAndKeepsItsMinimumHeight', 0, () => {
      const old = lineOnlyHeader(CYLFont.systemFont(OLD_HEADER_FONT_SIZE));
      const current = lineOnlyHeader(undefined);
      const line = Math.ceil(CYLTagButtonMetrics.lineHeight(new CYLMenuStyle().headerFont));
      expect(current).assertEqual(line + HEADER_VERTICAL_PADDING);
      expect(current > old).assertTrue();
      // The default minimum height (36) still holds the 17 vp line, so a default list keeps its header height.
      const list = new CYLTagListState();
      list.style = styleOf(CYLSectionStyle.plain);
      list.menuDataSource = new CYLBoardSource();
      list.setLayoutWidth(LIST_WIDTH);
      list.reloadMenuData();
      expect(list.headerHeight()).assertEqual(DEFAULT_HEADER_HEIGHT);
      // A larger system font grows it past the minimum.
      list.fontScale = LARGE_FONT_SCALE;
      list.reloadMenuData();
      expect(list.headerHeight() > DEFAULT_HEADER_HEIGHT).assertTrue();
    });

    it('theTitleStartsAtTheFirstTagInPlainAndInsetGroupedLtrAndRtl', 0, () => {
      const styles: CYLSectionStyle[] = [CYLSectionStyle.plain, CYLSectionStyle.insetGrouped];
      styles.forEach((sectionStyle: CYLSectionStyle) => {
        const ltr = firstSection(foldList(sectionStyle, CYLMenuFoldControlPosition.headerTrailing, CYLLayoutDirection.ltr));
        const rtl = firstSection(foldList(sectionStyle, CYLMenuFoldControlPosition.headerTrailing, CYLLayoutDirection.rtl));
        expect(ltr.headerTitleLeadingX).assertEqual(ltr.items[0].x);
        expect(rtl.headerTitleLeadingX).assertEqual(rtl.items[0].x + rtl.items[0].width);
      });
      const grouped = firstSection(foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerTrailing,
        CYLLayoutDirection.ltr));
      expect(grouped.headerTitleLeadingX).assertEqual(CONTENT_LEFT);
      expect(grouped.headerInsetLeft).assertEqual(CONTENT_LEFT);
      expect(grouped.headerInsetRight).assertEqual(LIST_WIDTH - CONTENT_RIGHT);
    });

    it('theFoldControlEndsAtTheTagsTrailingEdgeUnderInsetGrouped', 0, () => {
      const trailing = foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerTrailing,
        CYLLayoutDirection.ltr);
      const frame = firstSection(trailing);
      const width = trailing.headerFoldSize(frame.expanded).width;
      expect(frame.foldable).assertTrue();
      expect((frame.headerFoldX ?? 0) + width).assertEqual(CONTENT_RIGHT);
      // The board extends beyond the control by the board inset.
      expect((frame.card as CYLRect).x + (frame.card as CYLRect).width).assertEqual(CONTENT_RIGHT + CARD_PADDING);
      const leading = firstSection(foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerLeading,
        CYLLayoutDirection.ltr));
      expect(leading.headerFoldX).assertEqual(CONTENT_LEFT);
      // Right to left mirrors: the trailing control starts at the tags' left edge, the leading one ends at their right edge.
      const rtlTrailing = firstSection(foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerTrailing,
        CYLLayoutDirection.rtl));
      expect(rtlTrailing.headerFoldX).assertEqual(CONTENT_LEFT);
      const rtlLeadingList = foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerLeading,
        CYLLayoutDirection.rtl);
      const rtlLeading = firstSection(rtlLeadingList);
      expect((rtlLeading.headerFoldX ?? 0) + rtlLeadingList.headerFoldSize(rtlLeading.expanded).width)
        .assertEqual(CONTENT_RIGHT);
    });

    it('theBoardExtendsBeyondTheContentByTheInsetOnEachSide', 0, () => {
      const insets: number[] = [0, CARD_PADDING, WIDE_BOARD_INSET];
      insets.forEach((inset: number) => {
        const style = styleOf(CYLSectionStyle.insetGrouped);
        style.sectionBoardInset = inset;
        const frame = firstSection(boardList(style, CYLLayoutDirection.ltr));
        const card = frame.card as CYLRect;
        // The board is the margin column whatever the inset; the content column is narrower by the inset on each side.
        expect(card.x).assertEqual(SIDE_INSET);
        expect(card.x + card.width).assertEqual(LIST_WIDTH - SIDE_INSET);
        expect(card.x).assertEqual(frame.items[0].x - inset);
        expect(frame.headerTitleLeadingX).assertEqual(card.x + inset);
        expect(frame.headerInsetRight).assertEqual(LIST_WIDTH - (card.x + card.width) + inset);
        frame.items.forEach((item: CYLTagListItemFrame) => {
          expect(item.x >= card.x + inset).assertTrue();
          expect(item.x + item.width <= card.x + card.width - inset).assertTrue();
        });
      });
    });

    it('anInsetOfZeroMakesTheContentColumnEqualTheBoardColumn', 0, () => {
      const style = styleOf(CYLSectionStyle.insetGrouped);
      style.sectionBoardInset = 0;
      const ltr = firstSection(boardList(style, CYLLayoutDirection.ltr));
      const rtl = firstSection(boardList(style, CYLLayoutDirection.rtl));
      expect(ltr.items[0].x).assertEqual(SIDE_INSET);
      expect(ltr.headerTitleLeadingX).assertEqual(SIDE_INSET);
      expect(ltr.headerInsetLeft).assertEqual(SIDE_INSET);
      expect(ltr.headerInsetRight).assertEqual(SIDE_INSET);
      expect(ltr.card?.x).assertEqual(SIDE_INSET);
      expect(ltr.card?.width).assertEqual(LIST_WIDTH - 2 * SIDE_INSET);
      expect(rtl.headerTitleLeadingX).assertEqual(LIST_WIDTH - SIDE_INSET);
      expect(rtl.items[0].x + rtl.items[0].width).assertEqual(LIST_WIDTH - SIDE_INSET);
    });

    it('anUnsetInsetIsTwelveAndGivesTheFirstVersionNumbers', 0, () => {
      const unsetStyle = styleOf(CYLSectionStyle.insetGrouped);
      expect(unsetStyle.sectionBoardInset === undefined).assertTrue();
      const explicitStyle = styleOf(CYLSectionStyle.insetGrouped);
      explicitStyle.sectionBoardInset = CARD_PADDING;
      const unset = firstSection(boardList(unsetStyle, CYLLayoutDirection.ltr));
      const explicit = firstSection(boardList(explicitStyle, CYLLayoutDirection.ltr));
      // 320 list, default insets: board 16 ... 304, content 28 ... 292.
      expect(unset.card?.x).assertEqual(BOARD_LEFT);
      expect((unset.card?.x ?? 0) + (unset.card?.width ?? 0)).assertEqual(BOARD_RIGHT);
      expect(unset.items[0].x).assertEqual(CONTENT_LEFT);
      expect(unset.headerTitleLeadingX).assertEqual(CONTENT_LEFT);
      expect(frameKey(unset)).assertEqual(frameKey(explicit));
    });

    it('aSetInsetOverridesTheLeadingAndTrailingPartsOfTheContentInsetsButNotTopAndBottom', 0, () => {
      const overridden = styleOf(CYLSectionStyle.insetGrouped);
      overridden.sectionContentInsets = new CYLEdgeInsets(CONTENT_TOP, CONTENT_LEADING, CONTENT_BOTTOM, CONTENT_TRAILING);
      overridden.sectionBoardInset = WIDE_BOARD_INSET;
      const reference = styleOf(CYLSectionStyle.insetGrouped);
      reference.sectionContentInsets = new CYLEdgeInsets(CONTENT_TOP, WIDE_BOARD_INSET, CONTENT_BOTTOM, WIDE_BOARD_INSET);
      const frame = firstSection(boardList(overridden, CYLLayoutDirection.ltr));
      const card = frame.card as CYLRect;
      expect(frameKey(frame)).assertEqual(frameKey(firstSection(boardList(reference, CYLLayoutDirection.ltr))));
      expect(frame.items[0].x).assertEqual(SIDE_INSET + WIDE_BOARD_INSET);
      // Top and bottom still come from sectionContentInsets: the tags start CONTENT_TOP below the board's top.
      expect(frame.items[0].y - card.y).assertEqual(CONTENT_TOP);
      const defaultVertical = styleOf(CYLSectionStyle.insetGrouped);
      defaultVertical.sectionBoardInset = WIDE_BOARD_INSET;
      const defaultCard = firstSection(boardList(defaultVertical, CYLLayoutDirection.ltr)).card as CYLRect;
      expect(card.height - defaultCard.height).assertEqual(CONTENT_TOP + CONTENT_BOTTOM - 2 * CARD_PADDING);
    });

    it('theInsetAlsoNarrowsTheRowsAndStaysMirroredInRtl', 0, () => {
      const style = styleOf(CYLSectionStyle.insetGrouped);
      style.sectionBoardInset = WIDE_BOARD_INSET;
      const list = boardList(style, CYLLayoutDirection.ltr);
      expect(list.tagColumn(0).x).assertEqual(SIDE_INSET + WIDE_BOARD_INSET);
      expect(list.tagColumn(0).width).assertEqual(LIST_WIDTH - 2 * (SIDE_INSET + WIDE_BOARD_INSET));
      const rtl = firstSection(boardList(style, CYLLayoutDirection.rtl));
      expect(rtl.items[0].x + rtl.items[0].width).assertEqual(LIST_WIDTH - SIDE_INSET - WIDE_BOARD_INSET);
      expect(rtl.headerTitleLeadingX).assertEqual(LIST_WIDTH - SIDE_INSET - WIDE_BOARD_INSET);
    });

    it('aNegativeInsetIsZeroAndCopyKeepsIt', 0, () => {
      const style = new CYLMenuStyle();
      style.sectionBoardInset = -NEGATIVE_INSET;
      expect(style.sectionBoardInset).assertEqual(0);
      style.sectionBoardInset = WIDE_BOARD_INSET;
      expect(style.copy().sectionBoardInset).assertEqual(WIDE_BOARD_INSET);
      style.sectionBoardInset = 0;
      expect(style.copy().sectionBoardInset).assertEqual(0);
      style.sectionBoardInset = undefined;
      expect(style.copy().sectionBoardInset === undefined).assertTrue();
    });

    it('theConfigurationKeyParses', 0, () => {
      const parsed = CYLTagListState.withConfiguration(JSON.parse(
        `{"style":{"sectionBoardInset":${WIDE_BOARD_INSET}},"sections":[{"items":["a"]}]}`) as Record<string, Object>).style;
      expect(parsed.sectionBoardInset).assertEqual(WIDE_BOARD_INSET);
      const zero = CYLTagListState.withConfiguration(JSON.parse(
        '{"style":{"sectionBoardInset":0},"sections":[{"items":["a"]}]}') as Record<string, Object>).style;
      expect(zero.sectionBoardInset).assertEqual(0);
      const negative = CYLTagListState.withConfiguration(JSON.parse(
        `{"style":{"sectionBoardInset":-${NEGATIVE_INSET}},"sections":[{"items":["a"]}]}`) as Record<string, Object>).style;
      expect(negative.sectionBoardInset).assertEqual(0);
      const absent = CYLTagListState.withConfiguration(JSON.parse(
        '{"style":{},"sections":[{"items":["a"]}]}') as Record<string, Object>).style;
      expect(absent.sectionBoardInset === undefined).assertTrue();
    });

    it('thePlainStyleIgnoresTheBoardInset', 0, () => {
      const plain = styleOf(CYLSectionStyle.plain);
      const withInset = styleOf(CYLSectionStyle.plain);
      withInset.sectionBoardInset = WIDE_BOARD_INSET;
      const a = firstSection(boardList(plain, CYLLayoutDirection.ltr));
      const b = firstSection(boardList(withInset, CYLLayoutDirection.ltr));
      expect(b.card === undefined).assertTrue();
      expect(frameKey(b)).assertEqual(frameKey(a));
      expect(b.items[0].x).assertEqual(SIDE_INSET);
    });

    it('thePlainStyleKeepsTheColumnEdgesForTheTitleAndTheFoldControl', 0, () => {
      const ltr = foldList(CYLSectionStyle.plain, CYLMenuFoldControlPosition.headerTrailing, CYLLayoutDirection.ltr);
      const rtl = foldList(CYLSectionStyle.plain, CYLMenuFoldControlPosition.headerTrailing, CYLLayoutDirection.rtl);
      const ltrFrame = firstSection(ltr);
      const rtlFrame = firstSection(rtl);
      const width = ltr.headerFoldSize(ltrFrame.expanded).width;
      expect(ltrFrame.card === undefined).assertTrue();
      expect(ltrFrame.headerTitleLeadingX).assertEqual(SIDE_INSET);
      expect(ltrFrame.items[0].x).assertEqual(SIDE_INSET);
      expect((ltrFrame.headerFoldX ?? 0) + width).assertEqual(LIST_WIDTH - SIDE_INSET);
      expect(rtlFrame.headerTitleLeadingX).assertEqual(LIST_WIDTH - SIDE_INSET);
      expect(rtlFrame.headerFoldX).assertEqual(SIDE_INSET);
    });
  });
}

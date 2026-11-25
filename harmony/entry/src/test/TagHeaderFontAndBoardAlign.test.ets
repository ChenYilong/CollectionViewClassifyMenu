import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLDefaultHeaderFontSize, CYLDefaultHeaderFontWeight, CYLFont, CYLIndexPath, CYLLayoutDirection, CYLMenuDataSource,
  CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition, CYLMenuStyle, CYLRect, CYLSectionStyle,
  CYLTagButtonMetrics, CYLTagListSectionFrame, CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const LIST_WIDTH: number = 320;
/** The default section insets, left and right. */
const SIDE_INSET: number = 16;
const CARD_PADDING: number = 12;
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
 * The section header is a header (17 semibold by default) and, under the board (`insetGrouped`), its title and fold control
 * span the board's edges, not the tags' inside it; the plain style keeps the column's edges.
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

    it('underInsetGroupedTheTitleStartsAtTheBoardAndTheFoldControlEndsAtTheBoardInLtr', 0, () => {
      const trailing = foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerTrailing,
        CYLLayoutDirection.ltr);
      const frame = firstSection(trailing);
      const card = frame.card as CYLRect;
      const width = trailing.headerFoldSize(frame.expanded).width;
      expect(frame.foldable).assertTrue();
      expect(frame.headerTitleLeadingX).assertEqual(card.x);
      expect(frame.headerInsetLeft).assertEqual(card.x);
      expect(frame.headerInsetRight).assertEqual(LIST_WIDTH - card.x - card.width);
      expect((frame.headerFoldX ?? 0) + width).assertEqual(card.x + card.width);
      // The tags keep the board padding.
      expect(frame.items[0].x).assertEqual(card.x + CARD_PADDING);
      const leading = firstSection(foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerLeading,
        CYLLayoutDirection.ltr));
      expect(leading.headerFoldX).assertEqual(card.x);
    });

    it('underInsetGroupedTheTitleStartsAtTheBoardAndTheFoldControlEndsAtTheBoardInRtl', 0, () => {
      const trailing = foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerTrailing,
        CYLLayoutDirection.rtl);
      const frame = firstSection(trailing);
      const card = frame.card as CYLRect;
      // The title's leading edge is the board's right edge; the trailing control sits at the board's left edge.
      expect(frame.headerTitleLeadingX).assertEqual(card.x + card.width);
      expect(frame.headerInsetRight).assertEqual(LIST_WIDTH - card.x - card.width);
      expect(frame.headerFoldX).assertEqual(card.x);
      // The tags keep the board padding: the first tag ends one padding inside the board's right edge.
      expect(frame.items[0].x + frame.items[0].width).assertEqual(card.x + card.width - CARD_PADDING);
      const leading = foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerLeading,
        CYLLayoutDirection.rtl);
      const leadingFrame = firstSection(leading);
      expect((leadingFrame.headerFoldX ?? 0) + leading.headerFoldSize(leadingFrame.expanded).width)
        .assertEqual(card.x + card.width);
    });

    it('theTitleRoomUnderInsetGroupedIsTheBoardWidthLessTheControls', 0, () => {
      const grouped = foldList(CYLSectionStyle.insetGrouped, CYLMenuFoldControlPosition.headerTrailing,
        CYLLayoutDirection.ltr);
      const frame = firstSection(grouped);
      const card = frame.card as CYLRect;
      // The edges the room is measured from are the board's: card width, not card width less the padding.
      expect(LIST_WIDTH - frame.headerInsetLeft - frame.headerInsetRight).assertEqual(card.width);
      // The board is the column: the default section insets on both sides.
      expect(card.x).assertEqual(SIDE_INSET);
      expect(card.width).assertEqual(LIST_WIDTH - 2 * SIDE_INSET);
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

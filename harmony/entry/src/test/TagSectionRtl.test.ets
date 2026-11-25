import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLEdgeInsets, CYLFont, CYLHeaderSeparatorStyle, CYLIndexPath, CYLLayoutDirection, CYLMenuDataSource,
  CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition, CYLMenuStyle, CYLSectionStyle,
  CYLTagButtonMetrics, CYLTagListItemFrame, CYLTagListSectionFrame, CYLTagListState, CYLTagRowAlignment,
  CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const LIST_WIDTH: number = 320;
/** The default section insets, left and right. */
const SIDE_INSET: number = 16;
const TAG_WIDTH: number = 80;
const THREE_TAGS: number = 3;
const EIGHT_TAGS: number = 8;
const BAND_COLOR: string = '#FFEFEFF4';
/** Asymmetric insets (top, leading, bottom, trailing), so a swap of the two sides shows. */
const LEADING_INSET: number = 20;
const TRAILING_INSET: number = 4;
const CARD_LEADING: number = 20;
const CARD_TRAILING: number = 8;

/** One section of same-width tags ("Tag 00": 80 vp each: 60 vp of text and the tag padding). */
class CYLRtlSource implements CYLMenuDataSource {
  count: number;

  constructor(count: number) {
    this.count = count;
  }

  numberOfSectionsInMenu = (): number => 1;
  menuNumberOfItemsInSection = (section: number): number => this.count;
  menuTitleForSection = (section: number): string => 'Section';
  menuTitleForItem = (indexPath: CYLIndexPath): string => `Tag ${indexPath.item < 10 ? '0' : ''}${indexPath.item}`;
}

function plainStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.sectionStyle = CYLSectionStyle.plain;
  return style;
}

function makeList(style: CYLMenuStyle, count: number, direction: CYLLayoutDirection): CYLTagListState {
  const list = new CYLTagListState();
  list.style = style;
  list.menuDataSource = new CYLRtlSource(count);
  list.layoutDirection = direction;
  list.setLayoutWidth(LIST_WIDTH);
  list.reloadMenuData();
  return list;
}

function firstSection(list: CYLTagListState): CYLTagListSectionFrame {
  return list.layoutSections()[0];
}

/** Every item frame of the list as one string. */
function snapshot(list: CYLTagListState): string {
  const parts: string[] = [`content ${list.contentHeight}`];
  list.layoutSections().forEach((s: CYLTagListSectionFrame) => {
    parts.push(`s${s.section} y${s.y} hh${s.headerHeight} h${s.height} t${s.headerTitleLeadingX} l${s.headerInsetLeft} r${s.headerInsetRight}`);
    s.items.forEach((c: CYLTagListItemFrame) => parts.push(`${c.item}:${c.x},${c.y},${c.width},${c.height}`));
  });
  return parts.join(' | ');
}

function foldList(position: CYLMenuFoldControlPosition, direction: CYLLayoutDirection): CYLTagListState {
  const list = new CYLTagListState();
  list.style = plainStyle();
  list.menuDataSource = new CYLRtlSource(EIGHT_TAGS);
  list.layoutDirection = direction;
  list.setLayoutWidth(LIST_WIDTH);
  list.defaultVisibleRows = 1;
  list.foldControl = new CYLMenuFoldControl(position, CYLMenuFoldControlContent.title);
  list.reloadMenuData();
  return list;
}

/**
 * Right to left mirrors the section style views: the header title and fold control, the band, divider and card insets and
 * the rows of tags; left to right is unchanged.
 */
export default function tagSectionRtlTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagSectionRtl', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('theDirectionDefaultsToLeftToRightAndLeftToRightFramesAreUnchanged', 0, () => {
      const untouched = new CYLTagListState();
      expect(untouched.layoutDirection).assertEqual(CYLLayoutDirection.ltr);
      const implicit = new CYLTagListState();
      implicit.style = plainStyle();
      implicit.menuDataSource = new CYLRtlSource(EIGHT_TAGS);
      implicit.setLayoutWidth(LIST_WIDTH);
      implicit.reloadMenuData();
      const explicit = makeList(plainStyle(), EIGHT_TAGS, CYLLayoutDirection.ltr);
      expect(snapshot(explicit)).assertEqual(snapshot(implicit));
      const frame = firstSection(explicit);
      expect(frame.isRtl).assertFalse();
      expect(frame.items[0].x).assertEqual(SIDE_INSET);
      expect(frame.headerTitleLeadingX).assertEqual(SIDE_INSET);
      expect(frame.headerFoldX === undefined).assertTrue();
    });

    it('rowsStartAtTheTrailingEdgeAndEveryTagIsTheMirrorImage', 0, () => {
      const ltr = makeList(plainStyle(), EIGHT_TAGS, CYLLayoutDirection.ltr);
      const rtl = makeList(plainStyle(), EIGHT_TAGS, CYLLayoutDirection.rtl);
      const ltrItems = firstSection(ltr).items;
      const rtlItems = firstSection(rtl).items;
      expect(rtlItems.length).assertEqual(ltrItems.length);
      // The first tag sits at the right end of the column (16 .. 304), the next before it.
      expect(rtlItems[0].x).assertEqual(LIST_WIDTH - SIDE_INSET - TAG_WIDTH);
      ltrItems.forEach((c: CYLTagListItemFrame, i: number) => {
        expect(rtlItems[i].x).assertEqual(LIST_WIDTH - c.x - c.width);
        expect(rtlItems[i].y).assertEqual(c.y);
        expect(rtlItems[i].width).assertEqual(c.width);
      });
      expect(rtl.contentHeight).assertEqual(ltr.contentHeight);
      expect(firstSection(rtl).isRtl).assertTrue();
    });

    it('theRowAlignmentIsReadAsLeadingAndTrailingNotAsLeftAndRight', 0, () => {
      const trailingStyle = plainStyle();
      trailingStyle.rowAlignment = CYLTagRowAlignment.trailing;
      const trailingInRtl = makeList(trailingStyle, THREE_TAGS, CYLLayoutDirection.rtl);
      // Trailing in right to left is the left edge: the first tag at the left end of the column.
      expect(firstSection(trailingInRtl).items[0].x).assertEqual(SIDE_INSET);
      const centerStyle = plainStyle();
      centerStyle.rowAlignment = CYLTagRowAlignment.center;
      const centerLtr = makeList(centerStyle, THREE_TAGS, CYLLayoutDirection.ltr);
      const centerRtl = makeList(centerStyle, THREE_TAGS, CYLLayoutDirection.rtl);
      firstSection(centerLtr).items.forEach((c: CYLTagListItemFrame, i: number) => {
        expect(firstSection(centerRtl).items[i].x).assertEqual(LIST_WIDTH - c.x - c.width);
      });
    });

    it('theHeaderTitleIsMeasuredFromTheTrailingEdgeUnderAHeaderBand', 0, () => {
      const style = plainStyle();
      style.headerBackgroundColor = BAND_COLOR;
      style.headerContentInsets = new CYLEdgeInsets(0, LEADING_INSET, 0, TRAILING_INSET);
      const ltr = firstSection(makeList(style, THREE_TAGS, CYLLayoutDirection.ltr));
      const rtl = firstSection(makeList(style, THREE_TAGS, CYLLayoutDirection.rtl));
      // The leading inset is at the left in ltr and at the right in rtl; the band spans the column both ways.
      expect(ltr.headerInsetLeft).assertEqual(SIDE_INSET + LEADING_INSET);
      expect(ltr.headerInsetRight).assertEqual(SIDE_INSET + TRAILING_INSET);
      expect(rtl.headerInsetLeft).assertEqual(SIDE_INSET + TRAILING_INSET);
      expect(rtl.headerInsetRight).assertEqual(SIDE_INSET + LEADING_INSET);
      expect(ltr.headerTitleLeadingX).assertEqual(SIDE_INSET + LEADING_INSET);
      expect(rtl.headerTitleLeadingX).assertEqual(LIST_WIDTH - SIDE_INSET - LEADING_INSET);
      expect(rtl.headerBand?.x).assertEqual(ltr.headerBand?.x);
      expect(rtl.headerBand?.width).assertEqual(ltr.headerBand?.width);
    });

    it('theFoldControlSitsAtTheMirroredSideOfTheHeader', 0, () => {
      const trailingLtr = firstSection(foldList(CYLMenuFoldControlPosition.headerTrailing, CYLLayoutDirection.ltr));
      const trailingRtl = firstSection(foldList(CYLMenuFoldControlPosition.headerTrailing, CYLLayoutDirection.rtl));
      const leadingLtr = firstSection(foldList(CYLMenuFoldControlPosition.headerLeading, CYLLayoutDirection.ltr));
      const leadingRtl = firstSection(foldList(CYLMenuFoldControlPosition.headerLeading, CYLLayoutDirection.rtl));
      const width = foldList(CYLMenuFoldControlPosition.headerTrailing, CYLLayoutDirection.ltr).foldSize(false).width;
      expect(trailingLtr.foldable).assertTrue();
      expect(trailingLtr.headerFoldX).assertEqual(LIST_WIDTH - SIDE_INSET - width);
      expect(trailingRtl.headerFoldX).assertEqual(SIDE_INSET);
      expect(leadingLtr.headerFoldX).assertEqual(SIDE_INSET);
      expect(leadingRtl.headerFoldX).assertEqual(LIST_WIDTH - SIDE_INSET - width);
      // The title keeps the leading side: the left in ltr, the right in rtl.
      expect(trailingLtr.headerTitleLeadingX).assertEqual(SIDE_INSET);
      expect(trailingRtl.headerTitleLeadingX).assertEqual(LIST_WIDTH - SIDE_INSET);
    });

    it('theDividerInsetsSwapSidesAndItKeepsTheColumn', 0, () => {
      const style = plainStyle();
      style.headerSeparatorStyle = CYLHeaderSeparatorStyle.line;
      style.headerSeparatorInsets = new CYLEdgeInsets(0, LEADING_INSET, 0, TRAILING_INSET);
      const ltr = firstSection(makeList(style, THREE_TAGS, CYLLayoutDirection.ltr)).headerSeparator;
      const rtl = firstSection(makeList(style, THREE_TAGS, CYLLayoutDirection.rtl)).headerSeparator;
      expect(ltr !== undefined && rtl !== undefined).assertTrue();
      const columnRight = LIST_WIDTH - SIDE_INSET;
      expect(ltr?.x).assertEqual(SIDE_INSET + LEADING_INSET);
      expect((ltr?.x ?? 0) + (ltr?.width ?? 0)).assertEqual(columnRight - TRAILING_INSET);
      expect(rtl?.x).assertEqual(SIDE_INSET + TRAILING_INSET);
      expect((rtl?.x ?? 0) + (rtl?.width ?? 0)).assertEqual(columnRight - LEADING_INSET);
      expect(rtl?.y).assertEqual(ltr?.y);
      expect(rtl?.height).assertEqual(ltr?.height);
    });

    it('theCardKeepsTheColumnAndItsPaddingSwapsSides', 0, () => {
      const style = new CYLMenuStyle();
      style.sectionContentInsets = new CYLEdgeInsets(12, CARD_LEADING, 12, CARD_TRAILING);
      const ltr = firstSection(makeList(style, THREE_TAGS, CYLLayoutDirection.ltr));
      const rtl = firstSection(makeList(style, THREE_TAGS, CYLLayoutDirection.rtl));
      expect(ltr.card !== undefined && rtl.card !== undefined).assertTrue();
      expect(rtl.card?.x).assertEqual(ltr.card?.x);
      expect(rtl.card?.width).assertEqual(ltr.card?.width);
      expect(rtl.card?.height).assertEqual(ltr.card?.height);
      // ltr: the tags start at the leading padding; rtl: the first tag ends at the leading padding from the right edge.
      expect(ltr.items[0].x).assertEqual(SIDE_INSET + CARD_LEADING);
      expect(rtl.items[0].x).assertEqual(LIST_WIDTH - SIDE_INSET - CARD_LEADING - TAG_WIDTH);
      // The header title aligns with the board's (card's) leading edge, not with the tags inside it.
      expect(ltr.headerTitleLeadingX).assertEqual(ltr.card?.x);
      expect(rtl.headerTitleLeadingX).assertEqual((rtl.card?.x ?? 0) + (rtl.card?.width ?? 0));
      expect(ltr.headerInsetLeft).assertEqual(SIDE_INSET);
      expect(rtl.headerInsetRight).assertEqual(SIDE_INSET);
    });
  });
}

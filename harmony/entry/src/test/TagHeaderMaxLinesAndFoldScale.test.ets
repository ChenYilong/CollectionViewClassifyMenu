import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLFoldControlMaxFontScale, CYLFont, CYLHeaderTitleMaxLines, CYLIndexPath, CYLMenuDataSource, CYLMenuFoldControl,
  CYLMenuFoldControlContent, CYLMenuFoldControlPosition, CYLMenuStyle, CYLSectionStyle, CYLSize, CYLTagButtonMetrics,
  CYLTagFoldMetrics, CYLTagListState, CYLTextMeasurer
} from '@cyl/classifymenu';

const FIXED: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;
const LIST_WIDTH: number = 320;
/** 100 characters are 1000 vp wide: 4 lines in the 288 vp a plain header has. */
const LONG_TITLE: string = 'x'.repeat(100);
const LONG_TITLE_LINES: number = 4;
const THREE_LINES: number = 3;
const SECTION_COUNT: number = 2;
const TAGS_PER_SECTION: number = 2;
const HEADER_PADDING: number = 12;
const LARGE_FONT_SCALE: number = 2.0;
const NORMAL_FONT_SCALE: number = 1.0;

/** Section 0 has the long title, section 1 a short one. */
class CYLHeaderSource implements CYLMenuDataSource {
  numberOfSectionsInMenu = (): number => SECTION_COUNT;
  menuNumberOfItemsInSection = (section: number): number => TAGS_PER_SECTION;
  menuTitleForSection = (section: number): string => section === 0 ? LONG_TITLE : 'Short';
  menuTitleForItem = (indexPath: CYLIndexPath): string => `Tag ${indexPath.item}`;
}

function makeList(style: CYLMenuStyle): CYLTagListState {
  const list = new CYLTagListState();
  list.style = style;
  list.menuDataSource = new CYLHeaderSource();
  list.setLayoutWidth(LIST_WIDTH);
  list.reloadMenuData();
  return list;
}

function plainStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.sectionStyle = CYLSectionStyle.plain;
  return style;
}

function headerOf(list: CYLTagListState, section: number): number {
  return list.layoutSections()[section].headerHeight;
}

/**
 * A section header's title is one line by default (\`headerMaxLines\` 1) and grows the header with more lines; the fold /
 * More control never scales beyond \`CYLFoldControlMaxFontScale\`.
 */
export default function tagHeaderMaxLinesAndFoldScaleTest() {
  let saved: CYLTextMeasurer = FIXED;

  describe('CYLTagHeaderMaxLines', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('theDefaultIsOneLineAndTheHeaderHeightIsUnchanged', 0, () => {
      const style = plainStyle();
      expect(style.headerMaxLines).assertEqual(CYLHeaderTitleMaxLines.single);
      const list = makeList(style);
      // A long title is truncated: the header keeps its fixed height, long or short.
      expect(headerOf(list, 0)).assertEqual(style.headerHeight);
      expect(headerOf(list, 1)).assertEqual(style.headerHeight);
      expect(list.headerHeight()).assertEqual(style.headerHeight);
    });

    it('threeLinesGrowTheHeaderOfALongTitleOnly', 0, () => {
      const style = plainStyle();
      style.headerMaxLines = THREE_LINES;
      const list = makeList(style);
      const line = Math.ceil(CYLTagButtonMetrics.lineHeight(style.headerFontFor(1)));
      expect(headerOf(list, 0)).assertEqual(THREE_LINES * line + HEADER_PADDING);
      expect(headerOf(list, 0) > style.headerHeight).assertTrue();
      // The short title fits on one line: its header is as before.
      expect(headerOf(list, 1)).assertEqual(style.headerHeight);
      // The section below moves down by the growth, and the content is that much taller.
      const frames = list.layoutSections();
      expect(frames[1].y).assertEqual(frames[0].height);
      const before = makeList(plainStyle());
      expect(list.contentHeight - before.contentHeight).assertEqual(headerOf(list, 0) - style.headerHeight);
    });

    it('unlimitedShowsEveryLineAndAFoldControlTakesRoomFromTheTitle', 0, () => {
      const style = plainStyle();
      style.headerMaxLines = CYLHeaderTitleMaxLines.unlimited;
      const list = makeList(style);
      const line = Math.ceil(CYLTagButtonMetrics.lineHeight(style.headerFontFor(1)));
      expect(headerOf(list, 0)).assertEqual(LONG_TITLE_LINES * line + HEADER_PADDING);
      expect(list.headerHeight(0)).assertEqual(headerOf(list, 0));
      // The one-line height is still available without a section.
      expect(list.headerHeight()).assertEqual(style.headerHeight);
      // A header fold control narrows the title (the room is 288 less the control and a 6 vp gap).
      const folded = makeList(style);
      folded.defaultVisibleRows = 1;
      folded.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.headerTrailing,
        CYLMenuFoldControlContent.title);
      folded.reloadMenuData();
      expect(folded.headerHeight(0) >= list.headerHeight(0)).assertTrue();
    });

    it('theHeightIsNotChangedWhenTheHeadersAreHidden', 0, () => {
      const style = plainStyle();
      style.headerMaxLines = THREE_LINES;
      const list = makeList(style);
      list.showsSectionHeaders = false;
      list.reloadMenuData();
      expect(headerOf(list, 0)).assertEqual(0);
    });

    it('theLimitIsCleanedParsedFromTheConfigurationAndKeptByCopy', 0, () => {
      const style = new CYLMenuStyle();
      style.headerMaxLines = 0;
      expect(style.headerMaxLines).assertEqual(1);
      style.headerMaxLines = 2.7;
      expect(style.headerMaxLines).assertEqual(2);
      style.headerMaxLines = NaN;
      expect(style.headerMaxLines).assertEqual(1);
      style.headerMaxLines = THREE_LINES;
      expect(style.copy().headerMaxLines).assertEqual(THREE_LINES);
      const three = CYLTagListState.withConfiguration(
        JSON.parse('{"style":{"headerMaxLines":3},"sections":[{"items":["a"]}]}') as Record<string, Object>);
      expect(three.style.headerMaxLines).assertEqual(THREE_LINES);
      const all = CYLTagListState.withConfiguration(
        JSON.parse('{"style":{"headerMaxLines":"unlimited"},"sections":[{"items":["a"]}]}') as Record<string, Object>);
      expect(all.style.headerMaxLines).assertEqual(CYLHeaderTitleMaxLines.unlimited);
      const none = CYLTagListState.withConfiguration(
        JSON.parse('{"style":{},"sections":[{"items":["a"]}]}') as Record<string, Object>);
      expect(none.style.headerMaxLines).assertEqual(CYLHeaderTitleMaxLines.single);
    });
  });

  describe('CYLFoldControlMaxFontScale', () => {
    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('theFoldControlAtAnAccessibilityFontScaleIsTheSizeAtTheCap', 0, () => {
      const control = new CYLMenuFoldControl(CYLMenuFoldControlPosition.headerTrailing,
        CYLMenuFoldControlContent.iconAndTitle);
      const atCap = CYLTagFoldMetrics.size(control, false, CYLFoldControlMaxFontScale);
      const large = CYLTagFoldMetrics.size(control, false, LARGE_FONT_SCALE);
      expect(large.width).assertEqual(atCap.width);
      expect(large.height).assertEqual(atCap.height);
      // Uncapped, the same scale would have made the control taller: the cap does something.
      const uncapped = CYLTagButtonMetrics.height(CYLTagFoldMetrics.style(control), LARGE_FONT_SCALE);
      expect(uncapped > atCap.height).assertTrue();
      // Below the cap the control still follows the font scale.
      const normal = CYLTagFoldMetrics.size(control, false, NORMAL_FONT_SCALE);
      expect(normal.height <= atCap.height).assertTrue();
      expect(CYLTagFoldMetrics.cappedFontScale(LARGE_FONT_SCALE)).assertEqual(CYLFoldControlMaxFontScale);
      expect(CYLTagFoldMetrics.cappedFontScale(NORMAL_FONT_SCALE)).assertEqual(NORMAL_FONT_SCALE);
    });

    it('theInlineFoldControlIsCappedToo', 0, () => {
      const control = new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.icon);
      const style = plainStyle();
      const atCap: CYLSize = CYLTagFoldMetrics.inlineSize(control, style, false, CYLFoldControlMaxFontScale);
      const large: CYLSize = CYLTagFoldMetrics.inlineSize(control, style, false, LARGE_FONT_SCALE);
      expect(large.width).assertEqual(atCap.width);
      expect(large.height).assertEqual(atCap.height);
    });

    it('theListsFoldSizeUsesTheCapWhileTagsKeepScaling', 0, () => {
      const list = makeList(plainStyle());
      list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.headerTrailing,
        CYLMenuFoldControlContent.iconAndTitle);
      list.fontScale = CYLFoldControlMaxFontScale;
      const atCap = list.foldSize(false);
      const tagAtCap = list.itemHeight;
      list.fontScale = LARGE_FONT_SCALE;
      expect(list.foldSize(false).height).assertEqual(atCap.height);
      expect(list.foldSize(false).width).assertEqual(atCap.width);
      expect(list.itemHeight > tagAtCap).assertTrue();
    });
  });
}

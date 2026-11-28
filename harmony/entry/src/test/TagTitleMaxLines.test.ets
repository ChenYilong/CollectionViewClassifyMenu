import { describe, it, expect } from '@ohos/hypium';
import {
  CYLFont, CYLMenuStyle, CYLSize, CYLTagButtonMetrics, CYLTagListState, CYLTagTitleMaxLines, CYLTextMeasurer
} from '@cyl/classifymenu';

const TEN_PER_CHARACTER: CYLTextMeasurer = (text: string, font: CYLFont): number => Array.from(text).length * 10;

/**
 * A tag's title wraps up to \`CYLMenuStyle.titleMaxLines\` lines: 1 by default, a number of the app's choice, or
 * \`CYLTagTitleMaxLines.unlimited\` (a named value, no literal at the call site).
 */
export default function tagTitleMaxLinesTest() {
  describe('CYLTagTitleMaxLines', () => {
    it('theDefaultIsOneLineAndTitleWrapsIsItsShortForm', 0, () => {
      const style = new CYLMenuStyle();
      expect(style.titleMaxLines).assertEqual(CYLTagTitleMaxLines.single);
      expect(style.titleWraps).assertFalse();
      style.titleWraps = true;
      expect(style.titleMaxLines).assertEqual(CYLTagTitleMaxLines.unlimited);
      style.titleMaxLines = 3;
      expect(style.titleWraps).assertTrue();
      style.titleWraps = false;
      expect(style.titleMaxLines).assertEqual(CYLTagTitleMaxLines.single);
    });

    it('aValueThatIsNotAWholeNumberOfOneOrMoreIsOneLine', 0, () => {
      const style = new CYLMenuStyle();
      style.titleMaxLines = 0;
      expect(style.titleMaxLines).assertEqual(1);
      style.titleMaxLines = -4;
      expect(style.titleMaxLines).assertEqual(1);
      style.titleMaxLines = 2.7;
      expect(style.titleMaxLines).assertEqual(2);
      style.titleMaxLines = NaN;
      expect(style.titleMaxLines).assertEqual(1);
      style.titleMaxLines = CYLTagTitleMaxLines.unlimited;
      expect(style.titleMaxLines).assertEqual(CYLTagTitleMaxLines.unlimited);
    });

    it('copyAndConfigurationKeepTheLimit', 0, () => {
      const style = new CYLMenuStyle();
      style.titleMaxLines = 3;
      expect(style.copy().titleMaxLines).assertEqual(3);
      const three = CYLTagListState.withConfiguration(
        JSON.parse('{"style":{"titleMaxLines":3},"sections":[{"items":["a"]}]}') as Record<string, Object>);
      expect(three.style.titleMaxLines).assertEqual(3);
      const all = CYLTagListState.withConfiguration(
        JSON.parse('{"style":{"titleMaxLines":"unlimited"},"sections":[{"items":["a"]}]}') as Record<string, Object>);
      expect(all.style.titleMaxLines).assertEqual(CYLTagTitleMaxLines.unlimited);
    });

    it('theWrappedHeightStopsAtTheLimit', 0, () => {
      const saved: CYLTextMeasurer = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = TEN_PER_CHARACTER;
      try {
        const font = CYLFont.systemFont(14);
        // 100 characters are 1000 vp wide: 10 lines in a 100 vp room.
        const text = 'x'.repeat(100);
        const line = CYLTagButtonMetrics.wrappedTextHeight(text, font, 1000);
        expect(CYLTagButtonMetrics.wrappedTextHeight(text, font, 100)).assertEqual(10 * line);
        expect(CYLTagButtonMetrics.wrappedTextHeight(text, font, 100, 3)).assertEqual(3 * line);
        expect(CYLTagButtonMetrics.wrappedTextHeight(text, font, 100, CYLTagTitleMaxLines.unlimited)).assertEqual(10 * line);
        expect(CYLTagButtonMetrics.wrappedTextHeight(text, font, 100, CYLTagTitleMaxLines.single)).assertEqual(line);
        const style = new CYLMenuStyle();
        const icon = new CYLSize(0, 0);
        const oneLine = CYLTagButtonMetrics.heightForTitleWidth(text, icon, 100, false, style);
        style.titleMaxLines = 3;
        const threeLines = CYLTagButtonMetrics.heightForTitleWidth(text, icon, 100, false, style);
        style.titleMaxLines = CYLTagTitleMaxLines.unlimited;
        const all = CYLTagButtonMetrics.heightForTitleWidth(text, icon, 100, false, style);
        expect(threeLines > oneLine).assertTrue();
        expect(all > threeLines).assertTrue();
      } finally {
        CYLTagButtonMetrics.textMeasurer = saved;
      }
    });
  });
}

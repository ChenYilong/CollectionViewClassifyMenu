import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';
import {
  CYLConfiguration, CYLFont, CYLHeaderAccessoryMaxFraction, CYLHeaderFoldAloneMaxFraction,
  CYLHeaderFoldMaxWidthFraction, CYLHeaderFoldSharedMaxFraction, CYLHeaderTitleMaxLines, CYLLayoutDirection, CYLIndexPath, CYLMenuConfiguration,
  CYLMenuDataSource, CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlKey, CYLMenuFoldControlPosition,
  CYLMenuStyle, CYLSectionStyle, CYLSize, CYLTagButtonMetrics, CYLTagListSectionFrame, CYLTagListState, CYLTextMeasurer,
  HEADER_ITEM_SPACING
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

/** The plain header's inner width: the list width less both header edges. */
const INNER_WIDTH: number = LIST_WIDTH - 2 * SIDE_INSET;
/** The fixed text measurer's width of one character, vp. */
const CHARACTER_WIDTH: number = 10;
/** The side of a header's More button, vp (`HEADER_MORE_BUTTON_SIDE`). */
const HEADER_MORE_SIDE: number = 24;
/** The views next to the title in the crowded header: fold, More, clear and accessory. */
const ROOM_OTHER_VIEWS: number = 4;
const TWO_LINES: number = 2;
const HEADER_PADDING: number = 12;
const ROOM_TITLE: string = SECTION_TITLE;
/** 100 characters: 1000 vp of text, several lines in any header room. */
const ROOM_LONG_TITLE: string = 'x'.repeat(100);

@Builder
function roomAccessory(section: number) {
  Row().width(1).height(1)
}

/** Section 0 (foldable) with the given title and the header views that take room beside it. */
class CYLRoomSource implements CYLMenuDataSource {
  private readonly title: string;
  private readonly more: boolean;
  private readonly clear: boolean;
  private readonly accessory: boolean;

  constructor(title: string, more: boolean, clear: boolean, accessory: boolean) {
    this.title = title;
    this.more = more;
    this.clear = clear;
    this.accessory = accessory;
  }

  numberOfSectionsInMenu = (): number => 1;
  menuNumberOfItemsInSection = (section: number): number => FOLDABLE_TAGS;
  menuTitleForSection = (section: number): string => this.title;
  menuTitleForItem = (indexPath: CYLIndexPath): string => `Tag ${indexPath.item < 10 ? '0' : ''}${indexPath.item}`;
  menuShowsMoreButtonInSection = (section: number): boolean => this.more;
  menuShowsClearButtonForSection = (section: number): boolean => this.clear;
  menuAccessoryViewForSection = (section: number): WrappedBuilder<[number]> | undefined =>
    this.accessory ? wrapBuilder(roomAccessory) : undefined;
}

/** A list of one foldable section, a plain style that wraps `maxLines` lines (default unlimited). */
function roomList(control: CYLMenuFoldControl | undefined, source: CYLMenuDataSource, direction: CYLLayoutDirection,
  maxLines: number = CYLHeaderTitleMaxLines.unlimited): CYLTagListState {
  const list = new CYLTagListState();
  const style = plainStyle();
  style.headerMaxLines = maxLines;
  list.style = style;
  list.menuDataSource = source;
  list.layoutDirection = direction;
  list.setLayoutWidth(LIST_WIDTH);
  list.defaultVisibleRows = HEADER_FOLD_ROWS;
  if (control !== undefined) {
    list.foldControl = control;
  }
  list.reloadMenuData();
  return list;
}

/** A header fold control wider than any cap: its cap decides its width. */
function wideControl(): CYLMenuFoldControl {
  const control = makeControl(CYLMenuFoldControlPosition.headerTrailing, CYLMenuFoldControlContent.titleAndIcon);
  control.title = LONG_FOLD_TITLE;
  return control;
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
      // The cap is a fraction of the header's inner width (between the header edges), not of the list width.
      const limit = (LIST_WIDTH - 2 * SIDE_INSET) * CYLHeaderFoldAloneMaxFraction;
      expect(CYLHeaderFoldAloneMaxFraction).assertEqual(0.4);
      expect(CYLHeaderFoldMaxWidthFraction).assertEqual(CYLHeaderFoldAloneMaxFraction);
      // The control itself is wider than the limit; in the header it is cut to it, and the title gives way.
      expect(list.foldSize(false).width > limit).assertTrue();
      expect(list.headerFoldSize(false).width).assertEqual(limit);
      expect(list.headerFoldSize(true).width <= limit).assertTrue();
      expect(list.headerFoldSize(false).height).assertEqual(list.foldSize(false).height);
      expect(list.layoutSections()[0].headerFoldX).assertEqual(LIST_WIDTH - SIDE_INSET - limit);
    });

    it('theHeaderControlIsCappedAndAWideListLeavesItItsOwnWidth', 0, () => {
      const list = makeList(makeControl(CYLMenuFoldControlPosition.headerTrailing,
        CYLMenuFoldControlContent.titleAndIcon));
      // The wider of the collapsed and the expanded natural width.
      const own = Math.max(list.foldSize(false).width, list.foldSize(true).width);
      const inner = LIST_WIDTH - 2 * SIDE_INSET;
      // At the list's width the control is cut at the fraction of the header's inner width.
      expect(list.headerFoldSize(false).width).assertEqual(Math.min(own, inner * CYLHeaderFoldAloneMaxFraction));
      // In a header wide enough for it, it keeps its own width.
      expect(list.headerFoldSize(false, own / CYLHeaderFoldAloneMaxFraction + 2 * SIDE_INSET + 1).width).assertEqual(own);
    });
  });

  describe('CYLTagHeaderTitleRoom', () => {
    let saved: CYLTextMeasurer = CYLTagButtonMetrics.textMeasurer;

    beforeEach(() => {
      saved = CYLTagButtonMetrics.textMeasurer;
      CYLTagButtonMetrics.textMeasurer = FIXED;
    });

    afterEach(() => {
      CYLTagButtonMetrics.textMeasurer = saved;
    });

    it('withoutAFoldControlTheTitleRoomIsTheInnerWidth', 0, () => {
      const list = roomList(undefined, new CYLRoomSource(ROOM_TITLE, false, false, false), CYLLayoutDirection.ltr);
      expect(list.headerInnerWidth()).assertEqual(INNER_WIDTH);
      expect(list.headerTitleRoom(0)).assertEqual(INNER_WIDTH);
      expect(list.layoutSections()[0].headerTitleWidth).assertEqual(INNER_WIDTH);
    });

    it('aFoldControlAloneTakesAtMostFortyPercentAndTheTitleKeepsTheRest', 0, () => {
      const list = roomList(wideControl(), new CYLRoomSource(ROOM_TITLE, false, false, false), CYLLayoutDirection.ltr);
      const fold = list.headerFoldSize(false, LIST_WIDTH, 0).width;
      expect(fold <= INNER_WIDTH * CYLHeaderFoldAloneMaxFraction).assertTrue();
      expect(fold).assertEqual(INNER_WIDTH * CYLHeaderFoldAloneMaxFraction);
      expect(list.headerTitleRoom(0)).assertEqual(INNER_WIDTH - fold - HEADER_ITEM_SPACING);
      expect(list.layoutSections()[0].headerTitleWidth).assertEqual(list.headerTitleRoom(0));
    });

    it('foldMoreClearAndAccessoryTogetherFitTheInnerWidth', 0, () => {
      const list = roomList(wideControl(), new CYLRoomSource(ROOM_TITLE, true, true, true), CYLLayoutDirection.ltr);
      const frame = list.layoutSections()[0];
      const fold = list.headerFoldSize(false, LIST_WIDTH, 0).width;
      const clear = Math.ceil(CYLTagButtonMetrics.lineHeight(list.style.headerFontFor(list.fontScale)));
      const accessory = list.headerAccessoryMaxWidth(0);
      expect(CYLHeaderFoldSharedMaxFraction).assertEqual(0.3);
      expect(CYLHeaderAccessoryMaxFraction).assertEqual(0.3);
      expect(fold <= INNER_WIDTH * CYLHeaderFoldSharedMaxFraction).assertTrue();
      expect(accessory).assertEqual(INNER_WIDTH * CYLHeaderAccessoryMaxFraction);
      expect(frame.headerAccessoryMaxWidth).assertEqual(accessory);
      // Four other views (fold, More, clear, accessory) and the title: four gaps. All of it fits the inner width.
      const others = fold + HEADER_MORE_SIDE + clear + accessory;
      const gaps = HEADER_ITEM_SPACING * ROOM_OTHER_VIEWS;
      expect(frame.headerTitleWidth).assertEqual(INNER_WIDTH - others - gaps);
      expect(frame.headerTitleWidth + others + gaps <= INNER_WIDTH).assertTrue();
      // The title ends, one spacing, then the fold control starts.
      const titleEnd = frame.headerTitleLeadingX + frame.headerTitleWidth;
      expect(titleEnd + HEADER_ITEM_SPACING <= (frame.headerFoldX ?? 0)).assertTrue();
    });

    it('theTitleRoomAndTheFoldWidthAreTheSameCollapsedAndExpanded', 0, () => {
      const list = roomList(wideControl(), new CYLRoomSource(ROOM_TITLE, true, false, false), CYLLayoutDirection.ltr);
      expect(list.headerFoldSize(true, LIST_WIDTH, 0).width).assertEqual(list.headerFoldSize(false, LIST_WIDTH, 0).width);
      const collapsedRoom = list.headerTitleRoom(0);
      const collapsedFold = list.layoutSections()[0].headerFoldX;
      list.toggleSection(0);
      expect(list.isSectionExpanded(0)).assertTrue();
      expect(list.headerTitleRoom(0)).assertEqual(collapsedRoom);
      expect(list.layoutSections()[0].headerTitleWidth).assertEqual(collapsedRoom);
      expect(list.layoutSections()[0].headerFoldX).assertEqual(collapsedFold);
      // Even a control whose two states differ in text width keeps one width.
      const own = roomList(makeControl(CYLMenuFoldControlPosition.headerTrailing, CYLMenuFoldControlContent.titleAndIcon),
        new CYLRoomSource(ROOM_TITLE, false, false, false), CYLLayoutDirection.ltr);
      expect(own.foldSize(true).width !== own.foldSize(false).width).assertTrue();
      expect(own.headerFoldSize(true).width).assertEqual(own.headerFoldSize(false).width);
    });

    it('maxLinesTwoAndUnlimitedGrowTheHeaderByTheLinesAtTheRoomTheRenderUses', 0, () => {
      const limits: number[] = [TWO_LINES, CYLHeaderTitleMaxLines.unlimited];
      limits.forEach((maxLines: number) => {
        const bare = roomList(undefined, new CYLRoomSource(ROOM_LONG_TITLE, false, false, false), CYLLayoutDirection.ltr,
          maxLines);
        const folded = roomList(wideControl(), new CYLRoomSource(ROOM_LONG_TITLE, true, false, false),
          CYLLayoutDirection.ltr, maxLines);
        [bare, folded].forEach((list: CYLTagListState) => {
          const font = list.style.headerFontFor(list.fontScale);
          const room = list.headerTitleRoom(0);
          const line = Math.ceil(CYLTagButtonMetrics.lineHeight(font));
          const perLine = Math.floor(room / CHARACTER_WIDTH);
          const limit = maxLines === CYLHeaderTitleMaxLines.unlimited ? Number.POSITIVE_INFINITY : maxLines;
          const lines = Math.min(Math.ceil(ROOM_LONG_TITLE.length / perLine), limit);
          const frame = list.layoutSections()[0];
          // The frame (the render) carries the very room the height was computed for.
          expect(frame.headerTitleWidth).assertEqual(room);
          expect(frame.headerHeight).assertEqual(lines * line + HEADER_PADDING);
          expect(list.headerHeight(0)).assertEqual(frame.headerHeight);
        });
        // Narrower room: never fewer lines than the room-free one.
        expect(folded.headerHeight(0) >= bare.headerHeight(0)).assertTrue();
      });
    });

    it('rightToLeftMirrorsTheFoldAloneAndTheCrowdedHeader', 0, () => {
      const sources: CYLRoomSource[] = [new CYLRoomSource(ROOM_TITLE, false, false, false),
        new CYLRoomSource(ROOM_TITLE, true, true, true)];
      sources.forEach((source: CYLRoomSource) => {
        const ltr = roomList(wideControl(), source, CYLLayoutDirection.ltr);
        const rtl = roomList(wideControl(), source, CYLLayoutDirection.rtl);
        const l = ltr.layoutSections()[0];
        const r = rtl.layoutSections()[0];
        const fold = rtl.headerFoldSize(false, LIST_WIDTH, 0).width;
        expect(r.headerTitleWidth).assertEqual(l.headerTitleWidth);
        expect(r.headerHeight).assertEqual(l.headerHeight);
        // The trailing fold control is at the left edge, the title starts at the right edge and ends left of the
        // other views, one spacing right of the fold control's right edge at the nearest.
        expect(r.headerFoldX).assertEqual(SIDE_INSET);
        expect(l.headerFoldX).assertEqual(LIST_WIDTH - SIDE_INSET - fold);
        expect(r.headerTitleLeadingX - r.headerTitleWidth >= SIDE_INSET + fold + HEADER_ITEM_SPACING).assertTrue();
      });
    });

    it('aDefaultSingleLineHeaderWithAShortTitleKeepsItsGeometry', 0, () => {
      const style = plainStyle();
      style.headerMaxLines = CYLHeaderTitleMaxLines.single;
      const list = roomList(makeControl(CYLMenuFoldControlPosition.headerTrailing, CYLMenuFoldControlContent.title),
        new CYLRoomSource('Short', false, false, false), CYLLayoutDirection.ltr, CYLHeaderTitleMaxLines.single);
      const frame = list.layoutSections()[0];
      expect(frame.headerHeight).assertEqual(style.headerHeight);
      expect(frame.headerTitleLeadingX).assertEqual(SIDE_INSET);
      expect(frame.headerFoldX).assertEqual(LIST_WIDTH - SIDE_INSET - list.headerFoldSize(false, LIST_WIDTH, 0).width);
      // A short title fits the room it has.
      expect('Short'.length * CHARACTER_WIDTH <= frame.headerTitleWidth).assertTrue();
    });
  });
}

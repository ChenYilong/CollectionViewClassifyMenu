import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
/**
 * `CYLTagGlassDemoViewController` (液态玻璃): the liquid glass cases on a strong-contrast gradient plate, so that the
 * blur and the rim light show on the emulator. Only the library's public options are used:
 * - list A: glass tags and a glass section board, a header fold control with text and icon (More / Less,
 *   `CYLMenuFoldControlContent.titleAndIcon`, `headerTrailing`), `headerMaxLines` 2; its first section has a LONG
 *   title together with the More and clear buttons, its second a plain short title;
 * - list B: glass tags and a glass section board with the glass tail fold cell (icon only).
 * Tags and board of the same list sit side by side so that their edge glow can be compared.
 */
import {
  CYLIndexPath, CYLMenuDataSource, CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition,
  CYLMenuStyle, CYLSectionStyle, CYLTagBackgroundStyle, CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYLDemoBar } from '../DemoNav';

// Sample section titles, kept as written: the long Chinese title reproduces issue #13. NOLOCALIZE-BEGIN
/** The long header title of list A's first section (issue #13 of the repository). */
export const GLASS_LONG_TITLE: string = '滚动隐藏：模拟意外情况（issue #13）';
const SHORT_TITLE: string = '短标题';
const TAIL_TITLE: string = '尾部折叠';
const TAIL_SHORT_TITLE: string = '玻璃标签';
// NOLOCALIZE-END
/** The header fold control's titles: collapsed and expanded. */
const FOLD_MORE_TITLE: string = 'More';
const FOLD_LESS_TITLE: string = 'Less';
/** The id of the header fold control of list A's long-title section (`CYLTagListFold-<section>`). */
export const GLASS_LONG_TITLE_FOLD_ID: string = 'CYLTagListFold-0';
const LONG_SECTION: number = 0;
const TAGS_PER_SECTION: number = 12;
const HEADER_MAX_LINES: number = 2;
const VISIBLE_ROWS: number = 1;
const PLATE_PADDING: number = 12;
const PLATE_SPACE: number = 16;

/** The plate: five hard bands of strongly different colors, so that blur and rim stay visible over each. */
const PLATE_BLACK: string = '#000000';
const PLATE_WHITE: string = '#FFFFFF';
const PLATE_RED: string = '#FF0000';
const PLATE_BLUE: string = '#0000FF';
const PLATE_GREEN: string = '#00FF00';
const PLATE_BAND_COUNT: number = 5;
const PLATE_BANDS: string[] = [PLATE_BLACK, PLATE_WHITE, PLATE_RED, PLATE_BLUE, PLATE_GREEN];

/** The plate's gradient stops: every band from its start to its end with no blend between the bands. */
function plateStops(): Array<[ResourceColor, number]> {
  const stops: Array<[ResourceColor, number]> = [];
  PLATE_BANDS.forEach((color: string, index: number) => {
    stops.push([color, index / PLATE_BAND_COUNT]);
    stops.push([color, (index + 1) / PLATE_BAND_COUNT]);
  });
  return stops;
}

/** Sections of numbered tags; the first section of `moreAndClear` shows the More and clear buttons. */
class CYLGlassSource implements CYLMenuDataSource {
  private titles: string[];
  private moreAndClear: boolean;

  constructor(titles: string[], moreAndClear: boolean) {
    this.titles = titles;
    this.moreAndClear = moreAndClear;
  }

  numberOfSectionsInMenu = (): number => this.titles.length;
  menuNumberOfItemsInSection = (section: number): number => TAGS_PER_SECTION;
  menuTitleForSection = (section: number): string => this.titles[section];
  menuTitleForItem = (indexPath: CYLIndexPath): string => `Tag ${indexPath.item + 1}`;
  menuShowsMoreButtonInSection = (section: number): boolean => this.moreAndClear && section === LONG_SECTION;
  menuShowsClearButtonForSection = (section: number): boolean => this.moreAndClear && section === LONG_SECTION;
}

/** The glass look: glass tags and board on a clear list, grouped sections. */
function glassStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.backgroundStyle = CYLTagBackgroundStyle.liquidGlass;
  style.sectionBackgroundStyle = CYLTagBackgroundStyle.liquidGlass;
  style.sectionStyle = CYLSectionStyle.insetGrouped;
  style.backgroundColor = Color.Transparent;
  style.headerMaxLines = HEADER_MAX_LINES;
  return style;
}

function glassList(titles: string[], control: CYLMenuFoldControl, moreAndClear: boolean): CYLTagListState {
  const list = new CYLTagListState();
  list.style = glassStyle();
  list.menuDataSource = new CYLGlassSource(titles, moreAndClear);
  list.foldControl = control;
  list.defaultVisibleRows = VISIBLE_ROWS;
  list.isScrollEnabled = false;
  return list;
}

@Component
export struct CYLTagGlassPage {
  @State headerFoldHeight: number = 0;
  @State tailFoldHeight: number = 0;
  private headerFoldList: CYLTagListState = new CYLTagListState();
  private tailFoldList: CYLTagListState = new CYLTagListState();

  /** List A: the header fold control with text and icon, on the long and the short title. */
  private makeHeaderFoldList(): CYLTagListState {
    const control = new CYLMenuFoldControl(CYLMenuFoldControlPosition.headerTrailing,
      CYLMenuFoldControlContent.titleAndIcon);
    control.title = FOLD_MORE_TITLE;
    control.collapseTitle = FOLD_LESS_TITLE;
    return glassList([GLASS_LONG_TITLE, SHORT_TITLE], control, true);
  }

  /** List B: the glass fold cell as the last tag (icon only). */
  private makeTailFoldList(): CYLTagListState {
    const control = new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.icon);
    return glassList([TAIL_TITLE, TAIL_SHORT_TITLE], control, false);
  }

  aboutToAppear(): void {
    this.headerFoldList = this.makeHeaderFoldList();
    this.tailFoldList = this.makeTailFoldList();
    this.headerFoldList.menuDelegate = {
      menuDidChangeContentHeight: (menu: Object, height: number) => this.headerFoldHeight = height
    };
    this.tailFoldList.menuDelegate = {
      menuDidChangeContentHeight: (menu: Object, height: number) => this.tailFoldHeight = height
    };
    this.headerFoldList.reloadMenuData();
    this.tailFoldList.reloadMenuData();
  }

  build() {
    Column() {
      CYLDemoBar({ title: CYLExampleLocalizedString('液态玻璃'), showsBack: true, followsColorMode: true })
      Scroll() {
        Column({ space: PLATE_SPACE }) {
          CYLTagListView({ tagList: this.headerFoldList }).height(this.headerFoldHeight).id('glassHeaderFoldList')
          CYLTagListView({ tagList: this.tailFoldList }).height(this.tailFoldHeight).id('glassTailFoldList')
        }
        .padding({ top: PLATE_PADDING, bottom: PLATE_PADDING })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .linearGradient({ direction: GradientDirection.Bottom, colors: plateStops() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.cyl_animation_background'))
    .id('CYLTagGlassDemoViewController')
  }
}

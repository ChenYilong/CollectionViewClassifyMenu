import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
/**
 * The data of the plus button's page (CYLQueryScenariosPage): the scenarios as tag list sections. Kept free of views so
 * host tests can check the sections, titles, subtitles, fold limit and tap action.
 */
import {
  CYLImage, CYLIndexPath, CYLMenuDataSource, CYLMenuFoldControl, CYLMenuFoldControlContent, CYLMenuFoldControlPosition,
  CYLMenuSelectionMode, CYLMenuStyle, CYLTagLongPressActions, CYLTagListState
} from '@cyl/classifymenu';

/** `CYLQueryScenario`. */
export enum CYLQueryScenario {
  reviewsDatabase = 0,
  reviewsMemory = 1,
  reviewsNetwork = 2,
  menuLinkage = 3,
  searchDiscover = 4
}

/** One group of scenarios: its header (the section title) and the description shown as each row's long-press detail. */
export class CYLScenarioSection {
  header: string;
  detail: string;
  scenarios: CYLQueryScenario[];

  constructor(header: string, detail: string, scenarios: CYLQueryScenario[]) {
    this.header = header;
    this.detail = detail;
    this.scenarios = scenarios;
  }
}

/** Rows a collapsed section shows before the More / Less control (the tag list rule: 2). */
export const SCENARIO_DEFAULT_VISIBLE_ROWS: number = 2;
/** Lines a scenario title may take in its tag. */
export const SCENARIO_TITLE_MAX_LINES: number = 3;

export function scenarioSections(): CYLScenarioSection[] {
  return [
    new CYLScenarioSection(
      CYLExampleLocalizedString('场景：查询参数设置（多选）'),
      CYLExampleLocalizedString('淘宝评价默认显示全部；条件太多时，由用户多选输入筛选条件，标签列表就是为此而做。每次选择后按全部条件（AND）刷新列表。'),
      [CYLQueryScenario.reviewsDatabase, CYLQueryScenario.reviewsMemory, CYLQueryScenario.reviewsNetwork]),
    new CYLScenarioSection(
      CYLExampleLocalizedString('场景：菜单选择（移植原 Demo）'),
      CYLExampleLocalizedString('原 Demo 只实现了筛选界面，没有筛选数据；现在每次选择都会生成 SQL、查询数据库并显示结果，选择也保存在数据库中。'),
      [CYLQueryScenario.menuLinkage]),
    new CYLScenarioSection(
      CYLExampleLocalizedString('场景：搜索历史与发现'),
      CYLExampleLocalizedString('最近搜索折叠为两行，箭头是最后一个标签；发现每行两个，超出部分显示省略号，右上角的更多按钮随机刷新。数据来自本地 JSON。'),
      [CYLQueryScenario.searchDiscover])
  ];
}

export function scenarioTitle(scenario: CYLQueryScenario): string {
  switch (scenario) {
    case CYLQueryScenario.reviewsDatabase:
      return CYLExampleLocalizedString('评价筛选 · 数据库（SQLite）');
    case CYLQueryScenario.reviewsMemory:
      return CYLExampleLocalizedString('评价筛选 · 内存');
    case CYLQueryScenario.reviewsNetwork:
      return CYLExampleLocalizedString('评价筛选 · 网络');
    case CYLQueryScenario.menuLinkage:
      return CYLExampleLocalizedString('分类菜单 + 多选筛选 · 数据库联动');
    default:
      return CYLExampleLocalizedString('最近搜索 + 发现');
  }
}

/** The SF Symbol of a row (cylinder.split.1x2, memorychip, network, square.grid.3x2, magnifyingglass). */
export function scenarioSymbol(scenario: CYLQueryScenario): Resource {
  switch (scenario) {
    case CYLQueryScenario.reviewsDatabase:
      return $r('app.media.b_sym_cylinder');
    case CYLQueryScenario.reviewsMemory:
      return $r('app.media.b_sym_memorychip');
    case CYLQueryScenario.reviewsNetwork:
      return $r('app.media.b_sym_network');
    case CYLQueryScenario.menuLinkage:
      return $r('app.media.b_sym_grid3x2');
    default:
      return $r('app.media.b_sym_magnifyingglass');
  }
}

/** The tag list's data source: one section per group, one tag per scenario. */
export class CYLQueryScenariosSource implements CYLMenuDataSource {
  sections: CYLScenarioSection[] = scenarioSections();

  scenarioAt(indexPath: CYLIndexPath): CYLQueryScenario {
    return this.sections[indexPath.section].scenarios[indexPath.item];
  }

  numberOfSectionsInMenu(): number {
    return this.sections.length;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.sections[section].scenarios.length;
  }

  menuTitleForSection(section: number): string {
    return this.sections[section].header;
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return scenarioTitle(this.scenarioAt(indexPath));
  }

  menuImageForItem: (indexPath: CYLIndexPath) => CYLImage | undefined =
    (indexPath: CYLIndexPath): CYLImage | undefined => scenarioSymbol(this.scenarioAt(indexPath));

  /** Shown on a long press in the callout. */
  menuSubtitleForItem: (indexPath: CYLIndexPath) => string | undefined =
    (indexPath: CYLIndexPath): string | undefined => this.sections[indexPath.section].detail;
}

/**
 * Sets the list up as the page needs it: the scenarios, More / Less in the header, a tap that opens the scenario (the
 * tag never stays selected), the detail in the long-press callout, wrapping titles.
 */
export function cylConfigureScenarioList(list: CYLTagListState, source: CYLQueryScenariosSource,
  open: (scenario: CYLQueryScenario) => void, onHeight: (height: number) => void): void {
  list.selectionMode = CYLMenuSelectionMode.none;
  list.defaultVisibleRows = SCENARIO_DEFAULT_VISIBLE_ROWS;
  list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail,
    CYLMenuFoldControlContent.icon);
  list.longPressAction = CYLTagLongPressActions.callout;
  const style = new CYLMenuStyle();
  style.titleMaxLines = SCENARIO_TITLE_MAX_LINES;
  list.style = style;
  list.menuDelegate = {
    menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => open(source.scenarioAt(indexPath)),
    menuDidChangeContentHeight: (menu: Object, height: number) => onHeight(height)
  };
  list.menuDataSource = source;
  list.reloadMenuData();
}

import { cylFormat } from '../samples/SampleSupport';
import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
import { CYLUIContext } from '@cyl/classifymenu';
/**
 * `CYLMenuLinkageViewController` (分类菜单 + 多选筛选 · 数据库联动): the original app's classify menu (single choice)
 * and its multiple-choice filter (regions and dishes) drive one SQL query on the example database's `places`. Both
 * selections are saved in the database and restored on the next visit.
 */
import { common } from '@kit.AbilityKit';
import {
  CYLClassifyMenuView, CYLClassifyMenuViewController, CYLFilterBaseController, CYLFilterControllerDelegate, CYLIndexPath, CYLMenuResources,
  CYLMultipleFilterController, CYLMultipleFilterView
} from '@cyl/classifymenu';
import { CYL_DEMO_BAR_HEIGHT, CYLDemoNav } from '../DemoNav';
import { CYLDemoDataSource, CYLExampleDatabase, CYLExampleSQLQuery, CYLPlaceRow, CYLSystemColor } from './MenuSupport';

/** Keys of the selections saved in the database. */
export const CYLMenuLinkageClassifyScenario: string = 'menu.classify';
export const CYLMenuLinkageFilterScenario: string = 'menu.filter';

/** `query(forTag:regions:dishes:)`. */
export function menuLinkageQuery(tag: string | undefined, regions: string[], dishes: string[]): CYLExampleSQLQuery {
  const conditions: string[] = [];
  const args: string[] = [];
  if (tag !== undefined && tag.length > 0) {
    conditions.push('tag = ?');
    args.push(tag);
  }
  const groups: [string, string[]][] = [['region', regions], ['tag', dishes]];
  for (const group of groups) {
    if (group[1].length > 0) {
      conditions.push(`${group[0]} IN (${group[1].map(() => '?').join(', ')})`);
      args.push(...group[1]);
    }
  }
  let sql = 'SELECT name, category, tag, region, rating, price FROM places';
  if (conditions.length > 0) {
    sql += ` WHERE ${conditions.join(' AND ')}`;
  }
  return new CYLExampleSQLQuery(sql + ' ORDER BY rating DESC, id', args);
}

/** A result row of the footer: a title and an optional detail line. */
interface CYLLinkageRow {
  title: string;
  detail: string;
}

/** What the footer shows; the footer (a builder without arguments) observes it. */
class CYLLinkageResults {
  static status: string = '';
  static rows: CYLLinkageRow[] = [];
  static listeners: (() => void)[] = [];

  static update(status: string, rows: CYLLinkageRow[]): void {
    CYLLinkageResults.status = status;
    CYLLinkageResults.rows = rows;
    CYLLinkageResults.listeners.forEach((l: () => void) => l());
  }
}

@Builder
function linkageHeader() {
  Text(`  ${CYLExampleLocalizedString('点按分类标签（单选），左上角按钮多选地区与菜品')}\n  ${CYLExampleLocalizedString('每次选择 → 生成 SQL → SQLite 查询 → 刷新下方结果')}`)
    .fontSize(12)
    .maxLines(2)
    .minFontSize(9)
    .maxFontSize(12)
    .fontColor(CYLSystemColor.secondaryLabel)
    .backgroundColor(Color.White)
    .width('100%')
    .height(52)
}

@Builder
function linkageFooter() {
  CYLMenuLinkageFooter()
}

/** The footer: the conditions, the SQL and the number of results, then the results. */
@Component
struct CYLMenuLinkageFooter {
  @State status: string = CYLLinkageResults.status;
  @State rows: CYLLinkageRow[] = CYLLinkageResults.rows;
  private listener: () => void = () => {
    this.status = CYLLinkageResults.status;
    this.rows = CYLLinkageResults.rows;
  };

  aboutToAppear(): void {
    CYLLinkageResults.listeners.push(this.listener);
  }

  aboutToDisappear(): void {
    CYLLinkageResults.listeners = CYLLinkageResults.listeners.filter((l: () => void) => l !== this.listener);
  }

  build() {
    Column({ space: 8 }) {
      Text(this.status).fontSize(13).fontColor(CYLSystemColor.secondaryLabel).width('100%').id('menuLinkageStatus')
      Column({ space: 1 }) {
        ForEach(this.rows, (row: CYLLinkageRow) => {
          Column() {
            Text(row.title).fontSize(17).fontColor(CYLSystemColor.label)
            if (row.detail.length > 0) {
              Text(row.detail).fontSize(13).fontColor(CYLSystemColor.secondaryLabel)
            }
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .backgroundColor(Color.White)
        }, (row: CYLLinkageRow, index: number) => `${index}-${row.title}-${row.detail}`)
      }
      .width('100%')
      .backgroundColor(CYLSystemColor.separator)
      .id('menuLinkageResults')
    }
    .width('100%')
    .padding({ top: 10, left: 16, bottom: 16, right: 16 })
    .backgroundColor(CYLSystemColor.secondarySystemBackground)
  }
}

/** `CYLFilterControllerDelegate`: the filter closed after Apply or Reset. */
class CYLLinkageFilterDelegate implements CYLFilterControllerDelegate {
  private completion: () => void;

  constructor(completion: () => void) {
    this.completion = completion;
  }

  filterControllerDidComplete(controller: CYLFilterBaseController): void {
    this.completion();
  }
}

@Component
export struct CYLMenuLinkagePage {
  private menu: CYLClassifyMenuViewController = new CYLClassifyMenuViewController();
  private filterController: CYLMultipleFilterController = new CYLMultipleFilterController();
  private classifySource: CYLDemoDataSource = CYLDemoDataSource.classifyDataSource();
  private filterSource: CYLDemoDataSource = CYLDemoDataSource.filterDataSource();
  private db?: CYLExampleDatabase;
  /** The conditions: the classify menu's tag (undefined for every tag), the filter's regions and dishes. */
  private selectedTag: string | undefined = undefined;
  private selectedRegions: string[] = [];
  private selectedDishes: string[] = [];
  @State filterModified: boolean = false;

  aboutToAppear(): void {
    this.menu.menuDataSource = this.classifySource;
    this.menu.menuDelegate = {
      menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => this.selectClassifyItem(indexPath)
    };
    this.menu.defaultVisibleRows = 2;
    this.menu.menuHeaderView = wrapBuilder(linkageHeader);
    this.menu.menuFooterView = wrapBuilder(linkageFooter);
    this.menu.reloadMenuData();
    this.filterController.menuDataSource = this.filterSource;
    this.filterController.menuDelegate = {
      menuDidConfirmSelectedItems: (menu: Object, indexPaths: CYLIndexPath[]) => this.applyFilterSelection(indexPaths, true)
    };
    this.filterController.delegate = new CYLLinkageFilterDelegate(() => this.updateFilterButton());
    this.filterController.reloadMenuData();
    CYLLinkageResults.update('', []);
    this.load();
  }

  private async load(): Promise<void> {
    this.db = await CYLExampleDatabase.shared(CYLUIContext.hostContext(this.getUIContext()));
    await this.restoreSavedSelection();
  }

  private contains(p: CYLIndexPath, source: CYLDemoDataSource): boolean {
    return p.section >= 0 && p.section < source.numberOfSectionsInMenu() && p.item >= 0 &&
      p.item < source.menuNumberOfItemsInSection(p.section);
  }

  /** The selections saved by the last visit, if they still fit the menus. */
  private async restoreSavedSelection(): Promise<void> {
    const classify = (await this.db?.savedSelection(CYLMenuLinkageClassifyScenario)) ?? [];
    if (classify.length > 0 && this.contains(classify[0], this.classifySource)) {
      this.menu.selectedIndexPath = classify[0];
      this.selectedTag = this.classifySource.menuTitleForItem(classify[0]);
    }
    const filter = ((await this.db?.savedSelection(CYLMenuLinkageFilterScenario)) ?? [])
      .filter((p: CYLIndexPath) => this.contains(p, this.filterSource));
    if (filter.length > 0) {
      try {
        this.filterController.setSelectedIndexPaths(filter);
      } catch (e) {
        // A selection saved for other filter data ("全部" with another item): start over.
        console.warn(`[CYLMenuExample] Ignoring the saved filter selection: ${JSON.stringify(filter)}`);
        this.filterController.reloadMenuData();
      }
    }
    await this.applyFilterSelection(this.filterController.selectedIndexPaths(), false);
  }

  private updateFilterButton(): void {
    this.filterModified = this.selectedRegions.length > 0 || this.selectedDishes.length > 0;
  }

  /** Opens the multiple-choice filter, as the left bar button does. */
  showFilter(): void {
    this.filterController.refreshFilterParams();
    this.filterController.show();
  }

  /** Regions and dishes from the filter's selection: sections 0 and 1, without the exclusive "全部". */
  private async applyFilterSelection(indexPaths: CYLIndexPath[], save: boolean): Promise<void> {
    const regions: string[] = [];
    const dishes: string[] = [];
    for (const p of indexPaths) {
      if (this.filterSource.menuItemIsExclusive !== undefined && this.filterSource.menuItemIsExclusive(p)) {
        continue;
      }
      const title = this.filterSource.menuTitleForItem(p);
      if (p.section === 0) {
        regions.push(title);
      } else {
        dishes.push(title);
      }
    }
    this.selectedRegions = regions;
    this.selectedDishes = dishes;
    if (save) {
      await this.db?.saveSelection(indexPaths, CYLMenuLinkageFilterScenario);
    }
    await this.runQuery();
  }

  /** As a tap on the classify menu: selects the tag, or clears it when it is already selected. */
  private async selectClassifyItem(indexPath: CYLIndexPath): Promise<void> {
    const current = this.menu.selectedIndexPath;
    const deselect = current !== undefined && current.section === indexPath.section && current.item === indexPath.item;
    this.menu.selectedIndexPath = deselect ? undefined : indexPath;
    this.selectedTag = deselect ? undefined : this.classifySource.menuTitleForItem(indexPath);
    await this.db?.saveSelection(deselect ? [] : [indexPath], CYLMenuLinkageClassifyScenario);
    await this.runQuery();
  }

  /** Every tag, every region and dish ("重置"). */
  private async resetConditions(): Promise<void> {
    this.menu.selectedIndexPath = undefined;
    this.selectedTag = undefined;
    await this.db?.saveSelection([], CYLMenuLinkageClassifyScenario);
    const all: CYLIndexPath[] = [];
    for (let section = 0; section < this.filterSource.numberOfSectionsInMenu(); section++) {
      all.push({ section: section, item: 0 });
    }
    this.filterController.setSelectedIndexPaths(all);
    await this.applyFilterSelection(this.filterController.selectedIndexPaths(), true);
  }

  private async runQuery(): Promise<void> {
    const query = menuLinkageQuery(this.selectedTag, this.selectedRegions, this.selectedDishes);
    let results: CYLPlaceRow[] = [];
    let total = 0;
    try {
      results = (await this.db?.rows(query)) ?? [];
      total = (await this.db?.count('places')) ?? 0;
    } catch (e) {
      console.error(`[CYLMenuExample] ${query.sql}: ${JSON.stringify(e)}`);
    }
    this.updateFilterButton();
    const all = CYLExampleLocalizedString('全部');
    const names = (values: string[]): string =>
    values.length === 0 ? all : values.map((v: string) => CYLDemoDataSource.shortTitle(v)).join(CYLExampleLocalizedString('、'));
    const tag = this.selectedTag !== undefined ? CYLDemoDataSource.shortTitle(this.selectedTag) : all;
    const status = [
      cylFormat(CYLExampleLocalizedString('分类：%@ · 地区：%@ · 菜品：%@'), tag, names(this.selectedRegions), names(this.selectedDishes)),
      query.displayString(),
      cylFormat(CYLExampleLocalizedString('SQLite 返回 %lu 条（共 %ld 家）'), results.length, total)
    ].join('\n');
    const empty: CYLLinkageRow = { title: CYLExampleLocalizedString('没有符合条件的商家'), detail: '' };
    const rows: CYLLinkageRow[] = results.length === 0 ? [empty] :
    results.map((row: CYLPlaceRow): CYLLinkageRow => ({
      title: row.name,
      // The dish and the region only when the name does not already say them ("日式拉面 · 北京" repeated both).
      detail: [row.category, CYLDemoDataSource.shortTitle(row.tag), CYLDemoDataSource.shortTitle(row.region)]
        .filter((part: string, index: number) => index === 0 || !row.name.includes(part))
        .concat([`★${row.rating.toFixed(1)}`, `¥${row.price}`])
        .join(' · ')
    }));
    CYLLinkageResults.update(status, rows);
    this.menu.updateMenuLayout();
  }

  build() {
    Stack() {
      Column() {
        // The navigation bar: the filter button replaces the back button (leftBarButtonItem), 重置 on the right.
        Stack() {
          Text(CYLExampleLocalizedString('菜单选择 · 数据库联动')).fontSize(17).fontWeight(FontWeight.Medium).maxLines(1)
            .fontColor('#000000') // the label color on the example's light backgrounds, also in dark mode
            .padding({ left: 64, right: 64 }).textOverflow({ overflow: TextOverflow.Ellipsis })
          Image(CYLMenuResources.image(this.filterModified ? 'cyl_filter_modified' : 'cyl_filter_normal'))
            .width(22)
            .height(22)
            .objectFit(ImageFit.Contain)
            // Tinted as on iOS: the core's template images are near-white (1.01:1 on the bar). Each pixel takes the
            // tint scaled by its own alpha (unit-independent matrix), gray #6E6E73 (4.6:1) with no filter, system blue
            // (4:1) with one.
            .colorFilter(this.filterModified
              ? [0, 0, 0, 0 / 255, 0, 0, 0, 0, 122 / 255, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0]
              : [0, 0, 0, 110 / 255, 0, 0, 0, 0, 110 / 255, 0, 0, 0, 0, 115 / 255, 0, 0, 0, 0, 1, 0])
            .position({ x: 14, y: (CYL_DEMO_BAR_HEIGHT - 22) / 2 })
            // An image is not an accessibility element by default: expose it, and give it a 44 vp touch target.
            .accessibilityLevel('yes')
            .accessibilityText(CYLExampleLocalizedString('多选筛选'))
            .accessibilityDescription(this.filterModified ? CYLExampleLocalizedString('已修改') : CYLExampleLocalizedString('多选筛选'))
            .responseRegion({ x: -11, y: -11, width: 44, height: 44 })
            .id('menuLinkageFilter')
            .onClick(() => this.showFilter())
          Text(CYLExampleLocalizedString('重置'))
            .fontSize(17)
            .fontColor(CYLSystemColor.blue)
            .height(CYL_DEMO_BAR_HEIGHT)
            .position({ right: 16, top: 0 })
            .id('menuLinkageReset')
            .onClick(() => this.resetConditions())
        }
        .width('100%')
        .height(CYL_DEMO_BAR_HEIGHT)
        .backgroundColor('#F9F9F9')
        .border({ width: { bottom: 0.5 }, color: '#33000000' })
        .gesture(SwipeGesture({ direction: SwipeDirection.Horizontal }).onAction(() => CYLDemoNav.pop()))
        CYLClassifyMenuView({ controller: this.menu }).layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      CYLMultipleFilterView({ controller: this.filterController })
    }
    .width('100%')
    .height('100%')
    .id('CYLMenuLinkageViewController')
  }
}

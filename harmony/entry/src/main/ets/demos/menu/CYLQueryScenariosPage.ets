import { cylFormat } from '../samples/SampleSupport';
import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
import { CYLUIContext } from '@cyl/classifymenu';
/**
 * `CYLQueryScenariosViewController`: the plus button's page (查询筛选), an inset grouped table of the filter demos by
 * scenario, then the database's tables with their row counts. A row pushes its demo.
 */
import { common } from '@kit.AbilityKit';
import { CYLDemoBar, CYLDemoNav } from '../DemoNav';
import { CYLExampleDatabase, CYLSystemColor, cylSectionFooter, cylSectionHeader } from './MenuSupport';

/** The parameter of the `CYLReviewListViewController` route: `init(selectedFilterIndex:mode:)`. */
export interface CYLReviewListParam {
  selectedFilterIndex: number;
  /** "database", "memory" or "network" (`CYLReviewFilteringMode`). */
  mode: string;
}

/** `CYLQueryScenario`. */
export enum CYLQueryScenario {
  reviewsDatabase = 0,
  reviewsMemory = 1,
  reviewsNetwork = 2,
  menuLinkage = 3,
  searchDiscover = 4
}

interface CYLScenarioSection {
  header: string;
  footer: string;
  scenarios: CYLQueryScenario[];
}

const SECTIONS: CYLScenarioSection[] = [
  {
    header: CYLExampleLocalizedString('场景：查询参数设置（多选）'),
    footer: CYLExampleLocalizedString('淘宝评价默认显示全部；条件太多时，由用户多选输入筛选条件，标签列表就是为此而做。每次选择后按全部条件（AND）刷新列表。'),
    scenarios: [CYLQueryScenario.reviewsDatabase, CYLQueryScenario.reviewsMemory, CYLQueryScenario.reviewsNetwork]
  },
  {
    header: CYLExampleLocalizedString('场景：菜单选择（移植原 Demo）'),
    footer: CYLExampleLocalizedString('原 Demo 只实现了筛选界面，没有筛选数据；现在每次选择都会生成 SQL、查询数据库并显示结果，选择也保存在数据库中。'),
    scenarios: [CYLQueryScenario.menuLinkage]
  },
  {
    header: CYLExampleLocalizedString('场景：搜索历史与发现'),
    footer: CYLExampleLocalizedString('最近搜索折叠为两行，箭头是最后一个标签；发现每行两个，超出部分显示省略号，右上角的更多按钮随机刷新。数据来自本地 JSON。'),
    scenarios: [CYLQueryScenario.searchDiscover]
  }
];

const TABLES: string[] = ['reviews', 'places', 'selections'];

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
function scenarioSymbol(scenario: CYLQueryScenario): Resource {
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

/** Pushes a scenario's demo, as tapping its row does. */
export function openScenario(scenario: CYLQueryScenario): void {
  switch (scenario) {
    case CYLQueryScenario.reviewsDatabase:
      CYLDemoNav.push('CYLReviewListViewController', { selectedFilterIndex: 0, mode: 'database' } as CYLReviewListParam);
      break;
    case CYLQueryScenario.reviewsMemory:
      CYLDemoNav.push('CYLReviewListViewController', { selectedFilterIndex: 0, mode: 'memory' } as CYLReviewListParam);
      break;
    case CYLQueryScenario.reviewsNetwork:
      CYLDemoNav.push('CYLReviewListViewController', { selectedFilterIndex: 0, mode: 'network' } as CYLReviewListParam);
      break;
    case CYLQueryScenario.menuLinkage:
      CYLDemoNav.push('CYLMenuLinkageViewController', new Object());
      break;
    default:
      CYLDemoNav.push('CYLSearchDiscoverViewController', new Object());
      break;
  }
}

@Component
export struct CYLQueryScenariosPage {
  /** Root of the plus button's tab: no back button. */
  showsBack: boolean = false;
  @State counts: string[] = ['', '', ''];
  private removeListener?: () => void;

  aboutToAppear(): void {
    this.reloadCounts();
    this.removeListener = CYLExampleDatabase.addListener(() => this.reloadCounts());
  }

  aboutToDisappear(): void {
    this.removeListener?.();
  }

  /** viewWillAppear: the selections saved by the demos change the database section. */
  private async reloadCounts(): Promise<void> {
    try {
      const db = await CYLExampleDatabase.shared(CYLUIContext.hostContext(this.getUIContext()));
      const counts: string[] = [];
      for (const table of TABLES) {
        counts.push(cylFormat(CYLExampleLocalizedString('%ld 行'), await db.count(table)));
      }
      this.counts = counts;
    } catch (e) {
      console.error(`[CYLMenuExample] counts: ${JSON.stringify(e)}`);
    }
  }

  @Builder
  scenarioRow(scenario: CYLQueryScenario, last: boolean) {
    Row({ space: 12 }) {
      Image(scenarioSymbol(scenario)).width(24).height(24).objectFit(ImageFit.Contain).fillColor(CYLSystemColor.blue)
        .accessibilityLevel('no')
      Text(scenarioTitle(scenario)).fontSize(17).fontColor(CYLSystemColor.label).layoutWeight(1)
      Text('›').fontSize(22).fontColor('#C4C4C7')
    }
    .width('100%')
    .constraintSize({ minHeight: 44 })
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .border({ width: { bottom: last ? 0 : 0.5 }, color: CYLSystemColor.separator })
    .accessibilityGroup(true)
    .id(`scenario-${scenario}`)
    .onClick(() => openScenario(scenario))
  }

  @Builder
  tableRow(index: number) {
    Row() {
      Text(TABLES[index]).fontSize(15).fontFamily('monospace').fontColor(CYLSystemColor.label).layoutWeight(1)
      Text(this.counts[index]).fontSize(17).fontColor(CYLSystemColor.secondaryLabel).id(`table-${TABLES[index]}`)
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .border({ width: { bottom: index === TABLES.length - 1 ? 0 : 0.5 }, color: CYLSystemColor.separator })
  }

  build() {
    Column() {
      CYLDemoBar({ title: CYLExampleLocalizedString('查询筛选'), showsBack: this.showsBack })
      Scroll() {
        Column() {
          ForEach(SECTIONS, (section: CYLScenarioSection) => {
            cylSectionHeader(section.header)
            Column() {
              ForEach(section.scenarios, (scenario: CYLQueryScenario, index: number) => {
                this.scenarioRow(scenario, index === section.scenarios.length - 1)
              }, (scenario: CYLQueryScenario) => `${scenario}`)
            }
            .backgroundColor(Color.White)
            .borderRadius(10)
            .margin({ left: 16, right: 16 })
            cylSectionFooter(section.footer)
          }, (section: CYLScenarioSection) => section.header)
          cylSectionHeader(CYLExampleLocalizedString('数据库（SQLite）'))
          Column() {
            ForEach([0, 1, 2], (index: number) => {
              this.tableRow(index)
            }, (index: number) => `${index}-${this.counts[index]}`)
          }
          .backgroundColor(Color.White)
          .borderRadius(10)
          .margin({ left: 16, right: 16 })
          cylSectionFooter(CYLExampleLocalizedString('每次启动时由 App 内的数据重新生成，selections 表保留各演示最后确认的条件。'))
        }
        .padding({ bottom: 24 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CYLSystemColor.groupedBackground)
    .id('CYLQueryScenariosViewController')
  }
}

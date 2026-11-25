import { cylFormat } from '../samples/SampleSupport';
import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
import { CYLTagListState, CYLTagListView, CYLUIContext } from '@cyl/classifymenu';
/**
 * `CYLQueryScenariosViewController`: the plus button's page (查询筛选), a tag list of the filter demos by scenario
 * (one section per group; a long press shows the group's description), then the database's tables
 * with their row counts. A tag pushes its demo.
 */
import { common } from '@kit.AbilityKit';
import { CYLDemoBar, CYLDemoNav } from '../DemoNav';
import { CYLExampleDatabase, CYLSystemColor, cylSectionFooter, cylSectionHeader } from './MenuSupport';
import {
  CYLQueryScenario, CYLQueryScenariosSource, cylConfigureScenarioList
} from './CYLQueryScenariosSource';

export { CYLQueryScenario, scenarioTitle } from './CYLQueryScenariosSource';

/** The parameter of the `CYLReviewListViewController` route: `init(selectedFilterIndex:mode:)`. */
export interface CYLReviewListParam {
  selectedFilterIndex: number;
  /** "database", "memory" or "network" (`CYLReviewFilteringMode`). */
  mode: string;
}

const TABLES: string[] = ['reviews', 'places', 'selections'];

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
  @State scenarioHeight: number = 0;
  private scenarioList: CYLTagListState = new CYLTagListState();
  private scenarioSource: CYLQueryScenariosSource = new CYLQueryScenariosSource();
  private removeListener?: () => void;

  aboutToAppear(): void {
    cylConfigureScenarioList(this.scenarioList, this.scenarioSource, openScenario,
      (height: number) => this.scenarioHeight = height);
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
          CYLTagListView({ tagList: this.scenarioList }).width('100%').height(this.scenarioHeight).id('queryScenarioTags')
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

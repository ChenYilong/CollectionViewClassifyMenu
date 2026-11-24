import { cylFormat } from '../samples/SampleSupport';
import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
/**
 * 场景二（搜索页）：内嵌的分类 TabBar（位于底部）切换「找人/动态/八卦/职位」，每个 Tab 是一个标签页；职位页左侧是职位分类，
 * 分组右侧是宿主提供的行业选择按钮 (iOS CYLSearchCategoryViewController and CYLSearchCategoryPageViewController).
 */
import {
  CYLColor, CYLControlState, CYLEdgeInsets, CYLFont, CYLIndexPath, CYLMenuSelectionMode, CYLMenuStyle,
  CYLTagBackgroundStyle, CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYL_DEMO_BAR_HEIGHT, CYLDemoNav } from '../DemoNav';
import { CYLExampleMenuSection, CYLExampleMenuSource } from '../shell/CYLExampleMenuSource';

export enum CYLSearchCategory {
  people = 0,
  feeds = 1,
  gossip = 2,
  jobs = 3
}

const JOB_CATEGORY_WIDTH: number = 90;
const TITLES: string[] = ['找人', '动态', '八卦', '职位'];
const ICONS: Resource[] = [$r('app.media.a_tab_people'), $r('app.media.a_tab_feeds'), $r('app.media.a_tab_gossip'),
  $r('app.media.a_tab_jobs')];
const SELECTED_ICONS: Resource[] = [$r('app.media.a_tab_people_fill'), $r('app.media.a_tab_feeds_fill'),
  $r('app.media.a_tab_gossip_fill'), $r('app.media.a_tab_jobs_fill')];
export const INDUSTRIES: string[] = ['IT互联网', '金融', '教育培训', '医疗健康', '房地产'];
export const JOB_CATEGORIES: string[] = ['开发', '测试', '运维/DBA', '硬件', '产品', '运营', '设计', '编辑/记者', '游戏',
  '市场BD'];
export const JOB_KEYWORDS: Map<string, string[]> = new Map<string, string[]>([
  ['开发', ['后端开发', 'PHP', 'Java', 'Python', '.NET', 'C#', 'C/C++', 'Ruby', 'Hadoop', 'Node.js', 'Perl', '搜索算法',
    '推荐算法', '数据挖掘', '机器学习', '信息检索', 'NLP', '语音算法', '视频算法', '图像算法', '全栈', 'Linux', '广告算法', 'GO',
    'ASP', 'Shell', 'VB', 'Delphi', '前端开发', 'Web前端', 'Flash']],
  ['测试', ['测试工程师', '自动化测试', '性能测试', '测试开发', '白盒测试', '游戏测试', '手机测试']],
  ['运维/DBA', ['运维工程师', 'DBA', '系统管理员', '网络工程师', 'IT支持', 'SRE']],
  ['硬件', ['嵌入式', '单片机', '电路设计', 'FPGA', '驱动开发', '射频工程师']],
  ['产品', ['产品经理', '产品助理', '产品总监', '数据产品', '游戏策划', '移动产品']],
  ['运营', ['内容运营', '用户运营', '活动运营', '新媒体', '社区运营', '数据运营', 'SEO']],
  ['设计', ['UI设计', '交互设计', '视觉设计', '平面设计', '用户研究', '动效设计']],
  ['编辑/记者', ['编辑', '记者', '文案', '主编', '撰稿人']],
  ['游戏', ['游戏开发', '游戏策划', '游戏美术', 'Unity3D', 'Cocos2d-x']],
  ['市场BD', ['市场推广', '商务拓展', '品牌', '公关', '渠道', '大客户']]
]);

export function searchSections(category: CYLSearchCategory): CYLExampleMenuSection[] {
  const s = (title: string, titles: string[]) => CYLExampleMenuSection.withTitles(CYLExampleLocalizedString(title), titles);
  switch (category) {
    case CYLSearchCategory.people:
      return [s('认识同行', ['百度研发', '腾讯工程师', '搜狗开发', '腾讯开发', '搜狗研究员']),
        s('找投资', ['创投', 'IDG资本', '晨兴资本', '合伙人', '投资经理']),
        s('谈合作', ['CEO', '副总裁', 'VP', '总经理', '总监']),
        s('挖人才', ['Java', 'Android', 'JS', 'C++', 'HTML/CSS', 'iOS', 'PHP', '前端'])];
    case CYLSearchCategory.feeds:
      return [s('热门动态关键词', ['投资', '创业', 'o2o', '社交', '招聘', '运营', '线下聚会', '脉脉', '融资', '在线教育', '硬件',
        '电商', '产品经理'])];
    case CYLSearchCategory.gossip:
      return [s('热门词', ['百度', '新浪', '程序猿', '离职', '阿里', '360', '创业', '工资', '跳槽', '小三', '裁员', '加班', '女同事',
        '产品经理', '投资人', '老板']),
        s('我关注的标签', ['社交', '移动', '程序猿'])];
    default:
      return [];
  }
}

const PLACEHOLDERS: string[] = ['搜人名,职位,公司...', '搜动态', '搜八卦', '搜职位'];

export function maimaiStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  style.backgroundStyle = CYLTagBackgroundStyle.liquidGlass;
  style.setTitleTextAttributes(CYLFont.systemFont(14), CYLColor.white(0.35), CYLControlState.NORMAL);
  style.normalAppearance.borderColor = CYLColor.white(0.8);
  style.normalAppearance.borderWidth = 1;
  style.normalAppearance.cornerRadius = 2;
  style.normalAppearance.margin = 14;
  style.itemHeight = 32;
  style.interitemSpacing = 14;
  style.lineSpacing = 14;
  style.sectionInsets = new CYLEdgeInsets(4, 24, 14, 16);
  style.headerHeight = 32;
  style.headerFont = CYLFont.systemFont(13);
  style.headerTextColor = CYLColor.white(0.6);
  return style;
}

@Component
export struct CYLSearchCategoryPage {
  @State category: number = CYLSearchCategory.people;
  @State searchText: string = '';
  @State industry: string = INDUSTRIES[0];
  @State jobCategoryIndex: number = 0;
  private lists: CYLTagListState[] = [];
  private sources: CYLExampleMenuSource[] = [];

  aboutToAppear(): void {
    for (let index = 0; index < TITLES.length; index++) {
      const view = new CYLTagListState();
      view.style = maimaiStyle();
      view.selectionMode = CYLMenuSelectionMode.none;
      view.menuDelegate = {
        menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => {
          this.searchText = this.sources[index].item(indexPath).title;
        }
      };
      this.lists.push(view);
      this.sources.push(new CYLExampleMenuSource([]));
      this.reloadTags(index);
    }
  }

  private reloadTags(category: number): void {
    let sections: CYLExampleMenuSection[];
    if (category === CYLSearchCategory.jobs) {
      const name = JOB_CATEGORIES[this.jobCategoryIndex];
      sections = [CYLExampleMenuSection.withTitles(CYLExampleLocalizedString('热搜职位关键词:'), JOB_KEYWORDS.get(name) ?? [])];
    } else {
      sections = searchSections(category);
    }
    const source = new CYLExampleMenuSource(sections);
    this.sources[category] = source;
    this.lists[category].menuDataSource = source;
    this.lists[category].reloadMenuData();
  }

  selectJobCategory(index: number): void {
    this.jobCategoryIndex = Math.min(Math.max(index, 0), JOB_CATEGORIES.length - 1);
    this.reloadTags(CYLSearchCategory.jobs);
  }

  @Builder
  searchBar() {
    Row({ space: 6 }) {
      Image($r('app.media.a_magnifyingglass')).width(15).height(15)
        .accessibilityLevel('no')
      TextInput({ placeholder: CYLExampleLocalizedString(PLACEHOLDERS[this.category]), text: this.searchText })
        .accessibilityText(CYLExampleLocalizedString(PLACEHOLDERS[this.category]))
        .fontSize(16)
        .placeholderColor('#993C3C43')
        .backgroundColor(Color.Transparent)
        .padding(0)
        .layoutWeight(1)
        .height(36)
        .enterKeyType(EnterKeyType.Search)
        .id('searchCategoryField')
        .onChange((value: string) => this.searchText = value)
    }
    .layoutWeight(1)
    .height(36)
    .padding({ left: 8, right: 8 })
    .borderRadius(10)
    .backgroundColor('#1F767680')
  }

  @Builder
  industryButton() {
    Text(cylFormat(CYLExampleLocalizedString('行业: %@ ▾'), CYLExampleLocalizedString(this.industry)))
      .fontSize(13)
      .fontColor('#007AFF')
      .height(32)
      .id('industryButton')
      .accessibilityText(cylFormat(CYLExampleLocalizedString('行业 %@'), CYLExampleLocalizedString(this.industry)))
      .accessibilityDescription(CYLExampleLocalizedString('选择行业'))
      .bindMenu(INDUSTRIES.map((industry: string): MenuElement => ({
        value: (industry === this.industry ? '✓ ' : '') + CYLExampleLocalizedString(industry),
        action: () => {
          this.industry = industry;
        }
      })))
  }

  @Builder
  page(index: number) {
    // One tab of the category tab bar (CYLSearchCategoryPageViewController): a tag list, plus the job category sidebar.
    Row() {
      if (index === CYLSearchCategory.jobs) {
        List() {
          ForEach(JOB_CATEGORIES, (name: string, row: number) => {
            ListItem() {
              Text(CYLExampleLocalizedString(name))
                .fontColor('#000000') // the label color on the example's light backgrounds, also in dark mode
                .fontSize(15)
                .maxLines(2)
                .minFontSize(10.5)
                .maxFontSize(15)
                .textAlign(TextAlign.Center)
                .width('100%')
                .height(50)
                .backgroundColor(row === this.jobCategoryIndex ? '#FFFFFF' : Color.Transparent)
                .id(`jobCategory-${row}`)
                .onClick(() => this.selectJobCategory(row))
            }
          }, (name: string) => name)
        }
        .width(JOB_CATEGORY_WIDTH)
        .height('100%')
        .backgroundColor('#F2F2F7')
      }
      Stack({ alignContent: Alignment.TopEnd }) {
        CYLTagListView({ tagList: this.lists[index] }).height('100%').id(`searchTags-${index}`)
        if (index === CYLSearchCategory.jobs) {
          // A header accessory supplied by the host, at the trailing end of the section header.
          Row() {
            this.industryButton()
          }.padding({ right: 16 })
        }
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  tabBar(index: number) {
    Column({ space: 2 }) {
      Image(this.category === index ? SELECTED_ICONS[index] : ICONS[index])
        .accessibilityLevel('no')
        .width(24)
        .height(24)
        .fillColor(this.category === index ? '#007AFF' : '#8E8E93')
      Text(CYLExampleLocalizedString(TITLES[index])).fontSize(10).fontColor(this.category === index ? '#007AFF' : '#8E8E93')
    }
    .id(`searchTab-${TITLES[index]}`)
  }

  build() {
    Column() {
      // The search bar is the navigation item's title view.
      Row({ space: 4 }) {
        Text('‹')
          .fontSize(34)
          .fontColor('#007AFF')
          .width(36)
          .textAlign(TextAlign.Center)
          .accessibilityText(CYLExampleLocalizedString('返回'))
          .id('CYLSearchCategoryBack')
          .onClick(() => CYLDemoNav.pop())
        this.searchBar()
      }
      .width('100%')
      .height(CYL_DEMO_BAR_HEIGHT)
      .padding({ right: 12, top: 4, bottom: 4 })
      .backgroundColor('#F9F9F9')

      // The second tab bar of the app: the category tabs of this screen, at the bottom like every tab bar.
      Tabs({ barPosition: BarPosition.End, index: this.category }) {
        ForEach(TITLES, (title: string, index: number) => {
          TabContent() {
            this.page(index)
          }.tabBar(this.tabBar(index))
        }, (title: string) => title)
      }
      .layoutWeight(1)
      .scrollable(false)
      .animationDuration(0)
      .barBackgroundColor('#F9F9F9')
      .onChange((index: number) => this.category = index)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

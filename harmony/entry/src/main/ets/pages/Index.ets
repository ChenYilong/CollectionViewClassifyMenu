<<<<<<< HEAD
<<<<<<< HEAD
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { CYLTabBarConfiguration, CYLTabBarConfigurationResult, CYLTabBarController } from 'cyltabbar';
import { CYLIndexPath, CYLTagListController, CYLTagListView, CYLTagTap } from '@cyl/classifymenu';
import { Place, PlacesDatabase, REGIONS } from '../data/PlacesDatabase';

const CLASSIFY = 'menu.classify';

/**
 * The example's lookup (its own string resources; the core has CYLMenuLocalizedString): every user-facing string goes
 * through it or $r, never a literal.
 */
function t(component: Object, key: string): string {
  return getContext(component).resourceManager.getStringByNameSync(key);
}
const FILTER = 'menu.filter';

function key(p: CYLIndexPath): string {
  return `${p.section}-${p.item}`;
=======
=======
import { CYLExampleUIContext } from '../demos/samples/SampleSupport';
>>>>>>> d2e3a1d (fix(harmony): 🐛 ArkTS warnings 92 → 1 (score 9.1))
import { CYLDemoNav } from '../demos/DemoNav';
import { SHELL_ROUTES } from '../demos/shell/ShellRoutes';
import { MENU_ROUTES } from '../demos/menu/MenuRoutes';
import { SAMPLE_ROUTES } from '../demos/samples/SampleRoutes';

@Builder
function missingBuilder(param: Object) {
  Text('').fontColor('#8E8E93')
>>>>>>> c69f327 (feat(harmony): the iOS example's screens on HarmonyOS (score 98.4))
}

/** The builder of a route, from any group's map. */
function routeBuilder(name: string): WrappedBuilder<[Object]> {
  return SHELL_ROUTES.get(name) ?? MENU_ROUTES.get(name) ?? SAMPLE_ROUTES.get(name) ?? wrapBuilder(missingBuilder);
}

interface RootTab {
  title: string;
  route: string;
  image: Resource;
  selectedImage: Resource;
}

/**
 * The app's root tab bar (iOS CYLExampleAppDelegate.makeRootTabBarController): 场景一：评价筛选, 场景二：搜索分类,
 * the plus button in the middle (the filter scenarios, CYLQueryScenariosViewController), 样式 and 动效. Every tab's root
 * screen pushes onto one Navigation, whose pushed screens cover the tab bar (hidesBottomBarWhenPushed).
 */
const TABS: RootTab[] = [
  { title: '场景一：评价筛选', route: 'CYLProductViewController', image: $r('app.media.a_cart'),
    selectedImage: $r('app.media.a_cart_fill') },
  { title: '场景二：搜索分类', route: 'CYLSearchHomeViewController', image: $r('app.media.a_magnifyingglass_circle'),
    selectedImage: $r('app.media.a_magnifyingglass_circle_fill') },
  // The plus button (CYLExamplePlusButton): an image only, its title read by the screen reader.
  { title: '查询筛选', route: 'CYLQueryScenariosViewController', image: $r('app.media.a_plus_circle_fill'),
    selectedImage: $r('app.media.a_plus_circle_fill') },
  { title: '样式', route: 'CYLTagStyleDemoViewController', image: $r('app.media.a_paintbrush'),
    selectedImage: $r('app.media.a_paintbrush_fill') },
  { title: '动效', route: 'CYLTagAnimationDemoViewController', image: $r('app.media.a_sparkles'),
    selectedImage: $r('app.media.a_sparkles_selected') }
];
const PLUS_INDEX: number = 2;

<<<<<<< HEAD
interface CornerJSON {
  cornerRadius: number;
}

interface StyleJSON {
  itemHeight: number;
  imageSize?: string;
  normal: CornerJSON;
  selected: CornerJSON;
}

interface ConfigJSON {
  selectionMode: string;
  defaultVisibleRows?: number;
  selected?: CYLIndexPath[];
  style?: StyleJSON;
  sections: SectionJSON[];
}

function items(titles: string[]): ItemJSON[] {
  return titles.map((t): ItemJSON => ({ title: t }));
}

/** The tab images of the configuration (HarmonyOS has no SF Symbols): the Android example's vectors as SVG. */
const TAB_IMAGES: Record<string, Resource> = {
  'cyl_tab_tag': $r('app.media.cyl_tab_tag'),
  'cyl_tab_tag_selected': $r('app.media.cyl_tab_tag_selected'),
  'cyl_tab_classify': $r('app.media.cyl_tab_classify'),
  'cyl_tab_classify_selected': $r('app.media.cyl_tab_classify_selected'),
  'post_normal': $r('app.media.post_normal'),
  'post_highlight': $r('app.media.post_highlight'),
};

/** The tab and plus button titles, localized, by identifier (the configuration file keeps the English ones). */
const TAB_TITLES: Record<string, Resource> = {
  'tags': $r('app.string.tab_tags'), 'classify': $r('app.string.tab_classify'), 'plus': $r('app.string.tab_post')
};

/**
 * The example's shell: CYLTabBarController's HarmonyOS library (cyltabbar, scripts/fetch-cyltabbar.sh) shows the tab
 * bar from rawfile/cyl_tabbar_configuration.json: Tags, Classify and the raised Post plus button
 * (CYLTabBarControllerPlusButton), which selects a page of its own. Tab bars stay at the bottom (AGENTS.md).
 */
@Entry
@Component
struct Index {
  @State selectedIndex: number = 0;
  @State tabs?: CYLTabBarConfigurationResult = undefined;
  @State errorText: string = '';
  /** The system gesture bar's height (vp): the tab bar stays above it. */
  @State bottomInset: number = 0;

  aboutToAppear(): void {
    CYLTabBarConfiguration.imageResolver = (name: string) => TAB_IMAGES[name];
    try {
      const configuration = CYLTabBarConfiguration.configurationWithRawFile(getContext(this),
        'cyl_tabbar_configuration.json');
      const tabs = CYLTabBarConfiguration.resultWithConfiguration(configuration, '1.0.0', false);
      tabs.items.forEach((item) => {
        item.title = TAB_TITLES[item.identifier ?? ''] ?? item.title;
      });
      if (tabs.plusButton !== undefined) {
        tabs.plusButton.title = TAB_TITLES[tabs.plusButton.identifier ?? ''] ?? tabs.plusButton.title;
      }
      this.tabs = tabs;
    } catch (error) {
      this.errorText = `${(error as Error).message}`;
    }
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      this.bottomInset = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height);
    });
  }

  @Builder
  page(index: number, identifier: string) {
    if (identifier === 'tags') {
      TagsPage()
    } else if (identifier === 'classify') {
      ClassifyPage()
    } else {
      PostPage()
    }
  }

  build() {
    Column() {
      if (this.tabs !== undefined) {
        CYLTabBarController({
          tabBarItemsAttributes: this.tabs.items,
          plusButton: this.tabs.plusButton,
          selectedIndex: $selectedIndex,
          tintColor: this.tabs.tintColor ?? '#007AFF',
          tabBarBackgroundColor: this.tabs.backgroundColor ?? '#F8F8F8',
          titlePositionAdjustment: this.tabs.titlePositionAdjustment,
          pageBuilder: (index: number, identifier: string) => {
            this.page(index, identifier)
          },
        })
      } else {
        Text(this.errorText).fontColor(Color.Red).margin(16).id('cyl-config-error')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: this.bottomInset })
    .backgroundColor('#F8F8F8')
  }
}

/** The page of the raised plus button (the other examples' "The plus button page"). */
@Component
struct PostPage {
  build() {
    Column() {
      Text($r('app.string.plus_page')).fontSize(17)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .id('plusPage')
  }
}

/**
 * A tag list from one configuration (multiple selection, two rows folded) with the Lottie icons of CYLTagListView and
 * the playback controls of docs/example-demo-rules.md: Play all, a speed slider (0.25x to 4x) and a loop switch, which
 * combine and act at once.
 */
@Component
struct TagsPage {
  @State lastTap: string = '';
  @State speed: number = 1;
  @State loops: boolean = false;
  private controller: CYLTagListController = new CYLTagListController();

  private configuration(): string {
    const titles = ['Home', 'Search', 'Messages', 'Profile', 'Favorites', 'Settings', 'Camera', 'Music', 'Maps',
      'Calendar', 'A long tag that starts a new line', '你好，这是一个TAG。'];
    const animated = (title: string, file: string): ItemJSON => ({ title: title, animation: `asset:${file}` });
    const config: ConfigJSON = {
      selectionMode: 'multiple',
      defaultVisibleRows: 2,
      style: { itemHeight: 36, imageSize: '{18, 18}', normal: { cornerRadius: 0 }, selected: { cornerRadius: 0 } },
      sections: [
        {
          title: t(this, 'section_lottie'),
          items: [animated(t(this, 'tab_home'), 'tab_home_animate.json'),
            animated(t(this, 'tab_messages'), 'tab_message_animate.json'),
            animated(t(this, 'tab_search'), 'tab_search_animate.json'), animated(t(this, 'tab_me'), 'tab_me_animate.json')]
        },
        // Sample data, as the iOS example's tag titles: not localized.
        { title: t(this, 'section_tags'), items: items(titles) }
      ]
    };
    return JSON.stringify(config);
=======
@Entry
@Component
struct Index {
  @State tab: number = 0;
  private stack: NavPathStack = CYLDemoNav.stack;

  aboutToAppear(): void {
    CYLExampleUIContext.context = this.getUIContext();
  }

  @Builder
  destination(name: string, param: Object) {
    NavDestination() {
      routeBuilder(name).builder(param)
    }
    .hideTitleBar(true)
>>>>>>> c69f327 (feat(harmony): the iOS example's screens on HarmonyOS (score 98.4))
  }

  @Builder
  rootPage(route: string) {
    routeBuilder(route).builder(new Object())
  }

  @Builder
  tabBar(index: number) {
    if (index === PLUS_INDEX) {
      Column() {
        Image(TABS[index].image).width(36).height(36)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .id('tab-plus')
      .accessibilityText('查询筛选')
      .accessibilityDescription('按场景分组的筛选演示')
    } else {
      Column({ space: 2 }) {
        Image(this.tab === index ? TABS[index].selectedImage : TABS[index].image)
          .width(26)
          .height(26)
          .fillColor(this.tab === index ? '#007AFF' : '#8E8E93')
        Text(TABS[index].title)
          .fontSize(10)
          .maxLines(1)
          .fontColor(this.tab === index ? '#007AFF' : '#8E8E93')
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .id(`tab-${TABS[index].title}`)
    }
<<<<<<< HEAD
    const p = path(this.classify[0]);
    return this.categoryTags[p.section]?.[p.item] ?? null;
  }

  private filterTitles(section: number, titles: string[]): string[] {
    return this.filter.map(path).filter((p) => p.section === section && p.item > 0).map((p) => titles[p.item - 1]);
  }

  private async reload(): Promise<void> {
    await this.db?.saveSelection(CLASSIFY, this.classify);
    await this.db?.saveSelection(FILTER, this.filter);
    this.places = (await this.db?.places(this.selectedTag(), this.filterTitles(0, REGIONS),
      this.filterTitles(1, this.dishes))) ?? [];
  }

  private classifyJSON(): string {
    const config: ConfigJSON = {
      selectionMode: 'single',
      defaultVisibleRows: 2,
      selected: selectedJSON(this.classify),
      sections: this.categories.map((c, i): SectionJSON => ({ title: c, items: items(this.categoryTags[i]) }))
    };
    return JSON.stringify(config);
  }

  private filterJSON(): string {
    const all: ItemJSON = { title: t(this, 'all'), exclusive: true };
    const section = (title: string, titles: string[]): SectionJSON => ({ title: title, items: [all].concat(items(titles)) });
    const config: ConfigJSON = {
      selectionMode: 'multiple',
      selected: selectedJSON(this.draft),
      sections: [section(t(this, 'regions'), REGIONS), section(t(this, 'dishes'), this.dishes)]
    };
    return JSON.stringify(config);
  }

  private summary(): string {
    const parts: string[] = [this.selectedTag() ?? t(this, 'all')];
    parts.push(...this.filterTitles(0, REGIONS), ...this.filterTitles(1, this.dishes));
    return `${parts.join(' · ')}: ${t(this, 'places_count').replace('%d', `${this.places.length}`)}`;
  }

  @Builder
  filterSheet() {
    Column() {
      Scroll() {
        CYLTagListView({
          configuration: this.filterJSON(),
          onSelectionChange: (selected: CYLIndexPath[]) => this.draft = selected.map(key)
        })
      }.layoutWeight(1)
      Button($r('app.string.filter_ok')).id('filterOK').width('90%').margin(16).onClick(() => {
        this.filter = this.draft;
        this.showFilter = false;
        this.reload();
      })
    }.height('100%')
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.reset')).fontColor('#2AB9A0').id('reset')
          .constraintSize({ minHeight: 44 })
          .accessibilityDescription($r('app.string.reset_hint'))
          .onClick(() => {
          this.classify = [];
          this.filter = [];
          this.reload();
        })
        Text($r('app.string.classify_title')).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
        Text(this.filter.length > 0 ? `${t(this, 'filter')} ●` : t(this, 'filter')).fontColor('#2AB9A0').id('filter')
          .constraintSize({ minHeight: 44 })
          // The dot is visual only: the screen reader says that conditions are set.
          .accessibilityText(this.filter.length > 0 ? $r('app.string.filter_modified') : $r('app.string.filter'))
          .onClick(() => {
          this.draft = this.filter;
          this.showFilter = true;
        })
      }.width('100%').padding(16)
      List() {
        ListItem() {
          CYLTagListView({
            configuration: this.classifyJSON(),
            onSelectionChange: (selected: CYLIndexPath[]) => {
              this.classify = selected.map(key);
              this.reload();
            }
          })
        }
        ListItem() {
          Text(this.summary()).fontSize(13).fontColor('#8E8E93').padding(16).id('summary')
        }
        if (this.places.length === 0) {
          ListItem() {
            Text($r('app.string.no_places')).padding(16).id('empty')
          }
        }
        ForEach(this.places, (place: Place) => {
          ListItem() {
            Row() {
              Column() {
                Text(place.name).fontSize(15)
                Text(place.region).fontSize(12).fontColor('#8E8E93')
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              Text(`★ ${place.rating.toFixed(1)} · ¥${place.price}`).fontSize(13)
            }.padding({ left: 16, right: 16, top: 8, bottom: 8 })
            // One element per place: name, region, then the rating and price in words (not "★" and "¥").
            .accessibilityGroup(true)
            .accessibilityText(`${place.name}, ${place.region}, ${t(this, 'place_rating')
              .replace('%1$s', place.rating.toFixed(1)).replace('%2$d', `${place.price}`)}`)
          }
        }, (place: Place) => `${place.name}-${place.region}`)
      }.layoutWeight(1)
    }
    .id('classifyPage')
    .height('100%')
    .bindSheet($$this.showFilter, this.filterSheet(), { height: SheetSize.LARGE, title: { title: $r('app.string.filter') } })
=======
  }

  build() {
    Navigation(this.stack) {
      Tabs({ barPosition: BarPosition.End, index: this.tab }) {
        ForEach(TABS, (tab: RootTab, index: number) => {
          TabContent() {
            this.rootPage(tab.route)
          }.tabBar(this.tabBar(index))
        }, (tab: RootTab) => tab.route)
      }
      .scrollable(false)
      .animationDuration(0)
      .barHeight(56)
      .barBackgroundColor('#F9F9F9')
      .onChange((index: number) => this.tab = index)
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
    .navDestination(this.destination)
>>>>>>> c69f327 (feat(harmony): the iOS example's screens on HarmonyOS (score 98.4))
  }
}

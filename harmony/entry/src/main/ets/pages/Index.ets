import { CYLExampleLocalizedString } from '../data/CYLExampleLocalization';
import { CYLExampleUIContext } from '../demos/samples/SampleSupport';
import { CYLDemoNav } from '../demos/DemoNav';
import { SHELL_ROUTES } from '../demos/shell/ShellRoutes';
import { MENU_ROUTES } from '../demos/menu/MenuRoutes';
import { SAMPLE_ROUTES } from '../demos/samples/SampleRoutes';

@Builder
function missingBuilder(param: Object) {
  Text('').fontColor('#8E8E93')
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
      .accessibilityText(CYLExampleLocalizedString('查询筛选'))
      .accessibilityDescription(CYLExampleLocalizedString('按场景分组的筛选演示'))
    } else {
      Column({ space: 2 }) {
        Image(this.tab === index ? TABS[index].selectedImage : TABS[index].image)
          .width(26)
          .height(26)
          .fillColor(this.tab === index ? '#007AFF' : '#8E8E93')
        Text(CYLExampleLocalizedString(TABS[index].title))
          .fontSize(10)
          .maxLines(1)
          .fontColor(this.tab === index ? '#007AFF' : '#8E8E93')
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .id(`tab-${TABS[index].title}`)
    }
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
  }
}

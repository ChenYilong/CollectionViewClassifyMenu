/*
 * Index.ets
 * The example's shell on HarmonyOS: CYLTabBarController's HarmonyOS library (cyltabbar) shows the tab bar, built from
 * rawfile/cyl_tabbar_configuration.json: Tags, Classify and the raised Post plus button
 * (CYLTabBarControllerPlusButton), which selects a page of its own. Each page is a React Native surface (index.js: Tags, Classify, Post) of one React Native instance.
 */
import {
  ComponentBuilderContext,
  RNComponentContext,
  RNInstance,
  RNOHContext,
  RNOHCoreContext,
  RNSurface,
  ResourceJSBundleProvider,
  buildRNComponentForTag
} from '@rnoh/react-native-openharmony';
import {
  CYLTabBarConfiguration,
  CYLTabBarConfigurationResult,
  CYLTabBarController
} from 'cyltabbar';
import { window } from '@kit.ArkUI';
import { getRNOHPackages } from '../PackageProvider';
import { CylTagListRNView } from '../CylTagListRNView';
import { installPlacesDatabase } from '../PlacesDatabase';

@Builder
export function buildCustomRNComponent(ctx: ComponentBuilderContext) {
  Stack() {
    if (ctx.componentName === CylTagListRNView.NAME) {
      CylTagListRNView({ ctx: ctx.rnComponentContext, tag: ctx.tag })
    }
  }
  .position({ x: 0, y: 0 })
}

const wrappedCustomRNComponentBuilder = wrapBuilder(buildCustomRNComponent);

/** The tab images of the configuration (HarmonyOS has no SF Symbols): the Android example's vectors as SVG. */
const TAB_IMAGES: Record<string, Resource> = {
  'cyl_tab_tag': $r('app.media.cyl_tab_tag'),
  'cyl_tab_tag_selected': $r('app.media.cyl_tab_tag_selected'),
  'cyl_tab_classify': $r('app.media.cyl_tab_classify'),
  'cyl_tab_classify_selected': $r('app.media.cyl_tab_classify_selected'),
  'post_normal': $r('app.media.post_normal'),
  'post_highlight': $r('app.media.post_highlight'),
};

/** The tab and plus button titles, localized (base, zh_CN), by identifier. */
const TAB_TITLES: Record<string, Resource> = {
  'tags': $r('app.string.tab_tags'), 'classify': $r('app.string.tab_classify'), 'plus': $r('app.string.tab_post')
};

/** The React Native app of each page, by tab identifier (the plus button's is "plus"). */
const APP_KEYS: Record<string, string> = { 'tags': 'Tags', 'classify': 'Classify', 'plus': 'Post' };

@Entry
@Component
struct Index {
  @StorageLink('RNOHCoreContext') private rnohCoreContext: RNOHCoreContext | undefined = undefined;
  @State private selectedIndex: number = 0;
  @State private tabs?: CYLTabBarConfigurationResult = undefined;
  @State private ctx?: RNComponentContext = undefined;
  @State private errorText: string = '';
  /** The system gesture bar's height (vp): the tab bar stays above it. */
  @State private bottomInset: number = 0;
  private rnInstance?: RNInstance;

  async aboutToAppear() {
    const core = this.rnohCoreContext!;
    CYLTabBarConfiguration.imageResolver = (name: string) => TAB_IMAGES[name];
    try {
      const configuration = CYLTabBarConfiguration.configurationWithRawFile(getContext(this),
        'cyl_tabbar_configuration.json');
      const tabs = CYLTabBarConfiguration.resultWithConfiguration(configuration, '1.0.0', false);
      // Localized titles (the example's string resources, by identifier); the file keeps the English ones.
      tabs.items.forEach((item) => {
        const title = TAB_TITLES[item.identifier ?? ''];
        if (title !== undefined) {
          item.title = title;
        }
      });
      if (tabs.plusButton !== undefined) {
        tabs.plusButton.title = TAB_TITLES[tabs.plusButton.identifier ?? ''] ?? tabs.plusButton.title;
      }
      this.tabs = tabs;
    } catch (error) {
      this.errorText = `${(error as Error).message}`;
      return;
    }
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      const area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.bottomInset = px2vp(area.bottomRect.height);
    });
    // The Classify page's database, before React Native opens it (op-sqlite's port cannot copy it from rawfile).
    installPlacesDatabase(getContext(this));
    this.rnInstance = await core.createAndRegisterRNInstance({
      name: 'cyl-tag-list',
      createRNPackages: getRNOHPackages,
      fontResourceByFontFamily: {},
      arkTsComponentNames: [CylTagListRNView.NAME],
    });
    // The bundled JS only (react-native bundle-harmony); a Metro server on the host could be another app's.
    await this.rnInstance.runJSBundle(new ResourceJSBundleProvider(core.uiAbilityContext.resourceManager,
      'bundle.harmony.js'));
    this.ctx = new RNComponentContext(
      RNOHContext.fromCoreContext(core, this.rnInstance),
      wrappedCustomRNComponentBuilder,
      wrapBuilder(buildRNComponentForTag),
      new Map()
    );
  }

  onBackPress(): boolean | undefined {
    this.rnohCoreContext?.dispatchBackPress();
    return true;
  }

  @Builder
  page(index: number, identifier: string) {
    Column() {
      if (this.ctx !== undefined) {
        RNSurface({ ctx: this.ctx, surfaceConfig: { appKey: APP_KEYS[identifier] ?? 'Tags', initialProps: {} } })
      }
    }
    .width('100%')
    .height('100%')
    .id(`cyl-page-${identifier}`)
  }

  build() {
    Column() {
      if (this.tabs !== undefined) {
        CYLTabBarController({
          tabBarItemsAttributes: this.tabs.items,
          // The raised plus button of the configuration (CYLTabBarControllerPlusButton): a page of its own.
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

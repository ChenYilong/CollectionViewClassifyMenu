import { cylFormat } from '../samples/SampleSupport';
import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
import { CYLUIContext } from '@cyl/classifymenu';
/**
 * `CYLTagAnimationDemoViewController` (动效图标): the animations and images of CYLTabBarController's examples, one
 * section per library, created from a dictionary (map) configuration; a tap plays the tag's icon. The playback
 * controls of docs/example-demo-rules.md: Play all (全部播放), a speed slider (0.25x to 4x, steps of 0.25, the value next
 * to it) and a loop switch (循环播放); they combine and act at once, also on icons that are playing.
 *
 * HarmonyOS: the core picks the engine by the file's extension: Lottie (@ohos/lottie), PAG (@tencent/libpag), Rive
 * (@ohos/rive), SVGA (decoded by the library), GIF (frames decoded by ImageKit). The files are rawfiles (pag/, rive/,
 * svga/, gif/); every Rive scene has an SVGA twin (svga, svga-dark), with the same Rive
 * options and PAG resting progress as iOS. Rive has no playback speed on HarmonyOS (`CYLRivePlayer`).
 */
import {
  CYLConfiguration, CYLImage, CYLIndexPath, CYLMenuDataSource, CYLMenuStyle,
  CYLTagListController, CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYLDemoBar } from '../DemoNav';
import { CYLSystemColor } from './MenuSupport';

export const SPEED_MIN: number = 0.25;
export const SPEED_MAX: number = 4;
export const SPEED_STEP: number = 0.25;

/** Section identifiers, one per library, in order. */
export const ANIMATION_SECTION_IDENTIFIERS: string[] =
  ['lottie', 'lottie-images', 'lottie-green', 'pag', 'rive', 'rive-icons', 'svga', 'svga-dark', 'gif', 'images'];

/** The configuration (map) the tag list is created with (rawfile menu/animation-demo.json; Lottie files are rawfiles). */
const CONFIGURATION_PATH: string = 'menu/animation-demo.json';

/** Images by "section-item": the Lottie placeholders and the static tab images (resources need $r). */
const IMAGES: Map<string, CYLImage> = new Map<string, CYLImage>([
  ['1-0', $r('app.media.b_gray_tabbar_home_placeholder')],
  ['1-1', $r('app.media.b_gray_tabbar_message_placeholder')],
  ['1-2', $r('app.media.b_gray_tabbar_me_placeholder')],
  ['9-0', $r('app.media.b_home_normal')],
  ['9-1', $r('app.media.b_fishpond_normal')],
  ['9-2', $r('app.media.b_post_normal')],
  ['9-3', $r('app.media.b_message_normal')],
  ['9-4', $r('app.media.b_account_normal')]
]);

const SELECTED_IMAGES: Map<string, CYLImage> = new Map<string, CYLImage>([
  ['9-0', $r('app.media.b_home_highlight')],
  ['9-1', $r('app.media.b_fishpond_highlight')],
  ['9-2', $r('app.media.b_post_highlight')],
  ['9-3', $r('app.media.b_message_highlight')],
  ['9-4', $r('app.media.b_account_highlight')]
]);

function pathKey(p: CYLIndexPath): string {
  return `${p.section}-${p.item}`;
}

/** The configuration's data source with the images of IMAGES and SELECTED_IMAGES. */
class CYLAnimationDemoSource implements CYLMenuDataSource {
  private base: CYLMenuDataSource;
  menuImageForItem?: (indexPath: CYLIndexPath) => CYLImage | undefined;
  menuSelectedImageForItem?: (indexPath: CYLIndexPath) => CYLImage | undefined;
  menuAnimationURLForItem?: (indexPath: CYLIndexPath) => string | undefined;
  menuAnimationRestingProgressForItem?: (indexPath: CYLIndexPath) => number | undefined;
  menuStyleForSection?: (section: number) => CYLMenuStyle | undefined;

  constructor(base: CYLMenuDataSource) {
    this.base = base;
    this.menuImageForItem = (p: CYLIndexPath) => IMAGES.get(pathKey(p)) ?? base.menuImageForItem?.(p);
    this.menuSelectedImageForItem = (p: CYLIndexPath) => SELECTED_IMAGES.get(pathKey(p)) ?? base.menuSelectedImageForItem?.(p);
    this.menuAnimationURLForItem = (p: CYLIndexPath) => base.menuAnimationURLForItem?.(p);
    this.menuAnimationRestingProgressForItem = (p: CYLIndexPath) => base.menuAnimationRestingProgressForItem?.(p);
    this.menuStyleForSection = (s: number) => base.menuStyleForSection?.(s);
  }

  numberOfSectionsInMenu(): number {
    return this.base.numberOfSectionsInMenu();
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.base.menuNumberOfItemsInSection(section);
  }

  menuTitleForSection(section: number): string {
    return this.base.menuTitleForSection(section);
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.base.menuTitleForItem(indexPath);
  }
}

/** The tag list of the screen, from CONFIGURATION. */
export function animationDemoTagList(context: Context): CYLTagListState {
  const configuration: CYLConfiguration = CYLTagListState.configurationContentsOfFile(CONFIGURATION_PATH, context);
  const tagList = CYLTagListState.withConfiguration(configuration);
  const base = tagList.configurationDataSource;
  if (base !== undefined) {
    const selection = tagList.selectedIndexPaths;
    tagList.menuDataSource = new CYLAnimationDemoSource(base);
    tagList.reloadMenuData();
    tagList.selectedIndexPaths = selection;
  }
  return tagList;
}

/** The speed of the slider: a multiple of SPEED_STEP within SPEED_MIN...SPEED_MAX. */
export function clampedSpeed(value: number): number {
  return Math.min(Math.max(Math.round(value / SPEED_STEP) * SPEED_STEP, SPEED_MIN), SPEED_MAX);
}

@Component
export struct CYLTagAnimationPage {
  /** Root of the 动效 tab: no back button. */
  showsBack: boolean = false;
  @State status: string = CYLExampleLocalizedString('动效引擎：CYLTabBarItemAnimationFactory 已链接');
  @State speed: number = 1;
  @State loops: boolean = false;
  private tagList: CYLTagListState = animationDemoTagList(CYLUIContext.hostContext());
  private controller: CYLTagListController = new CYLTagListController();

  aboutToAppear(): void {
    this.tagList.menuDelegate = {
      menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => {
        const source = this.tagList.menuDataSource;
        const section = source?.menuTitleForSection(indexPath.section) ?? '';
        const title = source?.menuTitleForItem(indexPath) ?? '';
        this.status = cylFormat(CYLExampleLocalizedString('点击「%@」'), `${section} · ${title}`);
      }
    };
  }

  /** "1.5" for 1.5 (`%g`). */
  private speedValue(): string {
    return `${this.speed}`;
  }

  /** Plays every animated icon from progress 0, as 全部播放 does; with the loop switch on, they repeat. */
  playAllAnimations(): void {
    this.controller.playAll();
  }

  build() {
    Column() {
      CYLDemoBar({ title: CYLExampleLocalizedString('动效图标'), showsBack: this.showsBack })
      Text(this.status)
        .fontSize(13)
        .fontColor(CYLSystemColor.secondaryLabel)
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })
        .id('animationStatus')
      Column({ space: 8 }) {
        Row({ space: 10 }) {
          Text(CYLExampleLocalizedString('倍速')).fontSize(15).accessibilityLevel('no')
            .fontColor($r('app.color.cyl_animation_label')) // black, white in dark mode (resources/dark)
          Slider({ value: this.speed, min: SPEED_MIN, max: SPEED_MAX, step: SPEED_STEP })
            .layoutWeight(1)
            .id('speedSlider')
            .accessibilityText(CYLExampleLocalizedString('倍速'))
            .accessibilityDescription(cylFormat(CYLExampleLocalizedString('%@ 倍'), this.speedValue()))
            .onChange((value: number) => this.speed = clampedSpeed(value))
          Text(`${this.speedValue()}×`).fontSize(15).fontFeature('"tnum" on').textAlign(TextAlign.End)
            .fontColor($r('app.color.cyl_animation_label')) // black, white in dark mode (resources/dark)
            .id('speedValue').accessibilityLevel('no')
        }
        .width('100%')
        Row({ space: 10 }) {
          Text(CYLExampleLocalizedString('循环播放')).fontSize(15).accessibilityLevel('no')
            .fontColor($r('app.color.cyl_animation_label')) // black, white in dark mode (resources/dark)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.loops })
            .id('loopSwitch')
            .accessibilityText(CYLExampleLocalizedString('循环播放'))
            .onChange((isOn: boolean) => {
              this.loops = isOn;
              if (isOn) {
                this.playAllAnimations();
              }
            })
          Button() {
            Row({ space: 6 }) {
              Text('▶').fontSize(13).fontColor(Color.White)
              Text(CYLExampleLocalizedString('全部播放')).fontSize(15).fontColor(Color.White)
            }.padding({ left: 14, right: 14 })
          }
          .height(34)
          .backgroundColor(CYLSystemColor.blue)
          .accessibilityText(CYLExampleLocalizedString('全部播放'))
          .accessibilityDescription(CYLExampleLocalizedString('从头播放屏幕上的全部动效'))
          .id('playAll')
          .onClick(() => this.playAllAnimations())
        }
        .width('100%')
      }
      .padding({ left: 16, right: 16, top: 8 })
      CYLTagListView({
        tagList: this.tagList,
        animationSpeed: this.speed,
        animationLoops: this.loops,
        controller: this.controller
      })
        .layoutWeight(1)
        .margin({ top: 4 })
        .id('animationTagList')
    }
    .width('100%')
    .height('100%')
    // Follows the color mode (also `cylColorMode`): a fixed white kept the page light in dark mode.
    .backgroundColor($r('app.color.cyl_animation_background'))
    .id('CYLTagAnimationDemoViewController')
  }
}

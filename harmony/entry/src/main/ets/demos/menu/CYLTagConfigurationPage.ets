/**
 * `CYLTagConfigurationDemoViewController` (配置初始化): the two ways to create a tag list (after CYLTabBarController's
 * -initWithConfiguration: and -initWithConfigurationFile:error:): a configuration file (JSON, a rawfile of the app)
 * and a dictionary (map).
 *
 * HarmonyOS: the core plays Lottie; the PAG, Rive and GIF items show their titles, and "system:<SF Symbol>" images
 * have no HarmonyOS counterpart (the core leaves them out).
 */
import {
  CYLConfiguration, CYLIndexPath, CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYLDemoBar } from '../DemoNav';
import { CYLSystemColor } from './MenuSupport';

/** Path of the configuration file in the app (rawfile). */
export const CONFIGURATION_FILE_PATH: string = 'menu/animated-tags.json';

/** The dictionary of the map example (its contents in rawfile menu/map-configuration.json). */
export function mapConfiguration(context: Context): CYLConfiguration {
  return CYLTagListState.configurationContentsOfFile('menu/map-configuration.json', context);
}

@Builder
function caption(text: string, id: string) {
  Text(text)
    .fontSize(13)
    .fontColor(CYLSystemColor.secondaryLabel)
    .padding({ left: 16, right: 16 })
    .width('100%')
    .id(id)
}

@Component
export struct CYLTagConfigurationPage {
  @State fileHeight: number = 0;
  @State mapHeight: number = 0;
  @State event: string = '动效引擎：CYLTabBarItemAnimationFactory 已链接';
  private fileTagList?: CYLTagListState;
  private configurationError: string = '';
  private mapTagList: CYLTagListState = CYLTagListState.withConfiguration(mapConfiguration(getContext()));

  aboutToAppear(): void {
    try {
      this.fileTagList = CYLTagListState.withConfigurationFile(CONFIGURATION_FILE_PATH, getContext(this));
    } catch (e) {
      this.configurationError = (e as Error).message ?? '?';
    }
    const lists: (CYLTagListState | undefined)[] = [this.fileTagList, this.mapTagList];
    lists.forEach((list: CYLTagListState | undefined, index: number) => {
      if (list === undefined) {
        return;
      }
      list.menuDelegate = {
        menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => {
          this.event = `点击「${list.menuDataSource?.menuTitleForItem(indexPath) ?? ''}」`;
        },
        menuDidChangeContentHeight: (menu: Object, height: number) => {
          if (index === 0) {
            this.fileHeight = height;
          } else {
            this.mapHeight = height;
          }
        }
      };
    });
  }

  build() {
    Column() {
      CYLDemoBar({ title: '配置初始化', showsBack: true })
      Scroll() {
        Column({ space: 8 }) {
          caption(`配置文件初始化：${CONFIGURATION_FILE_PATH}`, 'configurationFileTitle')
          if (this.fileTagList !== undefined) {
            CYLTagListView({ tagList: this.fileTagList }).height(this.fileHeight).id('configurationFileList')
          } else {
            caption(this.configurationError, 'configurationError')
          }
          caption('字典（map）初始化：-initWithConfiguration:', 'configurationMapTitle')
          CYLTagListView({ tagList: this.mapTagList }).height(this.mapHeight).id('configurationMapList')
          caption(this.event, 'configurationEvent')
        }
        .padding({ top: 12 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CYLSystemColor.groupedBackground)
    .id('CYLTagConfigurationDemoViewController')
  }
}

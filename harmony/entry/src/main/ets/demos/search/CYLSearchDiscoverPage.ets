/**
 * 搜索历史与发现 (iOS CYLSearchDiscoverViewController): "最近搜索" is a tag list whose fold control is a tag cell
 * (tail position); "发现" is a grid of two plain titles per row, a "热" icon after a title, and the core's More button
 * refreshing the topics at random.
 */
import {
  CYLColor, CYLControlState, CYLEdgeInsets, CYLFont, CYLImage, CYLIndexPath, CYLMenuDataSource, CYLMenuFoldControl,
  CYLMenuFoldControlContent, CYLMenuFoldControlPosition, CYLMenuSelectionMode, CYLMenuStyle, CYLSize,
  CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYLDemoNav } from '../DemoNav';
import { CYLDiscoverTopic, CYLSearchDiscoverData } from './CYLSearchDiscoverData';

const SEPARATOR: string = '#4A3C3C43';

/** The recent searches, one section. */
class CYLRecentSearchSource implements CYLMenuDataSource {
  searches: string[] = [];

  numberOfSectionsInMenu(): number {
    return this.searches.length === 0 ? 0 : 1;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.searches.length;
  }

  menuTitleForSection(section: number): string {
    return '最近搜索';
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.searches[indexPath.item];
  }

  menuAccessibilityHintForItem: (indexPath: CYLIndexPath) => string | undefined = () => '轻点两下搜索';
}

/** The discover topics, one section with the core's More button. */
class CYLDiscoverSource implements CYLMenuDataSource {
  topics: CYLDiscoverTopic[] = [];

  numberOfSectionsInMenu(): number {
    return 1;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.topics.length;
  }

  menuTitleForSection(section: number): string {
    return '发现';
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.topics[indexPath.item].title;
  }

  menuImageForItem: (indexPath: CYLIndexPath) => CYLImage | undefined =
    (indexPath: CYLIndexPath) => this.topics[indexPath.item].icon === 'hot' ? $r('app.media.a_discover_hot') : undefined;
  menuAccessibilityHintForItem: (indexPath: CYLIndexPath) => string | undefined = () => '轻点两下搜索';
  menuShowsMoreButtonInSection: (section: number) => boolean = () => true;
  menuAccessibilityLabelForMoreButtonInSection: (section: number) => string | undefined = () => '换一批';
}

function applyHeaderLook(style: CYLMenuStyle): void {
  style.backgroundColor = CYLColor.WHITE;
  style.headerHeight = 44;
  style.headerFont = new CYLFont(20, FontWeight.Bold);
  style.headerTextColor = CYLColor.BLACK;
  style.headerHorizontalInset = 16;
}

/** The recent searches: white boxes with a light border, the inline chevron drawn the same way. */
export function recentStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
    const a = style.appearance(state);
    a.backgroundColor = CYLColor.WHITE;
    a.borderColor = SEPARATOR;
    a.borderWidth = 1;
    a.cornerRadius = 0;
    a.margin = 14;
    a.font = CYLFont.systemFont(17);
    a.textColor = CYLColor.BLACK;
  });
  style.itemHeight = 36;
  style.interitemSpacing = 12;
  style.lineSpacing = 12;
  style.sectionInsets = new CYLEdgeInsets(4, 16, 24, 16);
  applyHeaderLook(style);
  return style;
}

/** The discover grid: two plain titles per row, truncated, with the core's More button. */
export function discoverStyle(): CYLMenuStyle {
  const style = CYLMenuStyle.gridStyle(2);
  [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
    style.appearance(state).font = new CYLFont(17, FontWeight.Medium);
  });
  // The hot icon at its own size (18 × 18 in Chinese).
  style.imageSize = new CYLSize(18, 18);
  style.itemHeight = 36;
  style.lineSpacing = 16;
  style.sectionInsets = new CYLEdgeInsets(4, 16, 16, 16);
  applyHeaderLook(style);
  return style;
}

@Component
export struct CYLSearchDiscoverPage {
  @State searchText: string = '';
  @State placeholder: string = '搜索';
  @State hint: string = '按住提问，有问必答';
  @State recentHeight: number = 150;
  @State discoverHeight: number = 200;
  @State hasRecent: boolean = true;
  private data: CYLSearchDiscoverData = CYLSearchDiscoverData.bundled();
  private recentSource: CYLRecentSearchSource = new CYLRecentSearchSource();
  private discoverSource: CYLDiscoverSource = new CYLDiscoverSource();
  private recentList: CYLTagListState =
    new CYLTagListState(new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.icon));
  private discoverList: CYLTagListState = new CYLTagListState();

  aboutToAppear(): void {
    this.recentSource.searches = this.data.recentSearches.slice();
    this.discoverSource.topics = this.data.initialTopics;
    // 最近搜索: folded to two rows, the chevron as the last tag; the trash clears the list.
    this.recentList.style = recentStyle();
    this.recentList.selectionMode = CYLMenuSelectionMode.none;
    this.recentList.defaultVisibleRows = 2;
    this.recentList.isScrollEnabled = false;
    this.recentList.menuDataSource = this.recentSource;
    this.recentList.menuDelegate = {
      menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => {
        this.search(this.recentSource.searches[indexPath.item]);
      },
      menuDidChangeContentHeight: (menu: Object, height: number) => {
        this.recentHeight = height;
      }
    };
    // 发现: two per row, the More button refreshes the topics.
    this.discoverList.style = discoverStyle();
    this.discoverList.selectionMode = CYLMenuSelectionMode.none;
    this.discoverList.isScrollEnabled = false;
    this.discoverList.menuDataSource = this.discoverSource;
    this.discoverList.menuDelegate = {
      menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => {
        this.search(this.discoverSource.topics[indexPath.item].title);
      },
      menuDidTapMoreButtonInSection: () => this.refreshDiscover(),
      menuDidChangeContentHeight: (menu: Object, height: number) => {
        this.discoverHeight = height;
      }
    };
    this.reloadLists();
  }

  /** Shows the current data; the search field's placeholder is the first discover topic. */
  reloadLists(): void {
    this.placeholder = this.discoverSource.topics.length > 0 ? this.discoverSource.topics[0].title : '搜索';
    this.hasRecent = this.recentSource.searches.length > 0;
    this.recentList.reloadMenuData();
    this.discoverList.reloadMenuData();
  }

  /** The More button's action: another random selection of topics. */
  refreshDiscover(): void {
    this.discoverSource.topics = this.data.randomTopics(this.discoverSource.topics);
    this.reloadLists();
  }

  /** Searches `text`: shows it in the field and moves it to the front of the recent searches. */
  search(text: string): void {
    const query = text.trim();
    if (query.length === 0) {
      return;
    }
    this.searchText = query;
    const searches = this.recentSource.searches.filter((s: string) => s !== query);
    searches.unshift(query);
    this.recentSource.searches = searches;
    this.reloadLists();
  }

  /** The Search button and the keyboard's search key: the typed text, else the placeholder topic. */
  searchTapped(): void {
    this.search(this.searchText.length > 0 ? this.searchText : this.placeholder);
  }

  clearRecentSearches(): void {
    this.recentSource.searches = [];
    this.reloadLists();
  }

  /** The camera button: not part of this demo, which says so instead of ignoring the tap. */
  searchByImage(): void {
    this.getUIContext().getPromptAction().showDialog({ title: '以图搜索', message: '演示中暂不支持以图搜索。', buttons: [{ text: '好', color: '#007AFF' }] })
      .catch(() => {
        // The dialog was dismissed or could not be shown; nothing to undo.
      });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // The search bar replaces the navigation bar, as in the search apps this screen models.
        Row({ space: 2 }) {
          Image($r('app.media.a_chevron_left'))
            .width(32)
            .height(44)
            .objectFit(ImageFit.Contain)
            .padding(6)
            .accessibilityText('返回')
            .id('CYLSearchDiscoverBack')
            .onClick(() => CYLDemoNav.pop())
          Row({ space: 6 }) {
            TextInput({ placeholder: this.placeholder, text: this.searchText })
              .fontSize(16)
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .enterKeyType(EnterKeyType.Search)
              .accessibilityText('搜索')
              .id('CYLSearchDiscoverField')
              .onChange((value: string) => this.searchText = value)
              .onSubmit(() => this.searchTapped())
            Image($r('app.media.a_camera_viewfinder'))
              .width(36)
              .height(36)
              .padding(8)
              .accessibilityText('以图搜索')
              .id('CYLSearchDiscoverCamera')
              .onClick(() => this.searchByImage())
            Divider().vertical(true).height(18).color(SEPARATOR)
            Text('搜索')
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor('#000000')
              .padding({ left: 6, right: 14 })
              .id('CYLSearchDiscoverSearchButton')
              .onClick(() => this.searchTapped())
          }
          .layoutWeight(1)
          .height(46)
          .borderRadius(22)
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: SEPARATOR })
          .shadow({ radius: 8, color: '#0F000000', offsetY: 2 })
        }
        .padding({ left: 6, right: 14, top: 8 })
        .width('100%')

        Scroll() {
          Column({ space: 4 }) {
            if (this.hasRecent) {
              Stack({ alignContent: Alignment.TopEnd }) {
                CYLTagListView({ tagList: this.recentList }).height(this.recentHeight).id('recentList')
                // The trash button at the trailing edge of the section header.
                Image($r('app.media.a_trash'))
                  .width(44)
                  .height(44)
                  .padding(12)
                  .margin({ right: 4 })
                  .accessibilityText('清空最近搜索')
                  .id('clearRecentSearches')
                  .onClick(() => this.clearRecentSearches())
              }
            }
            CYLTagListView({ tagList: this.discoverList }).height(this.discoverHeight).id('discoverList')
          }
        }
        .margin({ top: 10 })
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .padding({ bottom: 180 })
      }
      .width('100%')
      .height('100%')

      // The light curved area behind the mic button.
      Column() {
        Image($r('app.media.a_ask_arc')).width('100%').height(40).objectFit(ImageFit.Fill)
        Column().width('100%').layoutWeight(1).backgroundColor('#F2F2F7')
      }
      .width('100%')
      .height(130)
      .hitTestBehavior(HitTestMode.Transparent)

      Column({ space: 20 }) {
        Text(this.hint + ' ✨')
          .fontSize(20)
          .fontColor('#993C3C43')
          .textAlign(TextAlign.Center)
          .accessibilityText(this.hint)
          .id('askHint')
        Image($r('app.media.a_mic_fill'))
          .width(68)
          .height(52)
          .padding({ left: 22, right: 22, top: 14, bottom: 14 })
          .backgroundColor('#FFFFFF')
          .borderRadius(26)
          .shadow({ radius: 8, color: '#14000000', offsetY: 2 })
          .accessibilityText('按住提问')
          .accessibilityDescription('按住说出问题，松开发送')
          .id('CYLSearchDiscoverMicButton')
          .gesture(LongPressGesture({ duration: 200 })
            .onAction(() => this.hint = '正在聆听…')
            .onActionEnd(() => this.hint = '按住提问，有问必答')
            .onActionCancel(() => this.hint = '按住提问，有问必答'))
      }
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

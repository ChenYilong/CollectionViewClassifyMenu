/**
 * CYLTagCloudSample.swift — kaedea/android-tagview's sample: MainActivity ("TagView Sample"), SubActivity (Activity
 * Result), ListViewActivity, RecyclerViewActivity, and the hot search screen of its README (YY). The library does the
 * drawing; these screens pass the data and the style values, and handle taps.
 */
import { common, Want } from '@kit.AbilityKit';
import {
  CYLColor, CYLEdgeInsets, CYLFont, CYLMenuStyle, CYLSize, CYLTag, CYLTagAppearance, CYLTagCornerRadiusSquare,
  CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYLDemoBar, CYLDemoNav } from '../DemoNav';
import { CYLSampleButton, SYSTEM_ORANGE, SYSTEM_TEAL, cylFormat, cylToast } from './SampleSupport';

/** android-tagview's sample data (res/values/arrays.xml). */
export class CYLTagCloudSampleData {
  static readonly continents: string[] = ['AFRICA', 'EUROPE', 'ASIA', 'NORTH AMERICA', 'SOUTH AMERICA', 'ANTARCTICA',
    'AUSTRALIA'];
  static readonly colors: string[] = ['#00BFFF', '#E91E63', '#F44336', '#9C27B0', '#673AB7'];

  static color(index: number): string {
    return CYLColor.fromHex(CYLTagCloudSampleData.colors[index]) ?? '#FF00BFFF';
  }

  /** The tags of MainActivity's onCreate, in order. Corner radii are android pixels divided by 3. */
  static mainTags(): CYLTag[] {
    const tags: CYLTag[] = CYLTagCloudSampleData.continents.map((title: string) => new CYLTag(0, title));
    for (let i = 1; i < CYLTagCloudSampleData.colors.length; i++) {
      const tag = new CYLTag(0, '彩色文字');
      tag.textColor = CYLTagCloudSampleData.color(i);
      tags.push(tag);
    }
    for (let i = 0; i < CYLTagCloudSampleData.colors.length; i++) {
      tags.push(CYLTag.withHex(0, '彩色背景', CYLTagCloudSampleData.colors[i]));
    }
    const widths: number[] = [1, 2, 3];
    const borderColors: (string | undefined)[] = [undefined, CYLTagCloudSampleData.color(1),
      CYLTagCloudSampleData.color(3)];
    widths.forEach((width: number, i: number) => {
      const tag = new CYLTag(0, '边框');
      tag.borderWidth = width;
      tag.borderColor = borderColors[i];
      tags.push(tag);
    });
    const radii: number[] = [CYLTagCornerRadiusSquare, 20 / 3, 60 / 3];
    radii.forEach((radius: number) => {
      const tag = new CYLTag(0, '圆角');
      tag.cornerRadius = radius;
      tags.push(tag);
    });
    const deletable = new CYLTag(0, '可删除');
    deletable.isDeletable = true;
    tags.push(deletable);
    const custom = new CYLTag(0, '自定义背景');
    custom.textColor = CYLTagCloudSampleData.color(0);
    custom.backgroundImage = $r('app.media.c_tag_bg');
    tags.push(custom);
    const detail = new CYLTag(0, '详情标签');
    detail.textColor = CYLColor.WHITE;
    detail.backgroundColor = '#FFDDDDDD';
    detail.highlightedBackgroundColor = '#FF555555';
    detail.cornerRadius = 20 / 3;
    detail.textSize = 14;
    detail.borderWidth = 1;
    detail.borderColor = CYLColor.WHITE;
    detail.isDeletable = true;
    tags.push(detail);
    tags.forEach((tag: CYLTag, index: number) => tag.identifier = index);
    return tags;
  }

  /** item_list_tag.xml: a tag cloud list that does not scroll. */
  static cellList(tags: CYLTag[]): CYLTagListState {
    const list = new CYLTagListState();
    list.style = CYLMenuStyle.tagCloud();
    list.lineSpacing = 5;
    list.interitemSpacing = 3;
    list.tagContentInsets = new CYLEdgeInsets(3, 10, 3, 10);
    list.isScrollEnabled = false;
    list.replaceTags(tags);
    return list;
  }
}

/** The parameter of CYLTagCloudSubViewController: called when it returns RESULT_OK. */
export class CYLTagCloudSubParam {
  onResult: () => void;

  constructor(onResult: () => void) {
    this.onResult = onResult;
  }
}

/** MainActivity. */
@Component
export struct CYLTagCloudSamplePage {
  @State text: string = '';
  private list: CYLTagListState = new CYLTagListState();

  aboutToAppear(): void {
    // activity_main.xml: lineMargin 5dp, tagMargin 3dp, textPadding 10dp × 3dp.
    const list = this.list;
    list.style = CYLMenuStyle.tagCloud();
    list.lineSpacing = 5;
    list.interitemSpacing = 3;
    list.tagContentInsets = new CYLEdgeInsets(3, 10, 3, 10);
    list.addTags(CYLTagCloudSampleData.mainTags());
    list.tagClickHandler = (position: number, tag: CYLTag) => {
      cylToast(cylFormat('点击标签 id = %ld，位置 = %ld', tag.identifier, position));
    };
    list.tagDeleteHandler = (position: number, tag: CYLTag) => {
      cylToast(cylFormat('删除标签 id = %ld，位置 = %ld', tag.identifier, position));
    };
  }

  /** tv_add: the typed text or "ADD A TAG", deletable half the time, one of the five colors. */
  addTag(): void {
    const tag = new CYLTag(0, this.text.length === 0 ? '添加标签' : this.text);
    tag.isDeletable = Math.floor(Math.random() * 2) === 0;
    tag.backgroundColor = CYLTagCloudSampleData.color(Math.floor(Math.random() * 5));
    tag.identifier = this.list.tags.length;
    this.list.addTag(tag);
    this.list.scrollToItem({ section: 0, item: this.list.tags.length - 1 }, true);
  }

  /** startActivityForResult(SubActivity): its button adds a tag here. */
  openActivityResult(): void {
    CYLDemoNav.push('CYLTagCloudSubViewController', new CYLTagCloudSubParam(() => {
      this.list.addTag(new CYLTag(0, '返回结果后添加'));
    }));
  }

  @Builder
  github() {
    Text('</>')
      .fontSize(15)
      .fontColor('#007AFF')
      .height(44)
      .padding({ left: 8, right: 8 })
      .accessibilityText('在 GitHub 上查看')
      .id('sample.github')
      .onClick(() => {
        const want: Want = { action: 'ohos.want.action.viewData', uri: 'https://github.com/kaedea/' };
        (getContext(this) as common.UIAbilityContext).startAbility(want).catch(() => {
        });
      })
  }

  build() {
    Column() {
      CYLDemoBar({ title: '标签视图示例', trailing: () => {
        this.github()
      } })
      Column() {
        CYLTagListView({ tagList: this.list }).height('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      Column({ space: 8 }) {
        Stack({ alignContent: Alignment.Bottom }) {
          TextInput({ placeholder: '输入标签文字', text: this.text })
            .backgroundColor(Color.Transparent)
            .borderRadius(0)
            .padding({ left: 0, right: 0 })
            .height(44)
            .accessibilityText('标签文字')
            .id('sample.tagText')
            .onChange((value: string) => this.text = value)
          Column().width('100%').height(1).backgroundColor(SYSTEM_TEAL)
        }
        Row({ space: 8 }) {
          CYLSampleButton({ title: '添加标签', identifier: 'sample.addTag', color: CYLTagCloudSampleData.color(0),
            action: () => this.addTag() }).layoutWeight(1)
          CYLSampleButton({ title: '页面返回结果', identifier: 'sample.activityResult',
            color: CYLTagCloudSampleData.color(0), action: () => this.openActivityResult() }).layoutWeight(1)
        }
        Row({ space: 8 }) {
          CYLSampleButton({ title: '列表视图', identifier: 'sample.listView', color: CYLTagCloudSampleData.color(0),
            action: () => CYLDemoNav.push('CYLTagCloudListViewController') }).layoutWeight(1)
          CYLSampleButton({ title: '回收视图', identifier: 'sample.recyclerView',
            color: CYLTagCloudSampleData.color(0),
            action: () => CYLDemoNav.push('CYLTagCloudRecyclerViewController') }).layoutWeight(1)
        }
        CYLSampleButton({ title: 'YY 热门搜索', identifier: 'sample.hotSearch', color: SYSTEM_ORANGE,
          action: () => CYLDemoNav.push('CYLHotSearchViewController') })
      }
      .padding({ left: 16, right: 16, bottom: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CYLColor.white(0.93))
  }
}

/** SubActivity: "Add Tag" returns RESULT_OK. */
@Component
export struct CYLTagCloudSubPage {
  param?: CYLTagCloudSubParam;

  build() {
    Column() {
      CYLDemoBar({ title: '子页面' })
      Column() {
        CYLSampleButton({ title: '添加标签并返回', identifier: 'sample.finish', color: CYLTagCloudSampleData.color(0),
          action: () => {
            this.param?.onResult();
            CYLDemoNav.pop();
          } }).width(200)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}

/** ListViewActivity: 51 rows, each with three tags of the row's text. */
@Component
export struct CYLTagCloudListPage {
  private rows: CYLTagListState[] = [];

  static tagsForRow(row: number): CYLTag[] {
    return ['#F06292', '#90CAF9', '#80DEEA'].map((hex: string) => CYLTag.withHex(0, cylFormat('条目 %ld', row), hex));
  }

  aboutToAppear(): void {
    for (let row = 0; row < 51; row++) {
      this.rows.push(CYLTagCloudSampleData.cellList(CYLTagCloudListPage.tagsForRow(row)));
    }
  }

  build() {
    Column() {
      CYLDemoBar({ title: 'ListView 示例' })
      List() {
        ForEach(this.rows, (list: CYLTagListState, row: number) => {
          ListItem() {
            CYLTagListView({ tagList: list })
          }
        }, (list: CYLTagListState, row: number) => `${row}`)
      }
      .divider({ strokeWidth: 0.5, color: '#33000000', startMargin: 16 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}

/** RecyclerViewActivity: 21 text rows and a footer row with two tags. */
@Component
export struct CYLTagCloudRecyclerPage {
  private texts: string[] = Array<string>(21).fill('文本');
  private footer: CYLTagListState = CYLTagCloudSampleData.cellList(
    [1, 2].map((n: number) => new CYLTag(0, cylFormat('页脚 %ld', n))));

  build() {
    Column() {
      CYLDemoBar({ title: 'RecyclerView 示例' })
      List() {
        ForEach(this.texts, (text: string, row: number) => {
          ListItem() {
            Text(text).fontSize(17).height(44).padding({ left: 16, right: 16 }).width('100%')
          }
        }, (text: string, row: number) => `${row}`)
        ListItem() {
          CYLTagListView({ tagList: this.footer })
        }
      }
      .divider({ strokeWidth: 0.5, color: '#33000000', startMargin: 16 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}

/** A hot search's badge: 神 for hit songs (blue), 热 for trending (red). */
enum CYLHotSearchBadge {
  none,
  song,
  trending
}

class CYLHotSearch {
  title: string;
  badge: CYLHotSearchBadge;

  constructor(title: string, badge: CYLHotSearchBadge = CYLHotSearchBadge.none) {
    this.title = title;
    this.badge = badge;
  }
}

/**
 * The hot search screen of android-tagview's README (YY): an orange search bar with 取消, then 热门搜索 tags, some
 * with a 神 or 热 badge. The navigation bar is hidden.
 */
@Component
export struct CYLHotSearchPage {
  static readonly orange: string = CYLColor.rgb(0.95, 0.56, 0.2);
  static readonly blue: string = CYLColor.rgb(0.29, 0.64, 0.94);
  static readonly red: string = CYLColor.rgb(0.9, 0.31, 0.29);
  static readonly hotSearches: CYLHotSearch[] = [
    new CYLHotSearch('入戏太深混合串烧版', CYLHotSearchBadge.song), new CYLHotSearch('他和她', CYLHotSearchBadge.song),
    new CYLHotSearch('妤宸'), new CYLHotSearch('赛菲尔'), new CYLHotSearch('小西瓜', CYLHotSearchBadge.trending),
    new CYLHotSearch('入戏太深', CYLHotSearchBadge.song), new CYLHotSearch('小虾米'), new CYLHotSearch('羽冰'),
    new CYLHotSearch('梦梦'), new CYLHotSearch('神曲不跳转呀呀呀56567', CYLHotSearchBadge.song),
  ];
  @State text: string = '';
  private list: CYLTagListState = new CYLTagListState();

  static hotTags(): CYLTag[] {
    return CYLHotSearchPage.hotSearches.map((search: CYLHotSearch) => {
      const tag = new CYLTag(0, search.title);
      if (search.badge !== CYLHotSearchBadge.none) {
        const song = search.badge === CYLHotSearchBadge.song;
        tag.badgeText = song ? '神' : '热';
        tag.badgeAccessibilityLabel = song ? '神曲' : '热门';
        tag.textColor = song ? CYLHotSearchPage.blue : CYLHotSearchPage.red;
      }
      return tag;
    });
  }

  static hotStyle(): CYLMenuStyle {
    const style = new CYLMenuStyle();
    const appearances: CYLTagAppearance[] = [style.normalAppearance, style.selectedAppearance];
    appearances.forEach((appearance: CYLTagAppearance) => {
      appearance.backgroundColor = CYLColor.WHITE;
      appearance.borderColor = CYLColor.white(0.88);
      appearance.borderWidth = 1;
      appearance.textColor = CYLColor.white(0.13);
      appearance.cornerRadius = CYLTagCornerRadiusSquare;
      appearance.font = CYLFont.systemFont(16);
    });
    style.tagContentInsets = new CYLEdgeInsets(9, 16, 9, 16);
    style.imageSize = new CYLSize(18, 18);
    style.imageTitleSpacing = 6;
    style.interitemSpacing = 8;
    style.lineSpacing = 10;
    style.highlightedBackgroundColor = CYLColor.white(0.94);
    style.headerIndicatorColor = CYLHotSearchPage.orange;
    style.headerFont = CYLFont.systemFont(18);
    style.headerTextColor = CYLColor.white(0.13);
    style.headerHeight = 48;
    style.backgroundColor = CYLColor.WHITE;
    return style;
  }

  aboutToAppear(): void {
    const list = this.list;
    list.style = CYLHotSearchPage.hotStyle();
    list.addTags(CYLHotSearchPage.hotTags());
    list.tagDataSource.sectionTitle = '热门搜索';
    list.showsSectionHeaders = true;
    list.tagClickHandler = (index: number, tag: CYLTag) => {
      this.text = tag.title;
      cylToast(cylFormat('搜索「%@」', tag.title));
    };
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Row({ space: 6 }) {
          SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(16).fontColor([CYLColor.white(0.6)])
          TextInput({ placeholder: '主播昵称/直播间ID/神曲名', text: this.text })
            .placeholderColor(CYLColor.white(0.6))
            .backgroundColor(Color.Transparent)
            .padding(0)
            .height(36)
            .layoutWeight(1)
            .enterKeyType(EnterKeyType.Search)
            .id('hotSearch.field')
            .onChange((value: string) => this.text = value)
        }
        .padding({ left: 8, right: 8 })
        .height(36)
        .layoutWeight(1)
        .borderRadius(4)
        .backgroundColor(CYLColor.rgb(0.99, 0.91, 0.82))
        Text('取消')
          .fontSize(17)
          .fontColor(Color.White)
          .id('hotSearch.cancel')
          .onClick(() => CYLDemoNav.pop())
      }
      .padding({ left: 8, right: 12 })
      .height(56)
      .width('100%')
      .backgroundColor(CYLHotSearchPage.orange)
      CYLTagListView({ tagList: this.list }).layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}

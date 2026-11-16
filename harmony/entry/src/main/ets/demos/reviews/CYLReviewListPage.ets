import { cylFormat } from '../samples/SampleSupport';
import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
import { CYLUIContext } from '@cyl/classifymenu';
import { CYLAccessibilitySelectedModifier } from '@cyl/classifymenu';
/**
 * 场景一（评价页）：多选评价筛选，折叠为两行，旋转箭头展开/收起；每次选择后按全部所选条件（AND）刷新下方评价列表。
 * 内存筛选、网络筛选与数据库筛选（SQLite）是三种场景，通过顶部开关切换 (iOS CYLReviewListViewController).
 */
import { common } from '@kit.AbilityKit';
import {
  CYLColor, CYLControlState, CYLEdgeInsets, CYLFont, CYLIndexPath, CYLMenuDelegate, CYLMenuFoldControl,
  CYLMenuFoldControlContent, CYLMenuFoldControlPosition, CYLMenuSelectionMode, CYLMenuStyle, CYLSize,
  CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYLDemoBar } from '../DemoNav';
import { CYLExampleMenuItem, CYLExampleMenuSection, CYLExampleMenuSource } from '../shell/CYLExampleMenuSource';
import {
  CYLDatabaseReviewQuery, CYLMemoryReviewQuery, CYLNetworkReviewQuery, CYLReview, CYLReviewFilter,
  CYLReviewFilteringMode, CYLReviewQuerying, CYLReviewStore
} from './CYLReviewStore';

/** The orange review filter style, also used for the product page preview. */
export function reviewFilterStyle(): CYLMenuStyle {
  const orange = CYLColor.rgb(1, 0.31, 0);
  const style = new CYLMenuStyle();
  const font = CYLFont.systemFont(12);
  style.setTitleTextAttributes(font, CYLColor.white(0.3), CYLControlState.NORMAL);
  style.setTitleTextAttributes(font, CYLColor.WHITE, CYLControlState.SELECTED);
  // The icon follows the title on the orange selected chip (an orange icon on orange was invisible).
  style.setIconColor(CYLColor.WHITE, CYLControlState.SELECTED);
  style.setTitleTextAttributes(font, CYLColor.white(0.7), CYLControlState.DISABLED);
  style.imageSize = new CYLSize(13, 13);
  style.imageTitleSpacing = 3;
  [style.normalAppearance, style.selectedAppearance, style.disabledAppearance].forEach((a) => {
    a.cornerRadius = 2;
    a.margin = 8;
    a.borderWidth = 0.5;
    a.backgroundColor = CYLColor.white(0.96);
    a.borderColor = CYLColor.white(0.88);
  });
  style.selectedAppearance.backgroundColor = orange;
  style.selectedAppearance.borderColor = orange;
  style.itemHeight = 28;
  style.interitemSpacing = 8;
  style.lineSpacing = 10;
  style.sectionInsets = new CYLEdgeInsets(10, 12, 6, 12);
  style.foldControlColor = CYLColor.white(0.45);
  return style;
}

const MODES: string[] = ['内存筛选', CYLExampleLocalizedString('网络筛选'), CYLExampleLocalizedString('数据库筛选')];

/** The pushed screen's parameter: the preselected filter (0 is "全部") and 'memory', 'network' or 'database'. */
export interface CYLReviewListParam {
  selectedFilterIndex: number;
  mode: string;
}

const MODE_NAMES: string[] = ['memory', 'network', 'database'];

@Component
export struct CYLReviewListPage {
  param?: CYLReviewListParam;
  @State mode: number = CYLReviewFilteringMode.memory;
  @State filterHeight: number = 120;
  @State status: string = '';
  @State loading: boolean = false;
  @State visibleReviews: CYLReview[] = [];
  private store: CYLReviewStore = CYLReviewStore.shared();
  private source: CYLExampleMenuSource = new CYLExampleMenuSource([]);
  private filterView: CYLTagListState =
    new CYLTagListState(new CYLMenuFoldControl(CYLMenuFoldControlPosition.footer, CYLMenuFoldControlContent.icon));
  private query: CYLReviewQuerying = new CYLMemoryReviewQuery();
  private selectedFilters: CYLReviewFilter[] = [];
  private lastEvent: string = '';

  aboutToAppear(): void {
    this.mode = Math.max(0, MODE_NAMES.indexOf(this.param?.mode ?? 'memory'));
    this.query = this.makeQuery(this.mode);
    const items: CYLExampleMenuItem[] = this.store.filters.map((filter: CYLReviewFilter) => {
      const item = new CYLExampleMenuItem(this.store.titleFor(filter));
      item.image = filter.image;
      // White on the orange selected chip: the icons are colored PNGs, which a tint (fillColor) does not recolor.
      item.selectedImage = filter.selectedImage;
      item.value = filter;
      item.isEnabled = this.store.reviewsMatching(filter).length > 0;
      item.isExclusive = filter.identifier === 'all';
      return item;
    });
    this.source = new CYLExampleMenuSource([new CYLExampleMenuSection(CYLExampleLocalizedString('评价'), items)]);
    const view = this.filterView;
    view.style = reviewFilterStyle();
    view.selectionMode = CYLMenuSelectionMode.multiple;
    view.showsSectionHeaders = false;
    view.defaultVisibleRows = 2;
    view.isScrollEnabled = false;
    view.menuDelegate = this.delegate();
    view.menuDataSource = this.source;
    view.reloadMenuData();

    const index = Math.max(0, Math.min(this.param?.selectedFilterIndex ?? 0, items.length - 1));
    const selected: CYLIndexPath = { section: 0, item: index };
    view.selectedIndexPaths = [selected];
    // A preselected chip hidden by folding would be confusing, so show it.
    if (index >= view.numberOfVisibleItems(0)) {
      view.setExpanded(true, 0, false);
    }
    this.lastEvent = cylFormat(CYLExampleLocalizedString('点击「%@」'), this.source.item(selected).title);
    this.refreshReviews();
  }

  private delegate(): CYLMenuDelegate {
    return {
      menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => {
        this.lastEvent = cylFormat(CYLExampleLocalizedString('点击「%@」'), this.source.item(indexPath).title);
      },
      menuDidDeselectItem: (menu: Object, indexPath: CYLIndexPath) => {
        this.lastEvent = cylFormat(CYLExampleLocalizedString('取消「%@」'), this.source.item(indexPath).title);
      },
      menuDidChangeSelectedItems: (menu: Object, indexPaths: CYLIndexPath[]) => {
        if (indexPaths.length === 0) {
          // Nothing selected means no condition: show "全部" as selected.
          this.filterView.selectItem({ section: 0, item: 0 });
        }
        this.refreshReviews();
      },
      menuDidChangeContentHeight: (menu: Object, height: number) => {
        this.filterHeight = height;
      }
    };
  }

  private makeQuery(mode: number): CYLReviewQuerying {
    if (mode === CYLReviewFilteringMode.network) {
      return new CYLNetworkReviewQuery();
    }
    if (mode === CYLReviewFilteringMode.database) {
      return new CYLDatabaseReviewQuery(CYLUIContext.hostContext(this.getUIContext()));
    }
    return new CYLMemoryReviewQuery();
  }

  setMode(mode: number): void {
    this.mode = mode;
    this.query = this.makeQuery(mode);
    this.refreshReviews();
  }

  refreshReviews(): void {
    this.selectedFilters = [];
    this.filterView.selectedIndexPaths.forEach((p: CYLIndexPath) => {
      const filter = this.source.item(p).value as CYLReviewFilter;
      if (filter.identifier !== 'all') {
        this.selectedFilters.push(filter);
      }
    });
    const query = this.query;
    query.fetchReviewsMatching(this.selectedFilters, (reviews: CYLReview[]) => {
      if (query === this.query) {
        this.show(reviews);
      }
    });
    if (query.isLoading) {
      this.loading = true;
      this.updateStatus();
    }
  }

  private show(reviews: CYLReview[]): void {
    this.visibleReviews = reviews;
    this.loading = false;
    this.updateStatus();
  }

  private updateStatus(): void {
    const names = this.selectedFilters.map((f: CYLReviewFilter) => f.name);
    const selection = names.length === 0 ? CYLExampleLocalizedString('全部') : names.join(CYLExampleLocalizedString('、'));
    const lines: string[] = [`${this.lastEvent} · ${cylFormat(CYLExampleLocalizedString('已选：%@'), selection)}`];
    const count = this.visibleReviews.length;
    if (this.mode === CYLReviewFilteringMode.network) {
      const network = this.query as CYLNetworkReviewQuery;
      const url = network.lastRequestURL ?? '';
      const path = url.replace('https://api.example.com', '');
      lines.push(`${CYLExampleLocalizedString('网络筛选：向服务器发送条件')} · GET ${decodeURIComponent(path)}`);
      lines.push(network.isLoading ? CYLExampleLocalizedString('加载中…') : cylFormat(CYLExampleLocalizedString('服务器返回 %lu 条'), count));
    } else if (this.mode === CYLReviewFilteringMode.database) {
      const database = this.query as CYLDatabaseReviewQuery;
      lines.push(`${CYLExampleLocalizedString('数据库筛选：条件生成 SQL，在 SQLite 中查询')} · ${cylFormat(CYLExampleLocalizedString('匹配 %lu 条'), count)}`);
      lines.push(database.lastQuery?.displayString() ?? '');
    } else {
      lines.push(`${CYLExampleLocalizedString('内存筛选：在已加载的评价中立即匹配')} · ${cylFormat(CYLExampleLocalizedString('匹配 %lu 条'), count)}`);
    }
    this.status = lines.join('\n');
  }

  @Builder
  modeControl() {
    Row() {
      ForEach(MODES, (title: string, index: number) => {
        Text(title)
          .fontSize(13)
          .fontWeight(this.mode === index ? FontWeight.Medium : FontWeight.Normal)
          .fontColor('#000000')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(28)
          .borderRadius(7)
          .backgroundColor(this.mode === index ? '#FFFFFF' : Color.Transparent)
          .shadow(this.mode === index ? { radius: 2, color: '#26000000', offsetY: 1 } : { radius: 0 })
          .id(`reviewMode-${index}`)
          .attributeModifier(new CYLAccessibilitySelectedModifier(this.mode === index))
          .onClick(() => {
            if (this.mode !== index) {
              this.setMode(index);
            }
          })
      }, (title: string) => title)
    }
    .padding(2)
    .borderRadius(9)
    .backgroundColor('#1F767680')
    .width(280)
  }

  build() {
    Column() {
      // A pushed screen: the segmented control is the navigation item's title view.
      CYLDemoBar({ title: cylFormat(CYLExampleLocalizedString('评价(%lu)'), this.store.reviews.length), hasTitleView: true, titleView: () => {
        this.modeControl()
      } })
      CYLTagListView({ tagList: this.filterView })
        .height(this.filterHeight)
        .id('reviewFilter')
      Row({ space: 6 }) {
        if (this.loading) {
          LoadingProgress().width(20).height(20)
            .accessibilityText(CYLExampleLocalizedString('加载中…'))
        }
        Text(this.status)
          .fontSize(13)
          .fontColor('#993C3C43')
          .layoutWeight(1)
          .id('reviewStatus')
      }
      .width('100%')
      .padding({ top: 4, left: 12, bottom: 8, right: 12 })
      .backgroundColor('#F2F2F7')
      Stack() {
        List() {
          ForEach(this.visibleReviews, (review: CYLReview) => {
            ListItem() {
              Row({ space: 12 }) {
                Image($r('app.media.a_person_circle')).width(28).height(28).fillColor('#007AFF')
                  .accessibilityLevel('no')
                Column({ space: 2 }) {
                  Text(review.user).fontSize(17).fontColor('#000000')
                  Text(`${review.text}\n${review.date} ${review.sku}`).fontSize(15).fontColor('#993C3C43')
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)
              .padding({ left: 16, right: 16, top: 11, bottom: 11 })
            }
          }, (review: CYLReview) => review.user)
        }
        .divider({ strokeWidth: 0.5, color: '#4A3C3C43', startMargin: 56 })
        .width('100%')
        .height('100%')
        .opacity(this.loading ? 0.5 : 1)
        .id('reviewList')
        if (this.visibleReviews.length === 0 && !this.loading) {
          Text(CYLExampleLocalizedString('没有匹配的评价')).fontColor('#993C3C43').id('reviewEmpty')
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

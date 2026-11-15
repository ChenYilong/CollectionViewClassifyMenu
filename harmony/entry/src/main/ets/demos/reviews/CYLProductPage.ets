/**
 * 场景一（商品页）：只展示两行评价关键词的预览，点击进入评价页 (iOS CYLProductViewController, the root of the first tab).
 */
import {
  CYLEdgeInsets, CYLIndexPath, CYLMenuFoldStyle, CYLMenuSelectionMode, CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYLDemoBar, CYLDemoNav } from '../DemoNav';
import { CYLExampleMenuItem, CYLExampleMenuSection, CYLExampleMenuSource } from '../shell/CYLExampleMenuSource';
import { CYLReview, CYLReviewFilter, CYLReviewStore } from './CYLReviewStore';
import { CYLReviewListParam, reviewFilterStyle } from './CYLReviewListPage';

@Component
export struct CYLProductPage {
  @State previewHeight: number = 80;
  private store: CYLReviewStore = CYLReviewStore.shared();
  private previewView: CYLTagListState = new CYLTagListState();
  /** Maps preview items to indexes in CYLReviewStore.filters. */
  private previewFilterIndexes: number[] = [];

  aboutToAppear(): void {
    const items: CYLExampleMenuItem[] = [];
    this.store.filters.forEach((filter: CYLReviewFilter, index: number) => {
      if (filter.isKeyword) {
        items.push(new CYLExampleMenuItem(this.store.titleFor(filter)));
        this.previewFilterIndexes.push(index);
      }
    });
    const style = reviewFilterStyle();
    style.sectionInsets = new CYLEdgeInsets(4, 0, 12, 0);
    const view = this.previewView;
    view.style = style;
    view.selectionMode = CYLMenuSelectionMode.none;
    view.showsSectionHeaders = false;
    view.foldStyle = CYLMenuFoldStyle.truncate;
    view.defaultVisibleRows = 2;
    view.isScrollEnabled = false;
    view.menuDelegate = {
      menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => {
        this.showReviews(this.previewFilterIndexes[indexPath.item]);
      },
      menuDidChangeContentHeight: (menu: Object, height: number) => {
        this.previewHeight = height;
      }
    };
    view.menuDataSource = new CYLExampleMenuSource([new CYLExampleMenuSection('关键词', items)]);
    view.reloadMenuData();
  }

  /** Pushes the review page with the given filter selected. */
  showReviews(index: number): void {
    const param: CYLReviewListParam = { selectedFilterIndex: index, mode: 'memory' };
    CYLDemoNav.push('CYLReviewListViewController', param);
  }

  build() {
    Column() {
      CYLDemoBar({ title: '宝贝详情', showsBack: false })
      Scroll() {
        Column({ space: 1 }) {
          Column({ space: 8 }) {
            // Sample data: the product's name and price.
            Text('潮牌电镀镜面MLGB字母iphone6手机壳苹果6plus手机壳情侣5S外壳潮').fontSize(16).fontColor('#000000')
            Text('¥9.90-14.90').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FF4F00')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#FFFFFF')

          Column({ space: 6 }) {
            Text(`宝贝评价(${this.store.reviews.length})`).fontSize(15).fontColor('#000000')
            CYLTagListView({ tagList: this.previewView }).height(this.previewHeight).id('productPreview')
            ForEach(this.store.reviews.slice(0, 2), (review: CYLReview) => {
              Text(`${review.user}\n${review.text}`).fontSize(13).fontColor('#993C3C43')
            }, (review: CYLReview) => review.user)
            Button('查看更多评价', { type: ButtonType.Normal })
              .fontSize(17)
              .fontColor('#007AFF')
              .backgroundColor(Color.Transparent)
              .height(44)
              .width('100%')
              .id('productMoreReviews')
              .onClick(() => this.showReviews(0))
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding({ left: 16, right: 16, top: 8 })
          .backgroundColor('#FFFFFF')
        }
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }
}

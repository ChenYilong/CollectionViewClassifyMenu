import { CYLExampleLocalizedString } from '../../data/CYLExampleLocalization';
/**
 * 场景二首页：一个搜索框，点击后 push 进入搜索页（隐藏根 TabBar） (iOS CYLSearchHomeViewController).
 */
import { CYLDemoBar, CYLDemoNav } from '../DemoNav';

@Component
export struct CYLSearchHomePage {
  /** Pushes the search screen (it covers the root tab bar). */
  openSearch(): void {
    CYLDemoNav.push('CYLSearchCategoryViewController');
  }

  build() {
    Column() {
      CYLDemoBar({ title: CYLExampleLocalizedString('脉脉搜索'), showsBack: false })
      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Image($r('app.media.a_magnifyingglass')).width(17).height(17)
            .accessibilityLevel('no')
          Text(CYLExampleLocalizedString('搜人名,职位,公司...')).fontSize(17).fontColor('#993C3C43')
        }
        .width('100%')
        .padding({ top: 12, left: 16, bottom: 12, right: 16 })
        .borderRadius(24)
        .backgroundColor('#1F767680')
        .id('searchHomeButton')
        .accessibilityText(CYLExampleLocalizedString('搜人名,职位,公司...'))
        .onClick(() => this.openSearch())
        Text(CYLExampleLocalizedString('按分类浏览热门标签：找人、动态、八卦、职位')).fontSize(13).fontColor('#993C3C43')
      }
      .alignItems(HorizontalAlign.Start)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }
}

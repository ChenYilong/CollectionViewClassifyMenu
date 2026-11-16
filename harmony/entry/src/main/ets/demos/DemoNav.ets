import { CYLExampleLocalizedString } from '../data/CYLExampleLocalization';
/**
 * The example's navigation: one Navigation (pages/Index.ets) whose NavPathStack pushes the iOS screens by route name
 * (the iOS class name). The route maps (SHELL_ROUTES, MENU_ROUTES, SAMPLE_ROUTES) give each route a builder of its
 * CONTENT: Index wraps it in a NavDestination with a hidden title bar, so every page draws its navigation bar
 * itself, with CYLDemoBar below. WrappedBuilder needs `Args extends Object[]`, so the maps are
 * Map<string, WrappedBuilder<[Object]>> and a screen without a parameter gets `new Object()`; (the title, the back button, an optional trailing builder). Root tabs render the same
 * builders inside their TabContent (without a back button).
 */
export class CYLDemoNav {
  static stack: NavPathStack = new NavPathStack();

  /** Pushes the screen of `route` (an iOS class name), with an optional parameter for its builder. */
  static push(route: string, param?: Object): void {
    CYLDemoNav.stack.pushPathByName(route, param);
  }

  static pop(): void {
    CYLDemoNav.stack.pop();
  }
}

/** The height of a navigation bar (iOS: 44 pt). */
export const CYL_DEMO_BAR_HEIGHT: number = 44;

@Builder
function emptyBuilder() {
}

/** A UINavigationBar: the centered title, a back button when pushed, an optional trailing item. */
@Component
export struct CYLDemoBar {
  @Prop title: string = '';
  /** Shows the back button (pushed screens). */
  @Prop showsBack: boolean = true;
  /** Dark in dark mode (color resources); the other pages keep their fixed light bar. */
  @Prop followsColorMode: boolean = false;
  /** Replaces the title (a navigationItem.titleView). */
  @BuilderParam titleView: () => void = emptyBuilder;
  hasTitleView: boolean = false;
  @BuilderParam trailing: () => void = emptyBuilder;

  build() {
    Stack() {
      if (this.hasTitleView) {
        Row() {
          this.titleView()
        }.padding({ left: this.showsBack ? 48 : 12, right: 12 }).width('100%').justifyContent(FlexAlign.Center)
      } else {
        Text(this.title)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.followsColorMode ? $r('app.color.cyl_animation_label') : '#000000')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding({ left: 56, right: 56 })
          .id('CYLDemoBarTitle')
      }
      if (this.showsBack) {
        Text('‹')
          .fontSize(34)
          .fontColor('#007AFF')
          .width(44)
          .height(CYL_DEMO_BAR_HEIGHT)
          .textAlign(TextAlign.Center)
          .position({ x: 0, y: 0 })
          .accessibilityText(CYLExampleLocalizedString('返回'))
          .id('CYLDemoBarBack')
          .onClick(() => CYLDemoNav.pop())
      }
      Row() {
        this.trailing()
      }.position({ right: 8, top: 0 }).height(CYL_DEMO_BAR_HEIGHT)
    }
    .width('100%')
    .height(CYL_DEMO_BAR_HEIGHT)
    .backgroundColor(this.followsColorMode ? $r('app.color.cyl_bar_background') : '#F9F9F9')
    .border({ width: { bottom: 0.5 }, color: '#33000000' })
  }
}

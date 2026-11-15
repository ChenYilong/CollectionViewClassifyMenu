/**
 * Group B's routes (route name = the iOS class name); no parameter. The tab roots (查询筛选, 标签样式, 动效图标) show
 * no back button, as in iOS; the pushed screens (CYLMenuLinkageViewController, CYLTagConfigurationDemoViewController)
 * do.
 */
import { CYLQueryScenariosPage } from './CYLQueryScenariosPage';
import { CYLMenuLinkagePage } from './CYLMenuLinkagePage';
import { CYLTagStylePage } from './CYLTagStylePage';
import { CYLTagAnimationPage } from './CYLTagAnimationPage';
import { CYLTagConfigurationPage } from './CYLTagConfigurationPage';

@Builder
function queryScenariosBuilder(param: Object) {
  CYLQueryScenariosPage()
}

@Builder
function menuLinkageBuilder(param: Object) {
  CYLMenuLinkagePage()
}

@Builder
function tagStyleBuilder(param: Object) {
  CYLTagStylePage()
}

@Builder
function tagAnimationBuilder(param: Object) {
  CYLTagAnimationPage()
}

@Builder
function tagConfigurationBuilder(param: Object) {
  CYLTagConfigurationPage()
}

export const MENU_ROUTES: Map<string, WrappedBuilder<[Object]>> =
  new Map<string, WrappedBuilder<[Object]>>([
    ['CYLQueryScenariosViewController', wrapBuilder(queryScenariosBuilder)],
    ['CYLMenuLinkageViewController', wrapBuilder(menuLinkageBuilder)],
    ['CYLTagStyleDemoViewController', wrapBuilder(tagStyleBuilder)],
    ['CYLTagAnimationDemoViewController', wrapBuilder(tagAnimationBuilder)],
    ['CYLTagConfigurationDemoViewController', wrapBuilder(tagConfigurationBuilder)]
  ]);

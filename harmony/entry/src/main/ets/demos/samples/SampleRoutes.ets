/**
 * Group C's routes: the iOS class name of each sample screen → the builder of its content.
 * WrappedBuilder needs `Args extends Object[]`, so the parameter is `Object` (pass e.g. `new Object()` for none).
 */
import { CYLTagCloudDemoPage } from './TagCloudDemo';
import {
  CYLHotSearchPage, CYLTagCloudListPage, CYLTagCloudRecyclerPage, CYLTagCloudSamplePage, CYLTagCloudSubPage,
  CYLTagCloudSubParam
} from './TagCloudSample';
import { CYLImageTagEditPage, CYLImageTagEditParam, CYLImageTagListPage, CYLImageTagSamplePage } from './ImageTagSample';
import { CYLTagContainerSamplePage } from './TagContainerSample';

@Builder
function tagCloudDemo(param: Object) {
  CYLTagCloudDemoPage()
}

@Builder
function tagCloudSample(param: Object) {
  CYLTagCloudSamplePage()
}

@Builder
function tagCloudSub(param: Object) {
  CYLTagCloudSubPage({ param: param instanceof CYLTagCloudSubParam ? param as CYLTagCloudSubParam : undefined })
}

@Builder
function tagCloudList(param: Object) {
  CYLTagCloudListPage()
}

@Builder
function tagCloudRecycler(param: Object) {
  CYLTagCloudRecyclerPage()
}

@Builder
function hotSearch(param: Object) {
  CYLHotSearchPage()
}

@Builder
function imageTagSample(param: Object) {
  CYLImageTagSamplePage()
}

@Builder
function imageTagEdit(param: Object) {
  CYLImageTagEditPage({ param: param instanceof CYLImageTagEditParam ? param as CYLImageTagEditParam : undefined })
}

@Builder
function imageTagList(param: Object) {
  CYLImageTagListPage()
}

@Builder
function tagContainerSample(param: Object) {
  CYLTagContainerSamplePage()
}

export const SAMPLE_ROUTES: Map<string, WrappedBuilder<[Object]>> =
  new Map<string, WrappedBuilder<[Object]>>([
    ['CYLTagCloudDemoViewController', wrapBuilder(tagCloudDemo)],
    ['CYLTagCloudSampleViewController', wrapBuilder(tagCloudSample)],
    ['CYLTagCloudSubViewController', wrapBuilder(tagCloudSub)],
    ['CYLTagCloudListViewController', wrapBuilder(tagCloudList)],
    ['CYLTagCloudRecyclerViewController', wrapBuilder(tagCloudRecycler)],
    ['CYLHotSearchViewController', wrapBuilder(hotSearch)],
    ['CYLImageTagSampleViewController', wrapBuilder(imageTagSample)],
    ['CYLImageTagEditViewController', wrapBuilder(imageTagEdit)],
    ['CYLImageTagListViewController', wrapBuilder(imageTagList)],
    ['CYLTagContainerSampleViewController', wrapBuilder(tagContainerSample)],
  ]);

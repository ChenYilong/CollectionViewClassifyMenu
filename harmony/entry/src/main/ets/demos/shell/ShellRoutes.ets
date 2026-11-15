/**
 * Group A's routes (route name = iOS class name): scenario 1 (reviews) and scenario 2 (search).
 */
import { CYLProductPage } from '../reviews/CYLProductPage';
import { CYLReviewListPage, CYLReviewListParam } from '../reviews/CYLReviewListPage';
import { CYLSearchHomePage } from '../search/CYLSearchHomePage';
import { CYLSearchCategoryPage } from '../search/CYLSearchCategoryPage';
import { CYLSearchDiscoverPage } from '../search/CYLSearchDiscoverPage';

@Builder
function productBuilder(param: Object) {
  CYLProductPage()
}

@Builder
function reviewListBuilder(param: Object) {
  CYLReviewListPage({ param: param as CYLReviewListParam })
}

@Builder
function searchHomeBuilder(param: Object) {
  CYLSearchHomePage()
}

@Builder
function searchCategoryBuilder(param: Object) {
  CYLSearchCategoryPage()
}

@Builder
function searchDiscoverBuilder(param: Object) {
  CYLSearchDiscoverPage()
}

export const SHELL_ROUTES: Map<string, WrappedBuilder<[Object]>> =
  new Map<string, WrappedBuilder<[Object]>>([
    ['CYLProductViewController', wrapBuilder(productBuilder)],
    ['CYLReviewListViewController', wrapBuilder(reviewListBuilder)],
    ['CYLSearchHomeViewController', wrapBuilder(searchHomeBuilder)],
    ['CYLSearchCategoryViewController', wrapBuilder(searchCategoryBuilder)],
    // The category screen's pages are its tabs, not pushed: the same screen.
    ['CYLSearchCategoryPageViewController', wrapBuilder(searchCategoryBuilder)],
    ['CYLSearchDiscoverViewController', wrapBuilder(searchDiscoverBuilder)]
  ]);

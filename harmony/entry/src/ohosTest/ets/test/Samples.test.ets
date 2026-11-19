import { CYLExampleLocalizedString } from '../../../main/ets/data/CYLExampleLocalization';
import { ON } from '@kit.TestKit';
import { describe, it } from '@ohos/hypium';
import { cylBack, cylLaunchExample, cylTapAccessible } from './TestSupport';

/**
 * The Android sample ports reached from the 样式 tab: android-tagview (tag cloud, sub page, list, recycler, hot search),
 * TagViewGroup (image tags) and AndroidTagView (tag containers).
 */
export default function samplesTest() {
  describe('SamplesTest', () => {
    it('tagCloudSampleAndItsPages', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('样式'), 'tab-样式', 1200);
      await cylTapAccessible(driver, CYLExampleLocalizedString('android-tagview 示例（Swift 版）'), 'style-sample.tagCloud', 1500);
      await cylTapAccessible(driver, CYLExampleLocalizedString('添加标签'), 'sample.addTag', 500);
      await cylTapAccessible(driver, CYLExampleLocalizedString('页面返回结果'), 'sample.activityResult', 1200);
      await cylTapAccessible(driver, CYLExampleLocalizedString('添加标签并返回'), 'sample.finish', 1200);
      await cylTapAccessible(driver, CYLExampleLocalizedString('列表视图'), 'sample.listView', 1200);
      await cylBack(driver);
      await cylTapAccessible(driver, CYLExampleLocalizedString('回收视图'), 'sample.recyclerView', 1200);
      await cylBack(driver);
      await cylTapAccessible(driver, CYLExampleLocalizedString('YY 热门搜索'), 'sample.hotSearch', 1200);
      await driver.assertComponentExist(ON.id('hotSearch.field'));
      await cylTapAccessible(driver, CYLExampleLocalizedString('取消'), 'hotSearch.cancel', 1000);
      await cylBack(driver);
    })

    it('imageTagSampleCreatesAndLists', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('样式'), 'tab-样式', 1200);
      await cylTapAccessible(driver, CYLExampleLocalizedString('TagViewGroup 示例：图片标签'), 'style-sample.imageTag', 1500);
      await cylTapAccessible(driver, CYLExampleLocalizedString('创建标签'), 'sample.createTags', 1200);
      await driver.assertComponentExist(ON.id('sample.create'));
      await cylBack(driver);
      await cylTapAccessible(driver, CYLExampleLocalizedString('标签列表'), 'sample.tagList', 1200);
      await cylBack(driver);
      await cylBack(driver);
    })

    it('tagContainerSampleAddsATag', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('样式'), 'tab-样式', 1200);
      await cylTapAccessible(driver, CYLExampleLocalizedString('AndroidTagView 示例：标签容器'), 'style-sample.tagContainer', 1500);
      await driver.assertComponentExist(ON.id('sample.newTag'));
      await cylTapAccessible(driver, CYLExampleLocalizedString('添加'), 'sample.add', 500);
      await cylBack(driver);
    })

    it('tagCloudDemoOpens', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTapAccessible(driver, CYLExampleLocalizedString('样式'), 'tab-样式', 1200);
      await cylTapAccessible(driver, CYLExampleLocalizedString('标签云：android-tagview 的初始化方式'), 'style-tagCloud', 1500);
      await driver.assertComponentExist(ON.id('tagCloud.codeCaption'));
      await cylBack(driver);
    })
  })
}

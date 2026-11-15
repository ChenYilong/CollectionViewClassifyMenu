import { ON } from '@kit.TestKit';
import { describe, it } from '@ohos/hypium';
import { cylBack, cylLaunchExample, cylTap } from './TestSupport';

/**
 * The Android sample ports reached from the 样式 tab: android-tagview (tag cloud, sub page, list, recycler, hot search),
 * TagViewGroup (image tags) and AndroidTagView (tag containers).
 */
export default function samplesTest() {
  describe('SamplesTest', () => {
    it('tagCloudSampleAndItsPages', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-样式', 1200);
      await cylTap(driver, 'style-sample.tagCloud', 1500);
      await cylTap(driver, 'sample.addTag', 500);
      await cylTap(driver, 'sample.activityResult', 1200);
      await cylTap(driver, 'sample.finish', 1200);
      await cylTap(driver, 'sample.listView', 1200);
      await cylBack(driver);
      await cylTap(driver, 'sample.recyclerView', 1200);
      await cylBack(driver);
      await cylTap(driver, 'sample.hotSearch', 1200);
      await driver.assertComponentExist(ON.id('hotSearch.field'));
      await cylTap(driver, 'hotSearch.cancel', 1000);
      await cylBack(driver);
    })

    it('imageTagSampleCreatesAndLists', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-样式', 1200);
      await cylTap(driver, 'style-sample.imageTag', 1500);
      await cylTap(driver, 'sample.createTags', 1200);
      await driver.assertComponentExist(ON.id('sample.create'));
      await cylBack(driver);
      await cylTap(driver, 'sample.tagList', 1200);
      await cylBack(driver);
      await cylBack(driver);
    })

    it('tagContainerSampleAddsATag', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-样式', 1200);
      await cylTap(driver, 'style-sample.tagContainer', 1500);
      await driver.assertComponentExist(ON.id('sample.newTag'));
      await cylTap(driver, 'sample.add', 500);
      await cylBack(driver);
    })

    it('tagCloudDemoOpens', 0, async () => {
      const driver = await cylLaunchExample();
      await cylTap(driver, 'tab-样式', 1200);
      await cylTap(driver, 'style-tagCloud', 1500);
      await driver.assertComponentExist(ON.id('tagCloud.codeCaption'));
      await cylBack(driver);
    })
  })
}

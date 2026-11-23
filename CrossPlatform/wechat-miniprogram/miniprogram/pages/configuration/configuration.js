/**
 * 配置初始化 (pushed from 样式): CYLTagConfigurationDemoViewController, 1:1. The two ways to create a tag list, after
 * CYLTabBarController's -initWithConfiguration: and -initWithConfigurationFile:error:: a configuration file (JSON) and
 * a dictionary (map), each under a caption, then a line with the engine status that shows the tapped tag. The icons
 * use the example's animation engines (CYLTabBarController's engine components, bound directly; GIF is drawn by cyl-animated-item itself).
 */
const { t } = require('../../utils/i18n.js');
const animations = require('../../utils/tag-animations.js');
const demo = require('./demo.js');

Page({
  data: {
    fileTitle: '',
    fileConfiguration: null,
    fileError: '',
    mapTitle: '',
    mapConfiguration: {},
    event: '',
  },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('配置初始化') });
    const fs = wx.getFileSystemManager();
    const file = demo.readConfiguration((path) => fs.readFileSync(path, 'utf8'));
    this.setData({
      fileTitle: t('配置文件初始化：%@', demo.CONFIGURATION_FILE_PATH),
      fileConfiguration: file.configuration,
      fileError: file.error,
      mapTitle: t('字典（map）初始化：-initWithConfiguration:'),
      mapConfiguration: demo.mapConfiguration(t),
      event: animations.isAnimationEngineAvailable
        ? t('动效引擎：CYLTabBarItemAnimationFactory 已链接')
        : t('动效引擎未链接：显示静态图标'),
    });
  },

  onTagTap(event) {
    // menu(_:didSelectItemAt:)
    if (event.detail.selected) this.setData({ event: t('点击「%@」', event.detail.title) });
  },
});

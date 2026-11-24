Pod::Spec.new do |s|
  s.name         = 'CollectionViewClassifyMenu'
  s.version      = '0.1.0'
  s.summary      = 'Collection view menus with collapsible and multiple-choice filters for iOS.'
  s.homepage     = 'https://github.com/ChenYilong/CollectionViewClassifyMenu'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'ChenYilong' => 'luohanchenyilong@163.com' }
  s.social_media_url = 'http://weibo.com/luohanchenyilong/'
  s.platform     = :ios, '15.0'
  s.source       = { :git => 'https://github.com/ChenYilong/CollectionViewClassifyMenu.git', :tag => s.version.to_s }
  s.requires_arc = true
  # The core moves from Objective-C to Swift (docs/Swift-Migration.md); both languages build in one module meanwhile.
  s.swift_version = '5.9'
  s.static_framework = true

  s.source_files = [
    'CollectionViewClassifyMenu/Class/**/*.swift',
    'TagCollectionView/TagCollectionView/{CYLTagView,Model/*,Views/*}.swift'
  ]
  # The demo apps' Swift files live next to the core's sources; the patterns above match Swift files (the core moves to
  # Swift), so they are excluded by name, with AppleDouble files.
  s.exclude_files = [
    '**/._*',
    'CollectionViewClassifyMenu/Class/ClassifyMenu/Controller/{CYLDemoDataSource,CYLFilterDemoViewController,CYLMainViewController}.swift',
    'CollectionViewClassifyMenu/Class/Other/Symtem/{CYLAppDelegate,CYLDemoLocalization}.swift',
    'CollectionViewClassifyMenu/Class/Other/Tool/CYLDBManager.swift',
    'TagCollectionView/TagCollectionView/{CYLTagDemoAppDelegate,CYLTagDemoViewController}.swift'
  ]
  s.resource_bundles = { 'CYLClassifyMenuResources' => [
    'CollectionViewClassifyMenu/Class/MultipleFilter/**/*.xib',
    'CollectionViewClassifyMenu/Class/Other/Symtem/Images.xcassets',
    'CollectionViewClassifyMenu/Resources/Localization/*.lproj',
    # Images of the core as a folder bundle (the trash icon of the clear button), as CYLTabBarController's
    # CYLAnimatedItem.bundle: copied whole into the resource bundle, found by CYLMenuResources.imagesBundle.
    'CollectionViewClassifyMenu/Resources/CYLClassifyMenuImages.bundle',
    'CollectionViewClassifyMenu/Resources/Privacy/PrivacyInfo.xcprivacy',
    # The license and the third-party notices ship inside the bundle (AGENTS.md, "License in every published package").
    'CollectionViewClassifyMenu/Resources/License/*',
    'TagCollectionView/TagCollectionView/CYLTagView.xib',
    'TagCollectionView/TagCollectionView/Views/*.xib'
  ] }
  s.frameworks = 'UIKit', 'Accelerate'
  # The tag list cache's database store (CYLTagListCachePolicyDatabase) uses the system SQLite.
  s.libraries = 'sqlite3'
  # CYLTagButton subclasses CYLTabBarController's shared animated icon + title component, CYLAnimatedItemView
  # (https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md): the
  # component's core only, which brings CYLUtils and no tab bar. No animation engine: an app that plays animated icons
  # adds the engine subspec of each file type (CYLAnimatedItem/LottieSwift, .../LottieObjectiveC,
  # ...PAG, ...PAGEnterprise, ...Rive, ...SVGA, ...GIF); without one, tags show their static images. The subspec is
  # not in a CocoaPods release yet: Podfiles pin CYLTabBarController by commit (:git + :commit).
  s.dependency 'CYLAnimatedItem'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end

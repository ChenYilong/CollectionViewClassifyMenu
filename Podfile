platform :ios, '15.0'
project 'CollectionViewClassifyMenu.xcodeproj'

# The demo app's tab bar (AGENTS.md, "CYLTabBarController reference and dependency"): CYLTabBarController at its
# newest commit, as in Example/Podfile; the core library does not depend on it.
CYL_TAB_BAR = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
                :commit => 'ec12a9d85f33d07dffbddb643d37ee67236bfb0a' }
# CYLAnimatedItem, the shared animated icon + title component: its own pod in the same repository and commit, not
# on the trunk yet (https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md).
CYL_ANIMATED_ITEM = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
                      :commit => 'ec12a9d85f33d07dffbddb643d37ee67236bfb0a' }

target 'CollectionViewClassifyMenu' do
  pod 'CollectionViewClassifyMenu', :path => '.'
  pod 'CYLTabBarController', CYL_TAB_BAR
  # Modular headers: CYLAnimatedItem is Objective-C and its podspec does not set DEFINES_MODULE, and this Podfile builds
  # static libraries, so without them the module that CYLTagButton imports does not exist for the targets here.
  pod 'CYLAnimatedItem', CYL_ANIMATED_ITEM.merge(:modular_headers => true)

  target 'CollectionViewClassifyMenuTests' do
    inherit! :search_paths
  end
end

# As Example/Podfile: every pod builds for the project's minimum, iOS 15.0 (CYLTabBarController's podspec says 12.0,
# below what Xcode 27 accepts).
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end

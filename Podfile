platform :ios, '15.0'
project 'CollectionViewClassifyMenu.xcodeproj'

# The demo app's tab bar (AGENTS.md, "CYLTabBarController reference and dependency"): CYLTabBarController at its
# newest commit, as in Example/Podfile; the core library does not depend on it.
CYL_TAB_BAR = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
              :commit => 'b4299707df2dc2d5e545f5175dc7dee075c93597' }
# CYLAnimatedItem, the shared animated icon + title component: its own pod in the same repository and commit, not
# on the trunk yet (https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md).
CYL_ANIMATED_ITEM = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
                    :commit => 'b4299707df2dc2d5e545f5175dc7dee075c93597' }

target 'CollectionViewClassifyMenu' do
  pod 'CollectionViewClassifyMenu', :path => '.'
  pod 'CYLTabBarController', CYL_TAB_BAR
  # No modular headers needed: the module conflict came from CYLTabBarController's headers including CYLAnimatedItemView.h
  # as text (fixed upstream in 83a8ff8, CYLAnimatedItem.podspec sets DEFINES_MODULE); docs/component-architecture.md.
  pod 'CYLAnimatedItem', CYL_ANIMATED_ITEM
  pod 'CYLDeallocBlockExecutor', :git => 'https://github.com/ChenYilong/CYLDeallocBlockExecutor.git', :commit => 'c85c10c0dac23308a5373e4ab4f4e1da7bc41ed9' # CYLTabBarController's badge needs 1.4, not on the trunk yet

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

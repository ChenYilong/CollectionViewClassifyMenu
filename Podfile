platform :ios, '15.0'
project 'CollectionViewClassifyMenu.xcodeproj'

# The demo app's tab bar (AGENTS.md, "CYLTabBarController reference and dependency"): CYLTabBarController at its
# newest commit, as in Example/Podfile; the core library does not depend on it.
CYL_TAB_BAR = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
              :commit => '544e50a3c392ac7a33054fc8895bea9216954211' }
# CYLAnimatedItem, the shared animated icon + title component: its own pod in the same repository and commit, not
# on the trunk yet (https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md).
CYL_ANIMATED_ITEM = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
                    :commit => '544e50a3c392ac7a33054fc8895bea9216954211' }

target 'CollectionViewClassifyMenu' do
  pod 'CollectionViewClassifyMenu', :path => '.'
  pod 'CYLTabBarController', CYL_TAB_BAR
  # No modular headers needed: the module conflict came from CYLTabBarController's headers including CYLAnimatedItemView.h
  # as text (fixed upstream in 83a8ff8, CYLAnimatedItem.podspec sets DEFINES_MODULE); docs/component-architecture.md.
  pod 'CYLAnimatedItem', CYL_ANIMATED_ITEM
  pod 'CYLDeallocBlockExecutor', :git => 'https://github.com/ChenYilong/CYLDeallocBlockExecutor.git', :commit => '4276a6dab5a428ccc3a5f3f347eab991881fb97c' # CYLTabBarController's badge needs 1.4, not on the trunk yet

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

platform :ios, '15.0'
project 'CollectionViewClassifyMenu.xcodeproj'

# The demo app's tab bar (AGENTS.md, "CYLTabBarController reference and dependency"): CYLTabBarController at its
# newest commit, as in Example/Podfile; the core library does not depend on it.
CYL_TAB_BAR = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
                :commit => '074285a66732e47a1783ed3926ac98a13a1c833f' }
# CYLAnimatedItem, the shared animated icon + title component: its own pod in the same repository and commit, not
# on the trunk yet (https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md).
CYL_ANIMATED_ITEM = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
                      :commit => '074285a66732e47a1783ed3926ac98a13a1c833f' }

target 'CollectionViewClassifyMenu' do
  pod 'CollectionViewClassifyMenu', :path => '.'
  pod 'CYLTabBarController', CYL_TAB_BAR
  # Static libraries: CYLAnimatedItem's module map must reach this target (DEFINES_MODULE in its podspec alone does not
  # make the app's Swift compiler load the module; CI b4d0e51, docs/issue-progress.md).
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

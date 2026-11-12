platform :ios, '15.0'
project 'CollectionViewClassifyMenu.xcodeproj'

# The demo app's tab bar (AGENTS.md, "CYLTabBarController reference and dependency"): CYLTabBarController at its
# newest commit, as in Example/Podfile; the core library does not depend on it.
CYL_TAB_BAR = { :git => 'https://github.com/ChenYilong/CYLTabBarController.git',
                :commit => '53766de3b8ca647a8e30e4301418b3264a515170' }

target 'CollectionViewClassifyMenu' do
  pod 'CollectionViewClassifyMenu', :path => '.'
  pod 'CYLTabBarController', CYL_TAB_BAR

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

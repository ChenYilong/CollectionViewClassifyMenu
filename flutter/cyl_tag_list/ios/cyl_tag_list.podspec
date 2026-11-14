#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cyl_tag_list.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cyl_tag_list'
  s.version          = '0.0.1'
  s.summary          = 'Flutter wrapper of the CYLTagListView of CollectionViewClassifyMenu.'
  s.description      = <<-DESC
A Flutter platform view of the native CYLTagListView (CollectionViewClassifyMenu).
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'cyl_tag_list/Sources/cyl_tag_list/**/*'
  s.dependency 'Flutter'
  s.dependency 'CollectionViewClassifyMenu'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'cyl_tag_list_privacy' => ['cyl_tag_list/Sources/cyl_tag_list/PrivacyInfo.xcprivacy']}
end

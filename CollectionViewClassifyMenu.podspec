Pod::Spec.new do |s|
  s.name         = 'CollectionViewClassifyMenu'
  s.version      = '0.1.0'
  s.summary      = 'Collection view menus with collapsible and multiple-choice filters for iOS.'
  s.homepage     = 'https://github.com/ChenYilong/CollectionViewClassifyMenu'
  s.license      = { :type => 'Copyright', :text => 'Copyright (c) ChenYilong. All rights reserved. See individual source files for their copyright notices.' }
  s.author       = { 'ChenYilong' => 'luohanchenyilong@163.com' }
  s.social_media_url = 'http://weibo.com/luohanchenyilong/'
  s.platform     = :ios, '15.0'
  s.source       = { :git => 'https://github.com/ChenYilong/CollectionViewClassifyMenu.git', :branch => 'master' }
  s.requires_arc = true
  s.static_framework = true

  s.source_files = 'CollectionViewClassifyMenu/Class/**/*.{h,m}'
  s.exclude_files = 'CollectionViewClassifyMenu/Class/Other/Symtem/{main.m,AppDelegate.h,AppDelegate.m}'
  s.resources = [
    'CollectionViewClassifyMenu/Class/MultipleFilter/**/*.xib',
    'CollectionViewClassifyMenu/Class/Other/Symtem/Images.xcassets',
    'CollectionViewClassifyMenu/Class/Other/data.json'
  ]
  s.frameworks = 'UIKit', 'Accelerate'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end

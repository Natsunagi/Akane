# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

inhibit_all_warnings!

target 'Akane' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Akane
  pod 'Masonry'
  pod 'SDWebImage'
  pod 'FMDB'

end

target 'Akane_SwiftUI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Akane_iPadOS
  pod 'Masonry'
  pod 'SDWebImage'
  pod 'FMDB'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 13.0
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = 11.0
    end
  end
end

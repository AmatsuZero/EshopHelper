# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
use_frameworks!

def shared_pods
  pod 'Alamofire'
  pod 'PromiseKit/Alamofire'
  pod 'SnapKit', '~> 4.0.0', :inhibit_warnings => true
  pod 'SDWebImage', '~> 4.0'
  pod 'Reusable'
  pod 'FontAwesome.swift'
end

target 'EshopHacker' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  # Pods for EshopHacker
  shared_pods
  pod 'Tabman', '~> 2.1'
  pod 'MJRefresh', :inhibit_warnings => true
  pod 'UIWindowTransitions'
  pod 'Toast-Swift', '~> 4.0.0'
  pod 'WechatOpenSDK'
  pod 'SwiftLint'
  pod 'NVActivityIndicatorView', '~> 4.6.0'

  target 'EshopHackerTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'TodayExtension' do
  shared_pods
end

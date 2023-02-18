# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'ImporterProject' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ImporterProject


pod 'Alamofire', '~> 4.5'
pod 'ObjectMapper'
pod 'SVProgressHUD'
pod 'DZNEmptyDataSet'
pod 'pop'
pod 'Cartography'
pod 'Gradientable'
pod 'SlideMenuControllerSwift'
pod 'Presentr'
pod 'IQKeyboardManagerSwift'
pod 'SDWebImage'
pod 'ESTabBarController-swift'
pod 'FSCalendar'
pod 'Toaster'
pod 'UIScrollView-InfiniteScroll'
pod 'SwiftDate'
pod 'UIImageViewAlignedSwift'
pod 'Material'
pod 'UPCarouselFlowLayout'
pod 'Firebase/Messaging'
pod 'GIFRefreshControl'
pod 'CropViewController'
pod 'lottie-ios'
pod 'AppCenter'
pod 'AppCenter/Distribute'


#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
#      target.build_configurations.each do |config|
#        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
#      end
#    end
#  end
#end

end




#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#    # some older pods don't support some architectures, anything over iOS 11 resolves that
#      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
#    end
#  end
#end



$iOSVersion = '13.0'

post_install do |installer|
 # add these lines:
 installer.pods_project.build_configurations.each do |config|
  config.build_settings["EXCLUDED_ARCHS[sdk=*]"] = "armv7"
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
 end

 installer.pods_project.targets.each do |target|

  # add these lines:
  target.build_configurations.each do |config|
   if Gem::Version.new($iOSVersion) > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
   end
  end

 end
end

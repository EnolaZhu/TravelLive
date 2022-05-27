# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TravelLive' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TravelLive
  pod 'GoogleMaps'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'SwiftLint'
  pod “PubNub”, “~> 4”
  pod 'IQKeyboardManagerSwift'
  pod 'Firebase/Storage'
  pod 'TXLiteAVSDK_Professional'
  pod 'Kingfisher', '~> 7.0' 
  pod 'mobile-ffmpeg-full', '~> 4.4'
  pod 'Firebase/Messaging'
  pod 'lottie-ios'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'Google-Mobile-Ads-SDK'
  pod 'GoogleMLKit/ImageLabeling', '2.6.0'
  pod 'GoogleToolboxForMac', '~> 2.3'
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'MJRefresh'
  pod 'RxSwift', '6.5.0'
  pod 'Firebase/Crashlytics'

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
   end
 end
end

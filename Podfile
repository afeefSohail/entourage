# Uncomment the next line to define a global platform for your project
  platform :ios, '15.0'

target 'entourage' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for entourage
  #pod 'KAPinField'
  pod 'FlagPhoneNumber'
  
  #pod 'Alamofire'
  #pod 'AlamofireImage'
  pod 'SwiftValidator', :git => 'https://github.com/ijameelkhan/SwiftValidator.git'
  #pod 'NVActivityIndicatorView' #, :git => 'https://github.com/ijameelkhan/NVActivityIndicatorView.git'
  #pod 'SwiftLocation'

  #pod 'Firebase/Core'
  #pod 'Firebase/Messaging'
  #pod 'Firebase/Auth'
  #pod 'Firebase/Storage'
  #pod 'Firebase/Firestore'
  #pod 'Firebase/Functions'
  #pod 'CodableFirebase'

  #pod 'MessageKit'
  #pod 'Fabric'
  #pod 'Crashlytics'

  pod 'Koloda'
  pod 'LZViewPager'
  pod 'HGRippleRadarView'
  pod 'FAPaginationLayout'
  #pod 'SwipeCellKit'
  pod 'AwesomeEnum'
  #pod 'Agrume'
  pod 'TPKeyboardAvoiding'
  #pod 'MultiSlider'
  #pod 'SwiftDate'
  #pod 'Kingfisher'
  #pod 'FittedSheets'
  pod 'RSSelectionMenu'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        # Fix for "libarclite" and "tls_record.cc" errors
        # Sets all pods to at least iOS 13.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end

end



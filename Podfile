# Uncomment the next line to define a global platform for your project
  platform :ios, '17.0'

target 'entourage' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for entourage
  #pod 'KAPinField'
  pod 'FlagPhoneNumber'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        # Fix for "libarclite" and "tls_record.cc" errors
        # Sets all pods to at least iOS 13.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      end
    end
  end

end



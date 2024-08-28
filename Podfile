use_frameworks!

target 'X2iOS' do
  # Comment the next line if you don't want to use dynamic frameworks
    pod 'Alamofire'
    pod 'AlamofireImage'
    pod 'SwiftyPing'
    pod 'UICKeyChainStore'
    pod 'IQKeyboardManagerSwift'
    pod 'OneSignal', '<= 4.0'
    pod 'lottie-ios'
end

target 'ConnectTunnel' do
  pod 'OpenVPNAdapter', :git => 'https://github.com/ss-abramchuk/OpenVPNAdapter.git', :tag => '0.3.0'
end

target 'NotificationServiceExtension' do
  pod 'OneSignal', '<= 4.0'
end

target 'X2NetworkExtensioniOS' do
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
    end
  end
end

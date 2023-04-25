use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'

target 'Anilibria' do
    #Network
    pod 'Kingfisher', '7.6.2'

    #Utils
    pod 'DITranquillity', '4.3.5'
    pod 'Localize-Swift', '3.1.0'
    pod 'lottie-ios', '4.1.3'
end


post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
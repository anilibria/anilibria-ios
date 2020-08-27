use_frameworks!
inhibit_all_warnings!

load 'remove_unsupported_libraries.rb'

target 'Anilibria' do
    #Network
    pod 'Kingfisher', '5.13.0'
    pod 'Alamofire', '4.8.2'

    #Utils
    pod 'DITranquillity', '3.9.3'
    pod 'RxSwift', '5.0.1'
    pod 'RxCocoa', :git => 'https://github.com/ReactiveX/RxSwift.git', :commit => '01f927a'
    pod 'Localize-Swift', '2.0.0'
    pod 'lottie-ios', '3.1.1'
    pod 'YandexMobileMetrica'
    pod 'FirebaseCore'
    pod 'Firebase/Messaging'
    pod 'Firebase/Crashlytics'

    #UI
    pod 'MXParallaxHeader'
    pod 'IGListKit', :git => 'https://github.com/Instagram/IGListKit.git', :commit => 'f50f3c7'
end

def unsupported_pods
    ['YandexMobileMetrica']
end

def supported_pods
    [
			'Kingfisher',
			'Alamofire',
			'DITranquillity',
			'RxSwift',
			'RxCocoa',
			'Localize-Swift',
			'lottie-ios',
			'FirebaseCore',
			'Firebase/Messaging',
			'Firebase/Crashlytics',
			'MXParallaxHeader',
			'IGListKit'
		]
end

post_install do |installer|
	$verbose = true # remove or set to false to avoid printing
	installer.configure_support_catalyst(supported_pods, unsupported_pods)
	
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '5'
		end
	end
end

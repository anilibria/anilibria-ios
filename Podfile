use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'

load 'remove_unsupported_libraries.rb'

target 'Anilibria' do
    #Network
    pod 'Kingfisher', '7.4.1'

    #Utils
    pod 'DITranquillity', '4.3.5'
    pod 'Localize-Swift', '3.1.0'
    pod 'lottie-ios', '3.5.0'
    pod 'YandexMobileMetrica', '4.4.0'
end

def unsupported_pods
    ['YandexMobileMetrica']
end

def supported_pods
    [
			'Kingfisher',
			'DITranquillity',
			'Localize-Swift',
			'lottie-ios',
		]
end

post_install do |installer|
	$verbose = true # remove or set to false to avoid printing
	installer.configure_support_catalyst(supported_pods, unsupported_pods)
end

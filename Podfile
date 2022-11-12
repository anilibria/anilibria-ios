use_frameworks!
inhibit_all_warnings!

load 'remove_unsupported_libraries.rb'

target 'Anilibria' do
    #Network
    pod 'Kingfisher', '7.4.1'

    #Utils
    pod 'DITranquillity', '4.3.5'
    pod 'Localize-Swift', '2.0.0'
    pod 'lottie-ios', '3.5.0'
    pod 'YandexMobileMetrica'
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

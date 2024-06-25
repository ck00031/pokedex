install!'cocoapods',:deterministic_uuids=>false

platform :ios, '14.0'
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

def defaults
    pod 'Alamofire', '~> 4.4'
    pod 'SDWebImage', '~> 5.0'
    pod 'SnapKit', '~> 5.0.0'
end

target 'Pokedex' do
	defaults
end

target 'PokedexTests' do
  defaults
end

post_install do |installer|
  xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`
  
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
		end
	end
end

source 'https://github.com/ello/cocoapod-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

# Yep.
inhibit_all_warnings!

project 'Ello'


# Opt into framework support (required for Swift support in CocoaPods RC1)
use_frameworks!

def ello_app_pods
  pod '1PasswordExtension', git: 'https://github.com/ello/onepassword-app-extension'
  pod 'CRToast', git: 'https://github.com/ello/CRToast'
  pod 'Fabric', '~> 1.6'
  pod 'Analytics/Segmentio'
  pod 'JTSImageViewController', git: 'https://github.com/ello/JTSImageViewController'
  pod 'KINWebBrowser', git: 'https://github.com/ello/KINWebBrowser'
  pod 'PINRemoteImage', git: 'https://github.com/pinterest/PINRemoteImage.git', commit: 'af312667f0ce830264198366f481f1b222675a31'
  pod 'SSPullToRefresh', '~> 1.2'
  pod 'ImagePickerSheetController', git: 'https://github.com/lbrndnr/ImagePickerSheetController', branch: 'swift2.3-improvements'
  pod 'iRate', '~> 1.11'
  # swift pods
  pod 'TimeAgoInWords', path: '/Users/s/work/Libraries/TimeAgoInWords'
  pod 'WebLinking', '~> 1.0'
  pod 'SnapKit', git: 'https://github.com/SnapKit/SnapKit', commit: '307d03ec433d61fbb25c9c4a6bb32689537db4d6'
  pod 'FutureKit', '~> 2.0'
  pod 'DeltaCalculator', '~> 1.0'
end

def common_pods
  if ENV['ELLO_STAFF']
    pod 'ElloUIFonts', '~> 1.2.0'
    pod 'ElloCerts', '~> 1.2'
  elsif ENV['ELLO_UI_FONTS_URL']
    pod 'ElloUIFonts', git: ENV['ELLO_UI_FONTS_URL']
    pod 'ElloOSSCerts', '~> 1.1'
  else
    pod 'ElloOSSUIFonts', '~> 1.0.1'
    pod 'ElloOSSCerts', '~> 1.1'
  end
  pod 'MBProgressHUD', '~> 0.9.0'
  pod 'SVGKit', git: 'https://github.com/SVGKit/SVGKit'
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'YapDatabase', '2.8.1'
  pod 'Alamofire', '~> 3.0'
  pod 'Moya', '~> 7.0'
  pod 'KeychainAccess', '~> 2.4.0'
  pod 'SwiftyUserDefaults', '~> 1.3.0'
  pod 'SwiftyJSON', git: 'https://github.com/ello/SwiftyJSON', branch: 'Swift-2.0'
  pod 'Crashlytics', '~> 3.4'
end

def spec_pods
  pod 'FBSnapshotTestCase', git: 'https://github.com/ello/ios-snapshot-test-case'
  pod 'Quick', '~> 0.9.3'
  pod 'Nimble', '4.1.0'
  pod 'Nimble-Snapshots', git: 'https://github.com/ashfurrow/Nimble-Snapshots'
  pod 'OHHTTPStubs', '~> 4.3'
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['WARNING_CFLAGS'] = '$(inherited) -Wno-error=private-header' if target.name == 'FBSnapshotTestCase'
        end
    end
end

target 'Ello' do
  common_pods
  ello_app_pods
end

target 'ShareExtension' do
  common_pods
end

target 'Specs' do
  common_pods
  ello_app_pods
  spec_pods
end

plugin 'cocoapods-keys', {
  project: 'Ello',
  keys: [
    'OauthKey',
    'OauthSecret',
    'CrashlyticsKey',
    'Domain',
    'HttpProtocol',
    'SodiumChloride',
    'SegmentKey',
  ]
}


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # cocoapods 1.1.0-rc2 *should* handle this but isn't for some reason
      config.build_settings['SWIFT_VERSION'] = '2.3'
      # cocoapods does not propogate the platform from above
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end

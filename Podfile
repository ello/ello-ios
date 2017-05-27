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
  pod 'PINRemoteImage', '3.0.0-beta.8'
  pod 'PINCache', git: 'https://github.com/ello/PINCache', commit: '78c3461'
  pod 'SSPullToRefresh', '~> 1.2'
  pod 'ImagePickerSheetController', git: 'https://github.com/ello/ImagePickerSheetController', branch: 'swift3'
  pod 'iRate', '~> 1.11'
  # swift pods
  pod 'TimeAgoInWords', git: 'https://github.com/ello/TimeAgoInWords'
  pod 'WebLinking', git: 'https://github.com/kylef/WebLinking.swift'
  pod 'SnapKit', git: 'https://github.com/ello/SnapKit'
  pod 'DeltaCalculator', git: 'https://github.com/ello/DeltaCalculator'
end

def common_pods
  if ENV['ELLO_STAFF']
    pod 'ElloUIFonts', git: 'git@github.com:ello/ElloUIFonts'
    pod 'ElloCerts', git: 'git@github.com:ello/Ello-iOS-Certs'
  elsif ENV['ELLO_UI_FONTS_URL']
    pod 'ElloUIFonts', git: ENV['ELLO_UI_FONTS_URL']
    pod 'ElloOSSCerts', '~> 2.0'
  else
    pod 'ElloOSSUIFonts', '~> 2.0'
    pod 'ElloOSSCerts', '~> 2.0'
  end
  pod 'PromiseKit'
  pod 'MBProgressHUD', '~> 0.9.0'
  pod 'SVGKit', git: 'https://github.com/ello/SVGKit'
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'YapDatabase', '2.8.1'
  pod 'Alamofire', '~> 4.0'
  pod 'Moya', '8.0.3'
  pod 'KeychainAccess', '~> 3.0'
  pod 'SwiftyUserDefaults', '~> 3.0'
  pod 'SwiftyJSON', '~> 3.1'
  pod 'JWTDecode', '~> 2.0'
  pod 'Crashlytics', '~> 3.4'
end

def spec_pods
  pod 'FBSnapshotTestCase'
  pod 'Quick', '1.1.0'
  pod 'Nimble', '6.0.1'
  pod 'Nimble-Snapshots', '~> 4.4'
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
    'SodiumChloride',
    'SegmentKey',
    'StagingSegmentKey',
    'TeamId',

    'NinjaOauthKey',
    'NinjaOauthSecret',
    'NinjaDomain',
    'Stage1OauthKey',
    'Stage1OauthSecret',
    'Stage1Domain',
    'Stage2OauthKey',
    'Stage2OauthSecret',
    'Stage2Domain',
  ]
}

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['WARNING_CFLAGS'] = '$(inherited) -Wno-error=private-header' if target.name == 'FBSnapshotTestCase'
      # cocoapods 1.1.0-rc2 *should* handle this but isn't for some reason
      config.build_settings['SWIFT_VERSION'] = '3.0'
      # cocoapods does not propogate the platform from above
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end

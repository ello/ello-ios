source 'https://github.com/ello/cocoapod-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '10.3'

# Yep.
inhibit_all_warnings!

project 'Ello'


# Opt into framework support (required for Swift support in CocoaPods RC1)
use_frameworks!

def ello_app_pods
  # objc
  pod '1PasswordExtension', '~> 1.8.5'
  pod 'CRToast', git: 'https://github.com/ello/CRToast'
  pod 'KINWebBrowser', git: 'https://github.com/ello/KINWebBrowser'
  pod 'PINRemoteImage', '3.0.0-beta.8'
  pod 'PINCache', git: 'https://github.com/ello/PINCache', commit: '78c3461'
  pod 'SSPullToRefresh', '~> 1.2'
  # swift pods
  pod 'ImagePickerSheetController', git: 'https://github.com/ello/ImagePickerSheetController', branch: 'swift4'
  pod 'TimeAgoInWords', git: 'https://github.com/ello/TimeAgoInWords'
  pod 'DeltaCalculator', git: 'https://github.com/ello/DeltaCalculator'
end

def ui_pods
  if ENV['ELLO_STAFF']
    pod 'ElloUIFonts', git: 'git@github.com:ello/ElloUIFonts'
  elsif ENV['ELLO_UI_FONTS_URL']
    pod 'ElloUIFonts', git: ENV['ELLO_UI_FONTS_URL']
  else
    pod 'ElloOSSUIFonts', '~> 2.2'
  end
  pod 'SnapKit', git: 'https://github.com/ello/SnapKit', branch: 'swift4-ios10'
end

def common_pods
  if ENV['ELLO_STAFF']
    pod 'ElloCerts', git: 'git@github.com:ello/Ello-iOS-Certs'
  else
    pod 'ElloOSSCerts', '~> 2.0'
  end
  pod 'PromiseKit/CorePromise'
  pod 'MBProgressHUD', '~> 0.9.0'
  pod 'SVGKit', git: 'https://github.com/ello/SVGKit'
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'YapDatabase', '~> 3.0'
  pod 'Alamofire', '~> 4.7'
  pod 'Moya', '~> 8'
  pod 'KeychainAccess', '~> 3.0'
  pod 'SwiftyUserDefaults', '~> 3.0'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'JWTDecode', '~> 2.0'
  pod 'WebLinking', git: 'https://github.com/kylef/WebLinking.swift'
  pod 'Analytics', '~> 3.0'
end

def spec_pods
  pod 'FBSnapshotTestCase'
  pod 'Quick', '~> 1.0'
  pod 'Nimble', '~> 7.0'
  pod 'Nimble-Snapshots', '~> 4.4'
end

target 'Ello' do
  common_pods
  ello_app_pods
  ui_pods
end

target 'ShareExtension' do
  common_pods
  ui_pods
end

target 'NotificationServiceExtension' do
  common_pods
end

target 'Specs' do
  common_pods
  ello_app_pods
  ui_pods
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

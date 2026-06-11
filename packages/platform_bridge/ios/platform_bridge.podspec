#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint platform_bridge.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'platform_bridge'
  s.version          = '0.0.1'
  s.summary          = 'App blocking (Screen Time) and health data bridge for DOPAMINE120.'
  s.description      = <<-DESC
MethodChannel bridge to FamilyControls/ManagedSettings app blocking and HealthKit.
                       DESC
  s.homepage         = 'https://github.com/dopamine120'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'DOPAMINE120' => 'dev@dopamine120.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.frameworks = 'HealthKit'
  # Screen Time frameworks only exist on iOS 15+/16+; usage is availability-guarded.
  s.weak_frameworks = 'FamilyControls', 'ManagedSettings'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'platform_bridge_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end

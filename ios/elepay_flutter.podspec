#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint elepay_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'elepay_flutter'
  s.version          = '3.2.0'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://elepay.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { "elestyle, Inc." => "info@elestyle.jp" }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.9'

  s.ios.deployment_target  = '12.0'
  s.dependency "ElepaySDK", "4.4.0"
end

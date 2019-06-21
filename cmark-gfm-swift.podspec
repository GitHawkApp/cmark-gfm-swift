#
# Be sure to run `pod lib lint cmark-gfm-swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'cmark-gfm-swift'
  s.version          = '0.1.0'
  s.summary          = 'A short description of cmark-gfm-swift.'

  s.homepage         = 'https://github.com/githawkapp/cmark-gfm-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ryan Nystrom' => 'rnystrom@whoisryannystrom.com' }
  s.source           = { :git => 'https://github.com/githawkapp/cmark-gfm-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'Source/**/*.swift', 'Source/**/*.c', 'Source/**/*.h'
  s.public_header_files = 'Source/*.h'
  s.exclude_files = "Source/Info.plist"
  s.preserve_path = 'cmark-gfm-swift/Source/cmark_gfm/module.modulemap'
  s.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/cmark-gfm-swift/Source/cmark_gfm/**' }

end

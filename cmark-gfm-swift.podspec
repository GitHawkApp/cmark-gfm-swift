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
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ryan Nystrom' => 'rnystrom@whoisryannystrom.com' }
  s.source           = { :git => 'https://github.com/githawkapp/cmark-gfm-swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'cmark-gfm-swift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'cmark-gfm-swift' => ['cmark-gfm-swift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  #s.dependency 'cmark-gfm', '~> 0.1.0'
  s.dependency 'libcmark_gfm'

end

#
# Be sure to run `pod lib lint TCPhotoViewer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TCPhotoViewer'
  s.version          = '0.1.2'
  s.summary          = 'A Swift 4 port of NYTPhotoViewer.'
  s.description      = <<-DESC
TCPhotoViewer is a slideshow and image viewer that includes double-tap to zoom, captions, support for multiple images, interactive flick to dismiss, animated zooming presentation, and more.
                       DESC

  s.homepage         = 'https://github.com/TizianoCoroneo/TCPhotoViewer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'TizianoCoroneo' => 'tizianocoroneo@me.com' }
  s.source           = { :git => 'https://github.com/TizianoCoroneo/TCPhotoViewer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tizianocoroneo'

  s.ios.deployment_target = '11.0'

  s.source_files = 'TCPhotoViewer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TCPhotoViewer' => ['TCPhotoViewer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

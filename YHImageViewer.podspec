#
# Be sure to run `pod lib lint YHImageViewer.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "YHImageViewer"
  s.version          = "0.1.1"
  s.summary          = "Simple fullscreen image preview."
  s.description      = <<-DESC
                       Simple fullscreen image preview.
                       Pull request and Issue are welcome :)
                       DESC
  s.homepage         = "https://github.com/hiragram/YHImageViewer"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "yuyahirayama" => "y@yura.me" }
  s.source           = { :git => "https://github.com/hiragram/YHImageViewer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hiragram'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'YHImageViewer' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

#
# Be sure to run `pod lib lint HUPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HUPhotoPicker'
  s.version          = '1.0.3'
  s.summary          = '本地图片选择器.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  本地图片选择器，支持图片多选
                       DESC

  s.homepage         = 'https://github.com/hujewelz/HUPhotoPicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hujewelz' => 'hujewelz@163.com' }
  s.source           = { :git => 'https://github.com/hujewelz/HUPhotoPicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'HUPhotoPicker/Classes/**/*'
  
  s.resource_bundles = {
    'HUPhotoPicker' => ['HUPhotoPicker/Assets/*.{xib,png}']
  }

  s.public_header_files = 'HUPhotoPicker/Classes/**/{HUPhotoPicker,HUPhotoManager,HUImagePickerViewController}.h'
  s.frameworks = 'UIKit', 'Photos'
  # s.dependency 'AFNetworking', '~> 2.3'
end

#
# Be sure to run `pod lib lint MRLogicInjection.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MRLogicInjection'
  s.version          = '0.1.1'
  s.summary          = '使用AOP进行业务逻辑注入的通用底层库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
使用AOP进行业务逻辑注入的通用底层库，主要关注在实例层级的业务逻辑注入
                       DESC

  s.homepage         = 'https://github.com/yishuiliunian/MRLogicInjection'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'stonedong' => 'yishuiliunian@gmail.com' }
  s.source           = { :git => 'https://github.com/yishuiliunian/MRLogicInjection.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '6.0'

  s.source_files = 'MRLogicInjection/Classes/**/*'

  # s.resource_bundles = {
  #   'MRLogicInjection' => ['MRLogicInjection/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

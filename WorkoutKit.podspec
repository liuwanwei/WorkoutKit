#
# Be sure to run `pod lib lint WorkoutKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WorkoutKit'
  s.version          = '0.1.0'
  s.summary          = 'Mostly used in training Apps like 7 mins workout, and HIIT workout.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
In 7 Mins workout and HIIT workout Apps, we need same iCloud functions, this is why I created it.
                       DESC

  s.homepage         = 'https://github.com/liuwanwei/WorkoutKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuwanwei@gmail.com' => 'liuwanwei@gmail.com' }
  s.source           = { :git => 'https://github.com/liuwanwei@gmail.com/WorkoutKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'WorkoutKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WorkoutKit' => ['WorkoutKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'DateTools'
  s.dependency 'FFGlobalAlertController'
end

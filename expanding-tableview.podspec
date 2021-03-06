#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "expanding-tableview"
  s.version          = "0.1.0"
  s.summary          = "A short description of expanding-tableview."
  s.description      = <<-DESC
                       An optional longer description of expanding-tableview

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://EXAMPLE/NAME"
  s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Ike Ellis" => "isaac.c.ellis@gmail.com" }
  s.source           = { :git => "https://github.com/iellis/expanding-tableview.git" }
  s.social_media_url = 'https://twitter.com/EXAMPLE'

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'Classes/**/*.{m,h}'
  s.public_header_files = 'Classes/**/*.h'

  s.resources = 'Assets/*.png'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end

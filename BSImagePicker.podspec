Pod::Spec.new do |s|
  s.name             = "BSImagePicker"
  s.version          = "1.0"
  s.summary          = "BSImagePicker is a multiple image picker for iOS 8."
  s.description      = <<-DESC
  A mix between the native iOS 8 gallery and facebooks image picker. Allows you to preview and select multiple images.
                       DESC
  s.homepage         = "https://github.com/mikaoj/BSImagePicker"
  s.screenshots = ["https://cloud.githubusercontent.com/assets/4034956/4519853/de47afca-4ccd-11e4-9b6b-1a5aea5d9a69.png",
                   "https://cloud.githubusercontent.com/assets/4034956/4519855/de4df42a-4ccd-11e4-865c-4d2e8de6b135.png",
                   "https://cloud.githubusercontent.com/assets/4034956/4519854/de4a3c68-4ccd-11e4-8258-314ead7e959c.png"]
  s.license          = 'MIT'
  s.author           = { "Joakim Gyllstrom" => "joakim@backslashed.se" }
  s.source           = { :git => "https://github.com/mikaoj/BSImagePicker.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BSImagePicker' => ['Pod/Assets/*.png',
                        'Pod/Assets/*.xib',
                        'Pod/Assets/*.storyboard',
                        'Pod/Assets/*.xcassets',
                        'Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Photos'
  s.dependency 'UIImageViewModeScaleAspect', '~> 1.3'
end

Pod::Spec.new do |s|
  s.name             = "BSImagePicker"
  s.version          = "2.0"
  s.summary          = "A short description of BSImagePicker."
  s.description      = <<-DESC
                       An optional longer description of BSImagePicker

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/mikaoj/BSImagePicker"
  # s.screenshots     = "www.example.com/screenshotsots_1", "www.example.com/screenshots_2"
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
end

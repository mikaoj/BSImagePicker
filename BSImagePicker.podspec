Pod::Spec.new do |s|
  s.name             = "BSImagePicker"
  s.version          = "2.3.0"
  s.summary          = "BSImagePicker is a multiple image picker for iOS. UIImagePickerController replacement"
  s.description      = <<-DESC
  A mix between the native iOS gallery and facebooks image picker. Allows you to preview and select multiple images.
  It is intended as a replacement for UIImagePickerController for both selecting and taking photos.
                       DESC
  s.homepage         = "https://github.com/mikaoj/BSImagePicker"
  s.screenshots = ["https://raw.githubusercontent.com/mikaoj/BSImagePicker/master/Misc/Screenshots/select_portrait.png",
                   "https://raw.githubusercontent.com/mikaoj/BSImagePicker/master/Misc/Screenshots/album_portrait.png",
                   "https://raw.githubusercontent.com/mikaoj/BSImagePicker/master/Misc/Screenshots/preview_portrait.png"]
  s.license          = 'MIT'
  s.author           = { "Joakim Gyllström" => "joakim@backslashed.se" }
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

  s.frameworks = 'UIKit', 'Photos'
  s.dependency 'UIImageViewModeScaleAspect', '~> 1.3'
  s.dependency 'BSGridCollectionViewLayout', '~> 1.1'
end

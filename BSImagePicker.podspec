Pod::Spec.new do |s|
  s.name             = "BSImagePicker"
  s.version          = "2.8.2"
  s.summary          = "BSImagePicker is a multiple image picker for iOS. UIImagePickerController replacement"
  s.description      = <<-DESC
  A mix between the native iOS gallery and facebooks image picker. Allows you to preview and select multiple images.
  It is intended as a replacement for UIImagePickerController for both selecting and taking photos.
                       DESC
  s.homepage         = "https://github.com/mikaoj/BSImagePicker"
  s.license          = 'MIT'
  s.author           = { "Joakim Gyllström" => "joakim@backslashed.se" }
  s.source           = { :git => "https://github.com/mikaoj/BSImagePicker.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.swift_version = '4.2'

  s.source_files = 'Source/**/*.swift'
  s.resource_bundles = {
    'BSImagePicker' => ['Assets/*.png',
                        'Assets/*.xib',
                        'Assets/*.storyboard',
                        'Assets/*.xcassets',
                        'Assets/*.png']
  }

  s.frameworks = 'UIKit', 'Photos'
  s.dependency 'BSImageView', '1.0.2'
  s.dependency 'BSGridCollectionViewLayout', '1.2.2'
end

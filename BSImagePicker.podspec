Pod::Spec.new do |s|
  s.name             = "BSImagePicker"
  s.version          = "3.3.1"
  s.summary          = "BSImagePicker is a multiple image picker for iOS. UIImagePickerController replacement"
  s.description      = <<-DESC
  A multiple image picker.
  It is intended as a replacement for UIImagePickerController for both selecting photos.
                       DESC
  s.homepage         = "https://github.com/mikaoj/BSImagePicker"
  s.license          = 'MIT'
  s.author           = { "Joakim Gyllström" => "joakim@backslashed.se" }
  s.source           = { :git => "https://github.com/mikaoj/BSImagePicker.git", :tag => s.version.to_s }

  s.platform     = :ios, '10.0'
  s.requires_arc = true
  s.swift_version = '5.1'

  s.source_files = 'Sources/**/*.swift'

  s.frameworks = 'UIKit', 'Photos'
end

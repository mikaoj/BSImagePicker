Pod::Spec.new do |s|
  s.name         = "BSImagePicker"
  s.version      = "0.7"
  s.summary      = "BSImagePicker is a multiple image picker for iOS"
  s.description  = <<-DESC
  A mix between the native iOS 7 gallery and facebooks image picker. Allows you to preview and select multiple images.
                   DESC
  s.homepage     = "https://github.com/mikaoj/BSImagePicker"
  s.license      = "MIT"
  s.author             = { "Joakim Gyllström" => "joakim@backslashed.se" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/mikaoj/BSImagePicker.git", :tag => "0.7" }
  s.source_files  = "BSImagePicker/**/*.{h,m}"
  s.exclude_files = "BSImagePicker/Controller/BSAppDelegate.{h,m}", "BSImagePicker/Misc/main.m"
  s.public_header_files = "BSImagePicker/Controller/BSImagePickerController.h", "BSImagePicker/Category/UIViewController+BSImagePicker.h"
  s.requires_arc = true
  s.frameworks = 'AssetsLibrary', 'UIKit', 'MediaPlayer'
  s.screenshots = ["https://cloud.githubusercontent.com/assets/4034956/4519853/de47afca-4ccd-11e4-9b6b-1a5aea5d9a69.png",
                   "https://cloud.githubusercontent.com/assets/4034956/4519855/de4df42a-4ccd-11e4-865c-4d2e8de6b135.png",
                   "https://cloud.githubusercontent.com/assets/4034956/4519854/de4a3c68-4ccd-11e4-8258-314ead7e959c.png"]
end


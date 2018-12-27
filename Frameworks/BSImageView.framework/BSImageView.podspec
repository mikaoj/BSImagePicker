Pod::Spec.new do |s|
  s.name         = "BSImageView"
  s.version      = "1.0.2"
  s.summary      = "An image view which lets you animate changes to content mode"
  s.description  = <<-DESC
			An image view which, unlike UIImageView, lets you animate chnages to its content mode.
                   DESC

  s.homepage     = "https://github.com/mikaoj/BSImageView"
  # s.screenshots  = "https://github.com/mikaoj/demo/blob/master/ezgif-2-12b4be73cd.gif"
  s.license      = "MIT"
  s.author             = { "Joakim Gyllström" => "joakim@backslashed.se" }
  s.platform     = :ios, "8.0"
  s.swift_version = "4.2"
  s.source       = { :git => "https://github.com/mikaoj/BSImageView.git", :tag => "#{s.version}" }
  s.source_files  = "Source/**/*.swift"
end

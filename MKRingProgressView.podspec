Pod::Spec.new do |s|
  s.name             = "MKRingProgressView"
  s.version          = "2.2"
  s.summary          = "Ring progress view similar to Activity app on Apple Watch"
  s.homepage         = "https://github.com/maxkonovalov/MKRingProgressView"
  s.license          = 'MIT'
  s.author           = "Max Konovalov"
  s.source           = { :git => "https://github.com/maxkonovalov/MKRingProgressView.git", :tag => s.version.to_s }
  s.source_files = "MKRingProgressView/**/*.swift"

  s.ios.deployment_target 		= "8.2"
  s.tvos.deployment_target 		= "9.0"

  s.frameworks = "UIKit"
  s.swift_version = '4.2'
end

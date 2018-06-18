Pod::Spec.new do |s|
  s.name             = "MKRingProgressView"
  s.version          = "2.0.1"
  s.summary          = "Ring progress view similar to Activity app on Apple Watch"
  s.homepage         = "https://github.com/maxkonovalov/MKRingProgressView"
  s.license          = 'MIT'
  s.author           = "Max Konovalov"
  s.source           = { :git => "https://github.com/maxkonovalov/MKRingProgressView.git", :tag => s.version.to_s }

  s.platform     = :ios, "8.0"
  s.requires_arc = true

  s.source_files = "MKRingProgressView/**/*.swift"

  s.frameworks = "UIKit"
end

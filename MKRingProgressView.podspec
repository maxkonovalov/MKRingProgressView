Pod::Spec.new do |s|
  s.name             = "MKRingProgressView"
  s.version          = "1.0.0"
  s.summary          = "Ring progress view similar to Activity app on Apple Watch"
  s.homepage         = "https://github.com/maxkonovalov/MKRingProgressView"
  s.license          = 'Code is MIT, then custom font licenses.'
  s.author           = { "Max" => "" }
  s.source           = { :git => "https://github.com/maxkonovalov/MKRingProgressView.git", :tag => s.version }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'MKRingProgressView/'
  s.resources = 'MKRingProgressView/*'

  s.frameworks = 'UIKit', 'CoreText'
end

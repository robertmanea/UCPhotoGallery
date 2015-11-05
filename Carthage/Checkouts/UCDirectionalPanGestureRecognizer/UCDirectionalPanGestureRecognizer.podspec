Pod::Spec.new do |s|
  s.name             = "UCDirectionalPanGestureRecognizer"
  s.version          = "0.1"
  s.summary          = "A gesture recognizer that only recognizes horizontal or vertical movement"
  s.homepage         = "https://github.com/bryanoltman/UCDirectionalPanGestureRecognizer"
  s.license          = 'MIT'
  s.authors          = { "Bryan Oltman" => "bryan@compass.com" }
  s.source           = { :git => "https://github.com/bryanoltman/UCDirectionalPanGestureRecognizer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/moltman'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'UCDirectionalPanGestureRecognizer.*'
  s.public_header_files = 'UCDirectionalPanGestureRecognizer.h'

  s.frameworks = 'UIKit'

end

Pod::Spec.new do |s|
  s.name             = "UCDirectionalPanGestureRecognizer"
  s.version          = "1.0"
  s.summary          = "A pan gesture recognizer that only recognizes panning on one axis"
  s.description      = <<-DESC
                        A subclass of UIPanGestureRecognizer than can be configured to only recognize vertical or horizontal panning
                       DESC
  s.homepage         = "https://github.com/UrbanCompass/UCDirectionalPanGestureRecognizer"
  s.license          = 'MIT'
  s.authors          = { "Bryan Oltman" => "bryan@compass.com" }
  s.source           = { :git => "https://github.com/UrbanCompass/UCDirectionalPanGestureRecognizer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/moltman'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'UCDirectionalPanGestureRecognizer'
  s.public_header_files = 'UCDirectionalPanGestureRecognizer/*.h'

  s.frameworks = 'UIKit'

end

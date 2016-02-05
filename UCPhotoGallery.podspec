Pod::Spec.new do |s|
  s.name             = "UCPhotoGallery"
  s.version          = "0.2.6"
  s.summary          = "A drop-in image gallery UI component"
  s.description      = <<-DESC
                       UCPhotoGallery provides two view controllers that both turn a collection of URLs into a photo gallery
                       DESC
  s.homepage         = "https://github.com/UrbanCompass/UCPhotoGallery"
  s.license          = 'MIT'
  s.authors          = { "Bryan Oltman" => "bryan@compass.com" }
  s.source           = { :git => "https://github.com/UrbanCompass/UCPhotoGallery.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/moltman'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'UCPhotoGallery'
  s.public_header_files = 'UCPhotoGallery/*.h'
  s.frameworks = 'UIKit'
  s.preserve_paths = 'Frameworks/*.framework'
  s.vendored_frameworks = 'Frameworks/WebImage.framework', 'Frameworks/UCDirectionalPanGestureRecognizer.framework'
end

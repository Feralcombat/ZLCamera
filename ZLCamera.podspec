

Pod::Spec.new do |s|

  s.name         = "ZLCamera"
  s.version      = '1.2.2'
  s.summary      = "A camera like WeChat"

  s.homepage     = "https://github.com/Feralcombat/ZLCamera"

  s.license      = { :type => "MIT" }

  s.author             = { "周麟" => "110795300@qq.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/Feralcombat/ZLCamera.git", :tag => s.version.to_s }

  s.source_files  = "ZLCamera/ZLCameraViewController/*.{h,m}"
  s.resources = "ZLCamera/ZLCameraViewController/*.{bundle}"

  s.frameworks = "UIKit", "Foundation", "AVFoundation"

  s.requires_arc = true

  s.dependency "Masonry"
  s.dependency "TOCropViewController"
end

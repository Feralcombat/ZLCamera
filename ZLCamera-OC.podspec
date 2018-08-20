

Pod::Spec.new do |s|

  s.name         = "ZLCamera-OC"
  s.version      = "1.0.0"
  s.summary      = "A camera like WeChat"

  s.homepage     = "https://github.com/Feralcombat/ZLCamera-OC"

  s.license      = { :type => "MIT" }

  s.author             = { "周麟" => "110795300@qq.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/Feralcombat/ZLCamera-OC.git", :tag => "#{s.version}" }

  s.source_files  = "ZLCameraViewController/**/*.{h,m,bundle}"

  s.framework  = "SomeFramework"
  s.frameworks = "UIKit", "Foundation", "AVFoundation"

  s.requires_arc = true

  s.dependency "Masnory"

end

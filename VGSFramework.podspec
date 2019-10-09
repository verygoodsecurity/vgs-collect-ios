Pod::Spec.new do |spec|
  spec.name         = "VGS_Collect_ios_SDK"
  spec.version      = "0.0.1"
  spec.swift_version = '4.2'
  spec.description  = <<-DESC
  VGS Collect - is a product suite that allows customers to collect information securely without possession of it. VGS Collect mobile SDKs - are native mobile forms modules that allow customers to collect information securely on mobile devices with iOS
                   DESC
  spec.homepage     = "https://www.verygoodsecurity.com"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  spec.license      = "MIT"
  spec.license      = { type: 'MIT', file: 'LICENSE' }
  spec.author       = { "Vitalii Obertynskyi" => "vitaliy.obertinskiy@icloud.com" }
  spec.social_media_url   = "https://twitter.com/miraving"
  spec.platform     = :ios, "12.0"
  spec.ios.deployment_target = "12.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"
  spec.source       = { 
    :git => "https://github.com/verygoodsecurity/vgs-collect-ios.git", 
    :tag => "#{spec.version}" 
  }
  spec.source_files  = "framework/Sources/VGSFramework", "framework/Sources/VGSFramework/**/*.{swift}"
  spec.frameworks = "Alamofire"
  spec.requires_arc = true
  spec.dependency "Alamofire"
end

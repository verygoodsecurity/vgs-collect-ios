Pod::Spec.new do |spec|
  spec.name = 'VGSCollectSDK'
  spec.version = '1.6.3'
  spec.summary = 'VGS Collect - is a product suite that allows customers to collect information securely without possession of it.'
  spec.swift_version = '5.0'
  spec.description  = <<-DESC
  VGS Collect iOS SDK allows you to securely collect data from your users without having to have that data pass through your systems. It provides customizable UI elements for collecting users’ sensitive data securely on mobile devices with iOS.
                   DESC
  spec.homepage     = "https://github.com/verygoodsecurity/vgs-collect-ios"
  spec.documentation_url    = "https://www.verygoodsecurity.com/docs/vgs-collect/ios-sdk/index"
  spec.license      = { type: 'MIT', file: 'LICENSE' }
  spec.author       = { 
    "Very Good Security" => "support@verygoodsecurity.com"
  }
  spec.social_media_url   = "https://twitter.com/getvgs"
  spec.platform     = :ios, "10.0"
  spec.ios.deployment_target = "10.0"
  spec.source = { :git => "https://github.com/verygoodsecurity/vgs-collect-ios.git", :tag => "#{spec.version}" }
  spec.requires_arc = true
  
  spec.default_subspec = 'Core'
  
  spec.subspec 'Core' do |core|
  #set as default podspec to prevent from downloading additional modules
    core.source_files = "Sources/VGSCollectSDK", "Sources/VGSCollectSDK/**/*.{swift}"
    core.resource_bundles = {
      'CardIcon' => ['Resources/*']
    }
  end
  
  spec.subspec 'CardIO' do |cardio|
    cardio.source_files  = "Sources/VGSCollectSDK", "Sources/VGSCollectSDK/**/*.{h, m}"
    cardio.dependency "CardIOSDK", "5.5.3"
  end
end

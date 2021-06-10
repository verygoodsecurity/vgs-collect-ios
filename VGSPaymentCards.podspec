Pod::Spec.new do |spec|
  spec.name = 'VGSPaymentCards'
  spec.version = '1.0.0'
  spec.summary = 'VGSPaymentCards is a set of models and resources to build payment flow with VGS.'
  spec.swift_version = '5.0'
  spec.description  = <<-DESC
    VGSPaymentCards contains models and resources to build payment flow with VGS.
                   DESC
  spec.homepage     = "https://github.com/verygoodsecurity/vgs-collect-ios"
  # spec.documentation_url    = "https://www.verygoodsecurity.com/docs/vgs-collect/ios-sdk/index"
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
    core.source_files = "Sources/VGSPaymentCards", "Sources/VGSPaymentCards/**/*.{swift}", "Sources/VGSPaymentCards/**/*.{h, m}"
    core.resource_bundles = {
      'CardIcon' => ['Sources/VGSPaymentCards/Resources/*']
    }
  end
end

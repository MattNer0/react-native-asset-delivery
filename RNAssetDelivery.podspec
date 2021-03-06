
Pod::Spec.new do |s|
  s.name         = "RNAssetDelivery"
  s.version      = "1.0.0"
  s.summary      = "RNAssetDelivery"
  s.description  = <<-DESC
                  React Native module to manage on-demand assets
                   DESC
  s.homepage     = "https://github.com/MattNer0/react-native-asset-delivery"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/MattNer0/react-native-asset-delivery.git", :tag => "master" }
  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
  #s.dependency "others"

end

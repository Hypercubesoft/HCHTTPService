Pod::Spec.new do |s|

s.platform = :ios
s.name             = "HCHTTPService"
s.version          = "1.1.1"
s.swift_versions = ['5.0']
s.summary          = "These are internal files we use in our company."

s.description      = <<-DESC
These are internal files we use in our company. We will not add new functions on request.
DESC

s.homepage         = "https://github.com/Hypercubesoft/HCHTTPService"
s.license          = { :type => "MIT", :file => "LICENSE" }
s.author           = { "Hypercubesoft" => "office@hypercubesoft.com" }
s.source           = { :git => "https://github.com/Hypercubesoft/HCHTTPService.git", :tag => "#{s.version}"}

s.ios.deployment_target = "10.0"
s.source_files = "HCHTTPService", "HCHTTPService/*", "HCHTTPService/**/*"

s.dependency 'Alamofire'
s.dependency 'AlamofireNetworkActivityIndicator'
s.dependency 'ReachabilitySwift'
s.dependency 'HCFramework'
s.dependency 'SDWebImage'
s.dependency 'SwiftyJSON'
s.dependency 'PKHUD'

end
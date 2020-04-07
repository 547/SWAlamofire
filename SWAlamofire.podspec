Pod::Spec.new do |spec|

  spec.name         = "SWAlamofire"
  spec.version      = "0.0.7"
  spec.summary      = "根据."

  spec.description  = <<-DESC
	根据公司项目实际情况封装的
                   DESC

  spec.homepage     = "https://github.com/547/SWAlamofire"



  spec.license      = { :type => "MIT", :file => "LICENSE" }


  spec.author    = "Seven Wang"
  
  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "https://github.com/547/SWAlamofire.git", :tag => "#{spec.version}" }


  spec.source_files  = "Sources", "Sources/**/*.{h,m,swift}"
  
  spec.framework  = "Foundation"
  
  spec.dependency "Alamofire", '~> 4.8.2'

  spec.swift_versions = "5.0"
end

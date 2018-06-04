Pod::Spec.new do |s|
  s.name         = "ServiceLocatorSwift"
  s.version      = "1.0.0"
  s.summary      = "ServiceLocator for Swift"
  s.description  = <<-DESC
			Written in Swift.
			ServiceLocator used ServiceProvider.
                   DESC
 
  s.homepage     = "https://github.com/ProVir/ServiceProvider"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "ViR (Vitaliy Korotkiy)" => "admin@provir.ru" }
  s.source       = { :git => "https://github.com/ProVir/ServiceProvider.git", :tag => "#{s.version}" }

  s.swift_version = '4'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = ['ServiceLocator/*.{h,swift}', 'ServiceProvider/*.swift']
  s.public_header_files = 'ServiceLocator/*.h'
  
end

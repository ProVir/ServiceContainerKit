Pod::Spec.new do |s|
  version = '3.0.0'
    
  s.name         = "ServiceInjects"
  s.version      = version
  s.summary      = "Simple injects for services and entities"
  s.description  = <<-DESC
			Written in Swift.
            ServiceInject used for injects services in presentation layer.
            EntityInject used for injects temporary entities in presentation layer.
                   DESC

  s.homepage     = "https://github.com/ProVir/ServiceContainerKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "ViR (Vitaliy Korotkiy)" => "admin@provir.ru" }
  s.source       = { :git => "https://github.com/ProVir/ServiceContainerKit.git", :tag => "#{s.version}" }

  s.swift_versions = ['5.2', '5.3']

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'
  
  s.dependency 'ServiceContainerKit', version
  s.source_files = ['ServiceInjects/Sources/*.swift', 'ServiceInjects/Sources/*.h']
  s.public_header_files = 'ServiceInjects/Sources/*.h'
  
end

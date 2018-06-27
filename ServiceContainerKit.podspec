Pod::Spec.new do |s|
  s.name         = "ServiceContainerKit"
  s.version      = "1.0.0"
  s.summary      = "Types for help create self DI Container. Use ServiceProvider as core, ServiceLocator as ready DI Container"
  s.description  = <<-DESC
			Written in Swift.
            Types for help create self DI Container.
            ServiceProvider: Wrapper for the service to hide the details of its creation.
            Allows you to create your custom IoC Container or ServiceLocator.
                   DESC

  s.homepage     = "https://github.com/ProVir/ServiceContainerKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "ViR (Vitaliy Korotkiy)" => "admin@provir.ru" }
  s.source       = { :git => "https://github.com/ProVir/ServiceContainerKit.git", :tag => "#{s.version}" }

  s.swift_version = '4'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  
  s.default_subspec = 'Provider'
  
  s.subspec 'Provider' do |ss|
    ss.source_files = 'Source/*.{h,swift}'
    ss.public_header_files = 'Source/*.h'
  end

  s.subspec 'ServiceLocator' do |ss|
    ss.source_files = 'Source/ServiceLocator/*.swift'
    
    ss.dependency 'ServiceContainerKit/Provider'
  end

end

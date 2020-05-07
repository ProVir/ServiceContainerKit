Pod::Spec.new do |s|
  s.name         = "ServiceContainerKit"
  s.version      = "3.0.0-beta1"
  s.summary      = "Kit to create your own IoC Container or ServiceLocator. Use ServiceProvider as core, ServiceLocator as ready IoC Container"
  s.description  = <<-DESC
			Written in Swift.
            Kit to create your own IoC Container or ServiceLocator for help implementation Dependency Injection (DI).
            ServiceProvider: wrapper for the service to hide the details of its creation.
            Allows you to create your custom IoC Container or ServiceLocator.
            Also includes a dynamic ServiceLocator as an option. Require Swift 5.1 and above, support Objective-C in readOnly regime.
                   DESC

  s.homepage     = "https://github.com/ProVir/ServiceContainerKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "ViR (Vitaliy Korotkiy)" => "admin@provir.ru" }
  s.source       = { :git => "https://github.com/ProVir/ServiceContainerKit.git", :tag => "#{s.version}" }

  s.swift_version = '5.2'

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
  
  s.subspec 'ServiceSimpleLocator' do |ss|
    ss.source_files = 'Source/ServiceSimpleLocator/*.swift'
    ss.dependency 'ServiceContainerKit/ServiceLocator'
  end
  
  s.subspec 'SLInject' do |ss|
    ss.source_files = 'Source/Injects/SLInject.swift'
    ss.dependency 'ServiceContainerKit/ServiceLocator'
  end
  
  s.subspec 'SLSimpleInject' do |ss|
    ss.source_files = 'Source/Injects/SLSimpleInject.swift'
    ss.dependency 'ServiceContainerKit/ServiceSimpleLocator'
  end

end

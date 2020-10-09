Pod::Spec.new do |s|
  s.name         = "ServiceContainerKit"
  s.version      = "3.0.0-beta3"
  s.summary      = "Kit to create your own IoC Container or ServiceLocator."
  s.description  = <<-DESC
			Written in Swift.
            Kit to create your own IoC Container or ServiceLocator for help implementation Dependency Injection (DI).
            ServiceProvider: wrapper for the service to hide the details of its creation.
            Allows you to create your custom IoC Container or ServiceLocator.
            Require Swift 5.1 and above, support Objective-C in readOnly regime.
                   DESC

  s.homepage     = "https://github.com/ProVir/ServiceContainerKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "ViR (Vitaliy Korotkiy)" => "admin@provir.ru" }
  s.source       = { :git => "https://github.com/ProVir/ServiceContainerKit.git", :tag => "#{s.version}" }

  s.swift_versions = ['5.1', '5.2', '5.3']

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'
  
  s.default_subspec = 'Injects'
  
  s.subspec 'Core' do |ss|
    ss.source_files = ['Sources/Core/*.swift', 'Sources/*.h']
    ss.public_header_files = 'Sources/*.h'
  end
  
  s.subspec 'Injects' do |ss|
    ss.source_files = 'Sources/Injects/*.swift'
    ss.dependency 'ServiceContainerKit/Core'
  end
  
end

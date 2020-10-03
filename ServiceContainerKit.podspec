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
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '2.0'
  
  s.default_subspec = 'Common'
  
  s.subspec 'Core' do |ss|
    ss.source_files = ['Source/Core/*.swift', 'Source/*.h']
    ss.public_header_files = 'Source/*.h'
  end
  
  s.subspec 'Common' do |ss|
    ss.dependency 'ServiceContainerKit/ServiceInject'
    ss.dependency 'ServiceContainerKit/EntityInject'
  end
  
  s.subspec 'CoreInject' do |ss|
    ss.source_files = 'Source/CoreInject/*.swift'
    ss.public_header_files = 'Source/*.h'
  end
  
  s.subspec 'ServiceInject' do |ss|
    ss.source_files = 'Source/ServiceInject/*.swift'
    ss.dependency 'ServiceContainerKit/Core'
    ss.dependency 'ServiceContainerKit/CoreInject'
  end
  
  s.subspec 'EntityInject' do |ss|
    ss.source_files = 'Source/EntityInject/*.swift'
    ss.dependency 'ServiceContainerKit/CoreInject'
  end

end

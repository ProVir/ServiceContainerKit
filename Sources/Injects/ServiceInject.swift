//
//  ServiceInject.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 08.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

@propertyWrapper
public final class ServiceInject<Container, Service> {
    private var lazyInit: ((Container?) -> Void)?
    private var lazyInitToken: ServiceInjectToken?
    private var factory: (() -> Service)?
    private var state = InjectState<Service>()
    
    public init(_ keyPath: KeyPath<Container, ServiceProvider<Service>>, lazyInject: Bool = false, file: StaticString = #file, line: UInt = #line) {
        setup { [unowned self] container in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            
            if lazyInject {
                self.factory = { container[keyPath: keyPath].getServiceOrFatal(file: file, line: line) }
            } else {
                let service = container[keyPath: keyPath].getServiceOrFatal(file: file, line: line)
                self.state.storage.setEntity(service)
            }
        }
    }
    
    public init<T>(_ keyPath: KeyPath<Container, ServiceProvider<T>?>, lazyInject: Bool = false, file: StaticString = #file, line: UInt = #line) where Service == T? {
        setup { [unowned self] container in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            
            if lazyInject {
                self.factory = { container[keyPath: keyPath]?.getServiceOrFatal(file: file, line: line) }
            } else {
                let service = container[keyPath: keyPath]?.getServiceOrFatal(file: file, line: line)
                self.state.storage.setEntity(service)
            }
        }
    }
    
    public var wrappedValue: Service {
        lazyInit?(nil)
        
        if let service = self.state.storage.entity {
            return service
        } else if let service = factory?() {
            self.factory = nil
            self.state.storage.setEntity(service)
            return service
        } else {
            fatalError("Unknown error in Inject")
        }
    }
    
    public var projectedValue: InjectState<Service> { return state }
    
    private func setup(_ configurator: @escaping (Container?) -> Void) {
        if let container = ServiceInjectResolver.resolve(Container.self) {
            configurator(container)
        } else {
            self.lazyInit = configurator
            self.lazyInitToken = ServiceInjectResolver.observeOnce(Container.self) { [weak self] in
                self?.resolved($0)
            }
        }
    }
    
    private func resolved(_ container: Container) {
        lazyInitToken = nil
        lazyInit?(container)
        lazyInit = nil
    }
}

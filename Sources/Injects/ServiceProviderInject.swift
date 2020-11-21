//
//  ServiceProviderInject.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 30.09.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

/// Injects ServiceProviders from shared containers (registered in `ServiceInjectResolver`).
@propertyWrapper
public final class ServiceProviderInject<Container, Provider> {
    private var lazyInit: ((Container?) -> Void)?
    private var lazyInitToken: ServiceInjectReadyToken?
    private var state = InjectState<Provider>()
    
    /// `keyPath` - key in container with value type `ServiceProvider`.
    public convenience init<Service>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceProvider<Service> {
        self.init(baseInitFor: keyPath, file: file, line: line)
    }
    
    /// `keyPath` - key in container with optional value type `ServiceProvider?`.
    public convenience init<Service>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceProvider<Service>? {
        self.init(baseInitFor: keyPath, file: file, line: line)
    }
    
    /// `keyPath` - key in container with value type `ServiceParamsProvider`.
    public convenience init<Service, Params>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceParamsProvider<Service, Params> {
        self.init(baseInitFor: keyPath, file: file, line: line)
    }
    
    /// `keyPath` - key in container with optional value type `ServiceParamsProvider?`.
    public convenience init<Service, Params>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceParamsProvider<Service, Params>? {
        self.init(baseInitFor: keyPath, file: file, line: line)
    }
    
    private init(baseInitFor keyPath: KeyPath<Container, Provider>, file: StaticString, line: UInt) {
        setup { [unowned self] container in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            
            let provider = container[keyPath: keyPath]
            self.state.storage.setEntity(provider)
        }
    }
    
    public var wrappedValue: Provider {
        lazyInit?(nil)
        
        if let provider = self.state.storage.entity {
            return provider
        } else {
            fatalError("Unknown error in Inject")
        }
    }
    
    public var projectedValue: InjectState<Provider> { return state }
    
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

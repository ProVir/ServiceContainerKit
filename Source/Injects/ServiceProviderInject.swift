//
//  ServiceProviderInject.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 30.09.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

@propertyWrapper
public final class ServiceProviderInject<Container, Provider> {
    private var factory: (Container?) -> Provider
    private var state = InjectState<Provider>()
    
    public convenience init<Service>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceProvider<Service> {
        self.init(baseInitFor: keyPath, file: file, line: line)
    }
    
    public convenience init<Service>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceProvider<Service>? {
        self.init(baseInitFor: keyPath, file: file, line: line)
    }
    
    public convenience init<Service, Params>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceParamsProvider<Service, Params> {
        self.init(baseInitFor: keyPath, file: file, line: line)
    }
    
    public convenience init<Service, Params>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceParamsProvider<Service, Params>? {
        self.init(baseInitFor: keyPath, file: file, line: line)
    }
    
    private init(baseInitFor keyPath: KeyPath<Container, Provider>, file: StaticString, line: UInt) {
        self.factory = { container in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            
            return container[keyPath: keyPath]
        }
    }
    
    public var wrappedValue: Provider {
        if let provider = self.state.storage.entity {
            return provider
        } else {
            let container = ServiceInjectResolver.resolve(Container.self)
            let provider = factory(container)
            self.state.storage.setEntity(provider)
            return provider
        }
    }
    
    public var projectedValue: InjectState<Provider> { return state }
}

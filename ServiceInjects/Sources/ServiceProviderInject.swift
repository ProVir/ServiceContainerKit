//
//  ServiceProviderInject.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 30.09.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

/// Injects ServiceProviders from shared containers (registered in `ServiceInjectResolver`).
@propertyWrapper
public final class ServiceProviderInject<Container, Provider> {
    private var lazyInit: ((Container?) -> Void)?
    private var lazyInitToken: ServiceInjectReadyToken?
    private var state = InjectState<Provider>()
    
    // MARK: Common constructors
    
    /// `keyPath` - key in container with value type `ServiceProvider`.
    public convenience init<Service>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceProvider<Service> {
        self.init(baseInitFor: keyPath, map: { $0 }, file: file, line: line)
    }
    
    /// `keyPath` - key in container with optional value type `ServiceProvider?`.
    public convenience init<Service>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceProvider<Service>? {
        self.init(baseInitFor: keyPath, map: { $0 }, file: file, line: line)
    }
    
    /// `keyPath` - key in container with value type `ServiceParamsProvider`.
    public convenience init<Service, Params>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceParamsProvider<Service, Params> {
        self.init(baseInitFor: keyPath, map: { $0 }, file: file, line: line)
    }
    
    /// `keyPath` - key in container with optional value type `ServiceParamsProvider?`.
    public convenience init<Service, Params>(_ keyPath: KeyPath<Container, Provider>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceParamsProvider<Service, Params>? {
        self.init(baseInitFor: keyPath, map: { $0 }, file: file, line: line)
    }
    
    // MARK: ObjC constructors
    
    /// `keyPath` - key in container with value type `ServiceProvider`, injected value type is `ServiceProviderObjC`.
    public convenience init<Service>(objc keyPath: KeyPath<Container, ServiceProvider<Service>>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceProviderObjC {
        self.init(baseInitFor: keyPath, map: { ServiceProviderObjC($0) }, file: file, line: line)
    }
    
    /// `keyPath` - key in container with optional value type `ServiceProvider?`, injected value type is `ServiceProviderObjC?`.
    public convenience init<Service>(objc keyPath: KeyPath<Container, ServiceProvider<Service>?>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceProviderObjC? {
        self.init(baseInitFor: keyPath, map: { $0.map { ServiceProviderObjC($0) } }, file: file, line: line)
    }
    
    /// `keyPath` - key in container with value type `ServiceParamsProvider`, injected value type is `ServiceParamsProviderObjC`.
    public convenience init<Service, Params>(objc keyPath: KeyPath<Container, ServiceParamsProvider<Service, Params>>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceParamsProviderObjC {
        self.init(baseInitFor: keyPath, map: { ServiceParamsProviderObjC($0) }, file: file, line: line)
    }
    
    /// `keyPath` - key in container with optional value type `ServiceParamsProvider?`, injected value type is `ServiceParamsProviderObjC?`.
    public convenience init<Service, Params>(objc keyPath: KeyPath<Container, ServiceParamsProvider<Service, Params>?>, file: StaticString = #file, line: UInt = #line)
        where Provider == ServiceParamsProviderObjC? {
        self.init(baseInitFor: keyPath, map: { $0.map { ServiceParamsProviderObjC($0) } }, file: file, line: line)
    }
    
    
    // MARK: General
    
    private init<SrcProvider>(baseInitFor keyPath: KeyPath<Container, SrcProvider>, map: @escaping (SrcProvider) -> Provider, file: StaticString, line: UInt) {
        setup { [unowned self] container in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            
            let provider = container[keyPath: keyPath]
            self.state.storage.setEntity(map(provider))
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

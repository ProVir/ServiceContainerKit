//
//  ServiceParamsInject.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 30.09.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

@propertyWrapper
public final class ServiceParamsInject<Container, Service, Params> {
    private var lazyInit: ((Container?) -> Void)?
    private var lazyInitToken: ServiceInjectToken?
    private var factory: ((Params?) -> Service)?
    private var state = InjectParamsState<Service, Params>()
    
    public convenience init(_ keyPath: KeyPath<Container, ServiceParamsProvider<Service, Params>>, params: Params, lazyInject: Bool = false, file: StaticString = #file, line: UInt = #line) {
        self.init(keyPath, file: file, line: line)
        self.state.params.setValue(params, lazyInject: lazyInject)
    }
    
    public init(_ keyPath: KeyPath<Container, ServiceParamsProvider<Service, Params>>, file: StaticString = #file, line: UInt = #line) {
        setup { [unowned self] container in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            
            if let params = self.state.params.value, self.state.params.lazyInject == false {
                let service = container[keyPath: keyPath].getServiceOrFatal(params: params, file: file, line: line)
                self.inject(service: service)
                
            } else {
                self.factory = { params in
                    guard let params = params else {
                        fatalError("Not found Parameters for Inject. Use $property.setParameters()", file: file, line: line)
                    }
                    
                    return container[keyPath: keyPath].getServiceOrFatal(params: params, file: file, line: line)
                }
            }
        }
        setupReadyParams()
    }
    
    public convenience init<T>(_ keyPath: KeyPath<Container, ServiceParamsProvider<T, Params>?>, params: Params, lazyInject: Bool = false, file: StaticString = #file, line: UInt = #line) where Service == T? {
        self.init(keyPath, file: file, line: line)
        self.state.params.setValue(params, lazyInject: lazyInject)
    }
    
    public init<T>(_ keyPath: KeyPath<Container, ServiceParamsProvider<T, Params>?>, file: StaticString = #file, line: UInt = #line) where Service == T? {
        setup { [unowned self] container in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            
            if let params = self.state.params.value, self.state.params.lazyInject == false {
                let service = container[keyPath: keyPath]?.getServiceOrFatal(params: params, file: file, line: line)
                self.inject(service: service)
                
            } else {
                self.factory = { params in
                    guard let params = params else {
                        fatalError("Not found Parameters for Inject. Use $property.setParameters()", file: file, line: line)
                    }
                    
                    return container[keyPath: keyPath]?.getServiceOrFatal(params: params, file: file, line: line)
                }
            }
        }
        setupReadyParams()
    }
    
    public var wrappedValue: Service {
        lazyInit?(nil)
        
        if let service = state.storage.entity {
            return service
        } else if let service = factory?(state.params.value) {
            inject(service: service)
            return service
        } else {
            fatalError("Unknown error in Inject")
        }
    }
    
    public var projectedValue: InjectParamsState<Service, Params> { return state }
    
    private func setup(_ configurator: @escaping (Container?) -> Void) {
        if let container = ServiceInjectResolver.resolve(Container.self) {
            configurator(container)
        } else {
            self.lazyInit = configurator
            self.lazyInitToken = ServiceInjectResolver.observeOnce(Container.self) { [weak self] in
                self?.resolved(container: $0)
            }
        }
    }
    
    private func resolved(container: Container) {
        lazyInitToken = nil
        lazyInit?(container)
        lazyInit = nil
    }
    
    private func setupReadyParams() {
        state.params.setReadyToInjectHandler { [weak self] params in
            guard let self = self, let factory = self.factory else { return }
            self.inject(service: factory(params))
        }
    }
    
    private func inject(service: Service) {
        self.factory = nil
        self.state.params.clear()
        self.state.storage.setEntity(service)
    }
}

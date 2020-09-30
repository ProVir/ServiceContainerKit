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
    private var factory: (Container?, Params?) -> Service
    private var state = InjectParamsState<Service, Params>()
    
    public convenience init(_ keyPath: KeyPath<Container, ServiceParamsProvider<Service, Params>>, params: Params, file: StaticString = #file, line: UInt = #line) {
        self.init(keyPath, file: file, line: line)
        self.state.params.setValue(params)
    }
    
    public init(_ keyPath: KeyPath<Container, ServiceParamsProvider<Service, Params>>, file: StaticString = #file, line: UInt = #line) {
        self.factory = { container, params in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            guard let params = params else {
                fatalError("Not found Parameters for Inject. Use $property.setParameters()", file: file, line: line)
            }
            
            return container[keyPath: keyPath].getServiceOrFatal(params: params, file: file, line: line)
        }
    }
    
    public convenience init<T>(_ keyPath: KeyPath<Container, ServiceParamsProvider<T, Params>?>, params: Params, file: StaticString = #file, line: UInt = #line) where Service == T? {
        self.init(keyPath, file: file, line: line)
        self.state.params.setValue(params)
    }
    
    public init<T>(_ keyPath: KeyPath<Container, ServiceParamsProvider<T, Params>?>, file: StaticString = #file, line: UInt = #line) where Service == T? {
        self.factory = { container, params in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            guard let params = params else {
                fatalError("Not found Parameters for Inject. Use $property.setParameters()", file: file, line: line)
            }
            
            return container[keyPath: keyPath]?.getServiceOrFatal(params: params, file: file, line: line)
        }
    }
    
    public var wrappedValue: Service {
        if let service = self.state.storage.entity {
            return service
        } else {
            let container = ServiceInjectResolver.resolve(Container.self)
            let service = factory(container, state.params.value)
            self.state.params.clear()
            self.state.storage.setEntity(service)
            return service
        }
    }
    
    public var projectedValue: InjectParamsState<Service, Params> { return state }
}

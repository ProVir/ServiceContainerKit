//
//  SLSimpleInject.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 06.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

private var serviceLocatorShared: ServiceSimpleLocator?

public extension ServiceSimpleLocator {
    func setupForInject() {
        serviceLocatorShared = self
    }
}

@propertyWrapper
public final class SLSimpleInject<ServiceType> {
    private var factory: (() -> ServiceType)?
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
        }
        
        if lazy {
            self.factory = { locator.getServiceOrFatal(ServiceType.self, file: file, line: line) }
        } else {
            self.service = locator.getServiceOrFatal(ServiceType.self, file: file, line: line)
        }
    }
    
    public init<ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
        }
        
        if lazy {
            self.factory = { locator.getServiceOrFatal(ServiceType.self, params: params, file: file, line: line) }
        } else {
            self.service = locator.getServiceOrFatal(ServiceType.self, params: params, file: file, line: line)
        }
    }
    
    public var wrappedValue: ServiceType {
        if let service = self.service {
            return service
        } else if let service = factory?() {
            self.service = service
            self.factory = nil
            return service
        } else {
            fatalError("Unknown error in Inject")
        }
    }
}

@propertyWrapper
public final class SLSimpleOptionalInject<ServiceType> {
    private var factory: (() -> ServiceType?)?
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
        }
        
        if lazy {
            self.factory = { locator.getServiceAsOptional(ServiceType.self) }
        } else {
            self.service = locator.getServiceAsOptional(ServiceType.self)
        }
    }
    
    public init<ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
        }
        
        if lazy {
            self.factory = { locator.getServiceAsOptional(ServiceType.self, params: params) }
        } else {
            self.service = locator.getServiceAsOptional(ServiceType.self, params: params)
        }
    }
    
    public var wrappedValue: ServiceType? {
        if let service = self.service {
            return service
        } else if let service = factory?() {
            self.service = service
            self.factory = nil
            return service
        } else {
            return nil
        }
    }
}

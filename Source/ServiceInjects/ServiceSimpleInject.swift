//
//  ServiceSimpleInject.swift
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
public final class ServiceSimpleInject<ServiceType> {
    public let lazy: Bool
    private var locator: ServiceSimpleLocator?
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
        }
        
        self.lazy = lazy
        
        if lazy {
            self.locator = locator
        } else {
            self.service = locator.getServiceOrFatal(ServiceType.self, file: file, line: line)
        }
    }
    
    public var wrappedValue: ServiceType {
        if let service = self.service {
            return service
        } else if self.lazy, let locator = locator {
            let service = locator.getServiceOrFatal(ServiceType.self)
            self.service = service
            self.locator = nil
            return service
        } else {
            fatalError("Unknown error in Inject")
        }
    }
}

@propertyWrapper
public final class ServiceOptionalSimpleInject<ServiceType> {
    public let lazy: Bool
    private var locator: ServiceSimpleLocator?
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
        }
        
        self.lazy = lazy
        
        if lazy {
            self.locator = locator
        } else {
            self.service = locator.getServiceAsOptional(ServiceType.self)
        }
    }
    
    public var wrappedValue: ServiceType? {
        if let service = self.service {
            return service
        } else if self.lazy, let service = locator?.getServiceAsOptional(ServiceType.self) {
            self.service = service
            self.locator = nil
            return service
        } else {
            return nil
        }
    }
}

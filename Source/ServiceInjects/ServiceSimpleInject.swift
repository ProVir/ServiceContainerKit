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
    private let locator: ServiceSimpleLocator
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
        }
        
        self.locator = locator
        
        if lazy == false {
            self.service = locator.getServiceOrFatal(ServiceType.self, file: file, line: line)
        }
    }
    
    public var wrappedValue: ServiceType {
        if let service = self.service {
            return service
        } else {
            let service = locator.getServiceOrFatal(ServiceType.self)
            self.service = service
            return service
        }
    }
}

@propertyWrapper
public final class ServiceOptionalSimpleInject<ServiceType> {
    private let lazy: Bool
    private let locator: ServiceSimpleLocator
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
        }
        
        self.locator = locator
        self.lazy = lazy
        
        if lazy == false {
            self.service = locator.getServiceAsOptional(ServiceType.self)
        }
    }
    
    public var wrappedValue: ServiceType? {
        if let service = self.service {
            return service
        } else if self.lazy, let service = locator.getServiceAsOptional(ServiceType.self) {
            self.service = service
            return service
        } else {
            return nil
        }
    }
}

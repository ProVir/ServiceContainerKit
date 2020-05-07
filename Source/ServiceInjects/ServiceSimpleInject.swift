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
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false) {
        if lazy == false {
            self.service = getService(ServiceType.self)
        }
    }
    
    public var wrappedValue: ServiceType {
        if let service = self.service {
            return service
        } else {
            let service = getService(ServiceType.self)
            self.service = service
            return service
        }
    }
}

@propertyWrapper
public final class ServiceOptionalSimpleInject<ServiceType> {
    private let lazy: Bool
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false) {
        self.lazy = lazy
        
        if lazy == false {
            self.service = getServiceAsOptional(ServiceType.self)
        }
    }
    
    public var wrappedValue: ServiceType? {
        if let service = self.service {
            return service
        } else if self.lazy, let service = getServiceAsOptional(ServiceType.self) {
            self.service = service
            return service
        } else {
            return nil
        }
    }
}

private func getService<ServiceType>(_ type: ServiceType.Type, file: StaticString = #file, line: UInt = #line) -> ServiceType {
    guard let locator = serviceLocatorShared else {
        fatalError("Not found ServiceLocator for Inject", file: file, line: line)
    }
    
    return locator.getServiceOrFatal(type)
}

private func getServiceAsOptional<ServiceType>(_ type: ServiceType.Type, file: StaticString = #file, line: UInt = #line) -> ServiceType? {
    guard let locator = serviceLocatorShared else {
        fatalError("Not found ServiceLocator for Inject", file: file, line: line)
    }
    
    return locator.getServiceAsOptional(type)
}

//
//  ServiceInject.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 06.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

private var serviceLocatorShared: ServiceLocator?

public extension ServiceLocator {
    func setupForInject() {
        serviceLocatorShared = self
    }
}

@propertyWrapper
public final class ServiceInject<Key: ServiceLocatorKey> {
    public let key: Key
    private var service: Key.ServiceType?
    
    public init(_ key: Key, lazy: Bool = false) {
        self.key = key
        
        if lazy == false {
            self.service = getService(key)
        }
    }
    
    public var wrappedValue: Key.ServiceType {
        if let service = self.service {
            return service
        } else {
            let service = getService(key)
            self.service = service
            return service
        }
    }
}

@propertyWrapper
public final class ServiceOptionalInject<Key: ServiceLocatorKey> {
    public let key: Key
    private let lazy: Bool
    private var service: Key.ServiceType?
    
    public init(_ key: Key, lazy: Bool = false) {
        self.key = key
        self.lazy = lazy
        
        if lazy == false {
            self.service = getServiceAsOptional(key)
        }
    }
    
    public var wrappedValue: Key.ServiceType? {
        if let service = self.service {
            return service
        } else if self.lazy, let service = getServiceAsOptional(key) {
            self.service = service
            return service
        } else {
            return nil
        }
    }
}

private func getService<Key: ServiceLocatorKey>(_ key: Key, file: StaticString = #file, line: UInt = #line) -> Key.ServiceType {
    guard let locator = serviceLocatorShared else {
        fatalError("Not found ServiceLocator for Inject", file: file, line: line)
    }
    
    return locator.getServiceOrFatal(key: key)
}

private func getServiceAsOptional<Key: ServiceLocatorKey>(_ key: Key, file: StaticString = #file, line: UInt = #line) -> Key.ServiceType? {
    guard let locator = serviceLocatorShared else {
        fatalError("Not found ServiceLocator for Inject", file: file, line: line)
    }
    
    return locator.getServiceAsOptional(key: key)
}

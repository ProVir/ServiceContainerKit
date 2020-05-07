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
    private let locator: ServiceLocator
    private var service: Key.ServiceType?
    
    public init(_ key: Key, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceLocator for Inject", file: file, line: line)
        }
        
        self.key = key
        self.locator = locator
        
        if lazy == false {
            self.service = locator.getServiceOrFatal(key: key, file: file, line: line)
        }
    }
    
    public var wrappedValue: Key.ServiceType {
        if let service = self.service {
            return service
        } else {
            let service = locator.getServiceOrFatal(key: key)
            self.service = service
            return service
        }
    }
}

@propertyWrapper
public final class ServiceOptionalInject<Key: ServiceLocatorKey> {
    public let key: Key
    private let lazy: Bool
    private let locator: ServiceLocator
    private var service: Key.ServiceType?
    
    public init(_ key: Key, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceLocator for Inject", file: file, line: line)
        }
        
        self.key = key
        self.lazy = lazy
        self.locator = locator
        
        if lazy == false {
            self.service = locator.getServiceAsOptional(key: key)
        }
    }
    
    public var wrappedValue: Key.ServiceType? {
        if let service = self.service {
            return service
        } else if self.lazy, let service = locator.getServiceAsOptional(key: key) {
            self.service = service
            return service
        } else {
            return nil
        }
    }
}

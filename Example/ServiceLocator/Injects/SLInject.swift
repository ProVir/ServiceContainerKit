//
//  SLInject.swift
//  ServiceLocator
//
//  Created by Короткий Виталий on 06.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

private var serviceLocatorShared: ServiceLocator?
private var lazyInjects: [SLInjectWrapper] = []

public extension ServiceLocator {
    func setupForInject() {
        serviceLocatorShared = self
        
        let list = lazyInjects
        lazyInjects = []
        list.forEach {
            $0.inject?.setServiceLocator(self)
        }
    }
}

@propertyWrapper
public final class SLInject<ServiceType>: SLInjectBase {
    fileprivate var lazyInit: ((ServiceLocator?) -> Void)?
    private var factory: (() -> ServiceType)?
    private var service: ServiceType?
    
    public init<Key: ServiceLocatorKey>(_ key: Key, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) where Key.ServiceType == ServiceType {
        setup { [unowned self] locator in
            guard let locator = locator else {
                fatalError("Not found ServiceLocator for Inject", file: file, line: line)
            }
            
            if lazy {
                self.factory = { locator.getServiceOrFatal(key: key, file: file, line: line) }
            } else {
                self.service = locator.getServiceOrFatal(key: key, file: file, line: line)
            }
        }
    }
    
    public init<Key: ServiceLocatorParamsKey>(_ key: Key, params: Key.ParamsType, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) where Key.ServiceType == ServiceType {
        setup {[unowned self] locator in
            guard let locator = locator else {
                fatalError("Not found ServiceLocator for Inject", file: file, line: line)
            }
            
            if lazy {
                self.factory = { locator.getServiceOrFatal(key: key, params: params, file: file, line: line) }
            } else {
                self.service = locator.getServiceOrFatal(key: key, params: params, file: file, line: line)
            }
        }
    }
    
    public var wrappedValue: ServiceType {
        lazyInit?(nil)
        
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
public final class SLOptionalInject<ServiceType>: SLInjectBase {
    fileprivate var lazyInit: ((ServiceLocator?) -> Void)?
    private var factory: (() -> ServiceType?)?
    private var service: ServiceType?
    
    public init<Key: ServiceLocatorKey>(_ key: Key, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) where Key.ServiceType == ServiceType {
        setup { [unowned self] locator in
            guard let locator = locator else {
                fatalError("Not found ServiceLocator for Inject", file: file, line: line)
            }
        
            if lazy {
                self.factory = { locator.getServiceAsOptional(key: key) }
            } else {
                self.service = locator.getServiceAsOptional(key: key)
            }
        }
    }
    
    public init<Key: ServiceLocatorParamsKey>(_ key: Key, params: Key.ParamsType, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) where Key.ServiceType == ServiceType {
        setup { [unowned self] locator in
            guard let locator = locator else {
                fatalError("Not found ServiceLocator for Inject", file: file, line: line)
            }
            
            if lazy {
                self.factory = { locator.getServiceAsOptional(key: key, params: params) }
            } else {
                self.service = locator.getServiceAsOptional(key: key, params: params)
            }
        }
    }
    
    public var wrappedValue: ServiceType? {
        lazyInit?(nil)
        
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

private protocol SLInjectBase: class {
    var lazyInit: ((ServiceLocator?) -> Void)? { get set }
    func setup(_ configurator: @escaping (ServiceLocator?) -> Void)
    func setServiceLocator(_ locator: ServiceLocator)
}

extension SLInjectBase {
    func setup(_ configurator: @escaping (ServiceLocator?) -> Void) {
        if let locator = serviceLocatorShared {
            configurator(locator)
        } else {
            self.lazyInit = configurator
            lazyInjects.append(.init(inject: self))
        }
    }
    
    func setServiceLocator(_ locator: ServiceLocator) {
        lazyInit?(locator)
        lazyInit = nil
    }
}

private final class SLInjectWrapper {
    weak var inject: SLInjectBase?
    
    init(inject: SLInjectBase) {
        self.inject = inject
    }
}

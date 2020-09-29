//
//  SLSimpleInject.swift
//  ServiceLocator
//
//  Created by Короткий Виталий on 06.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

private var serviceLocatorShared: ServiceSimpleLocator?
private var lazyInjects: [SLSimpleInjectWrapper] = []

public extension ServiceSimpleLocator {
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
public final class SLSimpleInject<ServiceType>: SLSimpleInjectBase {
    fileprivate var lazyInit: ((ServiceSimpleLocator?) -> Void)?
    private var factory: (() -> ServiceType)?
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        setup { [unowned self] locator in
            guard let locator = locator else {
                fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
            }
            
            if lazy {
                self.factory = { locator.getServiceOrFatal(ServiceType.self, file: file, line: line) }
            } else {
                self.service = locator.getServiceOrFatal(ServiceType.self, file: file, line: line)
            }
        }
    }
    
    public init<ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        setup { [unowned self] locator in
            guard let locator = locator else {
                fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
            }
            
            if lazy {
                self.factory = { locator.getServiceOrFatal(ServiceType.self, params: params, file: file, line: line) }
            } else {
                self.service = locator.getServiceOrFatal(ServiceType.self, params: params, file: file, line: line)
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
public final class SLSimpleOptionalInject<ServiceType>: SLSimpleInjectBase {
    fileprivate var lazyInit: ((ServiceSimpleLocator?) -> Void)?
    private var factory: (() -> ServiceType?)?
    private var service: ServiceType?
    
    public init(_ type: ServiceType.Type = ServiceType.self, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        setup { [unowned self] locator in
            guard let locator = locator else {
                fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
            }
            
            if lazy {
                self.factory = { locator.getServiceAsOptional(ServiceType.self) }
            } else {
                self.service = locator.getServiceAsOptional(ServiceType.self)
            }
        }
    }
    
    public init<ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) {
        setup { [unowned self] locator in
            guard let locator = locator else {
                fatalError("Not found ServiceSimpleLocator for Inject", file: file, line: line)
            }
            
            if lazy {
                self.factory = { locator.getServiceAsOptional(ServiceType.self, params: params) }
            } else {
                self.service = locator.getServiceAsOptional(ServiceType.self, params: params)
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

private protocol SLSimpleInjectBase: class {
    var lazyInit: ((ServiceSimpleLocator?) -> Void)? { get set }
    func setup(_ configurator: @escaping (ServiceSimpleLocator?) -> Void)
    func setServiceLocator(_ locator: ServiceSimpleLocator)
}

extension SLSimpleInjectBase {
    func setup(_ configurator: @escaping (ServiceSimpleLocator?) -> Void) {
        if let locator = serviceLocatorShared {
            configurator(locator)
        } else {
            self.lazyInit = configurator
            lazyInjects.append(.init(inject: self))
        }
    }
    
    func setServiceLocator(_ locator: ServiceSimpleLocator) {
        lazyInit?(locator)
        lazyInit = nil
    }
}

private final class SLSimpleInjectWrapper {
    weak var inject: SLSimpleInjectBase?
    
    init(inject: SLSimpleInjectBase) {
        self.inject = inject
    }
}

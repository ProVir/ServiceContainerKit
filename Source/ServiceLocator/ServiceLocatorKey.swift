//
//  ServiceLocatorKey.swift
//  ServiceContainerKit/ServiceLocator 2.0.0
//
//  Created by Короткий Виталий on 20/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import Foundation

/// Base protocol ServiceLocator key
public protocol ServiceLocatorKey {
    associatedtype ServiceType

    /// Key as unique hashable value for store in dictionary, usually "\(ServiceType.self)"
    var storeKey: AnyHashable { get }
}

/// Base protocol ServiceLocator key for services with params
public protocol ServiceLocatorParamsKey: ServiceLocatorKey {
    associatedtype ParamsType
}

/// Default implementation ServiceLocator key
public struct ServiceLocatorSimpleKey<ServiceType>: ServiceLocatorKey {
    public init() { }
    public var storeKey: AnyHashable { return "\(ServiceType.self)" }
}

/// Default implementation ServiceLocator key for services with params
public struct ServiceLocatorParamsSimpleKey<ServiceType, ParamsType>: ServiceLocatorParamsKey {
    public init() { }
    public var storeKey: AnyHashable { return "\(ServiceType.self)" }
}

extension ServiceFactory {
    /// Default key for service from factory
    public static var defaultKey: ServiceLocatorSimpleKey<ServiceType> { return .init() }
}

extension ServiceParamsFactory {
    /// Default key for service with params from factory
    public static var defaultKey: ServiceLocatorParamsSimpleKey<ServiceType, ParamsType> { return .init() }
}

// MARK: ObjC
/// ServiceLocator ObjC Key as wrapper for swift ServiceLocatorKey
@objc(ServiceLocatorKey)
public class ServiceLocatorObjCKey: NSObject {
    public let storeKey: AnyHashable

    public init<Key: ServiceLocatorKey>(_ key: Key) {
        self.storeKey = key.storeKey
        super.init()
    }

    /// Not recomendation constructor - used for ServiceSimpleLocator as internal logic
    public init(storeKey: AnyHashable) {
        self.storeKey = storeKey
        super.init()
    }
}

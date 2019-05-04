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

    /// Key as unique string for store in dictionary, usually "\(ServiceType.self)"
    var storeKey: String { get }
}

/// Base protocol ServiceLocator key for services with params
public protocol ServiceLocatorParamsKey: ServiceLocatorKey {
    associatedtype ParamsType
}

/// Default implementation ServiceLocator key
public struct ServiceLocatorEasyKey<ServiceType>: ServiceLocatorKey {
    public init() { }
    public var storeKey: String { return "\(ServiceType.self)" }
}

/// Default implementation ServiceLocator key for services with params
public struct ServiceLocatorParamsEasyKey<ServiceType, ParamsType>: ServiceLocatorParamsKey {
    public init() { }
    public var storeKey: String { return "\(ServiceType.self)" }
}

extension ServiceFactory {
    /// Default key for service from factory
    public static var defaultKey: ServiceLocatorEasyKey<ServiceType> { return .init() }
}

extension ServiceParamsFactory {
    /// Default key for service with params from factory
    public static var defaultKey: ServiceLocatorParamsEasyKey<ServiceType, ParamsType> { return .init() }
}

// MARK: ObjC
/// ServiceLocator ObjC Key as wrapper for swift ServiceLocatorKey
@objc(ServiceLocatorKey)
public class ServiceLocatorObjCKey: NSObject {
    public let storeKey: String

    public init<Key: ServiceLocatorKey>(_ key: Key) {
        self.storeKey = key.storeKey
        super.init()
    }

    /// Not recomendation constructor - used for ServiceEasyLocator as internal logic
    public init(storeKey: String) {
        self.storeKey = storeKey
        super.init()
    }
}

//
//  ServiceLocatorKey.swift
//  ServiceLocatorSwift 2.0.0
//
//  Created by Короткий Виталий on 20/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import Foundation

public protocol ServiceLocatorKey {
    associatedtype ServiceType
    var storeKey: String { get }
}

public protocol ServiceLocatorParamsKey: ServiceLocatorKey {
    associatedtype ParamsType
}

public struct ServiceLocatorEasyKey<ServiceType>: ServiceLocatorKey {
    public init() { }
    public var storeKey: String { return "\(ServiceType.self)" }
}

public struct ServiceLocatorParamsEasyKey<ServiceType, ParamsType>: ServiceLocatorParamsKey {
    public init() { }
    public var storeKey: String { return "\(ServiceType.self)" }
}

extension ServiceFactory {
    public static var defaultKey: ServiceLocatorEasyKey<ServiceType> { return .init() }
}

extension ServiceParamsFactory {
    public static var defaultKey: ServiceLocatorParamsEasyKey<ServiceType, ParamsType> { return .init() }
}

//
//  ServiceLocatorObjC.swift
//  ServiceLocator
//
//  Created by Короткий Виталий on 20/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import Foundation

/// Wrapper ServiceLocator for ObjC
@objc(ServiceLocator)
open class ServiceLocatorObjC: NSObject {
    /// Original Swift ServiceLocator
    public let serviceLocator: ServiceLocator
    
    public init(_ serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
        super.init()
    }
    
    /// Used empty ServiceLocator.
    @objc public override init() {
        self.serviceLocator = ServiceLocator()
        super.init()
    }

    /// Get Service by key with detail information throwed error.
    @objc public func getService(key: ServiceLocatorObjCKey) throws -> Any {
        return try serviceLocator.getServiceObjC(key: key).get()
    }

    /// Get Service by key with params with detail information throwed error.
    @objc public func getService(key: ServiceLocatorObjCKey, params: Any) throws -> Any {
        return try serviceLocator.getServiceObjC(key: key, params: params).get()
    }

    /// Get Service by key if there are no errors.
    @objc public func getService(key: ServiceLocatorObjCKey) -> Any? {
        return try? serviceLocator.getServiceObjC(key: key).get()
    }

    /// Get Service by key with params if there are no errors
    @objc public func getService(key: ServiceLocatorObjCKey, params: Any) -> Any? {
        return try? serviceLocator.getServiceObjC(key: key, params: params).get()
    }
}

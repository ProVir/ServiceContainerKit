//
//  ServiceLocatorObjC.swift
//  ServiceLocator 2.0.0
//
//  Created by Короткий Виталий on 20/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import Foundation

/// Wrapper ServiceLocator for ObjC
@objc(ServiceLocator)
public class ServiceLocatorObjC: NSObject {
    /// Original Swift ServiceLocator
    public let serviceLocator: ServiceLocator
    
    public init(_ serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
        super.init()
    }
    
    /// [ServiceLocator new] used empty ServiceLocator.
    @objc public override init() {
        self.serviceLocator = ServiceLocator()
        super.init()
    }
    
    @objc public func getService(key: ServiceLocatorObjCKey) throws -> Any {
        return try serviceLocator.tryServiceObjC(key: key)
    }
    
    @objc public func getService(key: ServiceLocatorObjCKey, params: Any) throws -> Any {
        return try serviceLocator.tryServiceObjC(key: key, params: params)
    }
    
    @objc public func getService(key: ServiceLocatorObjCKey) -> Any? {
        return try? serviceLocator.tryServiceObjC(key: key)
    }
    
    @objc public func getService(key: ServiceLocatorObjCKey, params: Any) -> Any? {
        return try? serviceLocator.tryServiceObjC(key: key, params: params)
    }
}


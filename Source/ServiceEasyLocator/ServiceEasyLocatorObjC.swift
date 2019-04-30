//
//  ServiceEasyLocatorObjC.swift
//  ServiceContainerKit/ServiceEasyLocator 2.0.0
//
//  Created by Короткий Виталий (ViR) on 08.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

/// Wrapper ServiceEasyLocator for ObjC
@objc(ServiceEasyLocator)
public class ServiceEasyLocatorObjC: NSObject {
    /// Original Swift ServiceLocator
    public let serviceLocator: ServiceEasyLocator
    
    public init(_ serviceLocator: ServiceEasyLocator) {
        self.serviceLocator = serviceLocator
        super.init()
    }
    
    /// Used empty ServiceEasyLocator.
    @objc public override init() {
        self.serviceLocator = ServiceEasyLocator()
        super.init()
    }

    /// Get Service with detailed information throwed error.
    @objc public func getService(class type: AnyClass) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: "\(type)")
    }

    /// Get Service as protocol with detailed information throwed error.
    @objc public func getService(protocol proto: Protocol) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto))
    }

    /// Get Service with params and detailed information throwed error.
    @objc public func getService(class type: AnyClass, params: Any) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: "\(type)", params: params)
    }

    /// Get Service as protocol with params and detailed information throwed error.
    @objc public func getService(protocol proto: Protocol, params: Any) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: params)
    }

    /// Get Service if there are no errors.
    @objc public func getService(class type: AnyClass) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: "\(type)")
    }

    /// Get Service as protocol if there are no errors.
    @objc public func getService(protocol proto: Protocol) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto))
    }

    /// Get Service with params if there are no errors
    @objc public func getService(class type: AnyClass, params: Any) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: "\(type)", params: params)
    }

    /// Get Service as protocol with params if there are no errors
    @objc public func getService(protocol proto: Protocol, params: Any) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: params)
    }
}


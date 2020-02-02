//
//  ServiceSimpleLocatorObjC.swift
//  ServiceContainerKit/ServiceSimpleLocator 2.0.0
//
//  Created by Короткий Виталий (ViR) on 08.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

/// Wrapper ServiceSimpleLocator for ObjC
@objc(ServiceSimpleLocator)
open class ServiceSimpleLocatorObjC: NSObject {
    /// Original Swift ServiceLocator
    public let serviceLocator: ServiceSimpleLocator
    
    public init(_ serviceLocator: ServiceSimpleLocator) {
        self.serviceLocator = serviceLocator
        super.init()
    }
    
    /// Used empty ServiceSimpleLocator.
    @objc public override init() {
        self.serviceLocator = ServiceSimpleLocator()
        super.init()
    }

    /// Get Service with detailed information throwed error.
    @objc public func getService(class type: AnyClass) throws -> Any {
        return try serviceLocator.getServiceObjC(typeName: "\(type)").get()
    }

    /// Get Service as protocol with detailed information throwed error.
    @objc public func getService(protocol proto: Protocol) throws -> Any {
        return try serviceLocator.getServiceObjC(typeName: NSStringFromProtocol(proto)).get()
    }

    /// Get Service with params and detailed information throwed error.
    @objc public func getService(class type: AnyClass, params: Any) throws -> Any {
        return try serviceLocator.getServiceObjC(typeName: "\(type)", params: params).get()
    }

    /// Get Service as protocol with params and detailed information throwed error.
    @objc public func getService(protocol proto: Protocol, params: Any) throws -> Any {
        return try serviceLocator.getServiceObjC(typeName: NSStringFromProtocol(proto), params: params).get()
    }

    /// Get Service if there are no errors.
    @objc public func getService(class type: AnyClass) -> Any? {
        return try? serviceLocator.getServiceObjC(typeName: "\(type)").get()
    }

    /// Get Service as protocol if there are no errors.
    @objc public func getService(protocol proto: Protocol) -> Any? {
        return try? serviceLocator.getServiceObjC(typeName: NSStringFromProtocol(proto)).get()
    }

    /// Get Service with params if there are no errors
    @objc public func getService(class type: AnyClass, params: Any) -> Any? {
        return try? serviceLocator.getServiceObjC(typeName: "\(type)", params: params).get()
    }

    /// Get Service as protocol with params if there are no errors
    @objc public func getService(protocol proto: Protocol, params: Any) -> Any? {
        return try? serviceLocator.getServiceObjC(typeName: NSStringFromProtocol(proto), params: params).get()
    }
}

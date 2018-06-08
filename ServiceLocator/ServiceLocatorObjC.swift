//
//  ServiceLocatorObjC.swift
//  ServiceLocator 1.0.0
//
//  Created by Короткий Виталий (ViR) on 08.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation


//MARK: Shared
extension ServiceLocatorObjC {
    //Without params
    @objc public static func getService(class type: AnyClass) throws -> Any {
        return try ServiceLocator.tryServiceObjC(typeName: "\(type)", params: Optional<Any>.none as Any)
    }
    
    @objc public static func getService(protocol proto: Protocol) throws -> Any {
        return try ServiceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: Optional<Any>.none as Any)
    }
    
    @objc public static func getService(class type: AnyClass) -> Any? {
        return try? ServiceLocator.tryServiceObjC(typeName: "\(type)", params: Optional<Any>.none as Any)
    }
    
    @objc public static func getService(protocol proto: Protocol) -> Any? {
        return try? ServiceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: Optional<Any>.none as Any)
    }
    
    
    //With params
    @objc public static func getService(class type: AnyClass, params: Any) throws -> Any {
        return try ServiceLocator.tryServiceObjC(typeName: "\(type)", params: params)
    }
    
    @objc public static func getService(protocol proto: Protocol, params: Any) throws -> Any {
        return try ServiceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: params)
    }
    
    @objc public static func getService(class type: AnyClass, params: Any) -> Any? {
        return try? ServiceLocator.tryServiceObjC(typeName: "\(type)", params: params)
    }
    
    @objc public static func getService(protocol proto: Protocol, params: Any) -> Any? {
        return try? ServiceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: params)
    }
}


//MARK: ServiceLocator Object

/// Wrapper ServiceLocator for ObjC
@objc(ServiceLocator)
public class ServiceLocatorObjC: NSObject {
    public let serviceLocator: ServiceLocator
    
    public init(_ serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
        super.init()
    }
    
    @objc public override init() {
        self.serviceLocator = ServiceLocator.shared ?? ServiceLocator()
        super.init()
    }
    
    
    //Without Params
    @objc public func getService(class type: AnyClass) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: "\(type)", params: Optional<Any>.none as Any)
    }
    
    @objc public func getService(protocol proto: Protocol) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: Optional<Any>.none as Any)
    }
    
    @objc public func getService(class type: AnyClass) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: "\(type)", params: Optional<Any>.none as Any)
    }
    
    @objc public func getService(protocol proto: Protocol) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: Optional<Any>.none as Any)
    }
    
    
    //With Params
    @objc public func getService(class type: AnyClass, params: Any) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: "\(type)", params: params)
    }
    
    @objc public func getService(protocol proto: Protocol, params: Any) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: params)
    }
    
    @objc public func getService(class type: AnyClass, params: Any) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: "\(type)", params: params)
    }
    
    @objc public func getService(protocol proto: Protocol, params: Any) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: NSStringFromProtocol(proto), params: params)
    }
    
}


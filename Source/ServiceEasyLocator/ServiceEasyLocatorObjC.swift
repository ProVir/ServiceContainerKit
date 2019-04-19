//
//  ServiceLocatorObjC.swift
//  ServiceLocator 1.1.0
//
//  Created by Короткий Виталий (ViR) on 08.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

/*
// MARK: Shared
/// Support singleton ServiceLocator.
extension ServiceLocatorObjC {
    //Without params
    @objc public static func getService(class type: AnyClass) throws -> Any {
        let serviceLocator = try ServiceLocator.tryShared()
        return try serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(for: type),
                                                 params: Optional<Any>.none as Any)
    }
    
    @objc public static func getService(protocol proto: Protocol) throws -> Any {
        let serviceLocator = try ServiceLocator.tryShared()
        return try serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(forObjCProtocol: proto),
                                                 params: Optional<Any>.none as Any)
    }
    
    @objc public static func getService(class type: AnyClass) -> Any? {
        guard let serviceLocator = ServiceLocator.shared else { return nil }
        return try? serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(for: type),
                                                  params: Optional<Any>.none as Any)
    }
    
    @objc public static func getService(protocol proto: Protocol) -> Any? {
        guard let serviceLocator = ServiceLocator.shared else { return nil }
        return try? serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(forObjCProtocol: proto),
                                                  params: Optional<Any>.none as Any)
    }
    
    
    //With params
    @objc public static func getService(class type: AnyClass, params: Any) throws -> Any {
        let serviceLocator = try ServiceLocator.tryShared()
        return try serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(for: type),
                                                 params: params)
    }
    
    @objc public static func getService(protocol proto: Protocol, params: Any) throws -> Any {
        let serviceLocator = try ServiceLocator.tryShared()
        return try serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(forObjCProtocol: proto),
                                                 params: params)
    }
    
    @objc public static func getService(class type: AnyClass, params: Any) -> Any? {
        guard let serviceLocator = ServiceLocator.shared else { return nil }
        return try? serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(for: type),
                                                  params: params)
    }
    
    @objc public static func getService(protocol proto: Protocol, params: Any) -> Any? {
        guard let serviceLocator = ServiceLocator.shared else { return nil }
        return try? serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(forObjCProtocol: proto),
                                                  params: params)
    }
}

// MARK: ServiceLocator Object
/// Wrapper ServiceLocator for ObjC
@objc(ServiceLocator)
public class ServiceLocatorObjC: NSObject {
    private let serviceLocatorInstance: ServiceLocator?
    
    /// Original Swift ServiceLocator
    public var serviceLocator: ServiceLocator {
        return serviceLocatorInstance ?? ServiceLocator.shared ?? ServiceLocator()
    }
    
    public init(_ serviceLocator: ServiceLocator) {
        self.serviceLocatorInstance = serviceLocator
        super.init()
    }
    
    /// [ServiceLocator new] used swift singleton or empty ServiceLocator.
    @objc public override init() {
        self.serviceLocatorInstance = nil
        super.init()
    }
    
    
    //Without Params
    @objc public func getService(class type: AnyClass) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(for: type),
                                                 params: Optional<Any>.none as Any)
    }
    
    @objc public func getService(protocol proto: Protocol) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(forObjCProtocol: proto),
                                                 params: Optional<Any>.none as Any)
    }
    
    @objc public func getService(class type: AnyClass) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(for: type),
                                                  params: Optional<Any>.none as Any)
    }
    
    @objc public func getService(protocol proto: Protocol) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(forObjCProtocol: proto),
                                                  params: Optional<Any>.none as Any)
    }
    
    
    //With Params
    @objc public func getService(class type: AnyClass, params: Any) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(for: type),
                                                 params: params)
    }
    
    @objc public func getService(protocol proto: Protocol, params: Any) throws -> Any {
        return try serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(forObjCProtocol: proto),
                                                 params: params)
    }
    
    @objc public func getService(class type: AnyClass, params: Any) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(for: type),
                                                  params: params)
    }
    
    @objc public func getService(protocol proto: Protocol, params: Any) -> Any? {
        return try? serviceLocator.tryServiceObjC(typeName: serviceLocator.serviceTypeName(forObjCProtocol: proto),
                                                  params: params)
    }
}
*/

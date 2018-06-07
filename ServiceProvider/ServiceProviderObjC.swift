//
//  ServiceProviderObjC.swift
//  ServiceProvider 1.0.0
//
//  Created by Короткий Виталий (ViR) on 07.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation


/// Wrapper ServiceProvider for use in ObjC code.
public class PVServiceProvider: NSObject {
    private let swiftProvider: ServiceProviderBindingObjC

    public init<ServiceType: NSObject>(_ provider: ServiceProvider<ServiceType>) {
        self.swiftProvider = provider
        super.init()
    }

    public func provider<ServiceType>() -> ServiceProvider<ServiceType>? {
        return swiftProvider as? ServiceProvider<ServiceType>
    }

    @objc public func getService() throws -> NSObject {
        return try swiftProvider.tryServiceBindingObjC(params: Void())
    }

    @objc public func getService() -> NSObject? {
        return try? swiftProvider.tryServiceBindingObjC(params: Void())
    }
}

/// Wrapper ServiceParamsProvider for use in ObjC code.
public class PVServiceParamsProvider: NSObject {
    private let swiftProvider: ServiceProviderBindingObjC
    
    public init<ServiceType: NSObject, ParamsType: NSObject>(_ provider: ServiceParamsProvider<ServiceType, ParamsType>) {
        self.swiftProvider = provider
        super.init()
    }
    
    public func provider<ServiceType>() -> ServiceProvider<ServiceType>? {
        return swiftProvider as? ServiceProvider<ServiceType>
    }
    
    @objc public func getService(params: Any) throws -> NSObject {
        return try swiftProvider.tryServiceBindingObjC(params: params)
    }
    
    @objc public func getService(params: Any) -> NSObject? {
        return try? swiftProvider.tryServiceBindingObjC(params: params)
    }
}


//MARK: - Private

/// Base protocol for ServiceProvider<T>
private protocol ServiceProviderBindingObjC {
    func tryServiceBindingObjC(params: Any) throws -> NSObject
}

extension ServiceProvider: ServiceProviderBindingObjC {
    fileprivate func tryServiceBindingObjC(params: Any) throws -> NSObject {
        if let service = try tryService() as? NSObject {
            return service
        } else {
            fatalError("Service require support Objective-C")
        }
    }
}

extension ServiceParamsProvider: ServiceProviderBindingObjC {
    fileprivate func tryServiceBindingObjC(params: Any) throws -> NSObject {
        guard let params = params as? ParamsType else {
            throw ServiceProviderError.wrongParams
        }
        
        if let service = try tryService(params: params) as? NSObject {
            return service
        } else {
            fatalError("Service require support Objective-C")
        }
    }
}

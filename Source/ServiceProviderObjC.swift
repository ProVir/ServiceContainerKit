//
//  ServiceProviderObjC.swift
//  ServiceContainerKit/ServiceProvider 2.0.0
//
//  Created by Короткий Виталий (ViR) on 07.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

/// Wrapper ServiceProvider for use in ObjC code.
@objc(ServiceProvider)
public class ServiceProviderObjC: NSObject {
    private let swiftProvider: ServiceProviderBindingObjC

    /// Create ServiceProviderObjC with Swift ServiceProvider
    public init<ServiceType>(_ provider: ServiceProvider<ServiceType>) {
        self.swiftProvider = provider
        super.init()
    }

    /// Get Swift ServiceProvider. Returned nil if wrong service type.
    public func provider<ServiceType>() -> ServiceProvider<ServiceType>? {
        return swiftProvider as? ServiceProvider<ServiceType>
    }

    /// Get Service with detail information throwed error.
    @objc public func getService() throws -> Any {
        return try swiftProvider.tryServiceBindingObjC(params: Void())
    }

    /// Get Service if there are no errors.
    @objc public func getService() -> Any? {
        return try? swiftProvider.tryServiceBindingObjC(params: Void())
    }
}

/// Wrapper ServiceParamsProvider for use in ObjC code.
@objc(ServiceParamsProvider)
public class ServiceParamsProviderObjC: NSObject {
    private let swiftProvider: ServiceProviderBindingObjC
    
    /// Create ServiceParamsProviderObjC with Swift ServiceParamsProvider
    public init<ServiceType, ParamsType>(_ provider: ServiceParamsProvider<ServiceType, ParamsType>) {
        self.swiftProvider = provider
        super.init()
    }
    
    /// Get Swift ServiceParamsProvider. Returned nil if wrong service type.
    public func provider<ServiceType>() -> ServiceProvider<ServiceType>? {
        return swiftProvider as? ServiceProvider<ServiceType>
    }
    
    /// Get Service with detail information throwed error.
    @objc public func getService(params: Any) throws -> Any {
        return try swiftProvider.tryServiceBindingObjC(params: params)
    }
    
    /// Get Service if there are no errors.
    @objc public func getService(params: Any) -> Any? {
        return try? swiftProvider.tryServiceBindingObjC(params: params)
    }
}

// MARK: - Private

/// Base protocol for Service[Params]Provider<T>
private protocol ServiceProviderBindingObjC {
    func tryServiceBindingObjC(params: Any) throws -> NSObject
}

extension ServiceProvider: ServiceProviderBindingObjC {
    fileprivate func tryServiceBindingObjC(params: Any) throws -> NSObject {
        if let service = try tryService() as? NSObject {
            return service
        } else {
            throw ServiceProviderError.notSupportObjC
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
            throw ServiceProviderError.notSupportObjC
        }
    }
}

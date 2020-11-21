//
//  ServiceProviderObjC.swift
//  ServiceContainerKit/Core 3.0.0
//
//  Created by Короткий Виталий (ViR) on 07.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

/// Wrapper ServiceProvider for use in ObjC code.
@objc(ServiceProvider)
public class ServiceProviderObjC: NSObject {
    @objc public static let errorNotSupportObjCError = NSError(
        domain: "ru.provir.ServiceContainerKit.notSupportObjC", code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Service require support Objective-C"]
    )

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
        return try swiftProvider.getServiceBindingObjC(params: Void())
    }

    /// Get Service if there are no errors.
    @objc public func getService() -> Any? {
        return try? swiftProvider.getServiceBindingObjC(params: Void())
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
        return try swiftProvider.getServiceBindingObjC(params: params)
    }
    
    /// Get Service if there are no errors.
    @objc public func getService(params: Any) -> Any? {
        return try? swiftProvider.getServiceBindingObjC(params: params)
    }
}

// MARK: - Private

/// Base protocol for Service[Params]Provider<T>
private protocol ServiceProviderBindingObjC {
    func getServiceBindingObjC(params: Any) throws -> NSObject
}

extension ServiceProvider: ServiceProviderBindingObjC {
    fileprivate func getServiceBindingObjC(params: Any) throws -> NSObject {
        let service = try getService()
        if let serviceObjC = service as? NSObject {
            return serviceObjC
        } else {
            LogRecorder.serviceProviderObjCNotSupport(type: type(of: service))
            throw ServiceProviderObjC.errorNotSupportObjCError
        }
    }
}

extension ServiceParamsProvider: ServiceProviderBindingObjC {
    fileprivate func getServiceBindingObjC(params: Any) throws -> NSObject {
        guard let params = params as? ParamsType else {
            throw ServiceObtainError(service: ServiceType.self, error: ServiceFactoryError.wrongParams)
        }
        
        let service = try getService(params: params)
        if let serviceObjC = service as? NSObject {
            return serviceObjC
        } else {
            LogRecorder.serviceProviderObjCNotSupport(type: type(of: service))
            throw ServiceProviderObjC.errorNotSupportObjCError
        }
    }
}

//
//  ServiceBaseTypes.swift
//  ServiceProvider 1.1.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

/// Errors for ServiceProvider and ServiceFactory
public enum ServiceProviderError: LocalizedError {
    case wrongParams
    case wrongService
    case notSupportObjC

    public var errorDescription: String? {
        switch self {
        case .wrongParams: return "Params type invalid for ServiceParamsFactory"
        case .wrongService: return "Service type invalid"
        case .notSupportObjC: return "Service require support Objective-C"
        }
    }
}

/// Factory type. Used only when added to provider.
public enum ServiceFactoryType {
    /// Create service at one when added to provider.
    case atOne
    
    /// Create service at one after first need and reused next.
    case lazy
    
    /// Create a new instance service for each request.
    case many
}

///Factory services for ServiceProvider or ServiceLocator.
public protocol ServiceFactory: ServiceCoreFactory {
    associatedtype ServiceType
    
    /// Factory type. Used only when added to provider. Recommendation use as constant (let).
    var factoryType: ServiceFactoryType { get }
    
    /// Create new instance service. Parameter settings use only for multiple factory. 
    func createService() throws -> ServiceType
}

///Factory services with params for ServiceProvider or ServiceLocator. Always factoryType = .many
public protocol ServiceParamsFactory: ServiceCoreFactory {
    associatedtype ServiceType
    associatedtype ParamsType
    
    /// Create new instance service.
    func createService(params: ParamsType) throws -> ServiceType
}

///Factory for ServiceProvider or ServiceLocator with generate service in closure. Also can used for lazy create singleton instance services.
public class ServiceClosureFactory<T>: ServiceFactory {
    public let closure: () throws -> T
    public let factoryType: ServiceFactoryType
    
    /**
     Constructor for ServiceFactory used closure for create service
     
     - Parameters:
        - closureFactory: Closure with logic create service.
        - lazyRegime: If `true` - Create service at one after first need and reused next. Default false.
     */
    public init(closureFactory closure: @escaping () throws -> T, lazyRegime: Bool = false) {
        self.closure = closure
        self.factoryType = lazyRegime ? .lazy : .many
    }
    
    public func createService() throws -> T {
        return try closure()
    }
}

// MARK: - Core protocols
public protocol ServiceCoreFactory {
    /// Can not implementation! Used only with framework implementation. 
    func coreCreateService(params: Any) throws -> Any
}

public extension ServiceFactory  {
    func coreCreateService(params: Any) throws -> Any {
        return try createService()
    }
}

public extension ServiceParamsFactory  {
    func coreCreateService(params: Any) throws -> Any {
        if let params = params as? ParamsType {
            return try createService(params: params)
        } else {
            throw ServiceProviderError.wrongParams
        }
    }
}

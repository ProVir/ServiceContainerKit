//
//  ServiceBaseTypes.swift
//  ServiceProvider 1.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

/// Errors for ServiceProvider and ServiceFactory
public enum ServiceProviderError: Error {
    case wrongParams
    case wrongService
}


/// Factory type. Used only when added to provider.
public enum ServiceFactoryType {
    /// Create service at one when added to provider.
    case single
    
    /// Create service at one after first need and reused next.
    case lazy
    
    /// Create a new instance service for each request.
    case multiple
}

///Factory services for ServiceProvider.
public protocol ServiceFactory: ServiceCoreFactory {
    associatedtype ServiceType
    
    /// Factory type. Used only when added to provider.
    var factoryType: ServiceFactoryType { get }
    
    /// Create new instance service. Parameter settings use only for multiple factory. 
    func createService() throws -> ServiceType
}

///Factory services with params for ServiceProvider. Always factoryType = .multiple
public protocol ServiceParamsFactory: ServiceCoreFactory {
    associatedtype ServiceType
    associatedtype ParamsType
    
    /// Create new instance service.
    func createService(params: ParamsType) throws -> ServiceType
}


///Factory for ServiceLocator with generate service in closure. Also can used for lazy create services.
public class ServiceClosureFactory<T>: ServiceFactory {
    public let closure: () throws -> T
    public let factoryType: ServiceFactoryType
    
    /**
     Constructor for ServiceFactory used closure for create service
     
     - Parameter closureFactory: Closure with logic create service.
     */
    public init(closureFactory closure: @escaping () throws -> T, lazyRegime: Bool = false) {
        self.closure = closure
        self.factoryType = lazyRegime ? .lazy : .multiple
    }
    
   public  func createService() throws -> T {
        return try closure()
    }
}


//MARK: - Core protocols
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

//
//  ServiceBaseTypes.swift
//  ServiceProvider 1.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation


///Protocol for settings types, used for factory services as parameter for create service.
public protocol ServiceFactorySettings { }

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
    associatedtype TypeService
    
    /// Factory type. Used only when added to provider.
    var factoryType: ServiceFactoryType { get }
    
    /// Create new instance service. Parameter settings use only for multiple factory. 
    func createService(settings: ServiceFactorySettings?) throws -> TypeService
}


///Factory for ServiceLocator with generate service in closure. Also can used for lazy create services.
public class ServiceClosureFactory<T>: ServiceFactory {
    public let closure: (ServiceFactorySettings?) throws -> T
    public let factoryType: ServiceFactoryType = .multiple
    
    /**
     Constructor for ServiceFactory used closure for create service
     
     - Parameter closureFactory: Closure with logic create service.
     */
    public init(closureFactory closure: @escaping (ServiceFactorySettings?) throws -> T) {
        self.closure = closure
    }
    
   public  func createService(settings: ServiceFactorySettings?) throws -> T {
        return try closure(settings)
    }
}

///Factory for ServiceLocator with generate service in closure. Also can used for lazy create services.
public class ServiceClosureLazyFactory<T>: ServiceFactory {
    public let closure: () throws -> T
    public let factoryType: ServiceFactoryType = .lazy
    
    /**
     Constructor for ServiceFactory used closure for create service
     
     - Parameter closureFactory: Closure with logic create service.
     */
    public init(closureFactory closure: @escaping () throws -> T) {
        self.closure = closure
    }
    
    public func createService(settings: ServiceFactorySettings?) throws -> T {
        return try closure()
    }
}

//MARK: - Core protocols
public protocol ServiceCoreFactory {
    /// Can not implementation! Used only with framework implementation. 
    func coreCreateService(settings: ServiceFactorySettings?) throws -> Any
}

public extension ServiceFactory  {
    func coreCreateService(settings: ServiceFactorySettings?) throws -> Any {
        return try createService(settings: settings)
    }
}

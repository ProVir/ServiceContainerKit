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

///Factory services for ServiceProvider.
public protocol ServiceFactory: ServiceCoreFactory {
    associatedtype TypeService
    func createService(settings: ServiceFactorySettings?) throws -> TypeService
}


///Factory for ServiceLocator with generate service in closure. Also can used for lazy create services.
public class ServiceClosureFactory<T>: ServiceFactory {
    public let closure: (ServiceFactorySettings?) throws -> T
    public let lazyRegime: Bool
    
    private var lazyInstance: T?
    
    /**
     Constructor for ServiceFactory used closure for create service
     
     - Parameters:
        - closureFactory: Closure with logic create service.
        - lazyRegime: If `true`, service will be created only once on the first get and re-used on the next call get.
     */
    public init(closureFactory closure: @escaping (ServiceFactorySettings?) throws -> T, lazyRegime: Bool = false) {
        self.closure = closure
        self.lazyRegime = lazyRegime
    }
    
   public  func createService(settings: ServiceFactorySettings?) throws -> T {
        if lazyRegime {
            if let instance = lazyInstance {
                return instance
            } else {
                let instance = try closure(settings)
                lazyInstance = instance
                return instance
            }
        } else {
            return try closure(settings)
        }
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

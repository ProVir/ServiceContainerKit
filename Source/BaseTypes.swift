//
//  BaseTypes.swift
//  ServiceContainerKit/ServiceProvider 2.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

/// Factory mode to make. Used only when added to provider.
public enum ServiceFactoryMode {
    /// Create service at one when added to provider.
    case atOne
    
    /// Create service at one after first need and reused next.
    case lazy
    
    /// Create a new instance service for each request.
    case many
}

public protocol ServiceSession {
    var key: AnyHashable { get }
}

///Factory services for ServiceProvider or ServiceLocator.
public protocol ServiceFactory: ServiceCoreFactory {
    associatedtype ServiceType
    
    /// Factory mode to make. Used only when added to provider. Recommendation use as constant (let).
    var mode: ServiceFactoryMode { get }
    
    /// Make new instance service.
    func makeService() throws -> ServiceType
}

///Factory services with params for ServiceProvider or ServiceLocator. Always factoryType = .many
public protocol ServiceParamsFactory: ServiceCoreFactory {
    associatedtype ServiceType
    associatedtype ParamsType
    
    /// Make new instance service.
    func makeService(params: ParamsType) throws -> ServiceType
}

public protocol ServiceSessionFactory: ServiceSessionCoreFactory {
    associatedtype ServiceType
    associatedtype SessionType: ServiceSession

    /// Create service at one after first need and reused next. If false - create after chnage session.
    var isLazy: Bool { get }

    /// Deactivate current service after change. Return true if can activate after, false - delete service.
    func deactivateService(_ service: ServiceType, session: SessionType) -> Bool

    /// Activate instance for new session
    func activateService(_ service: ServiceType, session: SessionType)

    /// Make new instance service.
    func makeService(session: SessionType) throws -> ServiceType
}

///Factory for ServiceProvider or ServiceLocator with generate service in closure.
///Also can used for lazy create singleton instance services.
public class ServiceClosureFactory<T>: ServiceFactory {
    public let factory: () throws -> T
    public let mode: ServiceFactoryMode
    
    /**
     Constructor for ServiceFactory used closure for make service
     
     - Parameters:
        - mode: Mode factory - atOne, lazy or many
        - factory: Closure with logic create service.
     */
    public init(mode: ServiceFactoryMode, factory: @escaping () throws -> T) {
        self.factory = factory
        self.mode = mode
    }

    public func makeService() throws -> T {
        return try factory()
    }
}

///Factory for ServiceProvider or ServiceLocator with generate service in closure.
///Also can used for lazy create singleton instance services.
public class ServiceParamsClosureFactory<T, P>: ServiceParamsFactory {
    public let factory: (P) throws -> T
    
    /// Constructor for ServiceParamsFactory used closure for make service
    public init(factory: @escaping (P) throws -> T) {
        self.factory = factory
    }

    public func makeService(params: P) throws -> T {
        return try factory(params)
    }
}

// MARK: Safe thread
public enum ServiceSafeProviderKind {
    case lock
    case semaphore
    case queue(qos: DispatchQoS = .utility, label: String? = nil)
}

// MARK: - Core protocols
public protocol ServiceCoreFactory {
    /// Can not implementation! Used only with framework implementation. 
    func coreMakeService(params: Any) throws -> Any
}

public protocol ServiceSessionCoreFactory {
    /// Can not implementation! Used only with framework implementation.
    var coreIsLazy: Bool { get }
    func coreDeactivateService(_ service: Any, session: ServiceSession) -> Bool
    func coreActivateService(_ service: Any, session: ServiceSession)
    func coreMakeService(session: ServiceSession) throws -> Any
}

public extension ServiceFactory {
    func coreMakeService(params: Any) throws -> Any {
        return try makeService()
    }
}

public extension ServiceParamsFactory {
    func coreMakeService(params: Any) throws -> Any {
        if let params = params as? ParamsType {
            return try makeService(params: params)
        } else {
            throw ServiceFactoryError.wrongParams
        }
    }
}

public extension ServiceSessionFactory {
    var coreIsLazy: Bool {
        return isLazy
    }

    func coreDeactivateService(_ service: Any, session: ServiceSession) -> Bool {
        if let service = service as? ServiceType, let session = session as? SessionType {
            return deactivateService(service, session: session)
        } else {
            return false
        }
    }

    func coreActivateService(_ service: Any, session: ServiceSession) {
        if let service = service as? ServiceType, let session = session as? SessionType {
            activateService(service, session: session)
        }
    }

    func coreMakeService(session: ServiceSession) throws -> Any {
        if let session = session as? SessionType {
            return try makeService(session: session)
        } else {
            throw ServiceFactoryError.wrongSession
        }
    }
}

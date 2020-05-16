//
//  ServiceProvider.swift
//  ServiceContainerKit/ServiceProvider 2.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

public extension ServiceFactory {
    /// Wrap the factory in ServiceProvider
    func serviceProvider() -> ServiceProvider<ServiceType> {
        return .init(factory: self)
    }

    /// Wrap the factory in ServiceSafeProvider
    func serviceSafeProvider(safeThread kind: ServiceSafeProviderKind = .lock) -> ServiceSafeProvider<ServiceType> {
        return .init(factory: self, safeThread: kind)
    }
}

public extension ServiceSessionFactory {
    /// Wrap the factory in ServiceProvider
    func serviceProvider(mediator: ServiceSessionMediator<SessionType>) -> ServiceProvider<ServiceType> {
        return .init(factory: self, mediator: mediator)
    }

    /// Wrap the factory in ServiceSafeProvider
    func serviceSafeProvider(mediator: ServiceSessionMediator<SessionType>, safeThread kind: ServiceSafeProviderKind = .lock) -> ServiceSafeProvider<ServiceType> {
        return .init(factory: self, mediator: mediator, safeThread: kind)
    }
}

/// ServiceProvider with information for make service (singleton or many instances)
public class ServiceProvider<ServiceType> {
    private enum Storage {
        case instance(ServiceType)
        case atOneError(ServiceObtainError)
        case lazy(ServiceCoreFactory)
        case weak(ServiceCoreFactory, ServiceWeakWrapper)
        case session(SessionStorage)
        case factory(ServiceCoreFactory, params: Any)

        func validateError() throws {
            switch self {
            case .atOneError(let error): throw error
            default: return
            }
        }
    }
    
    fileprivate final class ServiceWeakWrapper {
        private weak var instance: AnyObject?
        
        init() { }
        init(service: ServiceType) {
            instance = service as AnyObject
        }
        
        var service: ServiceType? {
            get { instance as? ServiceType }
            set {
                if let service = newValue {
                    instance = service as AnyObject
                } else {
                    instance = nil
                }
            }
        }
    }

    fileprivate final class SessionStorage {
        let factory: ServiceSessionCoreFactory
        let mode: ServiceSessionFactoryMode
        var token: ServiceSessionMediatorToken?
        var currentSession: ServiceSession?
        
        var strongServices: [AnyHashable: ServiceType] = [:]
        var weakServices: [AnyHashable: ServiceWeakWrapper] = [:]

        init(factory: ServiceSessionCoreFactory, mode: ServiceSessionFactoryMode) {
            self.factory = factory
            self.mode = mode
        }
    }

    private let helper = ServiceProviderHelper<ServiceType>()
    private var storage: Storage
    
    /// ServiceProvider with at one instance services.
    public init(_ service: ServiceType) {
        self.storage = .instance(service)
    }
    
    /// ServiceProvider with factory.
    public init<FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        switch factory.mode {
        case .atOne:
            let result = helper.makeService(factory: factory, params: Void())
            switch result {
            case let .success(service): self.storage = .instance(service)
            case let .failure(error): self.storage = .atOneError(error)
            }

        case .lazy:
            self.storage = .lazy(factory)
            
        case .weak:
            self.storage = .weak(factory, .init())

        case .many:
            self.storage = .factory(factory, params: Void())
        }
    }
    
    /// ServiceProvider with factory, use specific params.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, params: FactoryType.ParamsType) where FactoryType.ServiceType == ServiceType {
        self.storage = .factory(factory, params: params)
    }

    public convenience init<FactoryType: ServiceSessionFactory, SessionType>(factory: FactoryType, mediator: ServiceSessionMediator<SessionType>) where FactoryType.ServiceType == ServiceType, FactoryType.SessionType == SessionType {
        self.init(factory: factory) { storage in
            storage.sessionChanged(mediator.session, remakePolicy: .force)
            storage.token = mediator.addObserver { [weak storage] session, remakePolicy in
                storage?.sessionChanged(session, remakePolicy: remakePolicy)
            }
        }
    }

    fileprivate init<FactoryType: ServiceSessionFactory, SessionType>(factory: FactoryType, storageConfigurator: (SessionStorage) -> Void) where FactoryType.ServiceType == ServiceType, FactoryType.SessionType == SessionType {
        let storage = SessionStorage(factory: factory, mode: factory.mode)
        self.storage = .session(storage)
        storageConfigurator(storage)
    }

    init(coreFactory: ServiceCoreFactory, params: Any) {
        self.storage = .factory(coreFactory, params: params)
    }

    /// ServiceProvider with factory. If service factoryType == .atOne and throw error when make - throw this error from constructor.
    public convenience init<FactoryType: ServiceFactory>(tryFactory factory: FactoryType) throws where FactoryType.ServiceType == ServiceType {
        self.init(factory: factory)
        try validateError()
    }
    
    /// ServiceProvider with many or lazy singleton instance service type, create service in closure.
    public convenience init(lazySingleton: Bool = false, factory: @escaping () throws -> ServiceType) {
        self.init(factory: ServiceClosureFactory(mode: lazySingleton ? .lazy : .many, factory: factory))
    }

    /// Get Service with detail information throwed error.
    public func getServiceAsResult() -> Result<ServiceType, ServiceObtainError> {
        switch storage {
        case let .instance(service):
            return .success(service)

        case let .atOneError(error):
            return .failure(error)

        case let .lazy(factory):
            let result = helper.makeService(factory: factory, params: Void())
            if case let .success(service) = result {
                storage = .instance(service)
            }
            return result
            
        case let .weak(factory, wrapper):
            if let service = wrapper.service {
                return .success(service)
            } else {
                let result = helper.makeService(factory: factory, params: Void())
                if case let .success(service) = result {
                    wrapper.service = service
                }
                return result
            }

        case let .session(storage):
            return storage.getServiceAsResult(helper: helper)

        case let .factory(factory, params):
            return helper.makeService(factory: factory, params: params)
        }
    }

    /// Get Service with detail information throwed error.
    public func getService() throws -> ServiceType {
        return try getServiceAsResult().get()
    }

    /// Get Service if there are no errors.
    public func getServiceAsOptional() -> ServiceType? {
        return try? getServiceAsResult().get()
    }
    
    /// Get Service if there are no errors or fatal when failure obtain.
    public func getServiceOrFatal(file: StaticString = #file, line: UInt = #line) -> ServiceType {
        let result = getServiceAsResult()
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage, file: file, line: line)
        }
    }

    func validateError() throws {
        try storage.validateError()
    }
}

// MARK: - Safe thread
public class ServiceSafeProvider<ServiceType>: ServiceProvider<ServiceType> {
    private let hanlder: ServiceSafeProviderHandler

    /// ServiceProvider with at one instance services.
    public override init(_ service: ServiceType) {
        self.hanlder = .init(kind: nil)
        super.init(service)
    }

    /// ServiceProvider with factory.
    public init<FactoryType: ServiceFactory>(factory: FactoryType, safeThread kind: ServiceSafeProviderKind = .lock) where FactoryType.ServiceType == ServiceType {
        switch factory.mode {
        case .atOne: self.hanlder = .init(kind: nil)
        case .lazy, .weak, .many: self.hanlder = .init(kind: kind)
        }
        super.init(factory: factory)
    }

    /// ServiceProvider with factory, use specific params.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, params: FactoryType.ParamsType, safeThread kind: ServiceSafeProviderKind = .lock) where FactoryType.ServiceType == ServiceType {
        self.hanlder = .init(kind: kind)
        super.init(factory: factory, params: params)
    }

    public init<FactoryType: ServiceSessionFactory, SessionType>(factory: FactoryType, mediator: ServiceSessionMediator<SessionType>, safeThread kind: ServiceSafeProviderKind = .lock) where FactoryType.ServiceType == ServiceType, FactoryType.SessionType == SessionType {
        let handler = ServiceSafeProviderHandler(kind: kind)
        self.hanlder = handler
        super.init(factory: factory) { storage in
            storage.sessionChanged(mediator.session, remakePolicy: .force)
            storage.token = mediator.addObserver { [weak storage, handler] session, remakePolicy in
                handler.safelyHandling {
                    storage?.sessionChanged(session, remakePolicy: remakePolicy)
                }
            }
        }
    }

    init(coreFactory: ServiceCoreFactory, params: Any, handler: ServiceSafeProviderHandler) {
        self.hanlder = handler
        super.init(coreFactory: coreFactory, params: params)
    }

    /// ServiceProvider with factory. If service factoryType == .atOne and throw error when make - throw this error from constructor.
    public convenience init<FactoryType: ServiceFactory>(tryFactory factory: FactoryType, safeThread kind: ServiceSafeProviderKind = .lock) throws where FactoryType.ServiceType == ServiceType {
        self.init(factory: factory, safeThread: kind)
        try validateError()
    }
    
    /// ServiceProvider with many or lazy singleton instance service type, create service in closure.
    public convenience init(lazySingleton: Bool = false, safeThread kind: ServiceSafeProviderKind = .lock, factory: @escaping () throws -> ServiceType) {
        self.init(factory: ServiceClosureFactory(mode: lazySingleton ? .lazy : .many, factory: factory), safeThread: kind)
    }

    /// Get Service with detail information throwed error.
    public override func getServiceAsResult() -> Result<ServiceType, ServiceObtainError> {
        return hanlder.safelyHandling { super.getServiceAsResult() }
    }

    public func getServiceAsResultNotSafe() -> Result<ServiceType, ServiceObtainError> {
        return super.getServiceAsResult()
    }
}

// MARK: - Sessions
private extension ServiceProvider.SessionStorage {
    func findService(key: AnyHashable) -> ServiceType? {
        return mode == .weak ? weakServices[key]?.service : strongServices[key]
    }
    
    func setService(_ service: ServiceType, key: AnyHashable) {
        if mode == .weak {
            weakServices[key] = .init(service: service)
        } else {
            strongServices[key] = service
        }
    }
    
    func removeService(key: AnyHashable) {
        if mode == .weak {
            weakServices.removeValue(forKey: key)
        } else {
            strongServices.removeValue(forKey: key)
        }
    }
    
    func removeAllServices() {
        if mode == .weak {
            weakServices.removeAll()
        } else {
            strongServices.removeAll()
        }
    }
    
    func sessionChanged(_ session: ServiceSession, remakePolicy: ServiceSessionRemakePolicy) {
        let newKey = session.key
        let currentKey = currentSession?.key
        guard remakePolicy != .none || currentKey != newKey else { return }

        //Deactivate old service
        if let currentSession = currentSession, let key = currentKey, let service = findService(key: key) {
            let canUseNext = factory.coreDeactivateService(service, session: currentSession)
            if canUseNext == false {
                removeService(key: key)
            }
        }

        //Process remake
        switch remakePolicy {
        case .none: break
        case .force: removeService(key: newKey)
        case .clearAll: removeAllServices()
        }

        //Activate or make new service
        currentSession = session

        if remakePolicy != .force, let service = findService(key: newKey) {
            factory.coreActivateService(service, session: session)

        } else if mode == .atOne,
            let serviceAny = try? factory.coreMakeService(session: session),
            let service = serviceAny as? ServiceType {
            setService(service, key: newKey)
        }
    }

    func getServiceAsResult(helper: ServiceProviderHelper<ServiceType>) -> Result<ServiceType, ServiceObtainError> {
        guard let session = currentSession else {
            return helper.makeNoSessionFindResult()
        }

        let currentKey = session.key
        if let service = findService(key: currentKey) {
            return .success(service)
        }

        let result = helper.makeSessionService(factory: factory, session: session)
        if case let .success(service) = result {
            setService(service, key: currentKey)
        }
        return result
    }
}

//
//  ServiceProvider.swift
//  ServiceContainerKit/Core 3.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

/// ServiceProvider with information for make service (singleton or many instances)
public class ServiceProvider<ServiceType> {
    private let helper = ServiceProviderHelper<ServiceType>()
    private var storage: Storage
    
    /// ServiceProvider with at one instance services.
    public init(_ service: ServiceType) {
        self.storage = .instance(service)
    }
    
    /// ServiceProvider with simple factory.
    public init<FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        switch factory.mode {
        case .atOne:
            let result = helper.makeService(factory: factory, params: Void())
            switch result {
            case let .success(service):
                self.storage = .instance(service)
            case let .failure(error):
                self.storage = .atOneError(error)
                LogRecorder.serviceProviderMakeFailure(type: ServiceType.self, error: error)
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

    /// ServiceProvider with factory and support service sessions. Use mediator for re-making service in provider.
    public convenience init<FactoryType: ServiceSessionFactory, SessionType>(factory: FactoryType, mediator: ServiceSessionMediator<SessionType>) where FactoryType.ServiceType == ServiceType, FactoryType.SessionType == SessionType {
        self.init(factory: factory) { helper, storage in
            storage.setBeginSessionAndMake(helper: helper, session: mediator.session)
            storage.token = mediator.addObserver { [weak storage, helper] session, remakePolicy, step in
                switch step {
                case .general: storage?.sessionChangedGeneralStep(session, remakePolicy: remakePolicy)
                case .make: storage?.sessionChangedMakeStep(helper: helper, session: session)
                }
            }
        }
    }

    /// Internal constructor for session factory, used also in safe provider.
    fileprivate init<FactoryType: ServiceSessionFactory, SessionType>(
        factory: FactoryType,
        storageConfigurator: (ServiceProviderHelper<ServiceType>, SessionStorage) -> Void
    ) where FactoryType.ServiceType == ServiceType, FactoryType.SessionType == SessionType {
        let storage = SessionStorage(factory: factory, mode: factory.mode)
        self.storage = .session(storage)
        storageConfigurator(helper, storage)
    }

    /// ServiceProvider with factory. If service factoryType == .atOne and throw error when make - throw this error from constructor.
    public convenience init<FactoryType: ServiceFactory>(tryFactory factory: FactoryType) throws where FactoryType.ServiceType == ServiceType {
        self.init(factory: factory)
        try validateAtOneError()
    }
    
    /// ServiceProvider with make service in closure.
    public convenience init(mode: ServiceFactoryMode, factory: @escaping () throws -> ServiceType) {
        self.init(factory: ServiceClosureFactory(mode: mode, factory: factory))
    }
    
    /// Internal constructor for convert providers.
    init(coreFactory: ServiceCoreFactory, params: Any) {
        self.storage = .factory(coreFactory, params: params)
    }
    
    /// If service factoryType == .atOne and throw error when make - throw this error.
    public func validateAtOneError() throws {
        try storage.validateAtOneError()
    }

    // swiftlint:disable cyclomatic_complexity
    /// Get Service with detail information throwed error used `Result`.
    public func getServiceAsResult() -> Result<ServiceType, ServiceObtainError> {
        switch storage {
        case let .instance(service):
            return .success(service)

        case let .atOneError(error):
            return .failure(error)

        case let .lazy(factory):
            let result = helper.makeService(factory: factory, params: Void())
            switch result {
            case let .success(service): storage = .instance(service)
            case let .failure(error): LogRecorder.serviceProviderMakeFailure(type: ServiceType.self, error: error)
            }
            return result
            
        case let .weak(factory, wrapper):
            if let service = wrapper.service {
                return .success(service)
            } else {
                let result = helper.makeService(factory: factory, params: Void())
                switch result {
                case let .success(service): wrapper.service = service
                case let .failure(error): LogRecorder.serviceProviderMakeFailure(type: ServiceType.self, error: error)
                }
                return result
            }

        case let .session(storage):
            return storage.getServiceAsResult(helper: helper)

        case let .factory(factory, params):
            let result = helper.makeService(factory: factory, params: params)
            if case let .failure(error) = result {
                LogRecorder.serviceProviderMakeFailure(type: ServiceType.self, error: error)
            }
            return result
        }
    }
    // swiftlint:enable cyclomatic_complexity

    /// Get Service with detail information throwed error.
    public func getService() throws -> ServiceType {
        return try getServiceAsResult().get()
    }

    /// Get Service if there are no errors.
    public func getServiceAsOptional() -> ServiceType? {
        return try? getServiceAsResult().get()
    }
    
    /// Get Service if there are no errors or fatal with debug details when failure obtain.
    public func getServiceOrFatal(file: StaticString = #file, line: UInt = #line) -> ServiceType {
        let result = getServiceAsResult()
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage, file: file, line: line)
        }
    }
}

// MARK: Safe thread
public class ServiceSafeProvider<ServiceType>: ServiceProvider<ServiceType> {
    private let handler: ServiceSafeProviderHandler

    /// ServiceProvider with at one instance services.
    public override init(_ service: ServiceType) {
        self.handler = .init(kind: nil)
        super.init(service)
    }

    /// ServiceProvider with factory.
    public init<FactoryType: ServiceFactory>(factory: FactoryType, safeThread kind: ServiceSafeProviderKind = .default) where FactoryType.ServiceType == ServiceType {
        switch factory.mode {
        case .atOne: self.handler = .init(kind: nil)
        case .lazy, .weak, .many: self.handler = .init(kind: kind)
        }
        super.init(factory: factory)
    }

    /// ServiceProvider with factory, use specific params.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, params: FactoryType.ParamsType, safeThread kind: ServiceSafeProviderKind = .default) where FactoryType.ServiceType == ServiceType {
        self.handler = .init(kind: kind)
        super.init(factory: factory, params: params)
    }

    /// ServiceProvider with factory and support service sessions. Use mediator for re-making service in provider.
    public init<FactoryType: ServiceSessionFactory, SessionType>(factory: FactoryType, mediator: ServiceSessionMediator<SessionType>, safeThread kind: ServiceSafeProviderKind = .default) where FactoryType.ServiceType == ServiceType, FactoryType.SessionType == SessionType {
        let handler = ServiceSafeProviderHandler(kind: kind)
        self.handler = handler
        super.init(factory: factory) { helper, storage in
            storage.setBeginSessionAndMake(helper: helper, session: mediator.session)
            storage.token = mediator.addObserver { [weak storage, handler, helper] session, remakePolicy, step in
                handler.safelyHandling {
                    switch step {
                    case .general: storage?.sessionChangedGeneralStep(session, remakePolicy: remakePolicy)
                    case .make: storage?.sessionChangedMakeStep(helper: helper, session: session)
                    }
                }
            }
        }
    }

    /// ServiceProvider with factory. If service factoryType == .atOne and throw error when make - throw this error from constructor.
    public convenience init<FactoryType: ServiceFactory>(tryFactory factory: FactoryType, safeThread kind: ServiceSafeProviderKind = .default) throws where FactoryType.ServiceType == ServiceType {
        self.init(factory: factory, safeThread: kind)
        try validateAtOneError()
    }
    
    /// ServiceProvider with many or lazy singleton instance service type, create service in closure.
    public convenience init(mode: ServiceFactoryMode, safeThread kind: ServiceSafeProviderKind = .default, factory: @escaping () throws -> ServiceType) {
        self.init(factory: ServiceClosureFactory(mode: mode, factory: factory), safeThread: kind)
    }
    
    /// Internal constructor for convert providers.
    init(coreFactory: ServiceCoreFactory, params: Any, handler: ServiceSafeProviderHandler) {
        self.handler = handler
        super.init(coreFactory: coreFactory, params: params)
    }

    /// Get Service in safe thread mode with detail information throwed error.
    public override func getServiceAsResult() -> Result<ServiceType, ServiceObtainError> {
        return handler.safelyHandling { super.getServiceAsResult() }
    }

    /// Get Service in unsafe thread mode with detail information throwed error.
    public func getServiceAsResultNotSafe() -> Result<ServiceType, ServiceObtainError> {
        return super.getServiceAsResult()
    }
}

// MARK: - Private
private extension ServiceProvider {
    enum Storage {
        case instance(ServiceType)
        case atOneError(ServiceObtainError)
        case lazy(ServiceCoreFactory)
        case weak(ServiceCoreFactory, ServiceWeakWrapper)
        case session(SessionStorage)
        case factory(ServiceCoreFactory, params: Any)

        func validateAtOneError() throws {
            switch self {
            case .atOneError(let error): throw error
            case .session(let storage): try storage.validateAtOneError()
            default: return
            }
        }
    }
    
    final class ServiceWeakWrapper {
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

    final class SessionStorage {
        let factory: ServiceSessionCoreFactory
        let mode: ServiceSessionFactoryMode
        var token: ServiceSessionMediatorToken?
        var currentSession: ServiceSession?
        
        var atOneError: ServiceObtainError?
        var strongServices: [AnyHashable: ServiceType] = [:]
        var weakServices: [AnyHashable: ServiceWeakWrapper] = [:]

        init(factory: ServiceSessionCoreFactory, mode: ServiceSessionFactoryMode) {
            self.factory = factory
            self.mode = mode
        }
        
        func validateAtOneError() throws {
            if let error = atOneError {
                throw error
            }
        }
    }
}

// MARK: Sessions
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
    
    func setBeginSessionAndMake(helper: ServiceProviderHelper<ServiceType>, session: ServiceSession) {
        currentSession = session
        sessionChangedMakeStep(helper: helper, session: session)
    }
    
    func sessionChangedGeneralStep(_ session: ServiceSession, remakePolicy: ServiceSessionRemakePolicy) {
        let newKey = session.key
        let currentKey = currentSession?.key
        guard remakePolicy != .none || currentKey != newKey || atOneError != nil else { return }

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

        //Activate service
        currentSession = session
        atOneError = nil
        
        if remakePolicy != .force, let service = findService(key: newKey) {
            factory.coreActivateService(service, session: session)
        }
    }
    
    func sessionChangedMakeStep(helper: ServiceProviderHelper<ServiceType>, session: ServiceSession) {
        guard mode == .atOne else { return }
        
        let key = session.key
        guard findService(key: key) == nil else { return }
        
        let result = helper.makeSessionService(factory: factory, session: session)
        switch result {
        case let .success(service):
            setService(service, key: key)
            
        case let .failure(error):
            self.atOneError = error
            LogRecorder.serviceProviderMakeFailure(type: ServiceType.self, error: error)
        }
    }

    func getServiceAsResult(helper: ServiceProviderHelper<ServiceType>) -> Result<ServiceType, ServiceObtainError> {
        guard let session = currentSession else {
            let error = helper.makeNoSessionFindError()
            LogRecorder.serviceProviderMakeFailure(type: ServiceType.self, error: error)
            return .failure(error)
        }

        let currentKey = session.key
        if let service = findService(key: currentKey) {
            return .success(service)
        } else if mode == .atOne, let error = atOneError {
            return .failure(error)
        }

        let result = helper.makeSessionService(factory: factory, session: session)
        switch result {
        case .success(let service):
            setService(service, key: currentKey)
        case .failure(let error):
            LogRecorder.serviceProviderMakeFailure(type: ServiceType.self, error: error)
        }
        return result
    }
}

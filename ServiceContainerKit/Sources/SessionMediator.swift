//
//  SessionMediator.swift
//  ServiceContainerKit/Core 3.0.0
//
//  Created by Vitalii Korotkii on 05.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

/// Simple session, used to signal the re-making of services without saving the previous instances.
public struct ServiceVoidSession: ServiceSession {
    public let key: AnyHashable = ""
}

/// Re-making policy service
public enum ServiceSessionRemakePolicy {
    /// Save the previous instances or use current when key not changed.
    case none
    
    /// Force re-making service without save the previous instances.
    case force
    
    /// Prepare make new service, remove all previous instances for all keys.
    case clearAll
}

/// Session mediator for only send signal the re-making of services without saving the previous instances.
open class ServiceVoidSessionMediator: ServiceSessionMediator<ServiceVoidSession> {
    public init() {
        super.init(session: .init())
    }
    
    /// Remake all dependency services from this mediator.
    public func clearServices() {
        updateSession(.init(), remakePolicy: .clearAll)
    }
}

/// Mediator for dependency services to send a signal about the need to re-making the service.
open class ServiceSessionMediator<S: ServiceSession> {
    typealias Observer = (S, ServiceSessionRemakePolicy, ServiceSessionMediatorPerformStep) -> Void
    
    private let lock = NSLock()
    private var observers: [ObserverWrapper] = []
    private var currentSession: S

    /// Current session
    public var session: ServiceSession {
        lock.lock()
        defer { lock.unlock() }
        return currentSession
    }

    public init(session: S) {
        self.currentSession = session
    }

    /// Send signal for dependency services about current session is changed and remake services if needed.
    public func updateSession(_ session: S, remakePolicy: ServiceSessionRemakePolicy = .none) {
        lock.lock()
        self.currentSession = session
        self.observers = self.observers.filter { $0.token != nil }
        let observers = self.observers
        lock.unlock()

        observers.forEach { $0.token?.observer(session, remakePolicy, .general) }
        observers.forEach { $0.token?.observer(session, remakePolicy, .make) }
    }

    func addObserver(_ observer: @escaping Observer) -> ServiceSessionMediatorToken {
        lock.lock()
        defer { lock.unlock() }

        let token = Token(observer)
        self.observers = self.observers.filter { $0.token != nil }
        self.observers.append(.init(token: token))
        return token
    }
    
    // MARK: Private
    private final class Token: ServiceSessionMediatorToken {
        let observer: Observer
        init(_ observer: @escaping Observer) {
            self.observer = observer
        }
    }

    private final class ObserverWrapper {
        weak var token: Token?
        init(token: Token) {
            self.token = token
        }
    }
}

// MARK: Internal
protocol ServiceSessionMediatorToken: class { }

enum ServiceSessionMediatorPerformStep: Int {
    case general = 1
    case make = 2
}

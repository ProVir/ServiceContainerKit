//
//  SessionMediator.swift
//  ServiceContainerKit/ServiceProvider 3.0.0
//
//  Created by Vitalii Korotkii on 05.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public struct ServiceVoidSession: ServiceSession {
    public let key: AnyHashable = ""
}

protocol ServiceSessionMediatorToken: class { }

public enum ServiceSessionRemakePolicy {
    case none
    case force
    case clearAll
}

open class ServiceVoidSessionMediator: ServiceSessionMediator<ServiceVoidSession> {
    public func clearServices() {
        updateSession(.init(), remakePolicy: .clearAll)
    }
}

open class ServiceSessionMediator<ServiceSession> {
    private final class Token: ServiceSessionMediatorToken {
        let observer: (ServiceSession, ServiceSessionRemakePolicy) -> Void
        init(_ observer: @escaping (ServiceSession, ServiceSessionRemakePolicy) -> Void) {
            self.observer = observer
        }
    }

    private final class ObserverWrapper {
        weak var token: Token?
        init(token: Token) {
            self.token = token
        }
    }

    private let lock = NSLock()
    private var observers: [ObserverWrapper] = []
    private var currentSession: ServiceSession

    public var session: ServiceSession {
        lock.lock()
        defer { lock.unlock() }
        return currentSession
    }

    public init(session: ServiceSession) {
        self.currentSession = session
    }

    public func updateSession(_ session: ServiceSession, remakePolicy: ServiceSessionRemakePolicy = .none) {
        lock.lock()
        self.currentSession = session
        self.observers = self.observers.filter { $0.token != nil }
        let observers = self.observers
        lock.unlock()

        observers.forEach { $0.token?.observer(session, remakePolicy) }
    }

    func addObserver(_ observer: @escaping (ServiceSession, ServiceSessionRemakePolicy) -> Void) -> ServiceSessionMediatorToken {
        lock.lock()
        defer { lock.unlock() }

        let token = Token(observer)
        self.observers = self.observers.filter { $0.token != nil }
        self.observers.append(.init(token: token))
        return token
    }
}


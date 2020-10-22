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

enum ServiceSessionMediatorPerformStep: Int {
    case general = 1
    case make = 2
}

public enum ServiceSessionRemakePolicy {
    case none
    case force
    case clearAll
}

open class ServiceVoidSessionMediator: ServiceSessionMediator<ServiceVoidSession> {
    public init() {
        super.init(session: .init())
    }
    
    public func clearServices() {
        updateSession(.init(), remakePolicy: .clearAll)
    }
}

open class ServiceSessionMediator<S: ServiceSession> {
    typealias Observer = (S, ServiceSessionRemakePolicy, ServiceSessionMediatorPerformStep) -> Void
    
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

    private let lock = NSLock()
    private var observers: [ObserverWrapper] = []
    private var currentSession: S

    public var session: ServiceSession {
        lock.lock()
        defer { lock.unlock() }
        return currentSession
    }

    public init(session: S) {
        self.currentSession = session
    }

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
}

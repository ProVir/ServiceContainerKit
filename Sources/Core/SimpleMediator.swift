//
//  SimpleMediator.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 08.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public protocol MediatorToken: class { }

// MARK: SimpleMediator
public final class SimpleMediator<T> {
    private let mediator = MultipleMediator()
    
    public init() { }
    
    @discardableResult
    public func notify(_ entity: T) -> Bool {
        return mediator.notify(entity)
    }
    
    public func observe(once: Bool, handler: @escaping (T) -> Void) -> MediatorToken {
        return mediator.observe(T.self, once: once, handler: handler)
    }
}

// MARK: MultipleMediator
private protocol MultipleMediatorInternalToken: MediatorToken {
    func notify(_ entity: Any) -> Bool
}

public final class MultipleMediator {
    private var observers: [ObserverWrapper] = []
    
    public init() { }
    
    @discardableResult
    public func notify<T>(_ entity: T) -> Bool {
        var isNotifiedResult = false
        observers = observers.filter {
            let isNotified = $0.handle(entity)
            if isNotified {
                isNotifiedResult = true
            }
            return $0.isValid
        }
        return isNotifiedResult
    }
    
    @discardableResult
    public func notifySome(_ list: [Any]) -> Bool {
        var isNotifiedResult = false
        observers = observers.filter {
            for entity in list {
                let isNotified = $0.handle(entity)
                if isNotified {
                    isNotifiedResult = true
                }
            }
            return $0.isValid
        }
        return isNotifiedResult
    }
    
    public func observe<T>(_ type: T.Type, once: Bool, handler: @escaping (T) -> Void) -> MediatorToken {
        let token = Token(handler)
        observers.append(.init(token, once: once))
        return token
    }
    
    private final class Token<T>: MultipleMediatorInternalToken {
        private let handler: (T) -> Void
        
        init(_ handler: @escaping (T) -> Void) {
            self.handler = handler
        }
        
        func notify(_ entity: Any) -> Bool {
            if let entity = entity as? T {
                handler(entity)
                return true
            } else {
                return false
            }
        }
    }
    
    private final class ObserverWrapper {
        private let once: Bool
        private weak var token: MultipleMediatorInternalToken?
        
        init(_ token: MultipleMediatorInternalToken, once: Bool) {
            self.token = token
            self.once = once
        }
        
        var isValid: Bool { token != nil }
        
        func handle(_ entity: Any) -> Bool {
            guard let token = token else {
                return false
            }
            let isNotified = token.notify(entity)
            if once && isNotified {
                self.token = nil
            }
            return isNotified
        }
    }
}

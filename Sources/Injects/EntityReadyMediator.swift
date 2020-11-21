//
//  EntityReadyMediator.swift
//  ServiceContainerKit/Injects 3.0.0
//
//  Created by Короткий Виталий on 21.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public protocol EntityReadyToken: class { }

/// Mediator for wait to ready Container with services or Entity
final class EntityReadyMediator {
    private var observers: [ObserverWrapper] = []
    
    /// Notify to ready entity
    @discardableResult
    func notify<T>(_ entity: T) -> Bool {
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
    
    /// Notify to ready some entities
    @discardableResult
    func notifySome(_ list: [Any]) -> Bool {
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
    
    /// Subscribe to wait ready entity
    func observeOnce<T>(_ type: T.Type, handler: @escaping (T) -> Void) -> EntityReadyToken {
        let token = Token(handler)
        observers.append(.init(token))
        return token
    }
    
    // MARK: - Private
    private final class Token<T>: EntityReadyInternalToken {
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
        private weak var token: EntityReadyInternalToken?
        
        init(_ token: EntityReadyInternalToken) {
            self.token = token
        }
        
        var isValid: Bool { token != nil }
        
        func handle(_ entity: Any) -> Bool {
            guard let token = token else {
                return false
            }
            let isNotified = token.notify(entity)
            if isNotified {
                self.token = nil
            }
            return isNotified
        }
    }
}

private protocol EntityReadyInternalToken: EntityReadyToken {
    func notify(_ entity: Any) -> Bool
}

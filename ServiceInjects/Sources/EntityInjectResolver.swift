//
//  EntityInjectResolver.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 02.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

/// Token for register entity
public protocol EntityInjectToken: class { }

/// Token for subscribe ready entity
public typealias EntityInjectReadyToken = EntityReadyToken

public extension EntityInjectResolver {
    /// Register entity as shared and notify for ready to injects. Removed when token if lost.
    static func register<Entity>(_ entity: Entity) -> EntityInjectToken {
        return shared.register(entity)
    }
    /// Register entity as shared and notify for ready to injects. Removed after first use, but real removed in next loop in main thread.
    /// If `autoRemoveDelay != nil` - auto removed after delay if not used.
    static func registerForFirstInject<Entity>(_ entity: Entity, autoRemoveDelay: TimeInterval? = nil) {
        shared.registerForFirstInject(entity, autoRemoveDelay: autoRemoveDelay)
    }
    
    /// Register some entities as shared and notify for ready to injects. Removed when tokens if lost.
    static func registerSome(_ entities: [Any]) -> [EntityInjectToken] {
        return shared.registerSome(entities)
    }
    
    /// Register some entities as shared and notify for ready to injects. Removed after first use, but real removed in next loop in main thread.
    /// If `autoRemoveDelay != nil` - auto removed after delay if not used.
    static func registerForFirstInjectSome(_ entities: [Any], autoRemoveDelay: TimeInterval? = nil) {
        shared.registerForFirstInjectSome(entities, autoRemoveDelay: autoRemoveDelay)
    }
    
    /// Remove (unregister) entity.
    static func remove<Entity>(_ type: Entity.Type) {
        shared.remove(type)
    }

    /// Subscribe ready entity for use, called now and return nil token if ready.
    static func addReadyContainerHandler<Entity>(_ type: Entity.Type, handler: @escaping () -> Void) -> EntityInjectReadyToken? {
        return shared.addReadyContainerHandler(type, handler: handler)
    }
    
    /// If registered entity, returned true.
    static func contains<Entity>(_ type: Entity.Type) -> Bool {
        return shared.contains(type)
    }
}

// MARK: Internal
extension EntityInjectResolver {
    static func resolve<Entity>(_ type: Entity.Type) -> Entity? {
        return shared.resolve(type)
    }
    
    static func observeOnce<Entity>(_ type: Entity.Type, handler: @escaping (Entity) -> Void) -> EntityInjectReadyToken {
        return shared.observeOnce(type, handler: handler)
    }
}

extension EntityInjectResolver {
    static func removeAllForTests() {
        shared.removeAll()
    }
}

/// Resolver entities for `EntityInject`. Used for register entities.
public final class EntityInjectResolver {
    fileprivate static let shared = EntityInjectResolver()
    
    private let mediator = EntityReadyMediator()
    private let userMediator = EntityReadyMediator()
    private var list: [EntityWrapper] = []
    
    private init() { }
    
    func register<Entity>(_ entity: Entity) -> EntityInjectToken {
        let token = Token(entity)
        list.append(.init(token, forFirstInject: false))
        mediator.notify(entity)
        userMediator.notify(entity)
        return token
    }
    
    func registerForFirstInject<Entity>(_ entity: Entity, autoRemoveDelay: TimeInterval?) {
        registerForFirstInjectAny(entity, autoRemoveDelay: autoRemoveDelay)
    }
    
    func registerSome(_ entities: [Any]) -> [EntityInjectToken] {
        let tokens: [EntityInjectToken] = entities.map {
            let token = Token($0)
            list.append(.init(token, forFirstInject: false))
            return token
        }
        mediator.notifySome(entities)
        userMediator.notifySome(entities)
        return tokens
    }
    
    func registerForFirstInjectSome(_ entities: [Any], autoRemoveDelay: TimeInterval?) {
        entities.forEach {
            registerForFirstInjectAny($0, autoRemoveDelay: autoRemoveDelay)
        }
    }
    
    func remove<Entity>(_ type: Entity.Type) {
        list = list.filter {
            if $0.isValid, let token = $0.token {
                return (token.entity is Entity) == false
            } else {
                return false
            }
        }
    }
    
    func removeAll() {
        list = []
    }
    
    func resolve<Entity>(_ type: Entity.Type) -> Entity? {
        clearInvalids()
        for wrapper in list.reversed() {
            if let entity = wrapper.token?.entity as? Entity {
                wrapper.clearTokenIfNeeded()
                return entity
            }
        }
        return nil
    }
    
    func observeOnce<Entity>(_ type: Entity.Type, handler: @escaping (Entity) -> Void) -> EntityInjectReadyToken {
        return mediator.observeOnce(type, handler: handler)
    }
    
    func addReadyContainerHandler<Entity>(_ type: Entity.Type, handler: @escaping () -> Void) -> EntityInjectReadyToken? {
        if resolve(type) != nil {
            handler()
            return nil
        } else {
            return userMediator.observeOnce(type) { _ in handler() }
        }
    }
    
    func contains<Entity>(_ type: Entity.Type) -> Bool {
        return list.contains(where: { $0.token?.entity is Entity })
    }
    
    // MARK: Private
    private func registerForFirstInjectAny(_ entity: Any, autoRemoveDelay: TimeInterval?) {
        let token = Token(entity)
        let wrapper = EntityWrapper(token, forFirstInject: true)
        list.append(wrapper)
        let isNotified = mediator.notify(entity)
        userMediator.notify(entity)
        
        if isNotified {
            wrapper.clearTokenIfNeeded()
            
        } else if let delay = autoRemoveDelay {
            let entityType = type(of: entity)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak wrapper] in
                let isCleared = wrapper?.clearTokenIfNeeded() ?? false
                if isCleared {
                    LogRecorder.entityInjectResolverDidAutoRemove(entityType: entityType, delay: delay)
                }
            }
        }
    }
    
    private func clearInvalids() {
        list = list.filter { $0.isValid }
    }
    
    private final class Token: EntityInjectToken {
        let entity: Any
        init(_ entity: Any) { self.entity = entity }
    }
    
    private final class EntityWrapper {
        private(set) weak var token: Token?
        
        private var forFirstInjectToken: Token?
        private var allowClearToken: Bool
        
        init(_ token: Token, forFirstInject: Bool) {
            self.token = token
            self.allowClearToken = forFirstInject
            if forFirstInject {
                forFirstInjectToken = token
            }
        }
        
        var isValid: Bool { token != nil }
        
        @discardableResult
        func clearTokenIfNeeded() -> Bool {
            guard allowClearToken else {
                return false
            }
            
            allowClearToken = false
            DispatchQueue.main.async { [weak self] in
                self?.token = nil
                self?.forFirstInjectToken = nil
            }
            return true
        }
    }
}

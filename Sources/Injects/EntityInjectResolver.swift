//
//  EntityInjectResolver.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 02.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public typealias EntityInjectToken = EntityReadyToken

public extension EntityInjectResolver {
    static func register<Entity>(_ entity: Entity) -> EntityInjectToken {
        return shared.register(entity)
    }
    
    static func registerForFirstInject<Entity>(_ entity: Entity, autoRemoveDelay: TimeInterval? = nil) {
        shared.registerForFirstInject(entity, autoRemoveDelay: autoRemoveDelay)
    }
    
    static func registerSome(_ entities: [Any]) -> [EntityInjectToken] {
        return shared.registerSome(entities)
    }
    
    static func registerForFirstInjectSome(_ entities: [Any], autoRemoveDelay: TimeInterval? = nil) {
        shared.registerForFirstInjectSome(entities, autoRemoveDelay: autoRemoveDelay)
    }
    
    static func remove<Entity>(_ type: Entity.Type) {
        shared.remove(type)
    }

    static func addReadyContainerHandler<Entity>(_ type: Entity.Type, handler: @escaping () -> Void) -> EntityInjectToken? {
        return shared.addReadyContainerHandler(type, handler: handler)
    }
    
    static func contains<Entity>(_ type: Entity.Type) -> Bool {
        return shared.contains(type)
    }
}

// MARK: Internal
extension EntityInjectResolver {
    static func resolve<Entity>(_ type: Entity.Type) -> Entity? {
        return shared.resolve(type)
    }
    
    static func observeOnce<Entity>(_ type: Entity.Type, handler: @escaping (Entity) -> Void) -> EntityInjectToken {
        return shared.observeOnce(type, handler: handler)
    }
}

extension EntityInjectResolver {
    static func removeAllForTests() {
        shared.removeAll()
    }
}

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
    
    func observeOnce<Entity>(_ type: Entity.Type, handler: @escaping (Entity) -> Void) -> EntityInjectToken {
        return mediator.observeOnce(type, handler: handler)
    }
    
    func addReadyContainerHandler<Entity>(_ type: Entity.Type, handler: @escaping () -> Void) -> EntityInjectToken? {
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
    
    private final class Token: EntityInjectToken {
        let entity: Any
        init(_ entity: Any) { self.entity = entity }
    }
}

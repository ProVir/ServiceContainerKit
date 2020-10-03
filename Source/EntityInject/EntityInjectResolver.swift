//
//  EntityInjectResolver.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 02.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public typealias EntityInjectToken = MultipleMediatorToken

public extension EntityInjectResolver {
    static func register<Entity>(_ entity: Entity) -> EntityInjectToken {
        return shared.register(entity)
    }
    
    static func registerForFirstInject<Entity>(_ entity: Entity, autoRemoveDelay: TimeInterval?) {
        shared.registerForFirstInject(entity, autoRemoveDelay: autoRemoveDelay)
    }
    
    static func registerSome(_ entities: [Any]) -> [EntityInjectToken] {
        return shared.registerSome(entities)
    }
    
    static func registerForFirstInjectSome(_ entities: [Any], autoRemoveDelay: TimeInterval?) {
        shared.registerForFirstInjectSome(entities, autoRemoveDelay: autoRemoveDelay)
    }

    static func addReadyContainerHandler<Entity>(_ type: Entity.Type, handler: @escaping () -> Void) -> EntityInjectToken? {
        return shared.addReadyContainerHandler(type, handler: handler)
    }
}


// MARK: Internal
extension EntityInjectResolver {
    static func resolve<Entity>(_ type: Entity.Type) -> Entity? {
        return shared.resolve(type)
    }
    
    static func observe<Entity>(_ type: Entity.Type, handler: @escaping (Entity) -> Void) -> EntityInjectToken {
        return shared.observe(type, handler: handler)
    }
}

public final class EntityInjectResolver {
    static let shared = EntityInjectResolver()
    
    private let mediator = MultipleMediator()
    private let userMediator = MultipleMediator()
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
    
    func removeAll<Entity>(_ entity: Entity) {
        list = list.filter {
            if $0.isValid, let token = $0.token {
                return (token.entity is Entity) == false
            } else {
                return false
            }
        }
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
    
    func observe<Entity>(_ type: Entity.Type, handler: @escaping (Entity) -> Void) -> EntityInjectToken {
        return mediator.observe(type, single: true, handler: handler)
    }
    
    func addReadyContainerHandler<Entity>(_ type: Entity.Type, handler: @escaping () -> Void) -> EntityInjectToken? {
        if resolve(type) != nil {
            handler()
            return nil
        } else {
            return userMediator.observe(type, single: true) { _ in handler() }
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak wrapper] in
                wrapper?.clearTokenIfNeeded()
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
        
        func clearTokenIfNeeded() {
            if allowClearToken {
                allowClearToken = false
                DispatchQueue.main.async { [weak self] in
                    self?.token = nil
                    self?.forFirstInjectToken = nil
                }
            }
        }
    }
    
    private final class Token: EntityInjectToken {
        let entity: Any
        init(_ entity: Any) { self.entity = entity }
    }
}

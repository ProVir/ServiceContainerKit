//
//  ServiceInjectResolver.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 08.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public typealias ServiceInjectToken = EntityReadyToken

public extension ServiceInjectResolver {
    static func register<Container>(_ container: Container, failureIfContains: Bool = true) {
        shared.register(container, failureIfContains: failureIfContains)
    }
    
    static func registerSome(_ containers: [Any], failureIfContains: Bool = true) {
        shared.registerSome(containers, failureIfContains: failureIfContains)
    }
    
    static func remove<Container>(_ type: Container.Type, onlyLast: Bool = false) {
        shared.remove(type, onlyLast: onlyLast)
    }
    
    static func addReadyContainerHandler<Container>(_ type: Container.Type, handler: @escaping () -> Void) -> ServiceInjectToken? {
        return shared.addReadyContainerHandler(type, handler: handler)
    }
    
    static func contains<Container>(_ type: Container.Type) -> Bool {
        return shared.contains(type)
    }
}


// MARK: Internal
extension ServiceInjectResolver {
    static func resolve<Container>(_ type: Container.Type) -> Container? {
        return shared.resolve(type)
    }
    
    static func observeOnce<Container>(_ type: Container.Type, handler: @escaping (Container) -> Void) -> ServiceInjectToken {
        return shared.observeOnce(type, handler: handler)
    }
}

extension ServiceInjectResolver {
    static func removeAllForTests() {
        shared.removeAll()
    }
    
    static func containsSomeForTests(_ containers: [Any]) -> Bool {
        return shared.containsSome(containers)
    }
}

public final class ServiceInjectResolver {
    fileprivate static let shared = ServiceInjectResolver()
    
    private let mediator = EntityReadyMediator()
    private let userMediator = EntityReadyMediator()
    private var list: [Any] = []
    
    private init() { }
    
    func register<Container>(_ container: Container, failureIfContains: Bool) {
        if failureIfContains {
            assert(contains(Container.self) == false, "Register container already exists")
        }
        
        list.append(container)
        mediator.notify(container)
        userMediator.notify(container)
    }
    
    func registerSome(_ containers: [Any], failureIfContains: Bool) {
        if failureIfContains {
            assert(containsSome(containers) == false, "Register containers already exists")
        }
        
        list += containers
        mediator.notifySome(containers)
        userMediator.notifySome(containers)
    }
    
    func remove<Container>(_ type: Container.Type, onlyLast: Bool) {
        if onlyLast {
            if let index = list.lastIndex(where: { $0 is Container }) {
                list.remove(at: index)
            }
        } else {
            list = list.filter { ($0 is Container) == false }
        }
    }
    
    func removeAll() {
        list = []
    }
    
    func resolve<Container>(_ type: Container.Type) -> Container? {
        for entry in list.reversed() {
            if let container = entry as? Container {
                return container
            }
        }
        return nil
    }
    
    func observeOnce<Container>(_ type: Container.Type, handler: @escaping (Container) -> Void) -> ServiceInjectToken {
        return mediator.observeOnce(type, handler: handler)
    }
    
    func addReadyContainerHandler<Container>(_ type: Container.Type, handler: @escaping () -> Void) -> ServiceInjectToken? {
        if resolve(type) != nil {
            handler()
            return nil
        } else {
            return userMediator.observeOnce(type) { _ in handler() }
        }
    }
    
    func contains<Container>(_ type: Container.Type) -> Bool {
        return list.contains(where: { $0 is Container })
    }
    
    func containsSome(_ containers: [Any]) -> Bool {
        let listTypes = list.map { type(of: $0) }
        for entity in containers {
            let typeEntity = type(of: entity)
            if listTypes.contains(where: { $0 == typeEntity }) {
                return true
            }
        }
        return false
    }
}

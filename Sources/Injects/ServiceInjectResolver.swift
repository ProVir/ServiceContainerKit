//
//  ServiceInjectResolver.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 08.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

/// Token for subscribe ready container
public typealias ServiceInjectReadyToken = EntityReadyToken

public extension ServiceInjectResolver {
    /// Register container with services as shared and notify for ready to injects.
    static func register<Container>(_ container: Container, failureIfContains: Bool = true) {
        shared.register(container, failureIfContains: failureIfContains)
    }
    
    /// Register some containers with services as shared and notify for ready to injects.
    static func registerSome(_ containers: [Any], failureIfContains: Bool = true) {
        shared.registerSome(containers, failureIfContains: failureIfContains)
    }
    
    /// Remove (unregister) container.
    static func remove<Container>(_ type: Container.Type, onlyLast: Bool = false) {
        shared.remove(type, onlyLast: onlyLast)
    }
    
    /// Subscribe ready container for use, called now and return nil token if ready.
    static func addReadyContainerHandler<Container>(_ type: Container.Type, handler: @escaping () -> Void) -> ServiceInjectReadyToken? {
        return shared.addReadyContainerHandler(type, handler: handler)
    }
    
    /// If registered container, returned true.
    static func contains<Container>(_ type: Container.Type) -> Bool {
        return shared.contains(type)
    }
}

// MARK: Internal
extension ServiceInjectResolver {
    static func resolve<Container>(_ type: Container.Type) -> Container? {
        return shared.resolve(type)
    }
    
    static func observeOnce<Container>(_ type: Container.Type, handler: @escaping (Container) -> Void) -> ServiceInjectReadyToken {
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

/// Resolver containers for `ServiceInject` and `ServiceParamsInject`. Used for register containers with services.
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
    
    func observeOnce<Container>(_ type: Container.Type, handler: @escaping (Container) -> Void) -> ServiceInjectReadyToken {
        return mediator.observeOnce(type, handler: handler)
    }
    
    func addReadyContainerHandler<Container>(_ type: Container.Type, handler: @escaping () -> Void) -> ServiceInjectReadyToken? {
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

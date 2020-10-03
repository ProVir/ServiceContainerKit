//
//  ServiceInjectResolver.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 08.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public extension ServiceInjectResolver {
    static func register<Container>(container: Container) {
        shared.register(container)
    }
    
    static func registerSome(containers: [Any]) {
        shared.register(containers)
    }
    
    static func remove<Container>(container: Container) {
        shared.remove(container: container)
    }
    
    static func addReadyContainerHandler<Container>(_ type: Container.Type, handler: @escaping () -> Void) -> ServiceInjectToken? {
        return shared.addReadyContainerHandler(type, handler: handler)
    }
}


// MARK: Internal
public typealias ServiceInjectToken = MultipleMediatorToken

extension ServiceInjectResolver {
    static func resolve<Container>(_ type: Container.Type) -> Container? {
        return shared.resolve(type)
    }
    
    static func observe<Container>(_ type: Container.Type, handler: @escaping (Container) -> Void) -> ServiceInjectToken {
        return shared.observe(type, handler: handler)
    }
}

public final class ServiceInjectResolver {
    static let shared = ServiceInjectResolver()
    
    private let mediator = MultipleMediator()
    private let userMediator = MultipleMediator()
    private var list: [Any] = []
    
    private init() { }
    
    func register<Container>(_ container: Container) {
        list.append(container)
        mediator.notify(container)
        userMediator.notify(container)
    }
    
    func registerSome(_ containers: [Any]) {
        list += containers
        mediator.notifySome(containers)
        userMediator.notifySome(containers)
    }
    
    func remove<Container>(container: Container) {
        list = list.filter { ($0 is Container) == false }
    }
    
    func resolve<Container>(_ type: Container.Type) -> Container? {
        for entry in list.reversed() {
            if let container = entry as? Container {
                return container
            }
        }
        return nil
    }
    
    func observe<Container>(_ type: Container.Type, handler: @escaping (Container) -> Void) -> ServiceInjectToken {
        return mediator.observe(type, single: true, handler: handler)
    }
    
    func addReadyContainerHandler<Container>(_ type: Container.Type, handler: @escaping () -> Void) -> ServiceInjectToken? {
        if resolve(type) != nil {
            handler()
            return nil
        } else {
            return userMediator.observe(type, single: true) { _ in handler() }
        }
    }
}

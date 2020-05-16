//
//  ServiceInjectResolver.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 08.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public extension ServiceInjectResolver {
    static func register<ContainerType>(container: ContainerType) {
        ServiceInjectResolver.shared.register(container)
    }
    
    static func registerSome(containers: [Any]) {
        ServiceInjectResolver.shared.register(containers)
    }
    
    static func removeAll<ContainerType>(container: ContainerType) {
        ServiceInjectResolver.shared.removeAll(container)
    }
    
    static func setReadyContainerHandler<T>(_ type: T.Type, handler: @escaping () -> Void) -> ServiceInjectToken? {
        return shared.setReadyContainerHandler(type, handler: handler)
    }
}


// MARK: Internal
public typealias ServiceInjectToken = MultipleMediatorToken

extension ServiceInjectResolver {
    static func resolve<ContainerType>(_ type: ContainerType.Type) -> ContainerType? {
        return shared.resolve(type)
    }
    
    static func observe<T>(_ type: T.Type, handler: @escaping (T) -> Void) -> ServiceInjectToken {
        return shared.observe(type, handler: handler)
    }
}

public final class ServiceInjectResolver {
    static let shared = ServiceInjectResolver()
    
    private let mediator = MultipleMediator()
    private let userMediator = MultipleMediator()
    private var list: [Any] = []
    
    private init() { }
    
    func register<ContainerType>(_ container: ContainerType) {
        list.append(container)
        mediator.notify(container)
        userMediator.notify(container)
    }
    
    func registerSome(_ containers: [Any]) {
        list += containers
        mediator.notifySome(containers)
        userMediator.notifySome(containers)
    }
    
    func removeAll<ContainerType>(_ container: ContainerType) {
        list = list.filter { ($0 is ContainerType) == false }
    }
    
    func resolve<ContainerType>(_ type: ContainerType.Type) -> ContainerType? {
        for entry in list {
            if let container = entry as? ContainerType {
                return container
            }
        }
        return nil
    }
    
    func observe<T>(_ type: T.Type, handler: @escaping (T) -> Void) -> ServiceInjectToken {
        mediator.observe(type, single: true, handler: handler)
    }
    
    func setReadyContainerHandler<T>(_ type: T.Type, handler: @escaping () -> Void) -> ServiceInjectToken? {
        if resolve(type) != nil {
            handler()
            return nil
        } else {
            return userMediator.observe(type, single: true) { _ in handler() }
        }
    }
}

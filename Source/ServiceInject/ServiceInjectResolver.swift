//
//  ServiceInjectResolver.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 08.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

extension ServiceInjectResolver {
    public static func register<ContainerType>(_ container: ContainerType) {
        ServiceInjectResolver.shared.register(container)
        ServiceInjectMediator.shared.registered(container)
    }
    
    public static func registerSome(_ containers: [Any]) {
        ServiceInjectResolver.shared.register(containers)
        ServiceInjectMediator.shared.registeredSome(containers)
    }
    
    public static func removeAll<ContainerType>(container: ContainerType) {
        ServiceInjectResolver.shared.removeAll(container)
    }
}


// MARK: Internal
extension ServiceInjectResolver {
    static func resolve<ContainerType>(_ type: ContainerType.Type) -> ContainerType? {
        return shared.resolve(type)
    }
}

public final class ServiceInjectResolver {
    static let shared = ServiceInjectResolver(safe: false)
    
    private let lock: NSLock?
    private var list: [Any] = []
    
    private init(safe: Bool) {
        lock = safe ? NSLock() : nil
    }
    
    func register<ContainerType>(_ container: ContainerType) {
        lock?.lock()
        list.append(container)
        lock?.unlock()
    }
    
    func registerSome(_ containers: [Any]) {
        lock?.lock()
        list += containers
        lock?.unlock()
    }
    
    func removeAll<ContainerType>(_ container: ContainerType) {
        lock?.lock()
        list = list.filter { ($0 is ContainerType) == false }
        lock?.unlock()
    }
    
    func resolve<ContainerType>(_ type: ContainerType.Type) -> ContainerType? {
        lock?.lock()
        defer { lock?.unlock() }
        
        for entry in list {
            if let container = entry as? ContainerType {
                return container
            }
        }
        return nil
    }
}

//
//  ServiceInjectMediator.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 08.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

protocol ServiceInjectToken: class { }

private protocol ServiceInjectInternalToken: ServiceInjectToken {
    func resolved(_ container: Any) -> Bool
}

final class ServiceInjectMediator {
    static let shared = ServiceInjectMediator()
    
    private var observers: [ObserverWrapper] = []
    
    func registered<ContainerType>(_ container: ContainerType) {
        observers = observers.filter {
            ($0.token?.resolved(container) ?? true) == false
        }
    }
    
    func registeredSome(_ containers: [Any]) {
        observers = observers.filter {
            for container in containers {
                if $0.token?.resolved(container) ?? true {
                    return false
                }
            }
            return true
        }
    }
    
    func observe<ContainerType>(_ type: ContainerType.Type, handler: @escaping (ContainerType) -> Void) -> ServiceInjectToken {
        let token = Token(handler)
        observers.append(.init(token))
        return token
    }
    
    private final class Token<ContainerType>: ServiceInjectInternalToken {
        let handler: (ContainerType) -> Void
        
        init(_ handler: @escaping (ContainerType) -> Void) {
            self.handler = handler
        }
        
        func resolved(_ container: Any) -> Bool {
            if let container = container as? ContainerType {
                handler(container)
                return true
            } else {
                return false
            }
        }
    }
    
    private final class ObserverWrapper {
        weak var token: ServiceInjectInternalToken?
        init(_ token: ServiceInjectInternalToken) {
            self.token = token
        }
    }
}

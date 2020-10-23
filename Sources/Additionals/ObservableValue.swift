//
//  ObservableValue.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 22.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public typealias ObservableValueToken = MultipleMediatorToken

@propertyWrapper
public struct ObservableValue<T> {
    private let manager: ObservableValueManager<T>
    
    public init(wrappedValue: T) {
        manager = .init(wrappedValue)
    }
    
    public var wrappedValue: T {
        get { manager.value }
        set {
            manager.value = newValue
            manager.notify()
        }
    }
    
    public var projectedValue: ObservableValueManager<T> {
        return manager
    }
}

@propertyWrapper
public struct ObservableEquatableValue<T: Equatable> {
    private let manager: ObservableValueManager<T>
    
    public init(wrappedValue: T) {
        manager = .init(wrappedValue)
    }
    
    public var wrappedValue: T {
        get { manager.value }
        set {
            let oldValue = manager.value
            manager.value = newValue
            
            if oldValue != newValue {
                manager.notify()
            }
        }
    }
    
    public var projectedValue: ObservableValueManager<T> {
        return manager
    }
}

public final class ObservableValueManager<T> {
    private let mediator = MultipleMediator()
    fileprivate var value: T
    
    fileprivate init(_ value: T) {
        self.value = value
    }
    
    public func observe(initial: Bool = false, handler: @escaping (T) -> Void) -> ObservableValueToken {
        let token = mediator.observe(T.self, single: false, handler: handler)
        if initial {
            handler(value)
        }
        return token
    }
    
    public func observeOnce(handler: @escaping (T) -> Void) -> ObservableValueToken {
        return mediator.observe(T.self, single: true, handler: handler)
    }
    
    fileprivate func notify() {
        mediator.notify(value)
    }
}

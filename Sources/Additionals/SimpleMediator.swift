//
//  SimpleMediator.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 22.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public typealias SimpleMediatorToken = MultipleMediatorToken

public final class SimpleMediator<T> {
    private let mediator = MultipleMediator()
    
    public init() { }
    
    @discardableResult
    public func notify(_ entity: T) -> Bool {
        return mediator.notify(entity)
    }
    
    public func observe(single: Bool, handler: @escaping (T) -> Void) -> SimpleMediatorToken {
        return mediator.observe(T.self, single: single, handler: handler)
    }
}

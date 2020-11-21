//
//  InjectState.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 16.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public protocol InjectProjectedValue {
    associatedtype Entity
    var isReady: Bool { get }
    func setReadyHandler(_ handler: @escaping (Entity) -> Void)
}

public struct InjectState<Entity>: InjectProjectedValue {
    let storage: InjectStorage<Entity>
    
    init(storage: InjectStorage<Entity> = .init()) {
        self.storage = storage
    }

    public var isReady: Bool { return storage.isReady }
    
    public func setReadyHandler(_ handler: @escaping (Entity) -> Void) {
        storage.setReadyHandler(handler)
    }
}

public struct InjectParamsState<Entity, Params>: InjectProjectedValue {
    let storage: InjectStorage<Entity>
    let params: InjectParamsStorage<Params>
    
    init(storage: InjectStorage<Entity> = .init(), params: InjectParamsStorage<Params> = .init()) {
        self.storage = storage
        self.params = params
    }
    
    public var isReady: Bool { return storage.isReady }
    
    public func setReadyHandler(_ handler: @escaping (Entity) -> Void) {
        storage.setReadyHandler(handler)
    }
    
    public func setParameters(_ params: Params, lazyInject: Bool = false, file: StaticString = #file, line: UInt = #line) {
        guard storage.isReady == false else {
            fatalError("Failed to set parameters: the service has already been made", file: file, line: line)
        }
        self.params.setValue(params, lazyInject: lazyInject)
    }
}

// MARK: - Internal
final class InjectStorage<Entity> {
    private(set) var entity: Entity?
    private var readyHandler: ((Entity) -> Void)?
    
    var isReady: Bool { entity != nil }
    
    func setEntity(_ entity: Entity) {
        self.entity = entity
        readyHandler?(entity)
        readyHandler = nil
    }
    
    func setReadyHandler(_ handler: @escaping (Entity) -> Void) {
        if let entity = self.entity {
            handler(entity)
        } else {
            readyHandler = handler
        }
    }
}

final class InjectParamsStorage<Params> {
    private(set) var value: Params?
    private(set) var lazyInject: Bool = false
    private var readyToInjectHandler: ((Params) -> Void)?
    
    func setReadyToInjectHandler(_ handler: @escaping (Params) -> Void) {
        self.readyToInjectHandler = handler
    }
    
    func setValue(_ value: Params, lazyInject: Bool) {
        self.value = value
        self.lazyInject = lazyInject
        if lazyInject == false {
            readyToInjectHandler?(value)
        }
    }
    
    func clear() {
        self.value = nil
        self.readyToInjectHandler = nil
    }
}

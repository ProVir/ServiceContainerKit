//
//  InjectState.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 16.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation


public struct InjectState<Entity> {
    private let storage: InjectStorage<Entity>
    
    init(_ storage: InjectStorage<Entity>) {
        self.storage = storage
    }
    
    public var isReady: Bool { return storage.isReady }
    
    public func setReadyHandler(_ handler: @escaping (Entity) -> Void) {
        storage.setReadyHandler(handler)
    }
}

final class InjectStorage<Entity> {
    private(set) var entity: Entity?
    private(set) var readyHandler: ((Entity) -> Void)?
    
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

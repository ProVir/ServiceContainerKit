//
//  EntityInject.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 03.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

@propertyWrapper
public final class EntityInject<Container, Entity> {
    private var lazyInit: ((Container?) -> Void)?
    private var lazyInitToken: EntityInjectToken?
    private var state = InjectState<Entity>()
    
    public convenience init(_ type: Entity.Type, file: StaticString = #file, line: UInt = #line) where Container == Entity {
        self.init(\Container.self, file: file, line: line)
    }
    
    public init(_ keyPath: KeyPath<Container, Entity>, file: StaticString = #file, line: UInt = #line) {
        setup { [unowned self] container in
            guard let container = container else {
                fatalError("Not found Container for Inject", file: file, line: line)
            }
            
            let entity = container[keyPath: keyPath]
            self.state.storage.setEntity(entity)
        }
    }
    
    public var wrappedValue: Entity {
        lazyInit?(nil)
        
        if let entity = self.state.storage.entity {
            return entity
        } else {
            fatalError("Unknown error in Inject")
        }
    }
    
    public var projectedValue: InjectState<Entity> { return state }
    
    private func setup(_ configurator: @escaping (Container?) -> Void) {
        if let container = EntityInjectResolver.resolve(Container.self) {
            configurator(container)
        } else {
            self.lazyInit = configurator
            self.lazyInitToken = EntityInjectResolver.observeOnce(Container.self) { [weak self] in
                self?.resolved($0)
            }
        }
    }
    
    private func resolved(_ container: Container) {
        lazyInitToken = nil
        lazyInit?(container)
        lazyInit = nil
    }
}

//
//  ServiceProviderObjC.swift
//  ServiceProvider 1.0.0
//
//  Created by Короткий Виталий (ViR) on 07.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation


/// Wrapper ServiceProvider for use in ObjC code.
public class PVServiceProvider: NSObject {
    private let swiftProvider: ServiceProviderBindingObjC
    
    public init<T: NSObject>(_ provider: ServiceProvider<T>) {
        self.swiftProvider = provider
        super.init()
    }
    
    public func provider<T>() -> ServiceProvider<T>? {
        return swiftProvider as? ServiceProvider<T>
    }
    
    
    @objc public func tryService(settings: Any) throws -> NSObject {
        return try swiftProvider.tryServiceBindingObjC(settings: settings as? ServiceFactorySettings)
    }
    
    @objc public func tryService() throws -> NSObject {
        return try swiftProvider.tryServiceBindingObjC(settings: nil)
    }
    
    @objc public func getService(settings: Any) -> NSObject? {
        return try? swiftProvider.tryServiceBindingObjC(settings: settings as? ServiceFactorySettings)
    }
    
    @objc public func getService() -> NSObject? {
        return try? swiftProvider.tryServiceBindingObjC(settings: nil)
    }
}


//MARK: - Private

/// Base protocol for ServiceProvider<T>
private protocol ServiceProviderBindingObjC {
    func tryServiceBindingObjC(settings: ServiceFactorySettings?) throws -> NSObject
}

extension ServiceProvider: ServiceProviderBindingObjC {
    fileprivate func tryServiceBindingObjC(settings: ServiceFactorySettings?) throws -> NSObject {
        if let service = try tryService(settings: settings) as? NSObject {
            return service
        } else {
            fatalError("Service require support Objective-C")
        }
    }
}

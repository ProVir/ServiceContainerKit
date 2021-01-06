//
//  ObjcStubs.swift
//  ServiceContainerKitTests
//
//  Created by Виталий Короткий on 06.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

class ServiceObjCParams: NSObject {
    @objc let value: String
    @objc let error: Error?

    @objc init(value: String, error: Error?) {
        self.value = value
        self.error = error
    }
}

class ServiceObjC: NSObject, ServiceValueObjC {
    @objc var value: String
    init(value: String = "Default") {
        self.value = value
        super.init()
    }
}


// MARK: Factories

class SpyServiceSingletonObjCFactory: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(error: Error? = nil) {
        self.error = error
    }

    let mode: ServiceFactoryMode = .atOne
    func makeService() throws -> ServiceObjC {
        callCount += 1
        if let error = error {
            throw error
        } else {
            return ServiceObjC()
        }
    }
}

class SpyServiceParamsObjCFactory: ServiceContainerKit.ServiceParamsFactory {
    var callCount: Int = 0

    func makeService(params: ServiceObjCParams) throws -> ServiceObjC {
        callCount += 1
        if let error = params.error {
            throw error
        } else {
            return ServiceObjC(value: params.value)
        }
    }
}

class SpyServiceSingletonValueObjCFactory: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(error: Error? = nil) {
        self.error = error
    }

    let mode: ServiceFactoryMode = .atOne
    func makeService() throws -> ServiceValueObjC {
        callCount += 1
        if let error = error {
            throw error
        } else {
            return ServiceObjC()
        }
    }
}

class SpyServiceParamsValueObjCFactory: ServiceContainerKit.ServiceParamsFactory {
    var callCount: Int = 0

    func makeService(params: ServiceObjCParams) throws -> ServiceValueObjC {
        callCount += 1
        if let error = params.error {
            throw error
        } else {
            return ServiceObjC(value: params.value)
        }
    }
}

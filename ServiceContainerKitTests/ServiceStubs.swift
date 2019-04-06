//
//  ServiceStubs.swift
//  ServiceContainerKitTests
//
//  Created by Vitalii Korotkii on 05/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

@testable import ServiceContainerKit

// MARK: Services
protocol ServiceValue: class {
    init()
    var value: String { get set }
}

protocol ServiceParamsValue: class {
    var value: String { get set }
}

@objc protocol ServiceValueObjC {
    var value: String { get set }
}

class ServiceSingleton: ServiceValue {
    required init() { }
    var value: String = "Default"
}

class ServiceLazy: ServiceValue {
    required init() { }
    var value: String = "DefaultLazy"
}

class ServiceMany: ServiceValue {
    required init() { }
    var value: String = "DefaultMany"
}

class ServiceParams: ServiceParamsValue {
    struct Params {
        let value: String
        let error: Error?
    }

    var value: String
    init(value: String) {
        self.value = value
    }
}

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


// MARK: Factory
enum ServiceCreateError: Error, Equatable {
    case someError
}

class SpyServiceSingletonFactory: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(error: Error? = nil) {
        self.error = error
    }

    let factoryType: ServiceFactoryType = .atOne
    func createService() throws -> ServiceSingleton {
        callCount += 1
        if let error = error {
            throw error
        } else {
            return ServiceSingleton()
        }
    }
}

class SpyServiceLazyFactory: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(error: Error? = nil) {
        self.error = error
    }

    let factoryType: ServiceFactoryType = .lazy
    func createService() throws -> ServiceLazy {
        callCount += 1
        if let error = error {
            throw error
        } else {
            return ServiceLazy()
        }
    }
}

class SpyServiceManyFactory: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(error: Error? = nil) {
        self.error = error
    }

    let factoryType: ServiceFactoryType = .many
    func createService() throws -> ServiceMany {
        callCount += 1
        if let error = error {
            throw error
        } else {
            return ServiceMany()
        }
    }
}

class SpyServiceValueFactory<Service: ServiceValue>: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(factoryType: ServiceFactoryType, error: Error? = nil) {
        self.factoryType = factoryType
        self.error = error
    }

    let factoryType: ServiceFactoryType
    func createService() throws -> Service {
        callCount += 1
        if let error = error {
            throw error
        } else {
            return Service()
        }
    }
}

class SpyServiceParamsFactory: ServiceContainerKit.ServiceParamsFactory {
    var callCount: Int = 0

    func createService(params: ServiceParams.Params) throws -> ServiceParams {
        callCount += 1
        if let error = params.error {
            throw error
        } else {
            return ServiceParams(value: params.value)
        }
    }
}

class SpyServiceParamsValueFactory: ServiceContainerKit.ServiceParamsFactory {
    var callCount: Int = 0

    func createService(params: ServiceParams.Params) throws -> ServiceParamsValue {
        callCount += 1
        if let error = params.error {
            throw error
        } else {
            return ServiceParams(value: params.value)
        }
    }
}

class SpyServiceSingletonObjCFactory: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(error: Error? = nil) {
        self.error = error
    }

    let factoryType: ServiceFactoryType = .atOne
    func createService() throws -> ServiceObjC {
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

    func createService(params: ServiceObjCParams) throws -> ServiceObjC {
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

    let factoryType: ServiceFactoryType = .atOne
    func createService() throws -> ServiceValueObjC {
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

    func createService(params: ServiceObjCParams) throws -> ServiceValueObjC {
        callCount += 1
        if let error = params.error {
            throw error
        } else {
            return ServiceObjC(value: params.value)
        }
    }
}

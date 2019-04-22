//
//  ServiceStubs.swift
//  ServiceContainerKitTests
//
//  Created by Vitalii Korotkii on 05/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

@testable import ServiceContainerKit

struct ServiceLocatorKeys {
    static let serviceSingleton = SpyServiceSingletonFactory.defaultKey
    static let serviceLazy = SpyServiceLazyFactory.defaultKey
    static let serviceMany = SpyServiceManyFactory.defaultKey
    static let serviceSingletonValue = SpyServiceValueFactory<ServiceSingleton>.defaultKey
    static let serviceManyValue = SpyServiceValueFactory<ServiceMany>.defaultKey
    static let serviceParams = SpyServiceParamsFactory.defaultKey
    static let serviceOptParams = SpyServiceOptParamsFactory.defaultKey
    static let serviceParamsValue = SpyServiceParamsValueFactory.defaultKey
    
    static let serviceSingletonObjC = ServiceLocatorCustomKey<ServiceObjC>(storeKey: "SingletonObjC")
    static let serviceParamsObjC = SpyServiceParamsObjCFactory.defaultKey
    static let serviceSingletonValueObjC = ServiceLocatorCustomKey<ServiceValueObjC>(storeKey: "SingletonValueObjC")
    static let serviceParamsValueObjC = SpyServiceParamsValueObjCFactory.defaultKey
}

extension ServiceLocatorObjCKey {
    @objc static var serviceSingleton: ServiceLocatorObjCKey { return .init(ServiceLocatorKeys.serviceSingletonObjC) }
    @objc static var serviceParams: ServiceLocatorObjCKey { return .init(ServiceLocatorKeys.serviceParamsObjC) }
    @objc static var serviceSingletonValue: ServiceLocatorObjCKey { return .init(ServiceLocatorKeys.serviceSingletonValueObjC) }
    @objc static var serviceParamsValue: ServiceLocatorObjCKey { return .init(ServiceLocatorKeys.serviceParamsValueObjC) }
}

struct ServiceLocatorCustomKey<ServiceType>: ServiceLocatorKey {
    let storeKey: String
}

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
    func createService() throws -> ServiceValue {
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

class SpyServiceOptParamsFactory: ServiceContainerKit.ServiceParamsFactory {
    var callCount: Int = 0
    
    func createService(params: ServiceParams.Params?) throws -> ServiceParams {
        callCount += 1
        if let error = params?.error {
            throw error
        } else {
            return ServiceParams(value: params?.value ?? "Default")
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

//
//  FactoryStubs.swift
//  ServiceContainerKit
//
//  Created by Виталий Короткий on 06.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

enum ServiceCreateError: Error, Equatable {
    case someError
}

class SpyServiceSingletonFactory: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(error: Error? = nil) {
        self.error = error
    }

    let mode: ServiceFactoryMode = .atOne
    func makeService() throws -> ServiceSingleton {
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

    let mode: ServiceFactoryMode = .lazy
    func makeService() throws -> ServiceLazy {
        callCount += 1
        if let error = error {
            throw error
        } else {
            return ServiceLazy()
        }
    }
}

class SpyServiceWeakFactory: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(error: Error? = nil) {
        self.error = error
    }

    let mode: ServiceFactoryMode = .weak
    func makeService() throws -> ServiceWeak {
        callCount += 1
        if let error = error {
            throw error
        } else {
            return ServiceWeak()
        }
    }
}

class SpyServiceManyFactory: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(error: Error? = nil) {
        self.error = error
    }

    let mode: ServiceFactoryMode = .many
    func makeService() throws -> ServiceMany {
        callCount += 1
        if let error = error {
            throw error
        } else {
            return ServiceMany()
        }
    }
}

class SpyServiceNestedFactory: ServiceContainerKit.ServiceFactory {
    let provider: ServiceProvider<ServiceMany>
    var callCount: Int = 0

    init(provider: ServiceProvider<ServiceMany>) {
        self.provider = provider
    }

    let mode: ServiceFactoryMode = .many
    func makeService() throws -> ServiceNested {
        callCount += 1
        return ServiceNested(service: try provider.getService())
    }
}

class SpyServiceValueFactory<Service: ServiceValue>: ServiceContainerKit.ServiceFactory {
    var error: Error?
    var callCount: Int = 0

    init(mode: ServiceFactoryMode, error: Error? = nil) {
        self.mode = mode
        self.error = error
    }

    let mode: ServiceFactoryMode
    func makeService() throws -> ServiceValue {
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

    func makeService(params: ServiceParams.Params) throws -> ServiceParams {
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
    
    func makeService(params: ServiceParams.Params?) throws -> ServiceParams {
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

    func makeService(params: ServiceParams.Params) throws -> ServiceParamsValue {
        callCount += 1
        if let error = params.error {
            throw error
        } else {
            return ServiceParams(value: params.value)
        }
    }
}

class SpyServiceSessionFactory<T: ServiceValue, S: ServiceSession>: ServiceContainerKit.ServiceSessionFactory {
    var error: Error?
    var canActivate: Bool = true
    var callMakeCount: Int = 0
    var callDeActiveCount: Int = 0
    var callActiveCount: Int = 0
    var lastSession: S?

    init(mode: ServiceSessionFactoryMode, error: Error? = nil) {
        self.mode = mode
        self.error = error
    }

    let mode: ServiceSessionFactoryMode
    func makeService(session: S) throws -> T {
        callMakeCount += 1
        lastSession = session
        if let error = error {
            throw error
        } else {
            return T()
        }
    }
    
    func deactivateService(_ service: T, session: S) -> Bool {
        callDeActiveCount += 1
        service.isActive = false
        return canActivate
    }
    
    func activateService(_ service: T, session: S) {
        callActiveCount += 1
        lastSession = session
        service.isActive = true
    }
}

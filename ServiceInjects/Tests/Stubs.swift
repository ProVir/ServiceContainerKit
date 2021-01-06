//
//  Stubs.swift
//  ServiceInject
//
//  Created by Виталий Короткий on 06.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct SimpleFirstModel: Equatable {
    var value: String
}

struct SimpleSecondModel: Equatable {
    var value: String
}


// MARK: Services

class ServiceSingleton {
    init() { }
    var value: String = "Default"
}

class ServiceLazy {
    init() { }
    var value: String = "DefaultLazy"
}

class ServiceWeak {
    init() { }
    var value: String = "DefaultWeak"
}

class ServiceMany {
    required init() { }
    var value: String = "DefaultMany"
}

class ServiceParams {
    struct Params {
        let value: String
    }

    var value: String
    init(value: String) {
        self.value = value
    }
}


// MARK: Containers

protocol BaseContainer {
    var singletonService: ServiceProvider<ServiceSingleton> { get }
    var lazyService: ServiceProvider<ServiceLazy> { get }
    var weakService: ServiceProvider<ServiceWeak> { get }
    var manyService: ServiceProvider<ServiceMany> { get }
    var paramsService: ServiceParamsProvider<ServiceParams, ServiceParams.Params> { get }
}

struct SimpleContainer: BaseContainer {
    let singletonService: ServiceProvider<ServiceSingleton>
    let lazyService: ServiceProvider<ServiceLazy>
    let weakService: ServiceProvider<ServiceWeak>
    let manyService: ServiceProvider<ServiceMany>
    let paramsService: ServiceParamsProvider<ServiceParams, ServiceParams.Params>
    
    static func make() -> SimpleContainer {
        return .init(
            singletonService: .init(mode: .atOne) { .init() },
            lazyService: .init(mode: .lazy) { .init() },
            weakService: .init(mode: .weak) { .init() },
            manyService: .init(mode: .many) { .init() },
            paramsService: .init { params in .init(value: params.value) }
        )
    }
    
    static func makeAsProtocol() -> BaseContainer {
        return make()
    }
}

class ObjContainer: BaseContainer {
    let singletonService: ServiceProvider<ServiceSingleton>
    let lazyService: ServiceProvider<ServiceLazy>
    let weakService: ServiceProvider<ServiceWeak>
    let manyService: ServiceProvider<ServiceMany>
    let paramsService: ServiceParamsProvider<ServiceParams, ServiceParams.Params>
    
    init() {
        singletonService = .init(mode: .atOne) { .init() }
        lazyService = .init(mode: .lazy) { .init() }
        weakService = .init(mode: .weak) { .init() }
        manyService = .init(mode: .many) { .init() }
        paramsService = .init { params in .init(value: params.value) }
    }
}

struct OptionalContainer {
    let manyService: ServiceProvider<ServiceMany>?
    let paramsService: ServiceParamsProvider<ServiceParams, ServiceParams.Params>?
    
    static func make() -> OptionalContainer {
        return .init(
            manyService: .init(mode: .many) { .init() },
            paramsService: .init { params in .init(value: params.value) }
        )
    }
    
    static func makeNil() -> OptionalContainer {
        return .init(manyService: nil, paramsService: nil)
    }
}

struct ManyContainer {
    let manyService: ServiceProvider<ServiceMany>
}

struct ParamsContainer {
    let paramsService: ServiceParamsProvider<ServiceParams, ServiceParams.Params>
}

//
//  CommonStubs.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 21.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
@testable import ServiceContainerKit

struct SimpleServiceSession: ServiceSession {
    let key: AnyHashable
}

struct SimpleFirstModel: Equatable {
    var value: String
}

struct SimpleSecondModel: Equatable {
    var value: String
}

protocol BaseContainer {
    var singletonService: ServiceProvider<ServiceSingleton> { get }
    var lazyService: ServiceProvider<ServiceLazy> { get }
    var weakService: ServiceProvider<ServiceWeak> { get }
    var manyService: ServiceProvider<ServiceMany> { get }
}

struct SimpleContainer: BaseContainer {
    let singletonService: ServiceProvider<ServiceSingleton>
    let lazyService: ServiceProvider<ServiceLazy>
    let weakService: ServiceProvider<ServiceWeak>
    let manyService: ServiceProvider<ServiceMany>
    
    static func make() -> SimpleContainer {
        return .init(
            singletonService: SpyServiceSingletonFactory().serviceProvider(),
            lazyService: SpyServiceLazyFactory().serviceProvider(),
            weakService: SpyServiceWeakFactory().serviceProvider(),
            manyService: SpyServiceManyFactory().serviceProvider()
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
    
    init() {
        singletonService = SpyServiceSingletonFactory().serviceProvider()
        lazyService = SpyServiceLazyFactory().serviceProvider()
        weakService = SpyServiceWeakFactory().serviceProvider()
        manyService = SpyServiceManyFactory().serviceProvider()
    }
}

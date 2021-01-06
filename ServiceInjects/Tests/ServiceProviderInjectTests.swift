//
//  ServiceProviderInjectTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 11.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
import ServiceContainerKit
@testable import ServiceInjects

class ServiceProviderInjectTests: XCTestCase {

    override func tearDownWithError() throws {
        ServiceInjectResolver.removeAllForTests()
    }
    
    func testResolve() {
        struct Container {
            @ServiceProviderInject(\ManyContainer.manyService) var provider
        }
        
        let serviceProvider = ServiceProvider(mode: .many) { ServiceMany() }
        ServiceInjectResolver.register(ManyContainer(manyService: serviceProvider))
        
        let container = Container()
        XCTAssertTrue(container.$provider.isReady)
        
        var isCall = false
        container.$provider.setReadyHandler { provider in
            XCTAssertFalse(isCall)
            XCTAssert(serviceProvider === provider)
            isCall = true
        }
        XCTAssertTrue(isCall)

        let provider1 = container.provider
        XCTAssert(serviceProvider === provider1)
        
        let provider2 = container.provider
        XCTAssert(serviceProvider === provider2)
    }

    func testResolveBeforeInject() {
        struct Container {
            @ServiceProviderInject(\ManyContainer.manyService) var provider
        }
        
        let serviceProvider = ServiceProvider(mode: .many) { ServiceMany() }
        let container = Container()
        XCTAssertFalse(container.$provider.isReady)

        var isCall = false
        container.$provider.setReadyHandler { provider in
            XCTAssertFalse(isCall)
            XCTAssert(serviceProvider === provider)
            isCall = true
        }
        XCTAssertFalse(isCall)
        
        ServiceInjectResolver.register(ManyContainer(manyService: serviceProvider))
        XCTAssertTrue(isCall)
        XCTAssertTrue(container.$provider.isReady)
        
        let provider1 = container.provider
        XCTAssert(serviceProvider === provider1)
        
        let provider2 = container.provider
        XCTAssert(serviceProvider === provider2)
    }
    
    func testResolveOptionalSome() {
        struct Container {
            @ServiceProviderInject(\OptionalContainer.manyService) var provider
        }
        
        let serviceProvider = ServiceProvider(mode: .many) { ServiceMany() }
        ServiceInjectResolver.register(OptionalContainer(manyService: serviceProvider, paramsService: nil))
        
        let container = Container()
        XCTAssertTrue(container.$provider.isReady)
        
        var isCall = false
        container.$provider.setReadyHandler { provider in
            XCTAssertFalse(isCall)
            XCTAssert(serviceProvider === provider)
            isCall = true
        }
        XCTAssertTrue(isCall)

        let provider1 = container.provider
        XCTAssert(serviceProvider === provider1)
        
        let provider2 = container.provider
        XCTAssert(serviceProvider === provider2)
    }
    
    func testResolveOptionalNil() {
        struct Container {
            @ServiceProviderInject(\OptionalContainer.manyService) var provider
        }
        
        ServiceInjectResolver.register(OptionalContainer(manyService: nil, paramsService: nil))
        
        let container = Container()
        XCTAssertTrue(container.$provider.isReady)
        
        var isCall = false
        container.$provider.setReadyHandler { provider in
            XCTAssertFalse(isCall)
            XCTAssertNil(provider)
            isCall = true
        }
        XCTAssertTrue(isCall)
        XCTAssertNil(container.provider)
    }
    
    // MARK: Params
    func testParams() {
        struct Container {
            @ServiceProviderInject(\ParamsContainer.paramsService) var provider
        }
        
        let serviceProvider = ServiceParamsProvider<ServiceParams, ServiceParams.Params> { params in .init(value: params.value) }
        ServiceInjectResolver.register(ParamsContainer(paramsService: serviceProvider))
        
        let container = Container()
        XCTAssertTrue(container.$provider.isReady)
        
        var isCall = false
        container.$provider.setReadyHandler { provider in
            XCTAssertFalse(isCall)
            XCTAssert(serviceProvider === provider)
            isCall = true
        }
        XCTAssertTrue(isCall)

        let provider1 = container.provider
        XCTAssert(serviceProvider === provider1)
        
        let provider2 = container.provider
        XCTAssert(serviceProvider === provider2)
    }

    func testParamsBeforeInject() {
        struct Container {
            @ServiceProviderInject(\ParamsContainer.paramsService) var provider
        }
        
        let serviceProvider = ServiceParamsProvider<ServiceParams, ServiceParams.Params> { params in .init(value: params.value) }
        let container = Container()
        XCTAssertFalse(container.$provider.isReady)

        var isCall = false
        container.$provider.setReadyHandler { provider in
            XCTAssertFalse(isCall)
            XCTAssert(serviceProvider === provider)
            isCall = true
        }
        XCTAssertFalse(isCall)
        
        ServiceInjectResolver.register(ParamsContainer(paramsService: serviceProvider))
        XCTAssertTrue(isCall)
        XCTAssertTrue(container.$provider.isReady)
        
        let provider1 = container.provider
        XCTAssert(serviceProvider === provider1)
        
        let provider2 = container.provider
        XCTAssert(serviceProvider === provider2)
    }
    
    func testParamsOptionalSome() {
        struct Container {
            @ServiceProviderInject(\OptionalContainer.paramsService) var provider
        }
        
        let serviceProvider = ServiceParamsProvider<ServiceParams, ServiceParams.Params> { params in .init(value: params.value) }
        ServiceInjectResolver.register(OptionalContainer(manyService: nil, paramsService: serviceProvider))
        
        let container = Container()
        XCTAssertTrue(container.$provider.isReady)
        
        var isCall = false
        container.$provider.setReadyHandler { provider in
            XCTAssertFalse(isCall)
            XCTAssert(serviceProvider === provider)
            isCall = true
        }
        XCTAssertTrue(isCall)

        let provider1 = container.provider
        XCTAssert(serviceProvider === provider1)
        
        let provider2 = container.provider
        XCTAssert(serviceProvider === provider2)
    }
    
    func testParamsOptionalNil() {
        struct Container {
            @ServiceProviderInject(\OptionalContainer.paramsService) var provider
        }
        
        ServiceInjectResolver.register(OptionalContainer(manyService: nil, paramsService: nil))
        
        let container = Container()
        XCTAssertTrue(container.$provider.isReady)
        
        var isCall = false
        container.$provider.setReadyHandler { provider in
            XCTAssertFalse(isCall)
            XCTAssertNil(provider)
            isCall = true
        }
        XCTAssertTrue(isCall)
        XCTAssertNil(container.provider)
    }

}

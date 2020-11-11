//
//  ServiceParamsInjectTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 11.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class ServiceParamsInjectTests: XCTestCase {

    override func tearDownWithError() throws {
        ServiceInjectResolver.removeAllForTests()
    }
    
    // MARK: Params in init
    func testParamsInInit() {
        struct Container {
            @ServiceParamsInject(
                \BaseContainer.paramsService,
                params: ServiceParams.Params(value: "test", error: nil)
            ) var service
        }
        
        ServiceInjectResolver.register(SimpleContainer.make())

        let container = Container()
        XCTAssertTrue(container.$service.isReady)

        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertTrue(isCall)
        XCTAssertEqual(service1?.value, "test")

        let service2 = container.service
        XCTAssert(service1 === service2)

        let service3 = container.service
        XCTAssert(service2 === service3)
    }
    
    func testParamsInInitBeforeInject() {
        struct Container {
            @ServiceParamsInject(
                \BaseContainer.paramsService,
                params: ServiceParams.Params(value: "test", error: nil)
            ) var service
        }
        
        let container = Container()
        XCTAssertFalse(container.$service.isReady)

        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertFalse(isCall)
        
        ServiceInjectResolver.register(SimpleContainer.make())
        XCTAssertTrue(isCall)
        XCTAssertTrue(container.$service.isReady)
        XCTAssertNotNil(service1)
        
        let service2 = container.service
        XCTAssert(service1 === service2)
        
        let service3 = container.service
        XCTAssert(service2 === service3)
    }

    func testParamsInInitLazyInject() {
        struct Container {
            @ServiceParamsInject(
                \BaseContainer.paramsService,
                params: ServiceParams.Params(value: "test", error: nil),
                lazyInject: true
            ) var service
        }
        
        ServiceInjectResolver.register(SimpleContainer.make())
        
        let container = Container()
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity)
        
        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertFalse(isCall)
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity)

        let service2 = container.service
        XCTAssertNotNil(service1)
        XCTAssertEqual(service1?.value, "test")
        XCTAssert(service1 === service2)
        
        let service3 = container.service
        XCTAssert(service2 === service3)
    }
    
    // MARK: Params after init
    func testParamsAfterInit() {
        struct Container {
            @ServiceParamsInject(\BaseContainer.paramsService) var service
        }
        
        ServiceInjectResolver.register(SimpleContainer.make())

        let container = Container()
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity)
        
        container.$service.setParameters(.init(value: "test", error: nil))
        XCTAssertTrue(container.$service.isReady)

        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertTrue(isCall)
        XCTAssertEqual(service1?.value, "test")

        let service2 = container.service
        XCTAssert(service1 === service2)

        let service3 = container.service
        XCTAssert(service2 === service3)
    }
    
    func testParamsAfterInitBeforeInject() {
        struct Container {
            @ServiceParamsInject(\BaseContainer.paramsService) var service
        }
        
        let container = Container()
        XCTAssertFalse(container.$service.isReady)
        
        container.$service.setParameters(.init(value: "test", error: nil))
        XCTAssertFalse(container.$service.isReady)

        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertFalse(isCall)
        
        ServiceInjectResolver.register(SimpleContainer.make())
        XCTAssertTrue(isCall)
        XCTAssertTrue(container.$service.isReady)
        XCTAssertNotNil(service1)
        
        let service2 = container.service
        XCTAssert(service1 === service2)
        
        let service3 = container.service
        XCTAssert(service2 === service3)
    }
    
    func testParamsAfterInitAndInject() {
        struct Container {
            @ServiceParamsInject(\BaseContainer.paramsService) var service
        }
        
        let container = Container()
        XCTAssertFalse(container.$service.isReady)

        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertFalse(isCall)
        
        ServiceInjectResolver.register(SimpleContainer.make())
        XCTAssertFalse(container.$service.isReady)
        XCTAssertFalse(isCall)
        
        container.$service.setParameters(.init(value: "test", error: nil))
        XCTAssertTrue(isCall)
        XCTAssertTrue(container.$service.isReady)
        XCTAssertNotNil(service1)
        
        let service2 = container.service
        XCTAssert(service1 === service2)
        
        let service3 = container.service
        XCTAssert(service2 === service3)
    }
    
    func testParamsAfterInitLazyInject() {
        struct Container {
            @ServiceParamsInject(\BaseContainer.paramsService) var service
        }
        
        ServiceInjectResolver.register(SimpleContainer.make())
        
        let container = Container()
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity)
        
        container.$service.setParameters(.init(value: "test", error: nil), lazyInject: true)
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity)
        
        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertFalse(isCall)
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity)

        let service2 = container.service
        XCTAssertNotNil(service1)
        XCTAssertEqual(service1?.value, "test")
        XCTAssert(service1 === service2)
        
        let service3 = container.service
        XCTAssert(service2 === service3)
    }
    
    // MARK: Optionals
    func testParamsOptionalSome() {
        struct Container {
            @ServiceParamsInject(
                \OptionalContainer.paramsService,
                params: ServiceParams.Params(value: "test", error: nil)
            ) var service
        }
        
        ServiceInjectResolver.register(OptionalContainer.make())
        
        let container = Container()
        XCTAssertTrue(container.$service.isReady)
        
        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertTrue(isCall)
        XCTAssertEqual(service1?.value, "test")

        let service2 = container.service
        XCTAssert(service1 === service2)
    }
    
    func testParamsOptionalNil() {
        struct Container {
            @ServiceParamsInject(
                \OptionalContainer.paramsService,
                params: ServiceParams.Params(value: "test", error: nil)
            ) var service
        }
        
        ServiceInjectResolver.register(OptionalContainer.makeNil())
        
        let container = Container()
        XCTAssertTrue(container.$service.isReady)
        
        var isCall = false
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            XCTAssertNil(s)
            isCall = true
        }
        XCTAssertTrue(isCall)
        XCTAssertNil(container.service)
    }
    
    func testParamsLazyInjectOptional() {
        struct Container {
            @ServiceParamsInject(
                \OptionalContainer.paramsService,
                params: ServiceParams.Params(value: "test", error: nil),
                lazyInject: true
            ) var service
        }
        
        ServiceInjectResolver.register(OptionalContainer.make())
        
        let container = Container()
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity.flatMap { $0 })
        
        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertFalse(isCall)
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity.flatMap { $0 })

        let service2 = container.service
        XCTAssertNotNil(service1)
        XCTAssertEqual(service1?.value, "test")
        XCTAssert(service1 === service2)
        
        let service3 = container.service
        XCTAssert(service2 === service3)
    }

    func testParamsAfterInitOptional() {
        struct Container {
            @ServiceParamsInject(\OptionalContainer.paramsService) var service
        }
        
        ServiceInjectResolver.register(OptionalContainer.make())

        let container = Container()
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity.flatMap { $0 })
        
        container.$service.setParameters(.init(value: "test", error: nil))
        XCTAssertTrue(container.$service.isReady)

        var isCall = false
        var service1: ServiceParams?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertTrue(isCall)
        XCTAssertEqual(service1?.value, "test")

        let service2 = container.service
        XCTAssert(service1 === service2)

        let service3 = container.service
        XCTAssert(service2 === service3)
    }
}

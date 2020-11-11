//
//  ServiceInjectTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 10.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class ServiceInjectTests: XCTestCase {

    override func tearDownWithError() throws {
        ServiceInjectResolver.removeAllForTests()
    }

    func testResolve() {
        struct Container {
            @ServiceInject(\BaseContainer.manyService) var service
        }
        
        ServiceInjectResolver.register(SimpleContainer.make())
        
        let container = Container()
        XCTAssertTrue(container.$service.isReady)
        
        var isCall = false
        var service1: ServiceMany?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertTrue(isCall)

        let service2 = container.service
        XCTAssert(service1 === service2)
        
        let service3 = container.service
        XCTAssert(service2 === service3)
    }

    func testResolveBeforeInject() {
        struct Container {
            @ServiceInject(\BaseContainer.manyService) var service
        }
        
        let container = Container()
        XCTAssertFalse(container.$service.isReady)

        var isCall = false
        var service1: ServiceMany?
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

    func testLazyInject() {
        struct Container {
            @ServiceInject(\BaseContainer.manyService, lazyInject: true) var service
        }
        
        ServiceInjectResolver.register(SimpleContainer.make())
        
        let container = Container()
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity)
        
        var isCall = false
        var service1: ServiceMany?
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
        XCTAssert(service1 === service2)
        
        let service3 = container.service
        XCTAssert(service2 === service3)
    }
    
    func testResolveOptionalSome() {
        struct Container {
            @ServiceInject(\OptionalContainer.manyService) var service
        }
        
        ServiceInjectResolver.register(OptionalContainer.make())
        
        let container = Container()
        XCTAssertTrue(container.$service.isReady)
        
        var isCall = false
        var service1: ServiceMany?
        container.$service.setReadyHandler { s in
            XCTAssertFalse(isCall)
            isCall = true
            service1 = s
        }
        XCTAssertTrue(isCall)

        let service2 = container.service
        XCTAssert(service1 === service2)
    }
    
    func testResolveOptionalNil() {
        struct Container {
            @ServiceInject(\OptionalContainer.manyService) var service
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
    
    func testLazyInjectOptional() {
        struct Container {
            @ServiceInject(\OptionalContainer.manyService, lazyInject: true) var service
        }
        
        ServiceInjectResolver.register(OptionalContainer.make())
        
        let container = Container()
        XCTAssertFalse(container.$service.isReady)
        XCTAssertNil(container.$service.storage.entity.flatMap { $0 })
        
        var isCall = false
        var service1: ServiceMany?
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
        XCTAssert(service1 === service2)
        
        let service3 = container.service
        XCTAssert(service2 === service3)
    }
    
}

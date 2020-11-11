//
//  EntityInjectTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 09.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class EntityInjectTests: XCTestCase {
    
    override func tearDownWithError() throws {
        EntityInjectResolver.removeAllForTests()
    }
    
    func testResolve() {
        let entitySrc = ObjEntity()
        var token: EntityInjectToken? = EntityInjectResolver.register(entitySrc)
        _ = token.self
        
        let container = Container()
        XCTAssertTrue(container.$entity.isReady)
        
        var isCall = false
        container.$entity.setReadyHandler { entity in
            XCTAssertFalse(isCall)
            XCTAssert(entity === entitySrc)
            isCall = true
        }
        XCTAssertTrue(isCall)
        
        let entity1 = container.entity
        XCTAssert(entity1 === entitySrc)
        
        let entity2 = container.entity
        XCTAssert(entity2 === entitySrc)
        
        token = nil
        
        let expectation = XCTestExpectation(description: "Remove after injects or auto")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        let entity3 = container.entity
        XCTAssert(entity3 === entitySrc)
    }
    
    func testResolveUsePath() {
        let valueSrc = "test"
        let token = EntityInjectResolver.register(ObjEntity(value: valueSrc))
        _ = token.self
        
        let container = ContainerUsePath()
        XCTAssertTrue(container.$value.isReady)

        var isCall = false
        container.$value.setReadyHandler { value in
            XCTAssertFalse(isCall)
            XCTAssertEqual(value, valueSrc)
            isCall = true
        }
        XCTAssertTrue(isCall)
        XCTAssertEqual(container.value, valueSrc)
    }
    
    func testResolveBeforeInject() {
        let container = Container()
        XCTAssertFalse(container.$entity.isReady)

        var isCall = false
        container.$entity.setReadyHandler { _ in
            XCTAssertFalse(isCall)
            isCall = true
        }
        XCTAssertFalse(isCall)
        
        let token = EntityInjectResolver.register(ObjEntity())
        _ = token.self
        XCTAssertTrue(isCall)
        XCTAssertTrue(container.$entity.isReady)
    }
}

private extension EntityInjectTests {
    class ObjEntity {
        var value: String
        
        init(value: String = "") {
            self.value = value
        }
    }
    
    struct Container {
        @EntityInject(ObjEntity.self) var entity
    }
    
    struct ContainerUsePath {
        @EntityInject(\ObjEntity.value) var value
    }
}

//
//  EntityInjectResolverTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 30.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceInjects

class EntityInjectResolverTests: XCTestCase {

    override func tearDownWithError() throws {
        EntityInjectResolver.removeAllForTests()
    }
    
    func testRegisterAndRemove() {
        let entitySrc = ObjContainer()
        var token1: EntityInjectToken? = EntityInjectResolver.register(entitySrc)
        
        guard let entityDst = EntityInjectResolver.resolve(ObjContainer.self) else {
            XCTFail("Entity not found")
            return
        }
        
        XCTAssert(entitySrc === entityDst)
        
        let token2 = EntityInjectResolver.register(SimpleContainer.make())
        guard EntityInjectResolver.resolve(SimpleContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        
        token1 = nil
        guard EntityInjectResolver.resolve(ObjContainer.self) == nil else {
            XCTFail("Entity not be found")
            return
        }
        
        EntityInjectResolver.remove(SimpleContainer.self)
        guard EntityInjectResolver.resolve(SimpleContainer.self) == nil else {
            XCTFail("Entity not be found")
            return
        }
        
        _ = token1.self
        _ = token2.self
    }
    
    func testRegisterForFirst() {
        let entitySrc = ObjContainer()
        EntityInjectResolver.registerForFirstInject(entitySrc)
        
        guard let entityDst = EntityInjectResolver.resolve(ObjContainer.self) else {
            XCTFail("Entity not found")
            return
        }
        
        XCTAssert(entitySrc === entityDst)
        
        guard EntityInjectResolver.resolve(ObjContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        
        EntityInjectResolver.registerForFirstInject(SimpleContainer.make(), autoRemoveDelay: 0.1)
        guard EntityInjectResolver.resolve(SimpleContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        
        EntityInjectResolver.registerForFirstInject("notResolvedWithAutoRemove", autoRemoveDelay: 0.1)
        
        let expectation = XCTestExpectation(description: "Remove after injects or auto")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        guard EntityInjectResolver.resolve(ObjContainer.self) == nil else {
            XCTFail("Entity not be found")
            return
        }
        
        guard EntityInjectResolver.resolve(SimpleContainer.self) == nil else {
            XCTFail("Entity not be found")
            return
        }
        
        guard EntityInjectResolver.resolve(String.self) == nil else {
            XCTFail("Entity not be found")
            return
        }
    }
    
    func testRegisterAsProtocol() {
        let token = EntityInjectResolver.register(SimpleContainer.makeAsProtocol())
        
        guard EntityInjectResolver.resolve(SimpleContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        _ = token.self
    }
    
    func testRegisterAndResolveAsProtocol() {
        let token = EntityInjectResolver.register(SimpleContainer.make())
        
        guard EntityInjectResolver.resolve(BaseContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        _ = token.self
    }
    
    func testRegisterSome() {
        let tokens = EntityInjectResolver.registerSome([SimpleContainer.make(), ObjContainer()])
        _ = tokens.self
        
        guard EntityInjectResolver.resolve(SimpleContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        
        guard EntityInjectResolver.resolve(ObjContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
    }
    
    func testRegisterForFirstSome() {
        EntityInjectResolver.registerForFirstInjectSome([SimpleContainer.make(), ObjContainer()])
        
        guard EntityInjectResolver.resolve(SimpleContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        
        guard EntityInjectResolver.resolve(ObjContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        
        guard EntityInjectResolver.resolve(SimpleContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        
        guard EntityInjectResolver.resolve(ObjContainer.self) != nil else {
            XCTFail("Entity not found")
            return
        }
        
        let expectation = XCTestExpectation(description: "Remove after injects or auto")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        guard EntityInjectResolver.resolve(ObjContainer.self) == nil else {
            XCTFail("Entity not be found")
            return
        }
        
        guard EntityInjectResolver.resolve(SimpleContainer.self) == nil else {
            XCTFail("Entity not be found")
            return
        }
    }
    
    func testRegisterSomeAndResolveUseSort() {
        let tokens1 = EntityInjectResolver.registerSome([SimpleContainer.make(), ObjContainer()])
        _ = tokens1.self
        
        guard let container1 = EntityInjectResolver.resolve(BaseContainer.self) else {
            XCTFail("Entity not found")
            return
        }
        XCTAssert(container1 is ObjContainer)
        
        EntityInjectResolver.removeAllForTests()
        
        let tokens2 = EntityInjectResolver.registerSome([ObjContainer(), SimpleContainer.make()])
        _ = tokens2.self
        guard let container2 = EntityInjectResolver.resolve(BaseContainer.self) else {
            XCTFail("Entity not found")
            return
        }
        XCTAssert(container2 is SimpleContainer)
    }
    
    func testRegisterAndResolveUseSort() {
        let token1 = EntityInjectResolver.register(SimpleContainer.make())
        let token2 = EntityInjectResolver.register(ObjContainer())
        
        guard let container1 = EntityInjectResolver.resolve(BaseContainer.self) else {
            XCTFail("Entity not found")
            return
        }
        XCTAssert(container1 is ObjContainer)
        
        EntityInjectResolver.removeAllForTests()
        
        let token3 = EntityInjectResolver.register(ObjContainer())
        let token4 = EntityInjectResolver.register(SimpleContainer.make())
        guard let container2 = EntityInjectResolver.resolve(BaseContainer.self) else {
            XCTFail("Entity not found")
            return
        }
        XCTAssert(container2 is SimpleContainer)
        
        _ = token1.self
        _ = token2.self
        _ = token3.self
        _ = token4.self
    }
    
    func testRemoveAndContains() {
        XCTAssertFalse(EntityInjectResolver.contains(SimpleContainer.self))
        
        let token1 = EntityInjectResolver.register(SimpleContainer.make())
        let token2 = EntityInjectResolver.register(SimpleContainer.make())
        let token3 = EntityInjectResolver.register(SimpleContainer.make())
        
        XCTAssertTrue(EntityInjectResolver.contains(SimpleContainer.self))
        
        EntityInjectResolver.remove(SimpleContainer.self)
        XCTAssertFalse(EntityInjectResolver.contains(SimpleContainer.self))
        
        _ = token1.self
        _ = token2.self
        _ = token3.self
    }
    
    func testRemoveUseToken() {
        XCTAssertFalse(EntityInjectResolver.contains(SimpleContainer.self))
        
        var token1: EntityInjectToken? = EntityInjectResolver.register(SimpleContainer.make())
        var token2: EntityInjectToken? = EntityInjectResolver.register(SimpleContainer.make())
        var token3: EntityInjectToken? = EntityInjectResolver.register(SimpleContainer.make())
        
        XCTAssertTrue(EntityInjectResolver.contains(SimpleContainer.self))
        
        token2 = nil
        XCTAssertTrue(EntityInjectResolver.contains(SimpleContainer.self))
        
        token1 = nil
        XCTAssertTrue(EntityInjectResolver.contains(SimpleContainer.self))
        
        token3 = nil
        XCTAssertFalse(EntityInjectResolver.contains(SimpleContainer.self))
        
        _ = token1.self
        _ = token2.self
        _ = token3.self
    }

    func testReadyContainer() {
        var isCall_1 = false
        let token_1 = EntityInjectResolver.addReadyContainerHandler(BaseContainer.self) {
            XCTAssertFalse(isCall_1)
            isCall_1 = true
            XCTAssertNotNil(EntityInjectResolver.resolve(BaseContainer.self))
        }
        XCTAssertNotNil(token_1)
        XCTAssertFalse(isCall_1)
        
        let tokenE1 = EntityInjectResolver.register(SimpleContainer.make())
        XCTAssertTrue(isCall_1)
        
        var isCall_2 = false
        let token_2 = EntityInjectResolver.addReadyContainerHandler(BaseContainer.self) {
            XCTAssertFalse(isCall_2)
            isCall_2 = true
        }
        XCTAssertNil(token_2)
        XCTAssertTrue(isCall_2)
        
        let tokenE2 = EntityInjectResolver.register(SimpleContainer.make())
        
        _ = token_1.self
        _ = token_2.self
        _ = tokenE1.self
        _ = tokenE2.self
    }
    
    func testReadyContainerInvalidate() {
        var token: EntityInjectReadyToken? = EntityInjectResolver.addReadyContainerHandler(BaseContainer.self) {
            XCTFail("Needed not call after remove token")
        }
        token = nil
        
        let tokenEntity = EntityInjectResolver.register(SimpleContainer.make())
        
        _ = token.self
        _ = tokenEntity.self
    }
    
    func testObserveOnce() {
        var isCall_1 = false
        let token_1 = EntityInjectResolver.observeOnce(BaseContainer.self) { _ in
            XCTAssertFalse(isCall_1)
            isCall_1 = true
        }
        XCTAssertNotNil(token_1)
        XCTAssertFalse(isCall_1)
        
        _ = EntityInjectResolver.register(SimpleContainer.make())
        XCTAssertTrue(isCall_1)
        
        var isCall_2 = false
        let token_2 = EntityInjectResolver.observeOnce(BaseContainer.self) { _ in
            XCTAssertFalse(isCall_2)
            isCall_2 = true
        }
        XCTAssertNotNil(token_2)
        XCTAssertFalse(isCall_2)
        
        EntityInjectResolver.registerForFirstInject(SimpleContainer.make())
        XCTAssertTrue(isCall_2)
        
        _ = token_1.self
        _ = token_2.self
    }
    
    func testObserveOnceInvalidate() {
        var token: EntityInjectReadyToken? = EntityInjectResolver.observeOnce(BaseContainer.self) { _ in
            XCTFail("Needed not call after remove token")
        }
        token = nil
        
        let tokenEntity = EntityInjectResolver.register(SimpleContainer.make())
        
        _ = token.self
        _ = tokenEntity.self
    }
}

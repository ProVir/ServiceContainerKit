//
//  ServiceInjectResolverTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 30.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceInjects

class ServiceInjectResolverTests: XCTestCase {

    override func tearDownWithError() throws {
        ServiceInjectResolver.removeAllForTests()
    }

    func testRegisterAndRemove() {
        let containerSrc = ObjContainer()
        ServiceInjectResolver.register(containerSrc)
        
        guard let containerDst = ServiceInjectResolver.resolve(ObjContainer.self) else {
            XCTFail("Container not found")
            return
        }
        
        XCTAssert(containerSrc === containerDst)
        
        ServiceInjectResolver.register(SimpleContainer.make())
        guard ServiceInjectResolver.resolve(SimpleContainer.self) != nil else {
            XCTFail("Container not found")
            return
        }
        
        ServiceInjectResolver.remove(ObjContainer.self)
        guard ServiceInjectResolver.resolve(ObjContainer.self) == nil else {
            XCTFail("Container not be found")
            return
        }
        
        ServiceInjectResolver.remove(SimpleContainer.self)
        guard ServiceInjectResolver.resolve(SimpleContainer.self) == nil else {
            XCTFail("Container not be found")
            return
        }
    }
    
    func testRegisterAsProtocol() {
        ServiceInjectResolver.register(SimpleContainer.makeAsProtocol())
        
        guard ServiceInjectResolver.resolve(SimpleContainer.self) != nil else {
            XCTFail("Container not found")
            return
        }
    }
    
    func testRegisterAndResolveAsProtocol() {
        ServiceInjectResolver.register(SimpleContainer.make())
        
        guard ServiceInjectResolver.resolve(BaseContainer.self) != nil else {
            XCTFail("Container not found")
            return
        }
    }
    
    func testRegisterSome() {
        ServiceInjectResolver.registerSome([SimpleContainer.make(), ObjContainer()])
        
        guard ServiceInjectResolver.resolve(SimpleContainer.self) != nil else {
            XCTFail("Container not found")
            return
        }
        
        guard ServiceInjectResolver.resolve(ObjContainer.self) != nil else {
            XCTFail("Container not found")
            return
        }
    }
    
    func testRegisterSomeAndResolveUseSort() {
        ServiceInjectResolver.registerSome([SimpleContainer.make(), ObjContainer()])
        guard let container1 = ServiceInjectResolver.resolve(BaseContainer.self) else {
            XCTFail("Container not found")
            return
        }
        XCTAssert(container1 is ObjContainer)
        
        ServiceInjectResolver.removeAllForTests()
        
        ServiceInjectResolver.registerSome([ObjContainer(), SimpleContainer.make()])
        guard let container2 = ServiceInjectResolver.resolve(BaseContainer.self) else {
            XCTFail("Container not found")
            return
        }
        XCTAssert(container2 is SimpleContainer)
    }
    
    func testRegisterAndResolveUseSort() {
        ServiceInjectResolver.register(SimpleContainer.make())
        ServiceInjectResolver.register(ObjContainer())
        
        guard let container1 = ServiceInjectResolver.resolve(BaseContainer.self) else {
            XCTFail("Container not found")
            return
        }
        XCTAssert(container1 is ObjContainer)
        
        ServiceInjectResolver.removeAllForTests()
        
        ServiceInjectResolver.register(ObjContainer())
        ServiceInjectResolver.register(SimpleContainer.make())
        guard let container2 = ServiceInjectResolver.resolve(BaseContainer.self) else {
            XCTFail("Container not found")
            return
        }
        XCTAssert(container2 is SimpleContainer)
    }
    
    func testRemoveAndContains() {
        XCTAssertFalse(ServiceInjectResolver.contains(SimpleContainer.self))
        
        ServiceInjectResolver.register(SimpleContainer.make())
        ServiceInjectResolver.register(SimpleContainer.make(), failureIfContains: false)
        ServiceInjectResolver.register(SimpleContainer.make(), failureIfContains: false)
        
        XCTAssertTrue(ServiceInjectResolver.contains(SimpleContainer.self))
        
        ServiceInjectResolver.remove(SimpleContainer.self)
        XCTAssertFalse(ServiceInjectResolver.contains(SimpleContainer.self))
    }
    
    func testRemoveOnlyLast() {
        XCTAssertFalse(ServiceInjectResolver.contains(SimpleContainer.self))
        
        ServiceInjectResolver.register(SimpleContainer.make())
        ServiceInjectResolver.register(SimpleContainer.make(), failureIfContains: false)
        ServiceInjectResolver.register(SimpleContainer.make(), failureIfContains: false)
        
        XCTAssertTrue(ServiceInjectResolver.contains(SimpleContainer.self))
        
        ServiceInjectResolver.remove(SimpleContainer.self, onlyLast: true)
        XCTAssertTrue(ServiceInjectResolver.contains(SimpleContainer.self))
        
        ServiceInjectResolver.remove(SimpleContainer.self, onlyLast: true)
        XCTAssertTrue(ServiceInjectResolver.contains(SimpleContainer.self))
        
        ServiceInjectResolver.remove(SimpleContainer.self, onlyLast: true)
        XCTAssertFalse(ServiceInjectResolver.contains(SimpleContainer.self))
    }
    
    func testContainsSome() {
        let containers: [Any] = [SimpleContainer.make(), ObjContainer()]
        XCTAssertFalse(ServiceInjectResolver.containsSomeForTests(containers))
        ServiceInjectResolver.registerSome(containers)
        
        XCTAssertTrue(ServiceInjectResolver.containsSomeForTests(containers))
        
        ServiceInjectResolver.remove(SimpleContainer.self)
        XCTAssertTrue(ServiceInjectResolver.containsSomeForTests(containers))
        
        ServiceInjectResolver.remove(ObjContainer.self)
        XCTAssertFalse(ServiceInjectResolver.containsSomeForTests(containers))
    }
    
    func testContainsSomeWithDuplicates() {
        let containers: [Any] = [SimpleContainer.make(), SimpleContainer.make()]
        XCTAssertFalse(ServiceInjectResolver.containsSomeForTests(containers))
        
        ServiceInjectResolver.registerSome(containers)
        
        XCTAssertTrue(ServiceInjectResolver.containsSomeForTests(containers))
        ServiceInjectResolver.remove(SimpleContainer.self)
        
        XCTAssertFalse(ServiceInjectResolver.containsSomeForTests(containers))
    }
    
    func testReadyContainer() {
        var isCall_1 = false
        let token_1 = ServiceInjectResolver.addReadyContainerHandler(BaseContainer.self) {
            XCTAssertFalse(isCall_1)
            isCall_1 = true
            XCTAssertNotNil(ServiceInjectResolver.resolve(BaseContainer.self))
        }
        XCTAssertNotNil(token_1)
        XCTAssertFalse(isCall_1)
        
        ServiceInjectResolver.register(SimpleContainer.make())
        XCTAssertTrue(isCall_1)
        
        var isCall_2 = false
        let token_2 = ServiceInjectResolver.addReadyContainerHandler(BaseContainer.self) {
            XCTAssertFalse(isCall_2)
            isCall_2 = true
        }
        XCTAssertNil(token_2)
        XCTAssertTrue(isCall_2)
        
        ServiceInjectResolver.register(SimpleContainer.make(), failureIfContains: false)
        
        _ = token_1.self
        _ = token_2.self
    }
    
    func testReadyContainerInvalidate() {
        var token: ServiceInjectReadyToken? = ServiceInjectResolver.addReadyContainerHandler(BaseContainer.self) {
            XCTFail("Needed not call after remove token")
        }
        token = nil
        
        ServiceInjectResolver.register(SimpleContainer.make())
        
        _ = token.self
    }
    
    func testObserveOnce() {
        var isCall_1 = false
        let token_1 = ServiceInjectResolver.observeOnce(BaseContainer.self) { _ in
            XCTAssertFalse(isCall_1)
            isCall_1 = true
        }
        XCTAssertNotNil(token_1)
        XCTAssertFalse(isCall_1)
        
        ServiceInjectResolver.register(SimpleContainer.make())
        XCTAssertTrue(isCall_1)
        
        var isCall_2 = false
        let token_2 = ServiceInjectResolver.observeOnce(BaseContainer.self) { _ in
            XCTAssertFalse(isCall_2)
            isCall_2 = true
        }
        XCTAssertNotNil(token_2)
        XCTAssertFalse(isCall_2)
        
        ServiceInjectResolver.register(SimpleContainer.make(), failureIfContains: false)
        XCTAssertTrue(isCall_2)
        
        _ = token_1.self
        _ = token_2.self
    }
    
    func testObserveOnceInvalidate() {
        var token: ServiceInjectReadyToken? = ServiceInjectResolver.observeOnce(BaseContainer.self) { _ in
            XCTFail("Needed not call after remove token")
        }
        token = nil
        
        ServiceInjectResolver.register(SimpleContainer.make())
        
        _ = token.self
    }
}


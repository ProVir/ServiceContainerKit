//
//  SessionMediatorTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 21.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class ServiceSessionMediatorTests: XCTestCase {
    
    func testSendToObserver() {
        var key = "begin"
        let mediator = makeMediator(beginKey: key)
        XCTAssertEqual(mediator.session.key, key)
        
        key = "begin second"
        mediator.updateSession(.init(key: key))
        XCTAssertEqual(mediator.session.key, key)
        
        let tester = ObserverTester(mediator: mediator)
        tester.validateNoCalled()
        
        key = "1"
        mediator.updateSession(.init(key: key))
        XCTAssertEqual(mediator.session.key, key)
        tester.validateCall(key: key)
        tester.prepareCall()
        
        key = "2"
        mediator.updateSession(.init(key: key))
        XCTAssertEqual(mediator.session.key, key)
        tester.validateCall(key: key, policy: .none)
        tester.prepareCall()
        
        key = "3"
        mediator.updateSession(.init(key: key), remakePolicy: .force)
        XCTAssertEqual(mediator.session.key, key)
        tester.validateCall(key: key, policy: .force)
        tester.prepareCall()
        
        key = "4"
        mediator.updateSession(.init(key: key), remakePolicy: .clearAll)
        XCTAssertEqual(mediator.session.key, key)
        tester.validateCall(key: key, policy: .clearAll)
    }
    
    func testSendToSeveralObserver() {
        let mediator = makeMediator()
        let testerOne = ObserverTester(mediator: mediator)
        let testerTwo = ObserverTester(mediator: mediator)
        let testerThree = ObserverTester(mediator: mediator)
        
        var key = "some"
        mediator.updateSession(.init(key: key))
        XCTAssertEqual(mediator.session.key, key)
        testerOne.validateCall(key: key)
        testerTwo.validateCall(key: key)
        testerThree.validateCall(key: key)
        testerOne.prepareCall()
        testerTwo.prepareCall()
        testerThree.prepareCall()
        
        key = "other"
        mediator.updateSession(.init(key: key), remakePolicy: .clearAll)
        XCTAssertEqual(mediator.session.key, key)
        testerOne.validateCall(key: key, policy: .clearAll)
        testerTwo.validateCall(key: key, policy: .clearAll)
        testerThree.validateCall(key: key, policy: .clearAll)
    }
    
    func testInvalidateObserver() {
        let mediator = makeMediator()
        let testerOne = ObserverTester(mediator: mediator)
        let testerTwo = ObserverTester(mediator: mediator)
        
        var key = "some"
        mediator.updateSession(.init(key: key))
        XCTAssertEqual(mediator.session.key, key)
        testerOne.validateCall(key: key)
        testerTwo.validateCall(key: key)
        testerOne.prepareCall()
        testerTwo.prepareCall()
        
        key = "other"
        testerOne.invalidate()
        mediator.updateSession(.init(key: key), remakePolicy: .clearAll)
        XCTAssertEqual(mediator.session.key, key)
        testerOne.validateNoCalled()
        testerTwo.validateCall(key: key, policy: .clearAll)
        testerTwo.prepareCall()
        
        key = "three"
        testerTwo.invalidate()
        mediator.updateSession(.init(key: key), remakePolicy: .clearAll)
        XCTAssertEqual(mediator.session.key, key)
        testerOne.validateNoCalled()
        testerTwo.validateNoCalled()
    }
    
    func testVoidMediator() {
        let mediator = ServiceVoidSessionMediator()
        
        var isCalled = false
        var calledPolicy: ServiceSessionRemakePolicy = .none
        let token = mediator.addObserver { (_, policy, step) in
            if step == .general {
                XCTAssertFalse(isCalled)
            } else {
                XCTAssertTrue(isCalled)
            }
            isCalled = true
            calledPolicy = policy
        }
        
        mediator.clearServices()
        XCTAssertTrue(isCalled)
        XCTAssertEqual(calledPolicy, .clearAll)
        
        _ = token.self //Fix warning value 'token' was never used
    }
}

private extension ServiceSessionMediatorTests {
    class ObserverTester {
        private var token: ServiceSessionMediatorToken?
        private var isCalled = false
        private var calledSessionKey: AnyHashable?
        private var calledPolicy: ServiceSessionRemakePolicy = .none
        private var calledStep: ServiceSessionMediatorPerformStep = .general
        
        init(mediator: ServiceSessionMediator<SimpleServiceSession>) {
            token = mediator.addObserver { [unowned self] (session, policy, step) in
                if step == .general {
                    XCTAssertFalse(self.isCalled)
                } else {
                    XCTAssertTrue(self.isCalled)
                    XCTAssertEqual(self.calledStep, .general)
                }
                
                self.isCalled = true
                self.calledSessionKey = session.key
                self.calledPolicy = policy
                self.calledStep = step
            }
        }
        
        func prepareCall() {
            isCalled = false
            calledSessionKey = nil
            calledPolicy = .none
            calledStep = .general
        }
        
        func invalidate() {
            token = nil
        }
        
        func validateCall(key: AnyHashable, file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertTrue(isCalled, file: file, line: line)
            XCTAssertEqual(calledStep, .make, file: file, line: line)
            XCTAssertEqual(key, calledSessionKey, file: file, line: line)
        }
        
        func validateCall(key: AnyHashable, policy: ServiceSessionRemakePolicy, file: StaticString = #filePath, line: UInt = #line) {
            validateCall(key: key, file: file, line: line)
            XCTAssertEqual(policy, calledPolicy, file: file, line: line)
        }
        
        func validateNoCalled(file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertFalse(isCalled, file: file, line: line)
        }
    }
    
    func makeMediator(beginKey: AnyHashable = "") -> ServiceSessionMediator<SimpleServiceSession> {
        return .init(session: .init(key: beginKey))
    }
}

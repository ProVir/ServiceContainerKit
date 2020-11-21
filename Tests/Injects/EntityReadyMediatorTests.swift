//
//  EntityReadyMediatorTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 21.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class EntityReadyMediatorTests: XCTestCase {

    func testOnceObserver()  {
        let mediator = EntityReadyMediator()
        
        var model = SimpleFirstModel(value: "")
        var isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        
        let tester = ObserverTester<SimpleFirstModel>(mediator: mediator)
        tester.validateNoCalled()
        
        model.value = "1"
        isNotified = mediator.notify(model)
        XCTAssertTrue(isNotified)
        tester.validate(model: model)
        tester.prepareCall()
        
        model.value = "2"
        isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        tester.validateNoCalled()
    }
    
    func testInvalidateObserver()  {
        let mediator = EntityReadyMediator()
        
        var model = SimpleFirstModel(value: "")
        var isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        
        let tester = ObserverTester<SimpleFirstModel>(mediator: mediator)
        tester.validateNoCalled()
        tester.invalidate()
        
        model.value = "1"
        isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        tester.validateNoCalled()
    }

    func testSeveralObservers()  {
        let mediator = EntityReadyMediator()
        
        var model = SimpleFirstModel(value: "")
        var isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        
        let testerOne = ObserverTester<SimpleFirstModel>(mediator: mediator)
        let testerTwo = ObserverTester<SimpleFirstModel>(mediator: mediator)
        testerOne.validateNoCalled()
        testerTwo.validateNoCalled()
        
        model.value = "1"
        isNotified = mediator.notify(model)
        XCTAssertTrue(isNotified)
        testerOne.validate(model: model)
        testerTwo.validate(model: model)
        testerOne.prepareCall()
        testerTwo.prepareCall()
        
        model.value = "2"
        isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        testerOne.validateNoCalled()
        testerTwo.validateNoCalled()
    }
    
    func testManyModels()  {
        let mediator = EntityReadyMediator()
        
        var modelFirst = SimpleFirstModel(value: "1")
        var modelSecond = SimpleSecondModel(value: "2")
        var isNotified = mediator.notify(modelFirst)
        XCTAssertFalse(isNotified)
        
        let testerFirst = ObserverTester<SimpleFirstModel>(mediator: mediator)
        let testerSecond = ObserverTester<SimpleSecondModel>(mediator: mediator)
        testerFirst.validateNoCalled()
        
        modelFirst.value = "3"
        isNotified = mediator.notify(modelFirst)
        XCTAssertTrue(isNotified)
        testerFirst.validate(model: modelFirst)
        testerSecond.validateNoCalled()
        testerFirst.prepareCall()
        
        modelSecond.value = "4"
        isNotified = mediator.notify(modelSecond)
        XCTAssertTrue(isNotified)
        testerSecond.validate(model: modelSecond)
        testerFirst.validateNoCalled()
        testerSecond.prepareCall()
    }
    
    func testSomeModels()  {
        let mediator = EntityReadyMediator()
        
        var modelFirst = SimpleFirstModel(value: "1")
        var modelSecond = SimpleSecondModel(value: "2")
        var isNotified = mediator.notify(modelFirst)
        XCTAssertFalse(isNotified)
        
        let testerFirst = ObserverTester<SimpleFirstModel>(mediator: mediator)
        let testerSecond = ObserverTester<SimpleSecondModel>(mediator: mediator)
        testerFirst.validateNoCalled()
        
        modelFirst.value = "3"
        modelSecond.value = "4"
        isNotified = mediator.notifySome([modelFirst, modelSecond])
        XCTAssertTrue(isNotified)
        testerFirst.validate(model: modelFirst)
        testerSecond.validate(model: modelSecond)
        testerFirst.prepareCall()
        testerSecond.prepareCall()
        
        modelFirst.value = "5"
        modelSecond.value = "6"
        isNotified = mediator.notifySome([modelFirst, modelSecond])
        XCTAssertFalse(isNotified)
        testerFirst.validateNoCalled()
        testerSecond.validateNoCalled()
        testerFirst.prepareCall()
        testerSecond.prepareCall()
        
        modelFirst.value = "7"
        isNotified = mediator.notify(modelFirst)
        XCTAssertFalse(isNotified)
        
        modelSecond.value = "8"
        isNotified = mediator.notify(modelSecond)
        XCTAssertFalse(isNotified)
        
        testerFirst.validateNoCalled()
        testerSecond.validateNoCalled()
    }
}

private extension EntityReadyMediatorTests {
    class ObserverTester<T: Equatable> {
        private var token: EntityReadyToken?
        private var isCalled = false
        private var calledModel: T?
        
        init(mediator: EntityReadyMediator) {
            token = mediator.observeOnce(T.self) { [unowned self] model in
                XCTAssertFalse(self.isCalled)
                self.isCalled = true
                self.calledModel = model
            }
        }
        
        func prepareCall() {
            isCalled = false
            calledModel = nil
        }
        
        func invalidate() {
            token = nil
        }
        
        func validate(model: T, file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertTrue(isCalled, file: file, line: line)
            XCTAssertEqual(calledModel, model, file: file, line: line)
        }
        
        func validateNoCalled(file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertFalse(isCalled, file: file, line: line)
        }
    }
}

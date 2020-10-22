//
//  MultipleMediatorTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 21.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class MultipleMediatorTests: XCTestCase {

    func testOneObserver()  {
        let mediator = MultipleMediator()
        
        var model = SimpleFirstModel(value: "")
        var isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        
        let tester = ObserverTester<SimpleFirstModel>(mediator: mediator, single: false)
        tester.validateNoCalled()
        
        model.value = "1"
        isNotified = mediator.notify(model)
        XCTAssertTrue(isNotified)
        tester.validate(model: model)
        tester.prepareCall()
        
        model.value = "2"
        isNotified = mediator.notify(model)
        XCTAssertTrue(isNotified)
        tester.validate(model: model)
    }
    
    func testSingleObserver()  {
        let mediator = MultipleMediator()
        
        var model = SimpleFirstModel(value: "")
        var isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        
        let tester = ObserverTester<SimpleFirstModel>(mediator: mediator, single: true)
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
        let mediator = MultipleMediator()
        
        var model = SimpleFirstModel(value: "")
        var isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        
        let tester = ObserverTester<SimpleFirstModel>(mediator: mediator, single: false)
        tester.validateNoCalled()
        
        model.value = "1"
        isNotified = mediator.notify(model)
        XCTAssertTrue(isNotified)
        tester.validate(model: model)
        tester.prepareCall()
        tester.invalidate()
        
        model.value = "2"
        isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        tester.validateNoCalled()
    }

    func testSeveralObservers()  {
        let mediator = MultipleMediator()
        
        var model = SimpleFirstModel(value: "")
        var isNotified = mediator.notify(model)
        XCTAssertFalse(isNotified)
        
        let testerOne = ObserverTester<SimpleFirstModel>(mediator: mediator, single: false)
        let testerTwo = ObserverTester<SimpleFirstModel>(mediator: mediator, single: false)
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
        XCTAssertTrue(isNotified)
        testerOne.validate(model: model)
        testerTwo.validate(model: model)
    }
    
    func testManyModels()  {
        let mediator = MultipleMediator()
        
        var modelFirst = SimpleFirstModel(value: "0.1")
        var modelSecond = SimpleSecondModel(value: "0.2")
        var isNotified = mediator.notify(modelFirst)
        XCTAssertFalse(isNotified)
        
        let testerFirst = ObserverTester<SimpleFirstModel>(mediator: mediator, single: false)
        let testerSecond = ObserverTester<SimpleSecondModel>(mediator: mediator, single: false)
        testerFirst.validateNoCalled()
        
        modelFirst.value = "1.1"
        isNotified = mediator.notify(modelFirst)
        XCTAssertTrue(isNotified)
        testerFirst.validate(model: modelFirst)
        testerSecond.validateNoCalled()
        testerFirst.prepareCall()
        
        modelSecond.value = "1.2"
        isNotified = mediator.notify(modelSecond)
        XCTAssertTrue(isNotified)
        testerSecond.validate(model: modelSecond)
        testerFirst.validateNoCalled()
        testerSecond.prepareCall()
        
        modelFirst.value = "2.1"
        modelSecond.value = "2.2"
        isNotified = mediator.notifySome([modelFirst, modelSecond])
        XCTAssertTrue(isNotified)
        testerFirst.validate(model: modelFirst)
        testerSecond.validate(model: modelSecond)
    }
}

private extension MultipleMediatorTests {
    class ObserverTester<T: Equatable> {
        private var token: MultipleMediatorToken?
        private var isCalled = false
        private var calledModel: T?
        
        init(mediator: MultipleMediator, single: Bool) {
            token = mediator.observe(T.self, single: single) { [unowned self] model in
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

//
//  ObservableValueTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 23.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class ObservableValueTests: XCTestCase {

    // MARK: ObservableValue
    func testChangeValue() {
        let wrapper = TextWrapper()
        wrapper.value = "1"
        XCTAssertEqual(wrapper.value, "1")
        
        wrapper.value = "2"
        XCTAssertEqual(wrapper.value, "2")
    }
    
    func testOneObserver() {
        let wrapper = TextWrapper()
        wrapper.value = "0"
        
        var isCalled = true
        var testValue: String = ""
        let token = wrapper.$value.observe { value in
            XCTAssertFalse(isCalled)
            XCTAssertEqual(testValue, value)
            isCalled = true
        }
        
        isCalled = false
        testValue = "1"
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        isCalled = false
        testValue = "2"
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        isCalled = false
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        _ = token.self
    }
    
    func testInitialObserver() {
        let wrapper = TextWrapper()
        wrapper.value = "0"
        
        var isCalled = false
        var testValue: String = wrapper.value
        let token = wrapper.$value.observe(initial: true) { value in
            XCTAssertFalse(isCalled)
            XCTAssertEqual(testValue, value)
            isCalled = true
        }
        XCTAssertTrue(isCalled)
        
        isCalled = false
        testValue = "1"
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        _ = token.self
    }
    
    func testAtOnceObserver() {
        let wrapper = TextWrapper()
        wrapper.value = "0"
        
        var isCalled = true
        var testValue: String = ""
        let token = wrapper.$value.observeOnce { value in
            XCTAssertFalse(isCalled)
            XCTAssertEqual(testValue, value)
            isCalled = true
        }
        
        isCalled = false
        testValue = "1"
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        isCalled = false
        testValue = "2"
        wrapper.value = testValue
        XCTAssertFalse(isCalled)
  
        _ = token.self
    }
    
    func testInvalidateObserver() {
        let wrapper = TextWrapper()
        wrapper.value = "0"
        
        var isCalled = true
        var testValue: String = ""
        var token: ObservableValueToken? = wrapper.$value.observe { value in
            XCTAssertFalse(isCalled)
            XCTAssertEqual(testValue, value)
            isCalled = true
        }
        
        isCalled = false
        testValue = "1"
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        token = nil
        
        isCalled = false
        testValue = "2"
        wrapper.value = testValue
        XCTAssertFalse(isCalled)
        
        _ = token.self
    }
    
    func testSeveralObservers() {
        let wrapper = TextWrapper()
        wrapper.value = "0"
        
        var testValue: String = ""
        
        var isCalledFirst = true
        var isCalledSecond = true
        let tokenFirst = wrapper.$value.observe { value in
            XCTAssertFalse(isCalledFirst)
            XCTAssertEqual(testValue, value)
            isCalledFirst = true
        }
        let tokenSecond = wrapper.$value.observe { value in
            XCTAssertFalse(isCalledSecond)
            XCTAssertEqual(testValue, value)
            isCalledSecond = true
        }
        
        isCalledFirst = false
        isCalledSecond = false
        testValue = "1"
        wrapper.value = testValue
        XCTAssertTrue(isCalledFirst)
        XCTAssertTrue(isCalledSecond)
        
        isCalledFirst = false
        isCalledSecond = false
        testValue = "2"
        wrapper.value = testValue
        XCTAssertTrue(isCalledFirst)
        XCTAssertTrue(isCalledSecond)
        
        _ = tokenFirst.self
        _ = tokenSecond.self
    }
    
    // MARK: ObservableEquatableValue
    func testChangeEqualValue() {
        let wrapper = IdOnlyEqualWrapper()
        wrapper.value.id = "some"
        wrapper.value.noCompareValue = "1"
        XCTAssertEqual(wrapper.value.noCompareValue, "1")
        
        wrapper.value.noCompareValue = "2"
        XCTAssertEqual(wrapper.value.noCompareValue, "2")
    }
    
    func testNoChangedEqualValue() {
        let wrapper = IdOnlyEqualWrapper()
        wrapper.value.id = "0"
        
        var isCalled = true
        var testValue: IdOnlyEqualValue = wrapper.value
        let token = wrapper.$value.observe { value in
            XCTAssertFalse(isCalled)
            XCTAssertEqual(testValue.id, value.id)
            XCTAssertEqual(testValue.noCompareValue, value.noCompareValue)
            isCalled = true
        }
        
        isCalled = false
        testValue.id = "1"
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        isCalled = false
        testValue.id = "1"
        wrapper.value = testValue
        XCTAssertFalse(isCalled)
        
        isCalled = false
        testValue.noCompareValue = "123"
        wrapper.value = testValue
        XCTAssertFalse(isCalled)
        
        isCalled = false
        testValue.id = "234"
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        _ = token.self
    }
    
    func testInitialEqualObserver() {
        let wrapper = IdOnlyEqualWrapper()
        wrapper.value.id = "0"
        wrapper.value.noCompareValue = "1"
        wrapper.value.noCompareValue = "2"
        
        var isCalled = false
        var testValue = wrapper.value
        let token = wrapper.$value.observe(initial: true) { value in
            XCTAssertFalse(isCalled)
            XCTAssertEqual(testValue.id, value.id)
            XCTAssertEqual(testValue.noCompareValue, value.noCompareValue)
            isCalled = true
        }
        XCTAssertTrue(isCalled)
        
        isCalled = false
        testValue.noCompareValue = "3"
        wrapper.value = testValue
        XCTAssertFalse(isCalled)
        
        isCalled = false
        testValue.id = "1"
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        _ = token.self
    }
    
    func testAtOnceEqualObserver() {
        let wrapper = IdOnlyEqualWrapper()
        wrapper.value.id = "0"
        
        var isCalled = true
        var testValue = wrapper.value
        let token = wrapper.$value.observeOnce { value in
            XCTAssertFalse(isCalled)
            XCTAssertEqual(testValue.id, value.id)
            XCTAssertEqual(testValue.noCompareValue, value.noCompareValue)
            isCalled = true
        }
        
        isCalled = false
        testValue.noCompareValue = "3"
        wrapper.value = testValue
        XCTAssertFalse(isCalled)
        
        isCalled = false
        testValue.id = "1"
        wrapper.value = testValue
        XCTAssertTrue(isCalled)
        
        isCalled = false
        testValue.id = "2"
        wrapper.value = testValue
        XCTAssertFalse(isCalled)
  
        _ = token.self
    }
}

// MARK: Helpers
private extension ObservableValueTests {
    struct IdOnlyEqualValue: Equatable {
        var id: String
        var noCompareValue: String
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    class TextWrapper {
        @ObservableValue
        var value = ""
    }
    
    class IdOnlyEqualWrapper {
        @ObservableEquatableValue
        var value = IdOnlyEqualValue(id: "", noCompareValue: "")
    }
}

//
//  ServiceLocatorTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 21/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class ServiceLocatorTests: XCTestCase {
    
    func testReadOnly() {
        let serviceLocator = ServiceLocator()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, service: ServiceSingleton())
        serviceLocator.setReadOnly(assertionFailure: false)
        
        serviceLocator.addService(key: ServiceLocatorKeys.serviceLazy, factory: SpyServiceLazyFactory())
        
        if serviceLocator.getService(key: ServiceLocatorKeys.serviceSingleton) == nil {
            XCTFail("Service not found")
        }
        
        if serviceLocator.getService(key: ServiceLocatorKeys.serviceLazy) != nil {
            XCTFail("Service not be found")
        }
    }

    func testClone() {
        let serviceLocator1 = ServiceLocator()
        serviceLocator1.addService(key: ServiceLocatorKeys.serviceSingleton, service: ServiceSingleton())
        serviceLocator1.setReadOnly()
        
        let serviceLocator2 = serviceLocator1.clone()
        serviceLocator2.addService(key: ServiceLocatorKeys.serviceLazy, factory: SpyServiceLazyFactory())
        
        guard let servcie1 = serviceLocator1.getService(key: ServiceLocatorKeys.serviceSingleton) else {
            XCTFail("Service not found")
            return
        }
        
        guard let servcie2 = serviceLocator2.getService(key: ServiceLocatorKeys.serviceSingleton) else {
            XCTFail("Service not found")
            return
        }
        
        XCTAssert(servcie1 === servcie2, "Service singleton after clone also remains singleton")
        
        if serviceLocator1.getService(key: ServiceLocatorKeys.serviceLazy) != nil {
            XCTFail("Service not be found")
        }
        
        if serviceLocator2.getService(key: ServiceLocatorKeys.serviceLazy) == nil {
            XCTFail("Service not found")
        }
    }
    
    func testAddServiceProvider() {
        let serviceLocator = ServiceLocator()
        
        let provider1 = SpyServiceSingletonFactory().serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, provider: provider1)
        
        let provider2 = SpyServiceLazyFactory(error: ServiceCreateError.someError).serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceLazy, provider: provider2)
        
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetFailureService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceMany)
    }

    func testAddServiceParamsProvider() {
        let serviceLocator = ServiceLocator()
        
        let provider = SpyServiceParamsFactory().serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceParams, provider: provider)
        
        guard let service = serviceLocator.getService(key: ServiceLocatorKeys.serviceParams,
                                                      params: .init(value: "Test1", error: nil)) else {
            XCTFail("Service not found")
            return
        }
        
        XCTAssertEqual(service.value, "Test1")
        
        doTestGetErrorService(serviceLocator, key: ServiceLocatorKeys.serviceParams, error: ServiceLocatorError.wrongParams)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
    }
    
    func testAddServiceFactory() {
        let serviceLocator = ServiceLocator()
        
        let factory1 = SpyServiceSingletonFactory()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, factory: factory1)
        
        let factory2 = SpyServiceLazyFactory(error: ServiceCreateError.someError)
        serviceLocator.addService(key: ServiceLocatorKeys.serviceLazy, factory: factory2)
        
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetFailureService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceMany)
    }
    
    func testAddServiceParamsFactory() {
        let serviceLocator = ServiceLocator()
        
        let factory = SpyServiceParamsFactory()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceParams, factory: factory)
        
        guard let service = serviceLocator.getService(key: ServiceLocatorKeys.serviceParams,
                                                      params: .init(value: "Test1", error: nil)) else {
                                                        XCTFail("Service not found")
                                                        return
        }
        
        XCTAssertEqual(service.value, "Test1")
        
        doTestGetErrorService(serviceLocator, key: ServiceLocatorKeys.serviceParams, error: ServiceLocatorError.wrongParams)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
    }
    
    func testAddServiceAsProtocol() {
        let serviceLocator = ServiceLocator()
        
        let provider = SpyServiceValueFactory<ServiceSingleton>.init(factoryType: .atOne).serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingletonValue, provider: provider)
        
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingletonValue)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
    }
    
    func testAddServiceParamsAsProtocol() {
        let serviceLocator = ServiceLocator()
        
        let provider = SpyServiceParamsValueFactory().serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceParamsValue, provider: provider)
        
        guard let service = serviceLocator.getService(key: ServiceLocatorKeys.serviceParamsValue,
                                                      params: .init(value: "Test1", error: nil)) else {
                                                        XCTFail("Service not found")
                                                        return
        }
        
        XCTAssertEqual(service.value, "Test1")
        
        doTestGetErrorService(serviceLocator, key: ServiceLocatorKeys.serviceParamsValue, error: ServiceLocatorError.wrongParams)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceParams)
    }
    
    func testAddServiceOptParamsProvider() {
        let serviceLocator = ServiceLocator()
        
        let provider = SpyServiceOptParamsFactory().serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceOptParams, provider: provider)
        
        guard let service1 = serviceLocator.getService(key: ServiceLocatorKeys.serviceOptParams,
                                                      params: .init(value: "Test1", error: nil)) else {
                                                        XCTFail("Service not found")
                                                        return
        }
        
        guard let service2 = serviceLocator.getService(key: ServiceLocatorKeys.serviceOptParams) else {
                                                        XCTFail("Service not found")
                                                        return
        }
        
        XCTAssertEqual(service1.value, "Test1")
        XCTAssertEqual(service2.value, "Default")
        
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
    }
    
    func testAddServiceSingletonService() {
        let serviceLocator = ServiceLocator()
        
        let service = ServiceSingleton()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, service: service)
        
        guard let serviceGet = serviceLocator.getService(key: ServiceLocatorKeys.serviceSingleton) else {
            XCTFail("Service not found")
            return
        }
        
        service.value = "Test3"
        XCTAssertEqual(serviceGet.value, "Test3")
        XCTAssert(service === serviceGet)
        
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceMany)
    }
    
    func testAddServiceLazyClosure() {
        let serviceLocator = ServiceLocator()
        
        var callCount = 0
        var errorClosure: Error? = ServiceCreateError.someError
        serviceLocator.addLazyService(key: ServiceLocatorKeys.serviceLazy) {
            callCount += 1
            if let error = errorClosure {
                throw error
            } else {
                return ServiceLazy()
            }
        }
        
        XCTAssertEqual(callCount, 0, "Real create service when first needed")
        
        if serviceLocator.getService(key: ServiceLocatorKeys.serviceLazy) != nil {
            XCTFail("Service need failure create")
        }
        
        XCTAssertEqual(callCount, 1, "Real create service when first needed")
        
        do {
            _ = try serviceLocator.tryService(key: ServiceLocatorKeys.serviceLazy)
            XCTFail("Service need failure create")
        } catch {
            XCTAssert(error is ServiceCreateError)
        }
        
        XCTAssertEqual(callCount, 2, "While the error repeats - try to re-create")
        
        //Next without error
        errorClosure = nil
        guard let service1 = serviceLocator.getService(key: ServiceLocatorKeys.serviceLazy) else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 3, "While the error repeats - try to re-create")
        
        service1.value = "Test1"
        guard let service2 = serviceLocator.getService(key: ServiceLocatorKeys.serviceLazy) else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 3)
        XCTAssertEqual(service2.value,"Test1")
        
        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
        
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
    }
    
    func testAddServiceManyClosure() {
        let serviceLocator = ServiceLocator()
        
        var callCount = 0
        var errorClosure: Error? = ServiceCreateError.someError
        serviceLocator.addService(key: ServiceLocatorKeys.serviceManyValue) {
            callCount += 1
            if let error = errorClosure {
                throw error
            } else {
                return ServiceMany()
            }
        }
        
        XCTAssertEqual(callCount, 0, "Real create service when needed")
        
        if serviceLocator.getService(key: ServiceLocatorKeys.serviceManyValue) != nil {
            XCTFail("Service need failure create")
        }
        
        XCTAssertEqual(callCount, 1, "Create service new with error")
        
        do {
            _ = try serviceLocator.tryService(key: ServiceLocatorKeys.serviceManyValue)
            XCTFail("Service need failure create")
        } catch {
            XCTAssert(error is ServiceCreateError)
        }
        
        XCTAssertEqual(callCount, 2, "Create service new with error")
        
        //Next without error
        errorClosure = nil
        guard let service1 = serviceLocator.getService(key: ServiceLocatorKeys.serviceManyValue) else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 3, "Create service new")
        
        service1.value = "Test1"
        guard let service2 = serviceLocator.getService(key: ServiceLocatorKeys.serviceManyValue) else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 4)
        XCTAssertNotEqual(service2.value, "Test1")
        
        service2.value = "Test2"
        XCTAssertNotEqual(service1.value, "Test2")
        XCTAssert(service1 !== service2)
        
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceManyValue)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceMany)
    }
    
    
    
}

extension ServiceLocatorTests {
    private func doTestGetSuccessService<Key: ServiceLocatorKey>(_ serviceLocator: ServiceLocator, key: Key, file: StaticString = #file, line: UInt = #line) {
        if serviceLocator.getService(key: key) == nil {
            XCTFail("Service not found", file: file, line: line)
        }
    }
    
    private func doTestGetFailureService<Key: ServiceLocatorKey>(_ serviceLocator: ServiceLocator, key: Key, file: StaticString = #file, line: UInt = #line) {
        doTestGetErrorService(serviceLocator, key: key, error: ServiceCreateError.someError, file: file, line: line)
    }
    
    private func doTestGetNotFoundService<Key: ServiceLocatorKey>(_ serviceLocator: ServiceLocator, key: Key, file: StaticString = #file, line: UInt = #line) {
        doTestGetErrorService(serviceLocator, key: key, error: ServiceLocatorError.serviceNotFound, file: file, line: line)
    }
    
    private func doTestGetErrorService<Key: ServiceLocatorKey, E: Error & Equatable>(_ serviceLocator: ServiceLocator, key: Key, error errorService: E, file: StaticString = #file, line: UInt = #line) {
        do {
            _ = try serviceLocator.tryService(key: key)
            XCTFail("Service not be found", file: file, line: line)
        } catch {
            if let error = error as? E {
                XCTAssertEqual(error, errorService, file: file, line: line)
            } else {
                XCTFail("Unknown error \(error)", file: file, line: line)
            }
        }
    }
}

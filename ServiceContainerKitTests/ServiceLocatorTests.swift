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
    var serviceLocator = ServiceLocator()

    override func tearDown() {
        serviceLocator = ServiceLocator()
    }
    
    func testReadOnly() {
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, service: ServiceSingleton())
        serviceLocator.setReadOnly(assertionFailure: false)
        
        serviceLocator.addService(key: ServiceLocatorKeys.serviceLazy, factory: SpyServiceLazyFactory())
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)

        serviceLocator.removeService(key: ServiceLocatorKeys.serviceSingleton)
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
    }

    func testClone() {
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, service: ServiceSingleton())
        serviceLocator.setReadOnly()
        
        let serviceLocator2 = serviceLocator.clone()
        serviceLocator2.addService(key: ServiceLocatorKeys.serviceLazy, factory: SpyServiceLazyFactory())
        
        guard let servcie1 = serviceLocator.getService(key: ServiceLocatorKeys.serviceSingleton) else {
            XCTFail("Service not found")
            return
        }
        
        guard let servcie2 = serviceLocator2.getService(key: ServiceLocatorKeys.serviceSingleton) else {
            XCTFail("Service not found")
            return
        }
        
        XCTAssert(servcie1 === servcie2, "Service singleton after clone also remains singleton")
        
        if serviceLocator.getService(key: ServiceLocatorKeys.serviceLazy) != nil {
            XCTFail("Service not be found")
        }
        
        if serviceLocator2.getService(key: ServiceLocatorKeys.serviceLazy) == nil {
            XCTFail("Service not found")
        }
    }
    
    func testAddServiceProvider() {
        let factorySingleton = SpyServiceSingletonFactory()
        let provider1 = factorySingleton.serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, provider: provider1)

        let factoryLazyError = SpyServiceLazyFactory(error: ServiceCreateError.someError)
        let provider2 = factoryLazyError.serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceLazy, provider: provider2)

        XCTAssertEqual(factorySingleton.callCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factoryLazyError.callCount, 0, "Real create service when first needed")
        
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetFailureService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceMany)

        XCTAssertEqual(factorySingleton.callCount, 1)
        XCTAssertEqual(factoryLazyError.callCount, 1)

        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetFailureService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)

        XCTAssertEqual(factorySingleton.callCount, 1)
        XCTAssertEqual(factoryLazyError.callCount, 2,  "While the error repeats - try to re-create")
    }

    func testAddServiceParamsProvider() {
        let factory = SpyServiceParamsFactory()
        let provider = factory.serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceParams, provider: provider)

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")
        
        guard let service = serviceLocator.getService(key: ServiceLocatorKeys.serviceParams,
                                                      params: .init(value: "Test1", error: nil)) else {
            XCTFail("Service not found")
            return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service.value, "Test1")
        
        doTestGetErrorService(serviceLocator, key: ServiceLocatorKeys.serviceParams, error: ServiceLocatorError.wrongParams)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
    }
    
    func testAddServiceFactory() {
        let factorySingleton = SpyServiceSingletonFactory()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, factory: factorySingleton)
        
        let factoryLazyError = SpyServiceLazyFactory(error: ServiceCreateError.someError)
        serviceLocator.addService(key: ServiceLocatorKeys.serviceLazy, factory: factoryLazyError)

        XCTAssertEqual(factorySingleton.callCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factoryLazyError.callCount, 0, "Real create service when first needed")
        
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetFailureService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceMany)

        XCTAssertEqual(factorySingleton.callCount, 1)
        XCTAssertEqual(factoryLazyError.callCount, 1)

        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetFailureService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)

        XCTAssertEqual(factorySingleton.callCount, 1)
        XCTAssertEqual(factoryLazyError.callCount, 2,  "While the error repeats - try to re-create")
    }
    
    func testAddServiceParamsFactory() {
        let factory = SpyServiceParamsFactory()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceParams, factory: factory)

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")
        
        guard let service = serviceLocator.getService(key: ServiceLocatorKeys.serviceParams,
                                                      params: .init(value: "Test1", error: nil)) else {
                                                        XCTFail("Service not found")
                                                        return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service.value, "Test1")
        
        doTestGetErrorService(serviceLocator, key: ServiceLocatorKeys.serviceParams, error: ServiceLocatorError.wrongParams)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
    }
    
    func testAddServiceAsProtocol() {
        let factory = SpyServiceValueFactory<ServiceSingleton>.init(factoryType: .atOne)
        let provider = factory.serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingletonValue, provider: provider)

        XCTAssertEqual(factory.callCount, 1, "Real create service need when create provider")
        
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingletonValue)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)

        XCTAssertEqual(factory.callCount, 1)
    }
    
    func testAddServiceParamsAsProtocol() {
        let factory = SpyServiceParamsValueFactory()
        let provider = factory.serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceParamsValue, provider: provider)

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")
        
        guard let service = serviceLocator.getService(key: ServiceLocatorKeys.serviceParamsValue,
                                                      params: .init(value: "Test1", error: nil)) else {
                                                        XCTFail("Service not found")
                                                        return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service.value, "Test1")
        
        doTestGetErrorService(serviceLocator, key: ServiceLocatorKeys.serviceParamsValue, error: ServiceLocatorError.wrongParams)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceParams)
    }
    
    func testAddServiceOptParamsProvider() {
        let factory = SpyServiceOptParamsFactory()
        let provider = factory.serviceProvider()
        serviceLocator.addService(key: ServiceLocatorKeys.serviceOptParams, provider: provider)

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")
        
        guard let service1 = serviceLocator.getService(key: ServiceLocatorKeys.serviceOptParams,
                                                      params: .init(value: "Test1", error: nil)) else {
                                                        XCTFail("Service not found")
                                                        return
        }
        
        guard let service2 = serviceLocator.getService(key: ServiceLocatorKeys.serviceOptParams) else {
                                                        XCTFail("Service not found")
                                                        return
        }

        XCTAssertEqual(factory.callCount, 2)
        XCTAssertEqual(service1.value, "Test1")
        XCTAssertEqual(service2.value, "Default")

        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceOptParams)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)

        XCTAssertEqual(factory.callCount, 3)
    }
    
    func testAddServiceSingletonService() {
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

    func testRemoveServices() {
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, factory: SpyServiceSingletonFactory())
        serviceLocator.addService(key: ServiceLocatorKeys.serviceLazy, factory: SpyServiceLazyFactory())
        serviceLocator.addService(key: ServiceLocatorKeys.serviceMany, factory: SpyServiceManyFactory())

        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceMany)

        serviceLocator.removeService(key: ServiceLocatorKeys.serviceLazy)
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceMany)

        serviceLocator.removeService(key: ServiceLocatorKeys.serviceSingleton)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorKeys.serviceMany)

        serviceLocator.removeService(key: ServiceLocatorKeys.serviceMany)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceSingleton)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceLazy)
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorKeys.serviceMany)
    }

    func testAddServicesWithEqualKeys() {
        serviceLocator.addService(key: ServiceLocatorCustomKey(storeKey: "key1"), factory: SpyServiceSingletonFactory())
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorCustomKey<ServiceSingleton>(storeKey: "key1"))

        serviceLocator.addService(key: ServiceLocatorCustomKey(storeKey: "key1"), factory: SpyServiceLazyFactory())
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorCustomKey<ServiceLazy>(storeKey: "key1"))
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorCustomKey<ServiceSingleton>(storeKey: "key1"))

        serviceLocator.addService(key: ServiceLocatorCustomKey(storeKey: "key1"), factory: SpyServiceManyFactory())
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorCustomKey<ServiceMany>(storeKey: "key1"))
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorCustomKey<ServiceSingleton>(storeKey: "key1"))
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorCustomKey<ServiceLazy>(storeKey: "key1"))

        serviceLocator.addService(key: ServiceLocatorCustomKey(storeKey: "key2"), factory: SpyServiceSingletonFactory())
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorCustomKey<ServiceSingleton>(storeKey: "key1"))
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorCustomKey<ServiceSingleton>(storeKey: "key2"))
        doTestGetSuccessService(serviceLocator, key: ServiceLocatorCustomKey<ServiceMany>(storeKey: "key1"))
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorCustomKey<ServiceMany>(storeKey: "key2"))
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorCustomKey<ServiceLazy>(storeKey: "key1"))
        doTestGetNotFoundService(serviceLocator, key: ServiceLocatorCustomKey<ServiceLazy>(storeKey: "key2"))


        let service1 = ServiceSingleton()
        service1.value = "Test1"
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, service: service1)
        if let service = serviceLocator.getService(key: ServiceLocatorKeys.serviceSingleton) {
            XCTAssertEqual(service.value, "Test1")
            XCTAssert(service1 === service)
        } else {
            XCTFail("Not found service")
        }

        let service2 = ServiceSingleton()
        service2.value = "Test2"
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingleton, service: service2)
        if let service = serviceLocator.getService(key: ServiceLocatorKeys.serviceSingleton) {
            XCTAssertEqual(service.value, "Test2")
            XCTAssert(service2 === service)
        } else {
            XCTFail("Not found service")
        }
    }

    func testServiceLocatorObjC() {
        let serviceLocatorObjC = ServiceLocatorObjC(serviceLocator)

        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingletonObjC, factory: SpyServiceSingletonObjCFactory())
        serviceLocator.addService(key: ServiceLocatorKeys.serviceParamsObjC, factory: SpyServiceParamsObjCFactory())
        serviceLocator.addService(key: ServiceLocatorKeys.serviceSingletonValueObjC, factory: SpyServiceSingletonValueObjCFactory())
        serviceLocator.addService(key: ServiceLocatorKeys.serviceParamsValueObjC, factory: SpyServiceParamsValueObjCFactory())

        let params = ServiceObjCParams(value: "Test1", error: nil)

        let service1: Any? = serviceLocatorObjC.getService(key: ServiceLocatorObjCKey.serviceSingleton)
        if (service1 as? ServiceObjC) == nil {
            XCTFail("Not found service")
        }

        let service2: Any? = serviceLocatorObjC.getService(key: ServiceLocatorObjCKey.serviceParams, params: params)
        if (service2 as? ServiceObjC) == nil {
            XCTFail("Not found service")
        }

        let service3: Any? = serviceLocatorObjC.getService(key: ServiceLocatorObjCKey.serviceSingletonValue)
        if (service3 as? ServiceValueObjC) == nil {
            XCTFail("Not found service")
        }

        let service4: Any? = serviceLocatorObjC.getService(key: ServiceLocatorObjCKey.serviceParamsValue, params: params)
        if (service4 as? ServiceValueObjC) == nil {
            XCTFail("Not found service")
        }
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

//
//  ServiceProviderTests.swift
//  ServiceContainerKitTests
//
//  Created by Vitalii Korotkii on 05/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class ServiceProviderTests: XCTestCase {
    
    func testServiceSingleton() {
        let factory = SpyServiceSingletonFactory()
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 1, "Real create service need when create provider")

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1)
        service1.value = "Test1"

        let service2: ServiceSingleton
        do {
            service2 = try provider.getService()
        } catch {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }
    
    func testServiceInstance() {
        let service = ServiceSingleton()
        let provider = ServiceProvider(service)

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssert(service === service1)

        let service2: ServiceSingleton
        do {
            service2 = try provider.getService()
        } catch {
            XCTFail("Service not exist")
            return
        }
        XCTAssert(service === service2)
    }
    
    func testServiceInstanceSafe() {
        let service = ServiceSingleton()
        let provider = ServiceSafeProvider(service)

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssert(service === service1)

        let service2: ServiceSingleton
        do {
            service2 = try provider.getService()
        } catch {
            XCTFail("Service not exist")
            return
        }
        XCTAssert(service === service2)
    }

    func testServiceSingletonFailure() {
        let factory = SpyServiceSingletonFactory(error: ServiceCreateError.someError)
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 1, "Real create service need when create provider")

        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callCount, 1)
        factory.error = nil

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
        }

        XCTAssertEqual(factory.callCount, 1)
    }
    
    func testServiceSingletonFailureUseTryInit() {
        let factory = SpyServiceSingletonFactory(error: ServiceCreateError.someError)
        do {
            _ = try ServiceProvider(tryFactory: factory)
            XCTFail("Service need failure create")
        } catch { }

        XCTAssertEqual(factory.callCount, 1, "Real create service need when create provider")
    }
    
    func testServiceSafeSingletonFailureUseTryInit() {
        let factory = SpyServiceSingletonFactory(error: ServiceCreateError.someError)
        do {
            _ = try ServiceSafeProvider(tryFactory: factory, safeThread: .semaphore)
            XCTFail("Service need failure create")
        } catch { }

        XCTAssertEqual(factory.callCount, 1, "Real create service need when create provider")
    }

    func testServiceLazy() {
        let factory = SpyServiceLazyFactory()
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 0, "Real create service when first needed")

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Real create service when first needed")
        service1.value = "Test1"

        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }

    func testServiceLazyFailure() {
        let factory = SpyServiceLazyFactory(error: ServiceCreateError.someError)
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 0, "Real create service when first needed")

        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callCount, 1, "Real create service when first needed")

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
        }

        XCTAssertEqual(factory.callCount, 2, "While the error repeats - try to re-create")

        //Next without error
        factory.error = nil
        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 3, "While the error repeats - try to re-create")

        service1.value = "Test1"
        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 3)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }
    
    func testServiceWeak() {
        let factory = SpyServiceWeakFactory()
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 0, "Real create service when first needed")

        var service1 = provider.getServiceAsOptional()
        guard service1 != nil else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Real create service when first needed")
        service1?.value = "Test1"
        
        var service2 = provider.getServiceAsOptional()
        guard service2 != nil else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service2?.value, "Test1")

        service2?.value = "Test2"
        XCTAssertEqual(service1?.value, "Test2")
        XCTAssert(service1 === service2)
        
        service1 = nil
        service2 = nil
        
        guard let service3 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 2, "Real create service when first needed")
        XCTAssertNotEqual(service3.value, "Test2")
    }
    
    func testServiceWeakFailure() {
        let factory = SpyServiceWeakFactory(error: ServiceCreateError.someError)
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 0, "Real create service when first needed")

        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callCount, 1, "Real create service when first needed")

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
        }

        XCTAssertEqual(factory.callCount, 2, "While the error repeats - try to re-create")

        //Next without error
        factory.error = nil
        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 3, "While the error repeats - try to re-create")

        service1.value = "Test1"
        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 3)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }

    func testServiceMany() {
        let factory = SpyServiceManyFactory()
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new")
        service1.value = "Test1"

        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new")
        XCTAssertNotEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertNotEqual(service1.value, "Test2")
        XCTAssert(service1 !== service2)
    }

    func testServiceManySafe() {
        let factory = SpyServiceManyFactory()
        let provider = factory.serviceSafeProvider()

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new")
        service1.value = "Test1"

        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new")
        XCTAssertNotEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertNotEqual(service1.value, "Test2")
        XCTAssert(service1 !== service2)
    }

    func testServiceManyFailure() {
        let factory = SpyServiceManyFactory(error: ServiceCreateError.someError)
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 0, "Real create service when needed")

        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callCount, 1, "Create service new with error")

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error):
            XCTAssert(error.error is ServiceCreateError)
            XCTAssertFalse(error.isNested)
            XCTAssert(error.service == ServiceMany.self)
            XCTAssertEqual(error.pathServices.count, 1)
            XCTAssert(error.pathServices[0] == ServiceMany.self)
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new with error")

        //Next without error
        factory.error = nil
        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 3, "Create service new")

        service1.value = "Test1"
        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 4)
        XCTAssertNotEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertNotEqual(service1.value, "Test2")
        XCTAssert(service1 !== service2)
    }
    
    func testServiceNestedFailure() {
        let factoryNested = SpyServiceManyFactory(error: ServiceCreateError.someError)
        let providerNested = factoryNested.serviceProvider()
        
        let factory = SpyServiceNestedFactory(provider: providerNested)
        let provider = factory.serviceProvider()

        XCTAssertEqual(factoryNested.callCount, 0, "Real create service when needed")
        XCTAssertEqual(factory.callCount, 0, "Real create service when needed")

        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callCount, 1, "Create service new with error")

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error):
            XCTAssert(error.error is ServiceCreateError)
            XCTAssertTrue(error.isNested)
            XCTAssert(error.service == ServiceMany.self)
            XCTAssertEqual(error.pathServices.count, 2)
            XCTAssert(error.pathServices[0] == ServiceNested.self)
            XCTAssert(error.pathServices[1] == ServiceMany.self)
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new with error")

        //Next without error
        factoryNested.error = nil
        guard provider.getServiceAsOptional() != nil else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 3, "Create service new")
    }

    func testServiceAsProtocol() {
        let factory = SpyServiceValueFactory<ServiceSingleton>.init(mode: .atOne)
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 1, "Real create service need when create provider")

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1)
        service1.value = "Test1"

        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }
    
    func testServiceLazyClosure() {
        var callCount = 0
        let provider = ServiceProvider<ServiceLazy>(mode: .lazy) {
            callCount += 1
            return ServiceLazy()
        }
        
        XCTAssertEqual(callCount, 0, "Real create service when first needed")
        
        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(callCount, 1, "Real create service when first needed")
        service1.value = "Test1"
        
        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(service2.value, "Test1")
        
        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }
    
    func testServiceLazyClosureFailure() {
        var callCount = 0
        var errorClosure: Error? = ServiceCreateError.someError
        let provider = ServiceProvider<ServiceLazy>(mode: .lazy) {
            callCount += 1
            if let error = errorClosure {
                throw error
            } else {
                return ServiceLazy()
            }
        }
        
        XCTAssertEqual(callCount, 0, "Real create service when first needed")
        
        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }
        
        XCTAssertEqual(callCount, 1, "Real create service when first needed")

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
        }
        
        XCTAssertEqual(callCount, 2, "While the error repeats - try to re-create")
        
        //Next without error
        errorClosure = nil
        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 3, "While the error repeats - try to re-create")
        
        service1.value = "Test1"
        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 3)
        XCTAssertEqual(service2.value, "Test1")
        
        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }
    
    func testServiceManyProtocolClosure() {
        var callCount = 0
        let provider = ServiceProvider<ServiceValue>(mode: .many) {
            callCount += 1
            return ServiceMany()
        }
        
        XCTAssertEqual(callCount, 0, "Create service when needed")
        
        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(callCount, 1, "Create service new")
        service1.value = "Test1"
        
        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 2, "Create service new")
        XCTAssertNotEqual(service2.value, "Test1")
        
        service2.value = "Test2"
        XCTAssertNotEqual(service1.value, "Test2")
        XCTAssert(service1 !== service2)
    }
    
    func testServiceManyProtocolClosureFailure() {
        var callCount = 0
        var errorClosure: Error? = ServiceCreateError.someError
        let provider = ServiceProvider<ServiceValue>(mode: .many) {
            callCount += 1
            if let error = errorClosure {
                throw error
            } else {
                return ServiceMany()
            }
        }
        
        XCTAssertEqual(callCount, 0, "Real create service when needed")
        
        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }
        
        XCTAssertEqual(callCount, 1, "Create service new with error")

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
        }

        XCTAssertEqual(callCount, 2, "Create service new with error")
        
        //Next without error
        errorClosure = nil
        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 3, "Create service new")
        
        service1.value = "Test1"
        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        
        XCTAssertEqual(callCount, 4)
        XCTAssertNotEqual(service2.value, "Test1")
        
        service2.value = "Test2"
        XCTAssertNotEqual(service1.value, "Test2")
        XCTAssert(service1 !== service2)
    }

    // MARK: - ObjC
    func testServiceSingletonObjC() {
        let factory = SpyServiceSingletonObjCFactory()
        let provider = ServiceProviderObjC(factory.serviceProvider())

        XCTAssertEqual(factory.callCount, 1, "Real create service need when create provider")

        let serviceAny1: Any? = provider.getService()
        guard let service1 = serviceAny1 as? ServiceObjC else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1)
        service1.value = "Test1"

        let service2: ServiceObjC
        do {
            let serviceAny2: Any = try provider.getService()
            guard let service = serviceAny2 as? ServiceObjC else {
                XCTFail("Service not exist")
                return
            }

            service2 = service
        } catch {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")

        guard let swiftProvider: ServiceProvider<ServiceObjC> = provider.provider() else {
            XCTFail("Swift provider invalid")
            return
        }

        guard let service3 = swiftProvider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service3.value, "Test2")
        XCTAssert(service1 === service2)
        XCTAssert(service2 === service3)
    }

    func testServiceSingletonObjCFailure() {
        let factory = SpyServiceSingletonObjCFactory(error: ServiceCreateError.someError)
        let provider = ServiceProviderObjC(factory.serviceProvider())

        XCTAssertEqual(factory.callCount, 1, "Real create service need when create provider")

        let serviceAny1: Any? = provider.getService()
        if serviceAny1 != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callCount, 1)
        factory.error = nil

        do {
            _ = try provider.getService() as Any
            XCTFail("Service need failure create")
        } catch { }

        XCTAssertEqual(factory.callCount, 1)
    }

    func testServiceObjCAsProtocol() {
        let factory = SpyServiceSingletonValueObjCFactory()
        let provider = ServiceProviderObjC(factory.serviceProvider())

        XCTAssertEqual(factory.callCount, 1, "Real create service need when create provider")

        let serviceAny1: Any? = provider.getService()
        guard let service1 = serviceAny1 as? ServiceValueObjC else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1)
        service1.value = "Test1"

        let service2: ServiceValueObjC
        do {
            let serviceAny2: Any = try provider.getService()
            guard let service = serviceAny2 as? ServiceValueObjC else {
                XCTFail("Service not exist")
                return
            }

            service2 = service
        } catch {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")

        guard let swiftProvider: ServiceProvider<ServiceValueObjC> = provider.provider() else {
            XCTFail("Swift provider invalid")
            return
        }

        guard let service3 = swiftProvider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(service3.value, "Test2")
        XCTAssert(service1 === service2)
        XCTAssert(service2 === service3)
    }
}

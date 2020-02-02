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
    // MARK: ServiceProvider
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
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
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
        let provider = ServiceProvider(lazy: { () -> ServiceLazy in
            callCount += 1
            return ServiceLazy()
        })
        
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
        let provider = ServiceProvider(lazy: { () throws -> ServiceLazy in
            callCount += 1
            if let error = errorClosure {
                throw error
            } else {
                return ServiceLazy()
            }
        })
        
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
        let provider = ServiceProvider(manyFactory: { () -> ServiceValue in
            callCount += 1
            return ServiceMany()
        })
        
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
        let provider = ServiceProvider(manyFactory: { () throws -> ServiceValue in
            callCount += 1
            if let error = errorClosure {
                throw error
            } else {
                return ServiceMany()
            }
        })
        
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
    

    // MARK: - ServiceParamsProvider
    func testServiceParams() {
        let factory = SpyServiceParamsFactory()
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")

        guard let service1 = provider.getServiceAsOptional(params: .init(value: "Test1", error: nil)) else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new")
        XCTAssertEqual(service1.value, "Test1")

        guard let service2 = provider.getServiceAsOptional(params: .init(value: "Test2", error: nil)) else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new")
        XCTAssertEqual(service2.value, "Test2")

        service2.value = "Test3"
        XCTAssertNotEqual(service1.value, "Test3")
        XCTAssert(service1 !== service2)
    }

    func testServiceParamsFailure() {
        let factory = SpyServiceParamsFactory()
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 0, "Real create service when needed")

        if provider.getServiceAsOptional(params: .init(value: "Test1", error: ServiceCreateError.someError)) != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callCount, 1, "Create service new with error")

        switch provider.getServiceAsResult(params: .init(value: "Test2", error: ServiceCreateError.someError)) {
        case .success: XCTFail("Service need failure create")
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new with error")

        //Next without error
        guard let service1 = provider.getServiceAsOptional(params: .init(value: "Test3", error: nil)) else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 3, "Create service new")
        XCTAssertEqual(service1.value, "Test3")

        guard let service2 = provider.getServiceAsOptional(params: .init(value: "Test4", error: nil)) else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 4)
        XCTAssertEqual(service2.value, "Test4")

        service2.value = "Test5"
        XCTAssertNotEqual(service1.value, "Test5")
        XCTAssert(service1 !== service2)
    }

    func testServiceParamsWithDefParams() {
        let factory = SpyServiceParamsFactory()
        let provider = factory.serviceProvider(params: .init(value: "TestDef", error: nil))

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new")
        XCTAssertEqual(service1.value, "TestDef")

        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new")
        XCTAssertEqual(service2.value, "TestDef")

        service2.value = "Test1"
        XCTAssertNotEqual(service1.value, "Test1")
        XCTAssert(service1 !== service2)
    }

    func testServiceParamsConvertDefParams() {
        let factory = SpyServiceParamsFactory()
        let providerParams = factory.serviceProvider()
        let provider = providerParams.convert(params: .init(value: "TestDef", error: nil))

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")

        guard let service1 = providerParams.getServiceAsOptional(params: .init(value: "Test1", error: nil)) else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new")
        XCTAssertEqual(service1.value, "Test1")

        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new")
        XCTAssertEqual(service2.value, "TestDef")

        service2.value = "Test2"
        XCTAssertNotEqual(service1.value, "Test2")
        XCTAssert(service1 !== service2)
    }

    func testServiceParamsAsProtocol() {
        let factory = SpyServiceParamsValueFactory()
        let provider = factory.serviceProvider()

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")

        guard let service1 = provider.getServiceAsOptional(params: .init(value: "Test1", error: nil)) else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new")
        XCTAssertEqual(service1.value, "Test1")

        guard let service2 = provider.getServiceAsOptional(params: .init(value: "Test2", error: nil)) else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new")
        XCTAssertEqual(service2.value, "Test2")

        service2.value = "Test3"
        XCTAssertNotEqual(service1.value, "Test3")
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

    func testServiceParamsObjC() {
        let factory = SpyServiceParamsObjCFactory()
        let provider = ServiceParamsProviderObjC(factory.serviceProvider())

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")

        let serviceAny1: Any? = provider.getService(params: ServiceObjCParams(value: "Test1", error: nil))
        guard let service1 = serviceAny1 as? ServiceObjC else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new")
        XCTAssertEqual(service1.value, "Test1")

        let service2: ServiceObjC
        do {
            let serviceAny2: Any = try provider.getService(params: ServiceObjCParams(value: "Test2", error: nil))
            guard let service = serviceAny2 as? ServiceObjC else {
                XCTFail("Service not exist")
                return
            }

            service2 = service
        } catch {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new")
        XCTAssertEqual(service2.value, "Test2")

        service2.value = "Test3"
        XCTAssertNotEqual(service1.value, "Test3")
        XCTAssert(service1 !== service2)
    }

    func testServiceParamsObjCFailure() {
        let factory = SpyServiceParamsObjCFactory()
        let provider = ServiceParamsProviderObjC(factory.serviceProvider())

        XCTAssertEqual(factory.callCount, 0, "Real create service when needed")

        let serviceAny1: Any? = provider.getService(params: ServiceObjCParams(value: "Test2", error: ServiceCreateError.someError))
        if serviceAny1 != nil {
            XCTFail("Service need failure create")
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new with error")

        do {
            _ = try provider.getService(params: ServiceObjCParams(value: "Test2", error: ServiceCreateError.someError)) as Any
            XCTFail("Service need failure create")
        } catch { }

        XCTAssertEqual(factory.callCount, 2, "Create service new with error")

        do {
            _ = try provider.getService(params: NSObject()) as Any
            XCTFail("Service need failure create because invalid params")
        } catch { }

        XCTAssertEqual(factory.callCount, 2, "When params invalid type - no create new service")
    }

    func testServiceParamsObjCAsProtocol() {
        let factory = SpyServiceParamsValueObjCFactory()
        let provider = ServiceParamsProviderObjC(factory.serviceProvider())

        XCTAssertEqual(factory.callCount, 0, "Create service when needed")

        let serviceAny1: Any? = provider.getService(params: ServiceObjCParams(value: "Test1", error: nil))
        guard let service1 = serviceAny1 as? ServiceValueObjC else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new")
        XCTAssertEqual(service1.value, "Test1")

        let service2: ServiceValueObjC
        do {
            let serviceAny2: Any = try provider.getService(params: ServiceObjCParams(value: "Test2", error: nil))
            guard let service = serviceAny2 as? ServiceValueObjC else {
                XCTFail("Service not exist")
                return
            }

            service2 = service
        } catch {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new")
        XCTAssertEqual(service2.value, "Test2")

        service2.value = "Test3"
        XCTAssertNotEqual(service1.value, "Test3")
        XCTAssert(service1 !== service2)
    }
}

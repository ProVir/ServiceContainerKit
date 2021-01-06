//
//  ServiceParamsProviderTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 25.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class ServiceParamsProviderTests: XCTestCase {
    
    func testServiceFromFactory() {
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
    
    func testServiceFromClosure() {
        var callCount: Int = 0
        let provider = ServiceParamsProvider { (params: ServiceParams.Params) -> ServiceParams in
            callCount += 1
            if let error = params.error {
                throw error
            } else {
                return ServiceParams(value: params.value)
            }
        }

        XCTAssertEqual(callCount, 0, "Create service when needed")

        guard let service1 = provider.getServiceAsOptional(params: .init(value: "Test1", error: nil)) else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(callCount, 1, "Create service new")
        XCTAssertEqual(service1.value, "Test1")

        guard let service2 = provider.getServiceAsOptional(params: .init(value: "Test2", error: nil)) else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(callCount, 2, "Create service new")
        XCTAssertEqual(service2.value, "Test2")

        service2.value = "Test3"
        XCTAssertNotEqual(service1.value, "Test3")
        XCTAssert(service1 !== service2)
    }
    
    func testServiceSafe() {
        let factory = SpyServiceParamsFactory()
        let provider = factory.serviceSafeProvider()

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

    func testServiceFailure() {
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

    func testServiceWithDefParams() {
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

    func testServiceConvertDefParams() {
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
    
    func testServiceSafeConvertDefParams() {
        let factory = SpyServiceParamsFactory()
        let providerParams = factory.serviceSafeProvider()
        let provider = providerParams.convert(params: .init(value: "TestDef", error: nil))
        
        XCTAssertEqual(factory.callCount, 0, "Create service when needed")

        guard let service1 = providerParams.getServiceAsOptional(params: .init(value: "Test1", error: nil)) else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callCount, 1, "Create service new")
        XCTAssertEqual(service1.value, "Test1")

        guard let service2 = try? provider.getServiceAsResultNotSafe().get() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callCount, 2, "Create service new")
        XCTAssertEqual(service2.value, "TestDef")

        service2.value = "Test2"
        XCTAssertNotEqual(service1.value, "Test2")
        XCTAssert(service1 !== service2)
    }

    func testServiceAsProtocol() {
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
    func testServiceObjC() {
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

    func testServiceObjCFailure() {
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

    func testServiceObjCAsProtocol() {
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

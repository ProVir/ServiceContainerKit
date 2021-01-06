//
//  ServiceProviderSessionTests.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 25.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import XCTest
@testable import ServiceContainerKit

class ServiceProviderSessionTests: XCTestCase {
    
    func testServiceSingleton() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: ""))
        let factory = SpyServiceSessionFactory<ServiceSingleton, SimpleSession>(mode: .atOne)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factory.callActiveCount, 0)

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        service1.value = "Test1"

        let service2: ServiceSingleton
        do {
            service2 = try provider.getService()
        } catch {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }

    func testServiceSingletonFailure() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: ""))
        let factory = SpyServiceSessionFactory<ServiceSingleton, SimpleSession>(mode: .atOne, error: ServiceCreateError.someError)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factory.callActiveCount, 0)

        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callMakeCount, 1)
        factory.error = nil

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
        }

        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        // Remake after session change
        factory.error = nil
        mediator.updateSession(.init(key: ""))
        
        switch provider.getServiceAsResult() {
        case .success: break
        case .failure: XCTFail("Service not exist")
        }
        
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callActiveCount, 0)
    }
    
    func testServiceLazy() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: ""))
        let factory = SpyServiceSessionFactory<ServiceLazy, SimpleSession>(mode: .lazy)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 0, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)

        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)
        service1.value = "Test1"

        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }

    func testServiceLazyFailure() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: ""))
        let factory = SpyServiceSessionFactory<ServiceLazy, SimpleSession>(mode: .lazy, error: ServiceCreateError.someError)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 0, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)

        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
        }

        XCTAssertEqual(factory.callMakeCount, 2, "While the error repeats - try to re-create")
        XCTAssertEqual(factory.callActiveCount, 0)

        //Next without error
        factory.error = nil
        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callMakeCount, 3, "While the error repeats - try to re-create")
        XCTAssertEqual(factory.callActiveCount, 0)

        service1.value = "Test1"
        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callMakeCount, 3)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }
    
    func testServiceWeak() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: ""))
        let factory = SpyServiceSessionFactory<ServiceWeak, SimpleSession>(mode: .weak)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 0, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)

        var service1 = provider.getServiceAsOptional()
        guard service1 != nil else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)
        service1?.value = "Test1"
        
        var service2 = provider.getServiceAsOptional()
        guard service2 != nil else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
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
        XCTAssertEqual(factory.callMakeCount, 2, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssertNotEqual(service3.value, "Test2")
    }
    
    func testServiceWeakFailure() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: ""))
        let factory = SpyServiceSessionFactory<ServiceWeak, SimpleSession>(mode: .weak, error: ServiceCreateError.someError)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 0, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)

        if provider.getServiceAsOptional() != nil {
            XCTFail("Service need failure create")
        }

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)

        switch provider.getServiceAsResult() {
        case .success: XCTFail("Service need failure create")
        case .failure(let error): XCTAssert(error.error is ServiceCreateError)
        }

        XCTAssertEqual(factory.callMakeCount, 2, "While the error repeats - try to re-create")
        XCTAssertEqual(factory.callActiveCount, 0)

        //Next without error
        factory.error = nil
        guard let service1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callMakeCount, 3, "While the error repeats - try to re-create")
        XCTAssertEqual(factory.callActiveCount, 0)

        service1.value = "Test1"
        guard let service2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callMakeCount, 3)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssertEqual(service2.value, "Test1")

        service2.value = "Test2"
        XCTAssertEqual(service1.value, "Test2")
        XCTAssert(service1 === service2)
    }

    func testServiceWeakSafe() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: ""))
        let factory = SpyServiceSessionFactory<ServiceWeak, SimpleSession>(mode: .weak)
        let provider = factory.serviceSafeProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 0, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)

        var service1 = try? provider.getServiceAsResultNotSafe().get()
        guard service1 != nil else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)
        service1?.value = "Test1"
        
        var service2 = provider.getServiceAsOptional()
        guard service2 != nil else {
            XCTFail("Service not exist")
            return
        }

        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
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
        XCTAssertEqual(factory.callMakeCount, 2, "Real create service when first needed")
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssertNotEqual(service3.value, "Test2")
    }
 
    func testServiceSessionChangeRemakeNone() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: "1"))
        let factory = SpyServiceSessionFactory<ServiceSingleton, SimpleSession>(mode: .atOne)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factory.callActiveCount, 0)

        guard let service_1_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "1"))
        guard let service_1_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 2)
        XCTAssertEqual(factory.callActiveCount, 1)
        XCTAssert(service_1_0 === service_1_1)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 3)
        XCTAssertEqual(factory.callActiveCount, 2)
        XCTAssert(service_2_0 === service_2_1)
    }
    
    func testServiceSessionChangeRemakeNoneSafe() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: "1"))
        let factory = SpyServiceSessionFactory<ServiceSingleton, SimpleSession>(mode: .atOne)
        let provider = factory.serviceSafeProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factory.callActiveCount, 0)

        guard let service_1_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "1"))
        guard let service_1_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 2)
        XCTAssertEqual(factory.callActiveCount, 1)
        XCTAssert(service_1_0 === service_1_1)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 3)
        XCTAssertEqual(factory.callActiveCount, 2)
        XCTAssert(service_2_0 === service_2_1)
    }
    
    func testServiceNotAvailableReActivate() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: "1"))
        let factory = SpyServiceSessionFactory<ServiceSingleton, SimpleSession>(mode: .atOne)
        let provider = factory.serviceProvider(mediator: mediator)
        factory.canActivate = false

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factory.callActiveCount, 0)

        guard let service_1_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "1"))
        guard let service_1_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 3)
        XCTAssertEqual(factory.callDeActiveCount, 2)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssert(service_1_0 !== service_1_1)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 4)
        XCTAssertEqual(factory.callDeActiveCount, 3)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssert(service_2_0 !== service_2_1)
    }
    
    func testServiceSessionChangeRemakeForce() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: "1"))
        let factory = SpyServiceSessionFactory<ServiceSingleton, SimpleSession>(mode: .atOne)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factory.callActiveCount, 0)

        guard let service_1_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "1"), remakePolicy: .force)
        guard let service_1_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 3)
        XCTAssertEqual(factory.callDeActiveCount, 2)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssert(service_1_0 !== service_1_1)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 3)
        XCTAssertEqual(factory.callDeActiveCount, 3)
        XCTAssertEqual(factory.callActiveCount, 1)
        XCTAssert(service_2_0 === service_2_1)
    }
    
    func testServiceSessionChangeRemakeClearAll() {
        let mediator = ServiceSessionMediator(session: SimpleSession(key: "1"))
        let factory = SpyServiceSessionFactory<ServiceSingleton, SimpleSession>(mode: .atOne)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factory.callActiveCount, 0)

        guard let service_1_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        
        mediator.updateSession(.init(key: "1"), remakePolicy: .clearAll)
        guard let service_1_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 3)
        XCTAssertEqual(factory.callDeActiveCount, 2)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssert(service_1_0 !== service_1_1)
        
        mediator.updateSession(.init(key: "2"))
        guard let service_2_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 4)
        XCTAssertEqual(factory.callDeActiveCount, 3)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssert(service_2_0 !== service_2_1)
    }
    
    func testServiceSessionChangeWithEqualKey() {
        var session1 = SimpleSession(key: "1")
        session1.value = "1-0"
        
        let mediator = ServiceSessionMediator(session: session1)
        let factory = SpyServiceSessionFactory<ServiceSingleton, SimpleSession>(mode: .atOne)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factory.callActiveCount, 0)

        guard let service_1_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssertEqual(factory.lastSession?.value, "1-0")
        
        session1.value = "1-1"
        mediator.updateSession(session1)
        guard let service_1_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callDeActiveCount, 0)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssertEqual(factory.lastSession?.value, "1-0")
        XCTAssert(service_1_0 === service_1_1)

        var session2 = SimpleSession(key: "2")
        session2.value = "2-0"
        mediator.updateSession(session2)
        guard let service_2_0 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssertEqual(factory.lastSession?.value, "2-0")
        
        session1.value = "1-2"
        mediator.updateSession(session1)
        guard let service_1_2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 2)
        XCTAssertEqual(factory.callActiveCount, 1)
        XCTAssertEqual(factory.lastSession?.value, "1-2")
        XCTAssert(service_1_0 === service_1_2)
        
        session2.value = "2-1"
        mediator.updateSession(session2)
        guard let service_2_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 3)
        XCTAssertEqual(factory.callActiveCount, 2)
        XCTAssertEqual(factory.lastSession?.value, "2-1")
        XCTAssert(service_2_0 === service_2_1)
    }
    
    func testServiceVoidSession() {
        let mediator = ServiceVoidSessionMediator()
        let factory = SpyServiceSessionFactory<ServiceSingleton, ServiceVoidSession>(mode: .atOne)
        let provider = factory.serviceProvider(mediator: mediator)

        XCTAssertEqual(factory.callMakeCount, 1, "Real create service need when create provider")
        XCTAssertEqual(factory.callActiveCount, 0)

        guard let service_1 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)

        mediator.clearServices()
        guard let service_2 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 2)
        XCTAssertEqual(factory.callDeActiveCount, 1)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssert(service_1 !== service_2)

        mediator.clearServices()
        guard let service_3 = provider.getServiceAsOptional() else {
            XCTFail("Service not exist")
            return
        }
        XCTAssertEqual(factory.callMakeCount, 3)
        XCTAssertEqual(factory.callDeActiveCount, 2)
        XCTAssertEqual(factory.callActiveCount, 0)
        XCTAssert(service_1 !== service_3)
    }
    
    
}

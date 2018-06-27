//
//  ViewController.swift
//  ServiceProviderExample
//
//  Created by Короткий Виталий on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import UIKit
import ServiceContainerKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let locator = ServiceLocator()
        ServiceLocator.setupShared(serviceLocator: locator)
        
        locator.addService(factory: ServiceTestFactory())
        locator.addService(ObjCService() as ServiceObjC)
        
        
        
//        let service: ServiceTest = try! locator.tryService(params: "Test")
//        let service2: ServiceTest = try! locator.tryService()

        
    }

}



class ServiceTest: NSObject {
    
}

extension ServiceTest: ServiceSupportFactoryParams {
    typealias ParamsType = String
}

struct ServiceTestFactory: ServiceParamsFactory {
    
    func createService(params: String?) throws -> ServiceTest {
        return ServiceTest()
    }
}

//
//  ViewController.swift
//  ServiceProviderExample
//
//  Created by Короткий Виталий on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import UIKit
import ServiceLocator

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let locator = ServiceLocator()
        locator.addService(factory: ServiceTestFactory())
        
        let service: ServiceTest = try! locator.tryService(params: "Test")
        let service2: ServiceTest = try! locator.tryService()
        
    }

}



class ServiceTest {
    
}

extension ServiceTest: ServiceSupportFactoryParams {
    typealias ParamsType = String
}

struct ServiceTestFactory: ServiceParamsFactory {
    
    func createService(params: String?) throws -> ServiceTest {
        return ServiceTest()
    }
}

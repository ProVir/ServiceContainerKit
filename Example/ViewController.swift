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
    
    var serviceContainer: ServiceContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "objc", let vc = segue.destination as? ObjCViewController {
            vc.setup(withContainer: ServiceContainerObjC(container: serviceContainer))
        }
    }
    
    @IBAction func testContainer() {
        print("\n\nSTART TEST SERVICE CONTAINER")
        defer {
            print("\nSTOP TEST SERVICE CONTAINER\n")
        }
        
        print("\nCreate and test FirstService")
        let firstService = serviceContainer.firstServiceProvider.getService()!
        firstService.test()
        
        print("\n\nTest shared FirstService")
        let sharedService = serviceContainer.sharedFirstService
        sharedService.test()
        
        print("\n\nUpdate singleton value")
        let singletonService = serviceContainer.singletonServiceProvider.getService()!
        singletonService.value = "New Value from testContainer"
        
        firstService.test()
        sharedService.test()
        
        
        print("\n\nCreate and test SecondService with custom number (13)")
        let secondService = serviceContainer.secondServiceProvider.getService(params: .init(number: 13))!
        secondService.test()
        
        print("\n\nUpdate lazy value")
        let lazyService = serviceContainer.lazyServiceProvider.getService()!
        lazyService.value = "New Value in Lazy from testContainer"
        secondService.test()
        
        print("\n\nCreate and test SecondService with number = 0")
        let secondNum0Service = serviceContainer.secondServiceNumber0Provider.getService()!
        secondNum0Service.test()
        
        
        print("\n\nAll experiments completed, removed all services created in current function.")
    }
    
    @IBAction func testLocator() {
        print("\n\nSTART TEST SERVICE LOCATOR")
        defer {
            print("\nSTOP TEST SERVICE LOCATOR\n")
        }
        
        print("\nCreate and test FirstService")
        let firstService: FirstService = ServiceLocator.getServiceFromShared()!
        firstService.test()
        
        print("\n\nTest shared FirstService (for get used protocol)")
        let sharedService = (ServiceLocator.getServiceFromShared() as FirstServiceShared?) as! FirstService
        sharedService.test()
        
        print("\n\nUpdate singleton value")
        let singletonService: SingletonService = ServiceLocator.getServiceFromShared()!
        singletonService.value = "New Value from testLocator"
        
        firstService.test()
        sharedService.test()
        
        
        print("\n\nCreate and test SecondService with custom number (101)")
        let secondService: SecondService = ServiceLocator.getServiceFromShared(params: .init(number: 101))!
        secondService.test()
        
        print("\n\nUpdate lazy value")
        let lazyService: LazyService = ServiceLocator.getServiceFromShared()!
        lazyService.value = "New Value in Lazy from testLocator"
        secondService.test()
        
        print("\n\nCreate and test SecondService with default number (without params)")
        let secondNumDefService: SecondService = ServiceLocator.getServiceFromShared()!
        secondNumDefService.test()
        
        
        print("\n\nAll experiments completed, removed all services created in current function.")
    }
}

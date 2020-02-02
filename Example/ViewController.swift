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
        let firstService = serviceContainer.firstServiceProvider.getServiceOrFatal()
        firstService.test()
        
        print("\n\nTest shared FirstService")
        let sharedService = serviceContainer.sharedFirstService
        sharedService.test()
        
        print("\n\nUpdate singleton value")
        let singletonService = serviceContainer.singletonServiceProvider.getServiceOrFatal()
        singletonService.value = "New Value from testContainer"
        
        firstService.test()
        sharedService.test()
        
        
        print("\n\nCreate and test SecondService with custom number (13)")
        let secondService = serviceContainer.secondServiceProvider.getServiceOrFatal(params: .init(number: 13))
        secondService.test()
        
        print("\n\nUpdate lazy value")
        let lazyService = serviceContainer.lazyServiceProvider.getServiceOrFatal()
        lazyService.value = "New Value in Lazy from testContainer"
        secondService.test()
        
        print("\n\nCreate and test SecondService with number = 0")
        let secondNum0Service = serviceContainer.secondServiceNumber0Provider.getServiceOrFatal()
        secondNum0Service.test()
        
        
        print("\n\nAll experiments completed, removed all services created in current function.")
    }
    
    @IBAction func testKeyLocator() {
        print("\n\nSTART TEST SERVICE LOCATOR WITH KEYS")
        defer {
            print("\nSTOP TEST SERVICE LOCATOR WITH KEYS\n")
        }
        
        let serviceLocator = ServiceLocator.createDefault()
        print("CREATED SERVICE LOCATOR WITH SERVICES\n")
        
        print("\nCreate and test FirstService")
        let firstService = serviceLocator.getServiceOrFatal(key: ServiceLocatorKeys.firstService)
        firstService.test()
        
        print("\n\nTest shared FirstService")
        let sharedService = serviceLocator.getServiceOrFatal(key: ServiceLocatorKeys.firstServiceShared)
        sharedService.test()
        
        print("\n\nUpdate singleton value - use variant 2 for key")
        let singletonService = serviceLocator.getServiceOrFatal(key: SingletonServiceLocatorKey())
        singletonService.value = "New Value from testLocator"
        
        firstService.test()
        sharedService.test()
        
        
        print("\n\nCreate and test SecondService with custom number (101)")
        let secondService = serviceLocator.getServiceOrFatal(key: ServiceLocatorKeys.secondService,
                                                             params: SecondServiceParams(number: 101))
        secondService.test()
        
        print("\n\nUpdate lazy value - use variant 3 for key")
        let lazyService = serviceLocator.getServiceOrFatal(key: LazyService.locatorKey)
        lazyService.value = "New Value in Lazy from testLocator"
        secondService.test()
        
        print("\n\nCreate and test SecondService with default number (without params)")
        let secondNumDefService = serviceLocator.getServiceOrFatal(key: ServiceLocatorKeys.secondService)
        secondNumDefService.test()
        
        print("\n\nAll experiments completed, removed all services created in current function.")
    }
    
    @IBAction func testLocator() {
        print("\n\nSTART TEST SERVICE EASY LOCATOR")
        defer {
            print("\nSTOP TEST SERVICE EASY LOCATOR\n")
        }
        
        guard let serviceLocator = ServiceEasyLocator.shared else { return }
        
        print("\nCreate and test FirstService")
        let firstService: FirstService = serviceLocator.getServiceOrFatal()
        firstService.test()
        
        print("\n\nTest shared FirstService (for get used protocol)")
        let sharedService = serviceLocator.getServiceOrFatal(FirstServiceShared.self) as! FirstService
        sharedService.test()
        
        print("\n\nUpdate singleton value")
        let singletonService: SingletonService = serviceLocator.getServiceOrFatal()
        singletonService.value = "New Value from testLocator"
        
        firstService.test()
        sharedService.test()
        
        
        print("\n\nCreate and test SecondService with custom number (101)")
        let secondService: SecondService = serviceLocator.getServiceOrFatal(params: SecondServiceParams(number: 101))
        secondService.test()
        
        print("\n\nUpdate lazy value")
        let lazyService: LazyService = serviceLocator.getServiceOrFatal()
        lazyService.value = "New Value in Lazy from testLocator"
        secondService.test()
        
        print("\n\nCreate and test SecondService with default number (without params)")
        let secondNumDefService: SecondService = serviceLocator.getServiceOrFatal()
        secondNumDefService.test()
        
        print("\n\nAll experiments completed, removed all services created in current function.")
    }
}

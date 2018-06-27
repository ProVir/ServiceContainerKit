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
    
}

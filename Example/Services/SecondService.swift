//
//  SecondService.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation


class SecondService {
    var number: Int = 0
    
    let lazyService: LazyService
    let firstService: FirstService
    
    init(lazyService: LazyService, firstService: FirstService) {
        self.lazyService = lazyService
        self.firstService = firstService
        
        print("Created SecondService")
    }
    
    deinit {
        print("Removed SecondService")
    }
    
    func test() {
        print("test second service, number = \(number)")
        lazyService.test()
        firstService.test()
    }
}

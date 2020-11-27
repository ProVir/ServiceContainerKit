//
//  FirstService.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation


class FirstService: NSObject {
    let singletonService: SingletonService
    
    init(singletonService: SingletonService) {
        self.singletonService = singletonService
        super.init()
        
        print("> Created FirstService")
    }
    
    deinit {
        print("< Removed FirstService")
    }
    
    @objc func test() {
        print("  test first service")
        singletonService.test()
    }
}

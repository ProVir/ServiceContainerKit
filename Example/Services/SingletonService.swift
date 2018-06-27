//
//  SingletonService.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

class SingletonService {
    var value: String = ""
    
    init() {
        print("Created SingletonService")
    }
    
    deinit {
        print("Removed SingletonService")
    }
    
    func test() {
        print("test singleton service, value = \(value)")
    }
}

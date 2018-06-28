//
//  LazyService.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

class LazyService {
    var value: String = ""
    
    init() {
        print("> Created LazyService")
    }
    
    deinit {
        print("< Removed LazyService")
    }
    
    func test() {
        print("  test lazy service, value = \(value)")
    }
}

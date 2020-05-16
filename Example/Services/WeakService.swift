//
//  WeakService.swift
//  Example
//
//  Created by Короткий Виталий on 16.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

protocol WeakService {
    var value: String { get set }
    func test()
}

class WeakServiceImpl: WeakService {
    var value: String = ""
    
    init() {
        print("> Created WeakService")
    }
    
    deinit {
        print("< Removed WeakService")
    }
    
    func test() {
        print("  test weak service, value = \(value)")
    }
}

struct WeakServiceStruct: WeakService {
    var value: String = ""
    
    init() {
        print("> Created WeakServiceStruct")
    }
    
    func test() {
        print("  test weak service, value = \(value)")
    }
}

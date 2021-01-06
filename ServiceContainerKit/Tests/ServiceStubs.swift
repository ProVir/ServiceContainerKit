//
//  ServiceStubs.swift
//  ServiceContainerKitTests
//
//  Created by Виталий Короткий on 06.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct SimpleServiceSession: ServiceSession {
    let key: AnyHashable
}

struct SimpleSession: ServiceSession {
    let key: AnyHashable
    var value: String = ""
    
    init(key: AnyHashable) {
        self.key = key
    }
}

protocol ServiceValue: class {
    init()
    var value: String { get set }
    var isActive: Bool { get set }
}

protocol ServiceParamsValue: class {
    var value: String { get set }
}

@objc protocol ServiceValueObjC {
    var value: String { get set }
}

class ServiceSingleton: ServiceValue {
    required init() { }
    var value: String = "Default"
    var isActive: Bool = true
}

class ServiceLazy: ServiceValue {
    required init() { }
    var value: String = "DefaultLazy"
    var isActive: Bool = true
}

class ServiceWeak: ServiceValue {
    required init() { }
    var value: String = "DefaultWeak"
    var isActive: Bool = true
}

class ServiceMany: ServiceValue {
    required init() { }
    var value: String = "DefaultMany"
    var isActive: Bool = true
}

class ServiceNested {
    let service: ServiceMany
    init(service: ServiceMany) {
        self.service = service
    }
}

class ServiceParams: ServiceParamsValue {
    struct Params {
        let value: String
        let error: Error?
    }

    var value: String
    init(value: String) {
        self.value = value
    }
}


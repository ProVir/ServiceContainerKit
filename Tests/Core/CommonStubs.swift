//
//  CommonStubs.swift
//  ServiceContainerKitTests
//
//  Created by Короткий Виталий on 21.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
@testable import ServiceContainerKit

struct SimpleServiceSession: ServiceSession {
    let key: AnyHashable
}

struct SimpleFirstModel: Equatable {
    var value: String
}

struct SimpleSecondModel: Equatable {
    var value: String
}

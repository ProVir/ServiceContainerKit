//
//  Logger.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 03.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public protocol Logger: class {
    var queue: DispatchQueue { get }
}

public extension Logger {
    var queue: DispatchQueue { .main }
}

public extension Logger {
    func register() {
        LogRecorder.shared = self
    }
}

enum LogRecorder {
    fileprivate(set)
    static var shared: Logger?
}

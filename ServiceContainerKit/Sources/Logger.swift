//
//  Logger.swift
//  ServiceContainerKit/Core 3.0.0
//
//  Created by Короткий Виталий on 03.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

/// Base protocol for logger.
public protocol Logger: class {
    var queue: DispatchQueue { get }
}

public extension Logger {
    var queue: DispatchQueue { .main }
}

public extension Logger {
    /// Register this logger as shared singleton
    func register() {
        LogRecorder.shared = self
    }
}

public enum LogRecorder {
    public fileprivate(set)
    static var shared: Logger?
}

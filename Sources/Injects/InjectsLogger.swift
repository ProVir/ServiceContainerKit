//
//  InjectsLogger.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 03.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

/// Logger for injects
public protocol InjectsLogger: Logger {
    func entityInjectResolverDidAutoRemove(entityType: Any.Type, delay: TimeInterval)
}

extension LogRecorder {
    private static func send(_ handler: @escaping (InjectsLogger) -> Void) {
        guard let logger = shared as? InjectsLogger else { return }
        logger.queue.async { handler(logger) }
    }
    
    static func entityInjectResolverDidAutoRemove(entityType: Any.Type, delay: TimeInterval) {
        send { $0.entityInjectResolverDidAutoRemove(entityType: entityType, delay: delay) }
    }
}

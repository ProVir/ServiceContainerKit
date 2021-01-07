//
//  InjectsLogger.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 03.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

typealias LogRecorder = ServiceContainerKit.LogRecorder

/// Logger for injects
public protocol ServiceInjectLogger: Logger {
    func entityInjectResolverDidAutoRemove(entityType: Any.Type, delay: TimeInterval)
}

extension LogRecorder {
    private static func send(_ handler: @escaping (ServiceInjectLogger) -> Void) {
        guard let logger = shared as? ServiceInjectLogger else { return }
        logger.queue.async { handler(logger) }
    }
    
    static func entityInjectResolverDidAutoRemove(entityType: Any.Type, delay: TimeInterval) {
        send { $0.entityInjectResolverDidAutoRemove(entityType: entityType, delay: delay) }
    }
}

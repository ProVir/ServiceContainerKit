//
//  ProvidersLogger.swift
//  ServiceContainerKit/Core 3.0.0
//
//  Created by Короткий Виталий on 03.10.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

/// Logger for failure make services
public protocol ProvidersLogger: Logger {
    func serviceProviderMakeFailure(type: Any.Type, error: ServiceObtainError)
    func serviceProviderObjCNotSupport(type: Any.Type)
}

extension LogRecorder {
    private static func send(_ handler: @escaping (ProvidersLogger) -> Void) {
        guard let logger = shared as? ProvidersLogger else { return }
        logger.queue.async { handler(logger) }
    }
    
    static func serviceProviderMakeFailure(type: Any.Type, error: ServiceObtainError) {
        send { $0.serviceProviderMakeFailure(type: type, error: error) }
    }
    
    static func serviceProviderObjCNotSupport(type: Any.Type) {
        send { $0.serviceProviderObjCNotSupport(type: type) }
    }
}

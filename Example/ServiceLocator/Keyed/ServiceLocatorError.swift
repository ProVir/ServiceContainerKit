//
//  ServiceLocatorError.swift
//  ServiceLocator
//
//  Created by Vitalii Korotkii on 02/02/2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

///Errors for ServiceLocator
public enum ServiceLocatorError: LocalizedError {
    case serviceNotFound
    case invalidProvider
    case sharedRequireSetup

    public var errorDescription: String? {
        switch self {
        case .serviceNotFound: return "Service not found in ServiceLocator"
        case .invalidProvider: return "Provider with invalid service type"
        case .sharedRequireSetup: return "ServiceLocator don't setuped for use as share (singleton)"
        }
    }
}

public extension ServiceObtainError {
    var isServiceNotFound: Bool {
        if let error = error as? ServiceLocatorError {
            return error == .serviceNotFound
        } else {
            return false
        }
    }

    var isServiceLocatorError: Bool {
        return error is ServiceLocatorError
    }
}

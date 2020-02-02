//
//  ServiceLocatorError.swift
//  ServiceContainerKit
//
//  Created by Vitalii Korotkii on 02/02/2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

///Errors for ServiceLocator
public enum ServiceLocatorError: LocalizedError {
    case serviceNotFound
    case invalidProvider

    public var errorDescription: String? {
        switch self {
        case .serviceNotFound: return "Service not found in ServiceLocator"
        case .invalidProvider: return "Provider with invalid service type"
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

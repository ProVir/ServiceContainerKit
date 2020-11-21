//
//  Errors.swift
//  ServiceContainerKit/Core 3.0.0
//
//  Created by Vitalii Korotkii on 01/02/2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

/// General error for obtain services with support for multiple nesting levels of services.
public struct ServiceObtainError: LocalizedError {
    public typealias ServiceType = Any.Type

    /// Path service types from get service (first) to failure make service (last).
    public let pathServices: [ServiceType]
    
    /// The service type that received an error. Always equal to `pathServices.last`
    public let service: ServiceType
    
    /// Original error from service factory.
    public let error: Error
    
    /// Contains nested services.
    public var isNested: Bool { pathServices.count > 1 }

    public init(service: ServiceType, error: Error) {
        self.init(service: service, error: error, path: [service])
    }

    public func withAddedToPath(service: ServiceType) -> Self {
        return .init(service: self.service, error: self.error, path: [service] + self.pathServices)
    }

    /// Message with detail for `fatalError()` method.
    public var fatalMessage: String {
        let nameText = "Failure get service \(service)"
        let pathText = pathServices.count > 1 ? "pathServices: \([pathServices])" : nil
        let errorText = "error: \(error)"

        return [nameText, pathText, errorText].compactMap { $0 }.joined(separator: ", ")
    }

    public var errorDescription: String? {
        return fatalMessage
    }

    private init(service: ServiceType, error: Error, path: [ServiceType]) {
        self.service = service
        self.pathServices = path
        self.error = error
    }
}

/// Errors for make services in ServiceProvider.
public enum ServiceFactoryError: LocalizedError {
    case wrongParams
    case wrongSession
    case invalidFactory

    public var errorDescription: String? {
        switch self {
        case .wrongParams: return "Params type invalid for ServiceParamsFactory"
        case .wrongSession: return "Session type invalid for ServiceSessionFactory"
        case .invalidFactory: return "Factory with invalid service type"
        }
    }
}

public extension ServiceObtainError {
    var isWrongParams: Bool {
        if let error = error as? ServiceFactoryError {
            return error == .wrongParams
        } else {
            return false
        }
    }

    var isFactoryError: Bool {
        return error is ServiceFactoryError
    }
}

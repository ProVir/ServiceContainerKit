//
//  Errors.swift
//  ServiceContainerKit/ServiceProvider 2.0.0
//
//  Created by Vitalii Korotkii on 01/02/2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public typealias ServiceType = Any.Type

public struct ServiceObtainError: LocalizedError {
    public let pathServices: [ServiceType]
    public let service: ServiceType
    public let error: Error

    public init(service: ServiceType, error: Error) {
        self.init(service: service, error: error, path: [service])
    }

    public func withAddedToPath(service: ServiceType) -> Self {
        return .init(service: self.service, error: self.error, path: [service] + self.pathServices)
    }

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

public enum ServiceFactoryError: LocalizedError {
    case wrongParams
    case invalidFactory

    public var errorDescription: String? {
        switch self {
        case .wrongParams: return "Params type invalid for ServiceParamsFactory"
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

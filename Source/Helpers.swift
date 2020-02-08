//
//  Helpers.swift
//  ServiceContainerKit/ServiceProvider 2.0.0
//
//  Created by Vitalii Korotkii on 07/02/2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

struct ServiceProviderHelper<ServiceType> {
    func makeService(factory: ServiceCoreFactory, params: Any) -> Result<ServiceType, ServiceObtainError> {
        do {
            if let service = try factory.coreMakeService(params: params) as? ServiceType {
                return .success(service)
            } else {
                throw ServiceFactoryError.invalidFactory
            }
        } catch {
            return .failure(convertToObtainError(error: error))
        }
    }

    private func convertToObtainError(error: Error) -> ServiceObtainError {
        if let error = error as? ServiceObtainError {
            return error.withAddedToPath(service: ServiceType.self)
        } else {
            return ServiceObtainError(service: ServiceType.self, error: error)
        }
    }
}

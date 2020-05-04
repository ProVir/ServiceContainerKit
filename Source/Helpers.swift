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

// MARK: - Safe thread
final class ServiceSafeProviderHandler {
    let kind: ServiceSafeProviderKind?

    private let lock: NSLock?
    private let semaphore: DispatchSemaphore?
    private let queue: DispatchQueue?

    init(kind: ServiceSafeProviderKind?) {
        self.kind = kind
        switch kind {
        case .none:
            self.lock = nil
            self.semaphore = nil
            self.queue = nil

        case .lock:
            self.lock = .init()
            self.semaphore = nil
            self.queue = nil

        case .semaphore:
            self.lock = nil
            self.semaphore = .init(value: 1)
            self.queue = nil

        case let .queue(qos, label):
            self.lock = nil
            self.semaphore = nil
            self.queue = .init(label: label ?? "ru.provir.ServiceContainerKit.ServiceSafeProvider", qos: qos)
        }
    }

    func safelyHandling<R>(_ handler: () -> R) -> R {
        lock?.lock()
        semaphore?.wait()
        defer {
            lock?.unlock()
            semaphore?.signal()
        }

        if let queue = queue {
            return queue.sync(execute: handler)
        } else {
            return handler()
        }
    }
}


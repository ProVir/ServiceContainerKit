//
//  ServiceFactoryToProvider.swift
//  ServiceContainerKit/Core 3.0.0
//
//  Created by Короткий Виталий on 21.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

public extension ServiceFactory {
    /// Wrap the factory in ServiceProvider
    func serviceProvider() -> ServiceProvider<ServiceType> {
        return .init(factory: self)
    }

    /// Wrap the factory in ServiceSafeProvider
    func serviceSafeProvider(safeThread kind: ServiceSafeProviderKind = .default) -> ServiceSafeProvider<ServiceType> {
        return .init(factory: self, safeThread: kind)
    }
}

public extension ServiceSessionFactory {
    /// Wrap the factory in ServiceProvider
    func serviceProvider(mediator: ServiceSessionMediator<SessionType>) -> ServiceProvider<ServiceType> {
        return .init(factory: self, mediator: mediator)
    }

    /// Wrap the factory in ServiceSafeProvider
    func serviceSafeProvider(mediator: ServiceSessionMediator<SessionType>, safeThread kind: ServiceSafeProviderKind = .default) -> ServiceSafeProvider<ServiceType> {
        return .init(factory: self, mediator: mediator, safeThread: kind)
    }
}

public extension ServiceParamsFactory {
    /// Wrap the factory in ServiceParamsProvider
    func serviceProvider() -> ServiceParamsProvider<ServiceType, ParamsType> {
        return .init(factory: self)
    }

    /// Wrap the factory in ServiceProvider with specific params.
    func serviceProvider(params: ParamsType) -> ServiceProvider<ServiceType> {
        return .init(factory: self, params: params)
    }

    /// Wrap the factory in ServiceParamsSafeProvider
    func serviceSafeProvider(safeThread kind: ServiceSafeProviderKind = .default) -> ServiceParamsSafeProvider<ServiceType, ParamsType> {
        return .init(factory: self, safeThread: kind)
    }

    /// Wrap the factory in ServiceSafeProvider with specific params.
    func serviceSafeProvider(params: ParamsType, safeThread kind: ServiceSafeProviderKind = .default) -> ServiceSafeProvider<ServiceType> {
        return .init(factory: self, params: params, safeThread: kind)
    }
}

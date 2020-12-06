//
//  NoteRecordsManagerFactory.swift
//  Example
//
//  Created by Короткий Виталий on 30.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine
import ServiceContainerKit

struct NoteRecordsManagerParams {
    let folder: NoteFolder
}

final class NoteRecordsManagerFactory: ServiceParamsFactory {
    private let apiClient: ServiceProvider<APIClient>
    private let userService: ServiceProvider<UserService>
    
    private var services: [NoteFolder.Id: NoteRecordsManager] = [:]
    private var userCancellable: AnyCancellable?
    
    init(apiClient: ServiceProvider<APIClient>, userService: ServiceProvider<UserService>) {
        self.apiClient = apiClient
        self.userService = userService
    }
    
    func makeService(params: NoteRecordsManagerParams) throws -> NoteRecordsManager {
        if let service = services[params.folder.id] {
            return service
        } else {
            subscribeUserIfNeeded()
            let service = try makeNewService(params: params)
            services[params.folder.id] = service
            return service
        }
    }
    
    private func subscribeUserIfNeeded() {
        guard userCancellable == nil else { return }
        userCancellable = userService.getServiceAsOptional()?.userPublisher.sink { [weak self] _ in
            self?.services = [:]
        }
    }
    
    private func makeNewService(params: NoteRecordsManagerParams) throws -> NoteRecordsManager {
        NoteRecordsManagerImpl(
            folder: params.folder,
            apiClient: try apiClient.getService()
        )
    }
}


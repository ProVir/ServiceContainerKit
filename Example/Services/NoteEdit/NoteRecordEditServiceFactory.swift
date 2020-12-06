//
//  NoteRecordEditServiceFactory.swift
//  Example
//
//  Created by Короткий Виталий on 30.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine
import ServiceContainerKit

struct NoteRecordEditServiceParams {
    let folder: NoteFolder
    let record: NoteRecord?
}

struct NoteRecordEditServiceFactory: ServiceParamsFactory {
    let apiClient: ServiceProvider<APIClient>
    let recordsManager: ServiceParamsProvider<NoteRecordsManager, NoteRecordsManagerParams>
    
    func makeService(params: NoteRecordEditServiceParams) throws -> NoteRecordEditService {
        let recordsManager = try self.recordsManager.getService(params: .init(folder: params.folder))
        return NoteRecordEditServiceImpl(
            folder: params.folder,
            record: params.record,
            apiClient: try apiClient.getService(),
            notifyRecordsChanged: { [recordsManager] in recordsManager.reload(completion: nil) }
        )
    }
}

//
//  NoteRecordsManagerImpl.swift
//  Example
//
//  Created by Короткий Виталий on 05.12.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine

final class NoteRecordsManagerImpl: NoteRecordsManager {
    private let apiClient: APIClient
    private var lastReloadSuccess = false
    
    let folder: NoteFolder
    
    @Observable
    private(set) var notes: [NoteRecord] = []
    var notesPublisher: AnyPublisher<[NoteRecord], Never> { $notes }
    
    init(folder: NoteFolder, apiClient: APIClient) {
        self.folder = folder
        self.apiClient = apiClient
    }
    
    func reloadIfNeeded() {
        if lastReloadSuccess == false {
            reload(completion: nil)
        }
    }
    
    func reload(completion: ((Result<[NoteRecord], Error>) -> Void)?) {
        apiClient.requestNotes(folderId: folder.id) { [weak self] result in
            guard let self = self else { return }
            if let notes = try? result.get() {
                self.lastReloadSuccess = true
                self.notes = notes
            } else {
                self.lastReloadSuccess = false
            }
            completion?(result.mapError({ $0 }))
        }
    }
    
    func remove(recordId: NoteRecord.Id, completion: @escaping (Result<Void, Error>) -> Void) {
        apiClient.removeNote(folderId: folder.id, recordId: recordId) { [weak self] result in
            guard let self = self else { return }
            completion(result.mapError({ $0 }))
            if case .success = result {
                self.lastReloadSuccess = false
                self.reload(completion: nil)
            }
        }
    }
}

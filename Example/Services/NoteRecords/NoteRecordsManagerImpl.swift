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
    
    @Published
    private(set) var notes: [NoteRecord] = []
    var notesPublisher: Published<[NoteRecord]>.Publisher { $notes }
    
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
}

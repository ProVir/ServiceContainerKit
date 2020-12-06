//
//  NoteRecordEditServiceImpl.swift
//  Example
//
//  Created by Короткий Виталий on 05.12.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine

final class NoteRecordEditServiceImpl: NoteRecordEditService {
    private let apiClient: APIClient
    private let notifyRecordsChanged: () -> Void
    
    let folder: NoteFolder
    
    @Published
    private(set) var record: NoteRecord?
    var recordPublisher: Published<NoteRecord?>.Publisher { $record }
    
    init(folder: NoteFolder, record: NoteRecord?, apiClient: APIClient, notifyRecordsChanged: @escaping () -> Void) {
        self.folder = folder
        self.record = record
        self.apiClient = apiClient
        self.notifyRecordsChanged = notifyRecordsChanged
    }
    
    func apply(content: NoteRecord.Content, completion: @escaping (Result<NoteRecord, Error>) -> Void) {
        if let record = self.record {
            apiClient.editNote(folderId: folder.id, recordId: record.id, content: content) { [weak self] in
                self?.handleApply(result: $0, completion: completion)
            }
        } else {
            apiClient.addNote(folderId: folder.id, content: content) { [weak self] in
                self?.handleApply(result: $0, completion: completion)
            }
        }
    }
    
    func remove(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let record = self.record else {
            return completion(.success(()))
        }
        apiClient.removeNote(folderId: folder.id, recordId: record.id) { [weak self] result in
            guard let self = self else { return }
            if case .success = result {
                self.record = nil
                self.notifyRecordsChanged()
            }
            completion(result.mapError({ $0 }))
        }
    }
    
    private func handleApply(result: Result<NoteRecord, APIError>, completion: @escaping (Result<NoteRecord, Error>) -> Void) {
        if case let .success(record) = result {
            self.record = record
            self.notifyRecordsChanged()
        }
        completion(result.mapError({ $0 }))
    }
}

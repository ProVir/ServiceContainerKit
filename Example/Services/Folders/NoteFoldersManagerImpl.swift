//
//  NoteFoldersManagerImpl.swift
//  Example
//
//  Created by Короткий Виталий on 30.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine

final class NoteFoldersManagerImpl: NoteFoldersManager {
    private let apiClient: APIClient
    private var lastReloadSuccess = false
    
    private var cancellableStorage: Set<AnyCancellable> = []
    
    @Observable
    private(set) var folders: [NoteFolder] = []
    var foldersPublisher: AnyPublisher<[NoteFolder], Never> { $folders }
    
    init(apiClient: APIClient, userService: UserService) {
        self.apiClient = apiClient
        
        userService.userPublisher.sink { [weak self] user in
            self?.handleUserChanged(user)
        }.store(in: &cancellableStorage)
    }
    
    func reloadIfNeeded() {
        if lastReloadSuccess == false {
            reload(completion: nil)
        }
    }
    
    func reload(completion: ((Result<[NoteFolder], Error>) -> Void)?) {
        apiClient.requestFolders { [weak self] result in
            guard let self = self else { return }
            if let folders = try? result.get() {
                self.lastReloadSuccess = true
                self.folders = folders
            } else {
                self.lastReloadSuccess = false
            }
            completion?(result.mapError({ $0 }))
        }
    }
    
    func add(content: NoteFolder.Content, completion: @escaping (Result<NoteFolder, Error>) -> Void) {
        apiClient.addFolder(content: content) { [weak self] result in
            completion(result.mapError({ $0 }))
            self?.handleEditFolders(result)
        }
    }
    
    func remove(folderId: NoteFolder.Id, completion: @escaping (Result<Void, Error>) -> Void) {
        apiClient.removeFolder(folderId: folderId) { [weak self] result in
            completion(result.mapError({ $0 }))
            self?.handleEditFolders(result)
        }
    }
    
    func edit(folderId: NoteFolder.Id, content: NoteFolder.Content, completion: @escaping (Result<NoteFolder, Error>) -> Void) {
        apiClient.editFolder(folderId: folderId, content: content) { [weak self] result in
            completion(result.mapError({ $0 }))
            self?.handleEditFolders(result)
        }
    }
    
    // MARK: Private
    private func handleEditFolders<T>(_ result: Result<T, APIError>) {
        if case .success = result {
            lastReloadSuccess = false
            reload(completion: nil)
        }
    }
    
    private func handleUserChanged(_ user: User?) {
        folders = []
        if user != nil {
            lastReloadSuccess = false
            reload(completion: nil)
        } else {
            lastReloadSuccess = true
        }
    }
}

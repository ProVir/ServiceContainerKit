//
//  APIMockClient.swift
//  Example
//
//  Created by Короткий Виталий on 29.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

final class APIMockClient: APIClient {
    private struct UserStore {
        var folders: [NoteFolder] = []
        var notes: [NoteFolder.Id: [NoteRecord]] = [:]
    }
    
    private let userIdProvider: APIUserIdProvider
    
    private var authUsers: [String: User] = [:]
    private var userStores: [User.Id: UserStore] = [:]
    
    private var lastUserId: User.Id = 0
    private var lastFolderId: NoteFolder.Id = 0
    private var lastNoteId: NoteRecord.Id = 0
    
    init(userIdProvider: APIUserIdProvider) {
        self.userIdProvider = userIdProvider
    }
    
    // MARK: User
    func authUser(login: String, completion: @escaping (Result<User, APIError>) -> Void) {
        if let user = authUsers[login] {
            completion(.success(user))
        } else {
            lastUserId += 1
            let user = User(id: lastUserId, login: login)
            authUsers[login] = user
            userStores[user.id] = .init()
            
            completion(.success(user))
        }
    }
    
    // MARK: Folders
    func requestFolders(completion: @escaping (Result<[NoteFolder], APIError>) -> Void) {
        guard let userId = userIdProvider.currentUserId(),
              let folders = userStores[userId]?.folders else {
            return completion(.failure(.userInvalid))
        }
        completion(.success(folders))
    }

    func addFolder(content: NoteFolder.Content, completion: @escaping (Result<NoteFolder, APIError>) -> Void) {
        guard let userId = userIdProvider.currentUserId(), userStores[userId] != nil else {
            return completion(.failure(.userInvalid))
        }
  
        lastFolderId += 1
        let folder = NoteFolder(id: lastFolderId, content: content)
        userStores[userId]?.folders.append(folder)
        userStores[userId]?.notes[folder.id] = []
        completion(.success(folder))
    }
    
    func removeFolder(folderId: NoteFolder.Id, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let userId = userIdProvider.currentUserId(), userStores[userId] != nil else {
            return completion(.failure(.userInvalid))
        }
        guard let index = userStores[userId]?.folders.firstIndex(where: { $0.id == folderId }) else {
            return completion(.failure(.notFound))
        }
        userStores[userId]?.folders.remove(at: index)
        userStores[userId]?.notes.removeValue(forKey: folderId)
        completion(.success(()))
    }
    
    func editFolder(folderId: NoteFolder.Id, content: NoteFolder.Content, completion: @escaping (Result<NoteFolder, APIError>) -> Void) {
        guard let userId = userIdProvider.currentUserId(), userStores[userId] != nil else {
            return completion(.failure(.userInvalid))
        }
        guard let index = userStores[userId]?.folders.firstIndex(where: { $0.id == folderId }) else {
            return completion(.failure(.notFound))
        }
        let folder = NoteFolder(id: folderId, content: content)
        userStores[userId]?.folders[index] = folder
        completion(.success(folder))
    }
    
    // MARK: Notes
    func requestNotes(folderId: NoteFolder.Id, completion: @escaping (Result<[NoteRecord], APIError>) -> Void) {
        guard let userId = userIdProvider.currentUserId(),
              let noteMap = userStores[userId]?.notes else {
            return completion(.failure(.userInvalid))
        }
        if let notes = noteMap[folderId] {
            completion(.success(notes))
        } else {
            completion(.failure(.notFound))
        }
    }
    
    func addNote(folderId: NoteFolder.Id, content: NoteRecord.Content, completion: @escaping (Result<NoteRecord, APIError>) -> Void) {
        guard let userId = userIdProvider.currentUserId(), userStores[userId] != nil else {
            return completion(.failure(.userInvalid))
        }
        guard userStores[userId]?.notes[folderId] != nil else {
            return completion(.failure(.notFound))
        }
        
        lastNoteId += 1
        let note = NoteRecord(id: lastNoteId, date: Date(), content: content)
        userStores[userId]?.notes[folderId]?.append(note)
        completion(.success(note))
    }
    
    func removeNote(folderId: NoteFolder.Id, recordId: NoteRecord.Id, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let userId = userIdProvider.currentUserId(), userStores[userId] != nil else {
            return completion(.failure(.userInvalid))
        }
        guard let index = userStores[userId]?.notes[folderId]?.firstIndex(where: { $0.id == recordId }) else {
            return completion(.failure(APIError.notFound))
        }
        
        userStores[userId]?.notes[folderId]?.remove(at: index)
        completion(.success(()))
    }
    
    func editNote(folderId: NoteFolder.Id, recordId: NoteRecord.Id, content: NoteRecord.Content, completion: @escaping (Result<NoteRecord, APIError>) -> Void) {
        guard let userId = userIdProvider.currentUserId(), userStores[userId] != nil else {
            return completion(.failure(.userInvalid))
        }
        guard let index = userStores[userId]?.notes[folderId]?.firstIndex(where: { $0.id == recordId }) else {
            return completion(.failure(.notFound))
        }
        
        let note = NoteRecord(id: recordId, date: Date(), content: content)
        userStores[userId]?.notes[folderId]?[index] = note
        completion(.success(note))
    }
}

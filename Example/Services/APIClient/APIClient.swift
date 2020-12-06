//
//  APIClient.swift
//  Example
//
//  Created by Короткий Виталий on 29.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

enum APIError: Error {
    case userInvalid
    case notFound
}

protocol APIUserIdProvider: class {
    func currentUserId() -> User.Id?
}

protocol APIClient: class {
    // User
    func authUser(login: String, completion: @escaping (Result<User, APIError>) -> Void)
    
    // Folders
    func requestFolders(completion: @escaping (Result<[NoteFolder], APIError>) -> Void)
    func addFolder(content: NoteFolder.Content, completion: @escaping (Result<NoteFolder, APIError>) -> Void)
    func removeFolder(folderId: NoteFolder.Id, completion: @escaping (Result<Void, APIError>) -> Void)
    func editFolder(folderId: NoteFolder.Id, content: NoteFolder.Content, completion: @escaping (Result<NoteFolder, APIError>) -> Void)
    
    // Notes
    func requestNotes(folderId: NoteFolder.Id, completion: @escaping (Result<[NoteRecord], APIError>) -> Void)
    func addNote(folderId: NoteFolder.Id, content: NoteRecord.Content, completion: @escaping (Result<NoteRecord, APIError>) -> Void)
    func removeNote(folderId: NoteFolder.Id, recordId: NoteRecord.Id, completion: @escaping (Result<Void, APIError>) -> Void)
    func editNote(folderId: NoteFolder.Id, recordId: NoteRecord.Id, content: NoteRecord.Content, completion: @escaping (Result<NoteRecord, APIError>) -> Void)
}

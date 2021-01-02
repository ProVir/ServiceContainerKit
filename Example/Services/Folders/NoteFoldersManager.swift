//
//  NoteFoldersManager.swift
//  Example
//
//  Created by Короткий Виталий on 30.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine

protocol NoteFoldersManager: class {
    var folders: [NoteFolder] { get }
    var foldersPublisher: AnyPublisher<[NoteFolder], Never> { get }
    
    func reloadIfNeeded()
    func reload(completion: ((Result<[NoteFolder], Error>) -> Void)?)
    
    func add(content: NoteFolder.Content, completion: @escaping (Result<NoteFolder, Error>) -> Void)
    func remove(folderId: NoteFolder.Id, completion: @escaping (Result<Void, Error>) -> Void)
    func edit(folderId: NoteFolder.Id, content: NoteFolder.Content, completion: @escaping (Result<NoteFolder, Error>) -> Void)
}

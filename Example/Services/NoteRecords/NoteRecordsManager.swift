//
//  NoteRecordsManager.swift
//  Example
//
//  Created by Короткий Виталий on 30.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine

protocol NoteRecordsManager: class {
    var folder: NoteFolder { get }
    var notes: [NoteRecord] { get }
    var notesPublisher: AnyPublisher<[NoteRecord], Never> { get }
    
    func reloadIfNeeded()
    func reload(completion: ((Result<[NoteRecord], Error>) -> Void)?)
    
    func remove(recordId: NoteRecord.Id, completion: @escaping (Result<Void, Error>) -> Void)
}

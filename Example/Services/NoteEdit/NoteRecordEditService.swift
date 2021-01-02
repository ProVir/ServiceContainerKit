//
//  NoteRecordEditService.swift
//  Example
//
//  Created by Короткий Виталий on 30.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine

protocol NoteRecordEditService: class {
    var folder: NoteFolder { get }
    var record: NoteRecord? { get }
    var recordPublisher: AnyPublisher<NoteRecord?, Never> { get }
    
    func apply(content: NoteRecord.Content, completion: @escaping (Result<NoteRecord, Error>) -> Void)
    func remove(completion: @escaping (Result<Void, Error>) -> Void)
}

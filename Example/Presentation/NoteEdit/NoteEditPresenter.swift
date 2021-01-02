//
//  NoteEditPresenter.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation
import Combine

protocol NoteEditPresenter: class {
    var titlePublisher: AnyPublisher<String, Never> { get }
}

final class NoteEditPresenterImpl: NoteEditPresenter {
    private let editService: NoteRecordEditService
    
    var titlePublisher: AnyPublisher<String, Never> {
        editService.recordPublisher.map {
            $0 != nil ? "Edit note" : "Add note"
        }.eraseToAnyPublisher()
    }
    
    init(editService: NoteRecordEditService) {
        self.editService = editService
    }
    
}

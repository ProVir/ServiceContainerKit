//
//  NoteEditViewControllerFactory.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import UIKit
import ServiceInjects

extension NoteEditViewController {
    private struct Dependencies {
        @ServiceParamsInject(\Services.notes.editService) var editService
        
        init(folder: NoteFolder, editRecord: NoteRecord?) {
            $editService.setParameters(.init(folder: folder, record: editRecord))
        }
    }
    
    static func prepareForMakeNew(folder: NoteFolder) {
        prepareForMake(use: .init(folder: folder, editRecord: nil))
    }
    
    static func prepareForMakeEdit(folder: NoteFolder, record: NoteRecord) {
        prepareForMake(use: .init(folder: folder, editRecord: record))
    }
    
    private static func prepareForMake(use dependencies: Dependencies) {
        let presenter = NoteEditPresenterImpl(editService: dependencies.editService)
        EntityInjectResolver.registerForFirstInject(presenter)
    }
}

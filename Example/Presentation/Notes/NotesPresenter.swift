//
//  NotesPresenter.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation
import Combine
import ServiceContainerKit

protocol NotesPresenter: class {
    func configure(
        showAlertHandler: @escaping (String, String) -> Void,
        editNoteHandler: @escaping (NoteRecord) -> Void
    )
    
    var title: String { get }
    var folder: NoteFolder { get }
    
    var modelsPublisher: AnyPublisher<[SimpleCellViewModel], Never> { get }
    
    func reload(completion: @escaping () -> Void)
}

final class NotesPresenterImpl: NotesPresenter {
    @ServiceParamsInject(\Services.notes.manager)
    private var notesManager
    
    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .medium
        return f
    }()
    
    private var showAlert: (String, String) -> Void = { _, _ in }
    private var editNote: (NoteRecord) -> Void = { _ in }
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    var title: String {
        "Notes in \"\(folder.content.name)\""
    }
    
    var folder: NoteFolder { notesManager.folder }
    
    @Observable
    private var models: [SimpleCellViewModel] = []
    var modelsPublisher: AnyPublisher<[SimpleCellViewModel], Never> { $models }
    
    init(folder: NoteFolder) {
        $notesManager.setParameters(.init(folder: folder))
    }
    
    func configure(
        showAlertHandler: @escaping (String, String) -> Void,
        editNoteHandler: @escaping (NoteRecord) -> Void
    ) {
        self.showAlert = showAlertHandler
        self.editNote = editNoteHandler
        
        notesManager.notesPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.models = $0.map { self.buildCell(record: $0) }
        }.store(in: &cancellableSet)
    }
    
    func reload(completion: @escaping () -> Void) {
        notesManager.reload { [weak self] result in
            switch result {
            case .success: break
            case .failure(let error):
                self?.showErrorAlert(title: "Failed refresh list notes", error: error)
            }
            completion()
        }
    }
    
    // MARK: - Private
    private func showErrorAlert(title: String, error: Error) {
        let message = error.localizedDescription
        showAlert(title, message)
    }
    
    private func deleteNote(_ record: NoteRecord) {
        notesManager.remove(recordId: record.id) { [weak self] result in
            switch result {
            case .success: break
            case .failure(let error):
                self?.showErrorAlert(title: "Failed to remove note", error: error)
                self?._models.resendCurrentValue()
            }
        }
    }
    
    // MARK: Builder
    private func buildCell(record: NoteRecord) -> SimpleCellViewModel {
        return .init(
            text: record.content.title,
            detail: dateFormatter.string(from: record.date),
            onSelected: { [weak self] in self?.editNote(record) },
            onDeleted: { [weak self] in self?.deleteNote(record) }
        )
    }
}

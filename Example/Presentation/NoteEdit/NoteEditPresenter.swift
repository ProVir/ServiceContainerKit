//
//  NoteEditPresenter.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation
import Combine

enum NoteEditViewModel {
    enum EditState: Hashable {
        case new
        case newInvalid
        case changed
        case invalid
        case saved
    }
}

protocol NoteEditPresenter: class {
    func configure(
        showAlertHandler: @escaping (String, String) -> Void
    )
    
    var titlePublisher: AnyPublisher<String, Never> { get }
    var editStatePublisher: AnyPublisher<NoteEditViewModel.EditState, Never> { get }
    
    var contentText: String { get set }
    func save(completion: ((Bool) -> Void)?)
}

final class NoteEditPresenterImpl: NoteEditPresenter {
    private let editService: NoteRecordEditService
    
    private var showAlert: (String, String) -> Void = { _, _ in }
    
    @Observable
    var contentText: String
    
    var editStatePublisher: AnyPublisher<NoteEditViewModel.EditState, Never> {
        editService.recordPublisher.combineLatest($contentText).map { savedRecord, currentText in
            if let savedText = savedRecord?.content.content {
                if savedText == currentText {
                    return .saved
                } else {
                    return currentText.isEmpty ? .invalid : .changed
                }
            } else {
                return currentText.isEmpty ? .newInvalid : .new
            }
        }.removeDuplicates().eraseToAnyPublisher()
    }
    
    var titlePublisher: AnyPublisher<String, Never> {
        editStatePublisher.map {
            switch $0 {
            case .new, .newInvalid: return "New note"
            case .changed, .saved, .invalid: return "Edit note"
            }
        }.removeDuplicates().eraseToAnyPublisher()
    }
    
    init(editService: NoteRecordEditService) {
        self.editService = editService
        self.contentText = editService.record?.content.content ?? ""
    }
    
    func configure(
        showAlertHandler: @escaping (String, String) -> Void
    ) {
        self.showAlert = showAlertHandler
    }
    
    func save(completion: ((Bool) -> Void)?) {
        let title = makeTitle(for: contentText)
        let content = NoteRecord.Content(title: title, content: contentText)
        
        editService.apply(content: content) { [weak self] result in
            switch result {
            case .success: completion?(true)
            case .failure(let error):
                self?.showErrorAlert(title: "Failed to save note", error: error)
                completion?(false)
            }
        }
    }
    
    // MARK: - Private
    private func showErrorAlert(title: String, error: Error) {
        let message = error.localizedDescription
        showAlert(title, message)
    }
    
    private func makeTitle(for content: String) -> String {
        let firstLine = content.split(separator: "\n").first ?? ""
        
        let maxLength = 32
        if firstLine.count > maxLength {
            let str = firstLine.prefix(maxLength)
            if let index = str.lastIndex(of: " ") {
                return String(str[str.startIndex..<index])
            } else {
                return String(str)
            }
        } else {
            return String(firstLine)
        }
    }
}

//
//  MainPresenter.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation
import Combine
import ServiceInjects

protocol MainPresenter: class {
    func configure(
        showAlertHandler: @escaping (String, String) -> Void,
        routeToFolderHandler: @escaping (NoteFolder) -> Void
    )
    
    var titlePublisher: AnyPublisher<String, Never> { get }
    var modelsPublisher: AnyPublisher<[SimpleCellViewModel], Never> { get }
    var isAuthUser: Bool { get }
    
    func login(user: String)
    func logoutUser()
    
    func addFolder(name: String)
    func reload(completion: @escaping () -> Void)
}

final class MainPresenterImpl: MainPresenter {
    @ServiceInject(\Services.user.userService)
    private var userService
    
    @ServiceInject(\Services.folders.manager)
    private var foldersManager
    
    private var showAlert: (String, String) -> Void = { _, _ in }
    private var routeToFolder: (NoteFolder) -> Void = { _ in }
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    var titlePublisher: AnyPublisher<String, Never> {
        userService.userPublisher.map {
            if let user = $0 {
                return "Folders for \"\(user.login)\""
            } else {
                return "Not authorized user"
            }
        }.eraseToAnyPublisher()
    }
    
    @Observable
    private var models: [SimpleCellViewModel] = []
    var modelsPublisher: AnyPublisher<[SimpleCellViewModel], Never> { $models }
    
    var isAuthUser: Bool { userService.user != nil }
    
    func configure(
        showAlertHandler: @escaping (String, String) -> Void,
        routeToFolderHandler: @escaping (NoteFolder) -> Void
    ) {
        self.showAlert = showAlertHandler
        self.routeToFolder = routeToFolderHandler
        
        foldersManager.foldersPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.models = $0.map { self.buildCell(folder: $0) }
        }.store(in: &cancellableSet)
    }
    
    func login(user: String) {
        userService.auth(login: user) { [weak self] in
            self?.handleOperation(result: $0, errorTitle: "Failed change user")
        }
    }
    
    func logoutUser() {
        userService.logout()
    }
    
    func addFolder(name: String) {
        foldersManager.add(content: .init(name: name)) { [weak self] in
            self?.handleOperation(result: $0, errorTitle: "Failed to create folder")
        }
    }
    
    func reload(completion: @escaping () -> Void) {
        foldersManager.reload { [weak self] in
            self?.handleOperation(result: $0, errorTitle: "Failed refresh list folders")
            completion()
        }
    }
    
    // MARK: - Private
    private func handleOperation<T>(result: Result<T, Error>, errorTitle: @autoclosure () -> String) {
        switch result {
        case .success: break
        case .failure(let error):
            showErrorAlert(title: errorTitle(), error: error)
        }
    }
    
    private func showErrorAlert(title: String, error: Error) {
        let message = error.localizedDescription
        showAlert(title, message)
    }
    
    private func deleteFolder(_ folder: NoteFolder) {
        foldersManager.remove(folderId: folder.id) { [weak self] result in
            switch result {
            case .success: break
            case .failure(let error):
                self?.showErrorAlert(title: "Failed to remove folder", error: error)
                self?._models.resendCurrentValue()
            }
        }
    }
    
    // MARK: Builders
    private func buildCell(folder: NoteFolder) -> SimpleCellViewModel {
        return .init(
            text: folder.content.name,
            detail: nil,
            onSelected: { [weak self] in self?.routeToFolder(folder) },
            onDeleted: { [weak self] in self?.deleteFolder(folder) }
        )
    }
}

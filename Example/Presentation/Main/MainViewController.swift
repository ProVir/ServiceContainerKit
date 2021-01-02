//
//  MainViewController.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import UIKit
import Combine
import ServiceContainerKit

extension MainViewController {
    static func prepareForMake() {
        let presenter = MainPresenterImpl()
        EntityInjectResolver.registerForFirstInject(presenter)
    }
}

class MainViewController: SimpleTableViewController {
    @EntityInject(MainPresenter.self)
    private var presenter
    
    private var cancellableSet: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter.autoDeselect = false
        
        presenter.configure(
            showAlertHandler: { [weak self] title, message in
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            },
            routeToFolderHandler: { [weak self] folder in
                self?.routeTo(folder: folder)
            }
        )
        presenter.titlePublisher.sink { [weak self] in
            self?.navigationItem.title = $0
        }.store(in: &cancellableSet)
        presenter.modelsPublisher.sink { [weak self] in
            self?.adapter.update(models: $0)
        }.store(in: &cancellableSet)
    }
    
    // MARK: Actions
    @IBAction private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.presenter.reload {
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    @IBAction private func manageUser() {
        let isAuthUser = presenter.isAuthUser
        let message = isAuthUser ? "Change user or logout?" : "Login user"
        let alert = UIAlertController(title: "User manager", message: message, preferredStyle: .alert)
        
        var textField: UITextField?
        alert.addTextField {
            $0.placeholder = "Login"
            textField = $0
        }
        
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Login", style: .default) { [weak self] _ in
            guard let login = textField?.text else { return }
            self?.presenter.login(user: login)
        })
        
        if isAuthUser {
            alert.addAction(.init(title: "Logout", style: .destructive) { [weak self] _ in
                self?.presenter.logoutUser()
            })
        }
        
        present(alert, animated: true, completion: nil)
    }

    @IBAction private func addFolder() {
        let alert = UIAlertController(title: "New folder", message: "Enter the name of the folder", preferredStyle: .alert)
        
        var textField: UITextField?
        alert.addTextField {
            $0.placeholder = "Name folder"
            textField = $0
        }
        
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Create", style: .default) { [weak self] _ in
            guard let name = textField?.text, name.isEmpty == false else { return }
            self?.presenter.addFolder(name: name)
        })
        
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation
    private enum SegueIdentifier: String {
        case notes
    }
    
    private func routeTo(folder: NoteFolder) {
        NotesViewController.prepareForMake(folder: folder)
        performSegue(withIdentifier: SegueIdentifier.notes.rawValue, sender: nil)
    }

}

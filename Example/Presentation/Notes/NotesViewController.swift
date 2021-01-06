//
//  NotesViewController.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import UIKit
import Combine
import ServiceInjects

extension NotesViewController {
    static func prepareForMake(folder: NoteFolder) {
        let presenter = NotesPresenterImpl(folder: folder)
        EntityInjectResolver.registerForFirstInject(presenter)
    }
}

class NotesViewController: SimpleTableViewController {
    @EntityInject(NotesPresenter.self)
    private var presenter
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.configure(
            showAlertHandler: { [weak self] title, message in
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            },
            editNoteHandler: { [weak self] note in
                self?.routeToEdit(note: note)
            }
        )
        presenter.modelsPublisher.sink { [weak self] in
            self?.adapter.update(models: $0)
        }.store(in: &cancellableSet)
        
        navigationItem.title = presenter.title
    }
    
    // MARK: Actions
    @IBAction private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.presenter.reload {
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Navigation
    private enum SegueIdentifier: String {
        case add
        case edit
    }
    
    private func routeToEdit(note: NoteRecord) {
        performSegue(withIdentifier: SegueIdentifier.edit.rawValue, sender: note)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = SegueIdentifier(rawValue: segue.identifier ?? "") else { return }
        
        switch segueId {
        case .add:
            NoteEditViewController.prepareForMakeNew(folder: presenter.folder)
            
        case .edit:
            guard let note = sender as? NoteRecord else { return }
            NoteEditViewController.prepareForMakeEdit(folder: presenter.folder, record: note)
        }
    }

}

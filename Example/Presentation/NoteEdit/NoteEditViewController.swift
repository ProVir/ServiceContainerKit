//
//  NoteEditViewController.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import UIKit
import Combine
import ServiceContainerKit

class NoteEditViewController: UIViewController {
    @EntityInject(NoteEditPresenter.self)
    private var presenter
    
    private var cancellableSet: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.titlePublisher.sink { [weak self] in
            self?.navigationItem.title = $0
        }.store(in: &cancellableSet)
    }
    
}

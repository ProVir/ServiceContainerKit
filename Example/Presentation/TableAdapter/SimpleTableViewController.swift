//
//  SimpleTableViewController.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import UIKit

class SimpleTableViewController: UITableViewController {
    
    static let cellIdentifier = "cell"
    
    let adapter = SimpleTableAdapter()

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter.bind(tableView: tableView, cellIdentifier: Self.cellIdentifier, bindToAdapter: false)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return adapter.numberOfSections(in: tableView)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adapter.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return adapter.tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        adapter.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return adapter.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }
    
}

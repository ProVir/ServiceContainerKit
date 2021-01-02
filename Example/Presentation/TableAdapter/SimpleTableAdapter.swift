//
//  SimpleTableAdapter.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import UIKit

final class SimpleTableAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private weak var tableView: UITableView?
    private var cellIdentifier = ""
    
    private var models: [SimpleCellViewModel] = []
    
    var autoDeselect = true
    
    func bind(tableView: UITableView, cellIdentifier: String, bindToAdapter: Bool = true) {
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        
        if bindToAdapter {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    func update(models: [SimpleCellViewModel]) {
        self.models = models
        tableView?.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let model = models[indexPath.row]
        cell.textLabel?.text = model.text
        cell.detailTextLabel?.text = model.detail
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        model.onSelected()
        
        if autoDeselect {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let model = models[indexPath.row]
        guard let handler = model.onDeleted else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.models.remove(at: indexPath.row)
            self?.tableView?.deleteRows(at: [indexPath], with: .fade)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: handler)
            completion(true)
        }
        
        return .init(actions: [deleteAction])
    }
 
}

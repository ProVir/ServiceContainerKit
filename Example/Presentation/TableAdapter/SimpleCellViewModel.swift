//
//  SimpleCellViewModel.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation

struct SimpleCellViewModel {
    let text: String
    let detail: String?
    let onSelected: () -> Void
    let onDeleted: (() -> Void)?
}

//
//  Types.swift
//  Example
//
//  Created by Короткий Виталий on 27.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

struct User {
    typealias Id = Int64
    
    let id: Id
    let login: String
}

struct NoteFolder {
    typealias Id = Int64
    
    struct Content {
        let name: String
    }
    
    let id: Id
    let content: Content
}

struct NoteRecord {
    typealias Id = Int64
    
    struct Content {
        let title: String
        let content: String
    }
    
    let id: Id
    let date: Date
    let content: Content
}

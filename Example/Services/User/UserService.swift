//
//  UserService.swift
//  Example
//
//  Created by Короткий Виталий on 29.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine

protocol UserService: class {
    var user: User? { get }
    var userPublisher: AnyPublisher<User?, Never> { get }
    
    func auth(login: String, completion: @escaping (Result<User, Error>) -> Void)
    func logout()
}

final class UserIdProvider: APIUserIdProvider {
    weak var userService: UserService?
    
    func currentUserId() -> User.Id? {
        return userService?.user?.id
    }
}

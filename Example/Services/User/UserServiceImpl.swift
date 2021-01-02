//
//  UserServiceImpl.swift
//  Example
//
//  Created by Короткий Виталий on 29.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import Combine

final class UserServiceImpl: UserService {
    private let apiClient: APIClient
    
    @Observable
    private(set) var user: User?
    var userPublisher: AnyPublisher<User?, Never> { $user }
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func auth(login: String, completion: @escaping (Result<User, Error>) -> Void) {
        apiClient.authUser(login: login) { [weak self] result in
            if let user = try? result.get() {
                self?.user = user
            }
            completion(result.mapError({ $0 }))
        }
    }
    
    func logout() {
        user = nil
    }
}

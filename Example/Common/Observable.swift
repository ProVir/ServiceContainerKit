//
//  Observable.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
final class Observable<T> {
    private let subject: CurrentValueSubject<T, Never>
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        self.subject = .init(wrappedValue)
    }
    
    func resendCurrentValue() {
        subject.send(wrappedValue)
    }
    
    var wrappedValue: T {
        didSet {
            subject.value = wrappedValue
        }
    }
    
    var projectedValue: AnyPublisher<T, Never> { subject.eraseToAnyPublisher() }
}

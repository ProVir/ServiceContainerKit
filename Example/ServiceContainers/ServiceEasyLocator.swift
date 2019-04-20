//
//  ServiceEasyLocator.swift
//  Example
//
//  Created by Vitalii Korotkii on 18/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

extension ServiceEasyLocatorObjC {
    @objc static var shared: ServiceEasyLocatorObjC? {
        return ServiceEasyLocator.shared.map { .init($0) }
    }
}

/// Recommendation use ServiceLocator
final class ServiceEasyLocator: ServiceContainerKit.ServiceEasyLocator {
    enum Error: LocalizedError {
        case sharedRequireSetup

        public var errorDescription: String? {
            switch self {
            case .sharedRequireSetup: return "ServiceLocator don't setuped for use as share (singleton)"
            }
        }
    }

    // MARK: Shared
    /// ServiceLocator as singleton
    public private(set) static var shared: ServiceEasyLocator?

    /// Get shared ServiceLocator or error
    public static func tryShared() throws -> ServiceEasyLocator {
        if let shared = shared {
            return shared
        } else {
            throw Error.sharedRequireSetup
        }
    }

    /// ServiceLocator.shared don't can replace other instance. Also it can also be used to prohibit the use of a singleton
    public private(set) static var readOnlyShared: Bool = false

    // MARK: Setup locator
    /// Setup ServiceLocator as singleton. If `readOnlySharedAfter = true` (default) - don't change singleton instance after.
    public static func setupShared(_ serviceLocator: ServiceEasyLocator, readOnlySharedAfter: Bool = true) {
        if readOnlyShared {
            assertionFailure("Don't support setupShared in readOnly regime")
            return
        }

        shared = serviceLocator
        readOnlyShared = readOnlySharedAfter
    }
}

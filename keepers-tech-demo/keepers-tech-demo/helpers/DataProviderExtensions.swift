//
//  DataProviderExtensions.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import ARKit

extension DataProvider {
    static func hasRequiredAuthorizations(_ authorizationStatus: [ARKitSession.AuthorizationType : ARKitSession.AuthorizationStatus]) -> Bool {
        return requiredAuthorizations.allSatisfy({ requirement in            
            if case .allowed = authorizationStatus[requirement] { return true }
            return false
        })
    }
}

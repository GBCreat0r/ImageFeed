//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by semrumyantsev on 07.04.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private static let bearerTokenKey = "bearerToken"
    
    var token: String? {
        get {KeychainWrapper.standard.string(forKey: OAuth2TokenStorage.bearerTokenKey)}
        set {guard let token = newValue else {
            print("Ну удалось сохранить токен в KeyChain")
            return
        }
            KeychainWrapper.standard.set(token, forKey: OAuth2TokenStorage.bearerTokenKey)
        }
    }
    
    func clearStorage() {
        KeychainWrapper.standard.removeObject(forKey: OAuth2TokenStorage.bearerTokenKey)
    }
}

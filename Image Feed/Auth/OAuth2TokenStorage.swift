//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by semrumyantsev on 07.04.2025.
//

import Foundation

final class OAuth2TokenStorage {
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "bearerToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "bearerToken")
        }
    }
}

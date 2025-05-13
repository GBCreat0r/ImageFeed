//
//  ProfileLogoutService.swift
//  Image Feed
//
//  Created by semrumyantsev on 12.05.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        cleanToken()
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = SplashViewController()
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                window.makeKeyAndVisible()
            }
        }
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    private func cleanToken() {
        OAuth2TokenStorage().clearStorage()
    }
    
    private func cleanProfile() {
        ImagesListService().clearData()
        ProfileService.shared.clearData()
    }
}

//
//  Constants.swift
//  Image Feed
//
//  Created by semrumyantsev on 25.03.2025.
//

import Foundation

enum Constants {
    static let accessKey = "Tm0f7JJO27QSk2C4V9Z5crBkowECKdDoZyOfmTW7klI"
    static let secretKey = "BTMPNrX01IvyyQ7Y9TKH-Yz8kHjQ4QfUcwFJQhuiYTw"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static var defaultBaseURL = "https://api.unsplash.com"
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
}

//
//  OAuthTokenResponseBody.swift
//  Image Feed
//
//  Created by semrumyantsev on 07.04.2025.
//

import UIKit


struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by semrumyantsev on 07.04.2025.
//

import UIKit

protocol OAuth2ServiceProtocol {
    func make0AuthTokenRequest(code: String) -> URLRequest?
    func fetchOAuthToken(code: String, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void)
}

final class OAuth2Service: OAuth2ServiceProtocol {
    static let shared = OAuth2Service()
    private init() {}
    
    private enum NetworkError: Error {
        case codeError
    }
    func make0AuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("Error: Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
        guard let request = make0AuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.codeError))
            }
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network request failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                if let httpResponse = response as? HTTPURLResponse {
                    print("Server returned status code \(httpResponse.statusCode)")
                } else {
                    print("Failed to cast response to HTTPURLResponse")
                }
                
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.codeError))
                }
                return
            }

            guard let data = data else {
                print("Received no data in response")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.codeError))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let oauthTokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(oauthTokenResponse))
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

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
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func make0AuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        else {
            assertionFailure("Failed to created URLComponents")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("Сервис авторизации: ОШибка создания URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                print("Сервис авторизации: Код нового запроса совпадает с кодом текущей задачи")
                completion(.failure(NetworkError.codeError))
            }
        }
        lastCode = code
        
        guard let request = make0AuthTokenRequest(code: code) else {
            print("Сервис авторизации: Ошибка сетевого запроса: токен авторизации")
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let oauthTokenResponse):
                DispatchQueue.main.async {
                    completion(.success(oauthTokenResponse))
                    self?.task = nil
                    self?.lastCode = nil
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Сервис авторизации: Ошибка сетевого запроса: \(error)")
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
}

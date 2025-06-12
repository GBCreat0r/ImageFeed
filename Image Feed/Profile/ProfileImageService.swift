//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by semrumyantsev on 17.04.2025.
//

import Foundation

protocol ProfileImageServiceProtocol {
    static var didChangeNotification: Notification.Name { get }
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}

final class ProfileImageService: ProfileImageServiceProtocol {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    let storageToken = OAuth2TokenStorage()
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    
    private enum NetworkError: Error {
        case codeError
        case decodingError
    }
    
    private init() {}
    
    private func makeProfilePhotoRequest(username: String ) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        guard let token = storageToken.token else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            print("Сервис загрузки аватарки: Отмена лишнего запроса")
            completion(.failure(NetworkError.codeError))
        }
        
        guard let request = makeProfilePhotoRequest(username: username) else {
            print("Сервис загрузки аватарки: Ошибка сетевого запроса: фото профиля")
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let userResult):
                guard let image = userResult.profileImage
                else { print("Сервис загрузки аватарки: Ошибка получения структуры")
                    completion(.failure(NetworkError.decodingError))
                    return }
                guard let profileImageURL = image["large"]
                else {
                    print("Сервис загрузки аватарки: Ошибка получения структуры")
                    completion(.failure(NetworkError.decodingError))
                    return
                }
                
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL])
            case .failure(let error):
                print("Сервис загрузки аватарки: Ошибка сетевого запроса: \(error)")
                completion(.failure(error))
            }
            self.task = nil
        }
        task.resume()
    }
}

struct UserResult: Decodable {
    let profileImage: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

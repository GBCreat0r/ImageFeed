//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by semrumyantsev on 17.04.2025.
//

import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    let storageToken = OAuth2TokenStorage()
    private(set) var avatarURL: String?
    
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
        guard let request = makeProfilePhotoRequest(username: username) else {
            print("Ошибка сетевого запроса: фото профиля")
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let userResult):
                guard let profileImageURL = userResult.profileImage["large"]
                else {
                    print("Ошибка получения структуры")
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
                print("Ошибка сетевого запроса: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

struct UserResult: Decodable {
    let profileImage: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

//
//  ProfileService.swift
//  Image Feed
//
//  Created by semrumyantsev on 16.04.2025.
//

import UIKit

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(username: String, firstName: String, lastName: String, bio: String) {
        self.username = username
        self.name = "\(firstName) \(lastName)"
        self.loginName = "@\(username)"
        self.bio = bio
    }
}
//TODO: исправь гонки
final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: Profile?
    
    private init() {}
    
    private enum NetworkError: Error {
        case codeError
    }
    
    private func makeProfileRequest(bearer token: String ) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfile(bearer token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeProfileRequest(bearer: token) else {
            print("Ошибка сетевого запроса: запрос профиля")
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    firstName: profileResult.firstName,
                    lastName: profileResult.lastName,
                    bio: profileResult.bio
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("Ошибка сетевого запроса: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}


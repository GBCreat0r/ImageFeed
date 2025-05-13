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
    private var task: URLSessionTask?
    
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
    
    func clearData() {
        profile = nil
    }
    
    func fetchProfile(bearer token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            print("Отмена лишнего запроса")
            completion(.failure(NetworkError.codeError))
        }
        
        guard let request = makeProfileRequest(bearer: token) else {
            print("Ошибка сетевого запроса: запрос профиля")
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let profileResult):
                guard let username = profileResult.username,
                      let firstname = profileResult.firstName,
                      let lastname = profileResult.lastName
                else {
                    print("Ошибка получения данных профиля")
                    return
                }
                let bio = profileResult.bio
                let profile = Profile(
                    username: username,
                    firstName: firstname,
                    lastName: lastname,
                    bio: bio ?? ""
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("Ошибка сетевого запроса: \(error)")
                completion(.failure(error))
            }
            self.task = nil
        }
        task.resume()
    }
}


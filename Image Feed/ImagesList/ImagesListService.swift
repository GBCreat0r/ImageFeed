//
//  ImageListService.swift
//  Image Feed
//
//  Created by semrumyantsev on 28.04.2025.
//

import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
    private var task: URLSessionDataTask?
    private var tokenSrorage = OAuth2TokenStorage()
    private enum NetworkError: Error {
        case codeError
    }
    
    func clearData() {
            photos.removeAll()
            lastLoadedPage = 1
        }
    
    func fetchPhotosNextPage() {
        if task != nil {
            print("Отмена лишнего запроса")
            return
        }
        
        let page = lastLoadedPage ?? 1
        guard let request = makeRequest() else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            guard let self else { return }
            
            if let error {
                print ("ошибка")
                
                return
            }
            
            guard let data else {
                print("no data")
                return
            }
            
            do {
                let photoResult = try JSONDecoder().decode([PhotoResult].self, from: data)
                let newPhoto = photoResult.map { photoResult in Photo(
                    id: photoResult.id,
                    size: CGSize(width: photoResult.width,
                                 height: photoResult.height),
                    createdAt: photoResult.createdAt.flatMap { DateFormatter().date(from: $0) },
                    welcomeDescription: photoResult.description,
                    thumbImageURL: photoResult.urls.thumb,
                    largeImageURL: photoResult.urls.full,
                    isLiked: photoResult.likedByUser
                )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhoto)
                    self.lastLoadedPage = page + 1
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    print("cool")
                    print(self.photos.count)
                }
            } catch {
                print("Ошибка декодинга JSON: \(error)")
            }
            self.task = nil
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        var components = URLComponents(string: Constants.defaultBaseURL + "/photos/\(photoId)/like")
        guard let url = components?.url,
              let token = tokenSrorage.token
        else {
            completion(.failure(NetworkError.codeError))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ?
        Constants.httpMethod.post.rawValue :
        Constants.httpMethod.delete.rawValue
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: {
                        $0.id == photoId
                    }) {
                        self.photos[index].isLiked.toggle()
                        
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                            object: nil,
                            userInfo: ["photos": self.photos[index]])
                    }
                    
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    
    private func makeRequest() -> URLRequest? {
        
        var components = URLComponents(string: Constants.defaultBaseURL + "/photos")
        let page = lastLoadedPage ?? 1
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page))]
        guard let url = components?.url,
              let token = tokenSrorage.token
        else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = Constants.httpMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

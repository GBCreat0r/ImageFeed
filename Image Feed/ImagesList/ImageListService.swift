//
//  ImageListService.swift
//  Image Feed
//
//  Created by semrumyantsev on 28.04.2025.
//

import UIKit

final class ImageListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var lastLoadedPage: Int?
    private (set) var photos: [Photo] = []
    private var task: URLSessionDataTask?
    
    func fetchPhotosNextPage() {
        if task != nil {
            print("Отмена лишнего запроса")
            return
        }
        
        let page = lastLoadedPage ?? 1
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)")
        else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            guard let self else { return }
            
            if let error = error {
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
                    NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
                }
            } catch {
                print("Ошибка декодинга JSON: \(error)")
            }
            self.task = nil
        }
        task.resume()
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
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

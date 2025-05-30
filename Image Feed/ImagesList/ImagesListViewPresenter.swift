//
//  ImagesListViewPresenter.swift
//  Image Feed
//
//  Created by semrumyantsev on 28.05.2025.
//

import Foundation

protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func photo(at indexPath: IndexPath) -> Photo
    func numberOfPhotos() -> Int
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat
    func formattedDate(for photo: Photo) -> String
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imageListService: ImagesListServiceProtocol
    private let dateFormatter: DateFormatter
    private var photos: [Photo] = []
    
    init(imageListService: ImagesListServiceProtocol = ImagesListService()) {
        self.imageListService = imageListService
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        self.dateFormatter = formatter
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.updatePhotos()
            }
    }
    
    func viewDidLoad() {
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imageListService.fetchPhotosNextPage()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        view?.showLoadingIndicator()
        imageListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            guard let self else { return }
            self.view?.hideLoadingIndicator()
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                self.view?.showError(error: error)
                completion(.failure(error))
            }
        }
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    func numberOfPhotos() -> Int {
        return photos.count
    }
    
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat {
        let cellWidth = tableViewWidth - 32
        let proportion: CGFloat = cellWidth / photo.size.width
        let cellHeight = photo.size.height * proportion + 8
        return cellHeight
    }
    
    func formattedDate(for photo: Photo) -> String {
        return photo.createdAt.map { dateFormatter.string(from: $0) } ?? dateFormatter.string(from: Date())
    }
    
    func updatePhotos() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
}

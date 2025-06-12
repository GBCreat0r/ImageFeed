//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by semrumyantsev on 28.04.2025.
//

@testable import Image_Feed
import XCTest

final class ImagesListViewPresenterTests: XCTestCase {
    private var presenter: ImagesListViewPresenter!
    private var viewMock: ImagesListViewControllerMock!
    private var serviceMock: ImagesListServiceMock!
    
    override func setUp() {
        super.setUp()
        serviceMock = ImagesListServiceMock()
        presenter = ImagesListViewPresenter(imageListService: serviceMock)
        viewMock = ImagesListViewControllerMock()
        presenter.view = viewMock
    }
    
    override func tearDown() {
        presenter = nil
        viewMock = nil
        serviceMock = nil
        super.tearDown()
    }
    
    func testViewDidLoad() {
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(serviceMock.fetchPhotosNextPageCalled, "При viewDidLoad должен вызываться fetchPhotosNextPage")
    }
    
    func testFetchPhotosNextPage() {
        // when
        presenter.fetchPhotosNextPage()
        
        // then
        XCTAssertTrue(serviceMock.fetchPhotosNextPageCalled, "Должен вызываться fetchPhotosNextPage сервиса")
    }
    
    func testNumberOfPhotosReturnsCorrectCount() {
        // Given
        serviceMock.photos = [
            Photo(
                id: "1",
                size: CGSize(width: 100, height: 100),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            ),
            Photo(
                id: "2",
                size: CGSize(width: 200, height: 200),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: true
            )
        ]
        
        // When
        presenter.updatePhotos()
        let count = presenter.numberOfPhotos()
        
        // Then
        XCTAssertEqual(count, 2)
    }
    
    func testPhotoAtIndexPath() {
        let validPhoto = Photo(id: "1", size: CGSize(width: 100, height: 100),
                          createdAt: nil, welcomeDescription: nil,
                          thumbImageURL: "", largeImageURL: "", isLiked: false)
        serviceMock.photos = [validPhoto]
        presenter.updatePhotos()
        
        let validIndex = IndexPath(row: 0, section: 0)
        XCTAssertEqual(presenter.photo(at: validIndex).id, "1")
    }
    
    func testCalculateCellHeight() {
        // given
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        let tableViewWidth: CGFloat = 400
        
        // when
        let height = presenter.calculateCellHeight(for: photo, tableViewWidth: tableViewWidth)
        
        // then
        let expectedHeight = (tableViewWidth - 32) / photo.size.width * photo.size.height + 8
        XCTAssertEqual(height, expectedHeight, "Должна правильно рассчитываться высота ячейки")
    }
    
    func testFormattedDate() {
        // given
        let date = Date(timeIntervalSince1970: 0)
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: date, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        
        // when
        let dateString = presenter.formattedDate(for: photo)
        
        // then
        XCTAssertEqual(dateString, "1 января 1970", "Должна правильно форматироваться дата")
    }
    
    func testChangeLikeSuccess() {
        // given
        let photoId = "1"
        let isLike = true
        
        // when
        presenter.changeLike(photoId: photoId, isLike: isLike) { result in
            // then
            switch result {
            case .success:
                break // expected
            case .failure:
                XCTFail("Должен возвращаться success")
            }
        }
        
        XCTAssertTrue(viewMock.showLoadingIndicatorCalled, "Должен показываться индикатор загрузки")
        XCTAssertTrue(serviceMock.changeLikeCalled, "Должен вызываться changeLike сервиса")
    }
    
    func testUpdatePhotosNotification() {
        // given
        let oldCount = serviceMock.photos.count
        serviceMock.photos = [
            Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        ]
        
        // when
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        // then
        XCTAssertTrue(viewMock.updateTableViewAnimatedCalled, "Должен вызываться updateTableViewAnimated при нотификации")
    }
}

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

final class ImagesListViewControllerMock: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var showLoadingIndicatorCalled = false
    var hideLoadingIndicatorCalled = false
    var showErrorCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }
    
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
    
    func showError(error: Error) {
        showErrorCalled = true
    }
}

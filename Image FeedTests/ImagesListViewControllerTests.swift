


import XCTest
@testable import Image_Feed


final class ImagesListViewControllerTests: XCTestCase {
    
    var sut: ImagesListViewController!
    var presenterMock: ImagesListViewPresenterMock!
    var tableViewMock: UITableViewMock!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        presenterMock = ImagesListViewPresenterMock()
        tableViewMock = UITableViewMock()
        
        sut.presenter = presenterMock
        sut.loadViewIfNeeded()
#if DEBUG
        sut.test_tableView = tableViewMock
#endif
    }
    
    override func tearDown() {
        sut = nil
        presenterMock = nil
        tableViewMock = nil
        super.tearDown()
    }
    
    func testViewDidLoadCallsPresenter() {
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertTrue(presenterMock.viewDidLoadCalled)
    }
    
    func testNumberOfRowsInSection() {
        // given
        presenterMock.photos = [
            Photo(id: "1", size: CGSize(width: 100, height: 100),
            Photo(id: "2", size: CGSize(width: 200, height: 200))
        ]
        
        // when
        let rows = sut.tableView(sut.test_tableView, numberOfRowsInSection: 0)
        
        // then
        XCTAssertEqual(rows, 2)
    }
    
    func testCellForRowConfiguresCell() {
        // given
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "thumb", largeImageURL: "large", isLiked: true)
        presenterMock.photos = [photo]
        
        // when
        let cell = sut.tableView(sut.test_tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! ImagesListCell
        
        // then
        XCTAssertEqual(cell.cellDateLabel.text, presenterMock.formattedDate(for: photo))
        XCTAssertEqual(cell.cellLikeButton.image(for: .normal), UIImage(resource: .likeButtonOn))
    }
    
    func testHeightForRow() {
        // given
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 200))
        presenterMock.photos = [photo]
        
        // when
        let height = sut.tableView(sut.test_tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        
        // then
        let expectedHeight = presenterMock.calculateCellHeight(for: photo, tableViewWidth: sut.test_tableView.bounds.width)
        XCTAssertEqual(height, expectedHeight)
    }
    
    func testWillDisplayCellTriggersFetchNextPage() {
        // given
        presenterMock.photos = Array(repeating: Photo(id: "1", size: CGSize(width: 100, height: 100)), count: 10)
        
        // when
        sut.tableView(sut.test_tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 9, section: 0))
        
        // then
        XCTAssertTrue(presenterMock.fetchPhotosNextPageCalled)
    }
    
    func testLikeButtonTapped() {
        // given
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), isLiked: false)
        presenterMock.photos = [photo]
        let cell = sut.tableView(sut.test_tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! ImagesListCell
        
        // when
        cell.pressCellLikeButton(UIButton())
        
        // then
        XCTAssertTrue(presenterMock.changeLikeCalled)
        XCTAssertEqual(presenterMock.changeLikePhotoId, "1")
        XCTAssertEqual(presenterMock.changeLikeIsLike, true)
    }
    
    func testUpdateTableViewAnimated() {
        // when
        sut.updateTableViewAnimated(oldCount: 0, newCount: 1)
        
        // then
        XCTAssertTrue(tableViewMock.performBatchUpdatesCalled)
    }
    
    func testShowLoadingIndicator() {
        // when
        sut.showLoadingIndicator()
        
        // then
        XCTAssertTrue(UIBlockingProgressHUD.showCalled)
    }
    
    func testHideLoadingIndicator() {
        // when
        sut.hideLoadingIndicator()
        
        // then
        XCTAssertTrue(UIBlockingProgressHUD.dismissCalled)
    }
    
    func testPrepareForSegue() {
        // given
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), largeImageURL: "https://example.com/image.jpg")
        presenterMock.photos = [photo]
        let destination = SingleImageViewController()
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: sut, destination: destination)
        
        // when
        sut.prepare(for: segue, sender: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertEqual(destination.imageURL?.absoluteString, "https://example.com/image.jpg")
    }
}

// MARK: - Mocks

final class ImagesListViewPresenterMock: ImagesListViewPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    var viewDidLoadCalled = false
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var changeLikePhotoId: String?
    var changeLikeIsLike: Bool?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        changeLikePhotoId = photoId
        changeLikeIsLike = isLike
        completion(.success(()))
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    func numberOfPhotos() -> Int {
        return photos.count
    }
    
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat {
        return 200
    }
    
    func formattedDate(for photo: Photo) -> String {
        return "1 января 2023"
    }
    
    func updatePhotos() {}
}

final class UITableViewMock: UITableView {
    var performBatchUpdatesCalled = false
    
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdatesCalled = true
        updates?()
        completion?(true)
    }
}

final class UIBlockingProgressHUD {
    static var showCalled = false
    static var dismissCalled = false
    
    static func show() {
        showCalled = true
    }
    
    static func dismiss() {
        dismissCalled = true
    }
}

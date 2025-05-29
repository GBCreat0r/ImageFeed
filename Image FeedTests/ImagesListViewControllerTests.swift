
import XCTest
@testable import Image_Feed

final class MockImagesListViewPresenter: ImagesListViewPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = [
        Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test photo",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: false
        )
    ]
    
    var viewDidLoadCalled = false
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    func numberOfPhotos() -> Int {
        return photos.count
    }
    
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat {
        return 100
    }
    
    func formattedDate(for photo: Photo) -> String {
        return "1 января 2023"
    }
}

final class ImagesListViewControllerTests: XCTestCase {
    private var sut: ImagesListViewController!
    private var presenter: MockImagesListViewPresenter!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        presenter = MockImagesListViewPresenter()
        
        sut.loadViewIfNeeded()
        sut.configure(presenter)
    }
    
    override func tearDown() {
        sut = nil
        presenter = nil
        super.tearDown()
    }
    
    func testViewDidLoad_CallsPresenter() {
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testTableViewDataSource_NumberOfRows() {
        // When
        let rows = sut.test_tableView.numberOfRows(inSection: 0)
        
        // Then
        XCTAssertEqual(rows, presenter.numberOfPhotos())
    }
    
    func testTableViewDataSource_CellForRow() {
        // Given
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        let cell = sut.test_tableView.dataSource?.tableView(
            sut.test_tableView,
            cellForRowAt: indexPath
        ) as? ImagesListCell
        
        // Then
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.cellDateLabel.text, "1 января 2023")
    }
    
    func testTableViewDelegate_HeightForRow() {
        // Given
        let indexPath = IndexPath(row: 0, section: 0)
        let photo = presenter.photo(at: indexPath)
        let expectedHeight = presenter.calculateCellHeight(
            for: photo,
            tableViewWidth: sut.test_tableView.bounds.width
        )
        
        // When
        let height = sut.test_tableView.delegate?.tableView?(
            sut.test_tableView,
            heightForRowAt: indexPath
        )
        
        // Then
        XCTAssertEqual(height, expectedHeight)
    }
    
    func testTableViewDelegate_WillDisplayCell_FetchesNextPage() {
        // Given
        let indexPath = IndexPath(row: presenter.numberOfPhotos() - 1, section: 0)
        let cell = ImagesListCell()
        
        // When
        sut.test_tableView.delegate?.tableView?(
            sut.test_tableView,
            willDisplay: cell,
            forRowAt: indexPath
        )
        
        // Then
        XCTAssertTrue(presenter.fetchPhotosNextPageCalled)
    }
    
    func testShowAndHideLoadingIndicator() {
        // When
        sut.showLoadingIndicator()
        sleep(2)
        sut.hideLoadingIndicator()
        sleep(2)
        // Then
        XCTAssertFalse(UIBlockingProgressHUD.isShowing)
    }
    
    func testPrepareForSegue() {
        // Given
        let segue = UIStoryboardSegue(
            identifier: "ShowSingleImage",
            source: sut,
            destination: SingleImageViewController()
        )
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        sut.prepare(for: segue, sender: indexPath)
        
        // Then
        if let destination = segue.destination as? SingleImageViewController {
            XCTAssertEqual(destination.imageURL?.absoluteString, "https://example.com/large.jpg")
        } else {
            XCTFail("Destination should be SingleImageViewController")
        }
    }
}

class UIBlockingProgressHUD {
    static var isShowing = false
    
    static func show() {
        isShowing = true
    }
    
    static func dismiss() {
        isShowing = false
    }
}

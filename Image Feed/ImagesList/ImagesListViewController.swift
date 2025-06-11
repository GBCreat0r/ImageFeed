import UIKit
import Kingfisher


protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showError(error: Error)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
#if DEBUG
    var test_tableView: UITableView { tableView }
#endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil {
            let defaultPresenter = ImagesListViewPresenter(
                imageListService: ImagesListService()
            )
            self.configure(defaultPresenter)
        }
        presenter?.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func configure(_ presenter: ImagesListViewPresenterProtocol) {
        
        var localPresenter = presenter
        self.presenter = localPresenter
        localPresenter.view = self
    }
    
    // MARK: - ImagesListViewControllerProtocol
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    func showLoadingIndicator() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoadingIndicator() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func showError(error: Error) {
        print("Error: \(error.localizedDescription)")
        // Здесь можно добавить показ алерта с ошибкой
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == showSingleImageSegueIdentifier,
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard let presenter else {return}
        let photo = presenter.photo(at: indexPath)
        guard let url = URL(string: photo.largeImageURL) else {
            print("Invalid URL: \(photo.largeImageURL)")
            return
        }
        viewController.imageURL = url
        viewController.isLiked = photo.isLiked
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return presenter?.numberOfPhotos() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.layoutIfNeeded()
        imageListCell.delegate = self
        guard let presenter else { return UITableViewCell() }
        let photo = presenter.photo(at: indexPath)
        configCell(imageListCell, with: photo)
        
        return imageListCell
    }
    
    func configCell(_ cell: ImagesListCell, with photo: Photo) {
        cell.cellPhoto.addPhotoCellGradientLayer()
        let imageURL = URL(string: photo.thumbImageURL)
        cell.cellPhoto.kf.setImage(
            with: imageURL,
            completionHandler: { result in
                cell.cellPhoto.removeLoadGradientLayer()
            }
        )
        
        cell.cellDateLabel.text = presenter?.formattedDate(for: photo)
        let likeImage = photo.isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        cell.cellLikeButton.setImage(likeImage, for: .normal)
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter else { return CGFloat() }
        let photo = presenter.photo(at: indexPath)
        return presenter.calculateCellHeight(for: photo, tableViewWidth: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == presenter?.numberOfPhotos() {
            presenter?.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListDidTapLike(_ cell: ImagesListCell) {
        guard let presenter else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = presenter.photo(at: indexPath)
        
        presenter.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                if let newCell = self.tableView.cellForRow(at: indexPath) as? ImagesListCell {
                    let updatedPhoto = self.presenter?.photo(at: indexPath)
                    guard let updatedPhoto else { return }
                    newCell.setIsLiked(updatedPhoto.isLiked)
                }
            case .failure(let error):
                self.showError(error: error)
            }
        }
    }
}

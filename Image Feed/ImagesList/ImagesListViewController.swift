import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    //private let photosName: [String] = Array(0..<20).map{"\($0)"}
    private let imageListService = ImagesListService()
    private var photos: [Photo] = []
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didFetchPhotos), name: ImagesListService.didChangeNotification, object: nil)
        
        imageListService.fetchPhotosNextPage ()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        print("\(photos.count)")
    }
    
    @objc private func didFetchPhotos() {
        updateTableViewAnimated()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == showSingleImageSegueIdentifier,
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            super.prepare(for: segue, sender: sender)
            return
        }
        //TODO: разберись тут +
        let photo = photos[indexPath.row]
        viewController.imageURL = URL(string: photo.largeImageURL)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return photos.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        
        let imageURL = URL(string: photos[indexPath.row].thumbImageURL)
        //TODO: gradient
        imageListCell.cellPhoto.kf.setImage(
            with: imageURL,
            placeholder: UIImage(named: "StubPhoto"),
            completionHandler: { result in
                switch result {
                case .success:
                    if let indexPath = self.tableView.indexPath(for: imageListCell) {
                        //                                self.tableView.performBatchUpdates({
                        //                                    self.tableView.reloadRows(at: [indexPath], with: .none)
                        //                                }, completion: nil)
                    }
                case .failure:
                    break
                }
            }
        )
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.cellPhoto.image = nil
        
        cell.cellDateLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = photos[indexPath.row].isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.cellLikeButton.setImage(likeImage, for: .normal)
        
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let cellWidth = tableView.bounds.width - 32
        let proportion: CGFloat = cellWidth / photo.size.width
        let cellHeight = photo.size.height * proportion + 8
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print("Error: \(error)")
                UIBlockingProgressHUD.dismiss()
                //TODO: Alert
            }
            
        }
        
    }
}

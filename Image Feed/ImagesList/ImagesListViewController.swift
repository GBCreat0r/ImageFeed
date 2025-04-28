import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
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
        
        let image = UIImage(named: photosName[indexPath.row])
        viewController.image = image
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(
      _ tableView: UITableView,
      willDisplay cell: UITableViewCell,
      forRowAt indexPath: IndexPath
    ) {
        //indexPath.row + 1 == photos.count
        // ...
    }
    
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.cellPhoto.image = nil
        
        cell.cellDateLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.cellLikeButton.setImage(likeImage, for: .normal)
        
        cell.cellPhoto.removeGradientLayer()
        DispatchQueue.global().async {
            guard let image = UIImage(named: self.photosName[indexPath.row]) else { return }
            DispatchQueue.main.async {
                cell.cellPhoto.image = image
                cell.cellPhoto.addGradientLayer()
                cell.setNeedsLayout()
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return 0 }
        
        let cellWidth = tableView.bounds.width - 32
        let cellPhotoWidth = image.size.width
        let proportion: CGFloat = cellWidth / cellPhotoWidth
        let cellHeight = image.size.height * proportion + 8
        return cellHeight
    }
}

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var cellDateLabel: UILabel!
    @IBOutlet weak var cellLikeButton: UIButton!
    @IBOutlet weak var cellPhoto: UIImageView!
    
    @IBAction func pressCellLikeButton(_ sender: Any) {
        delegate?.imageListDidTapLike(self)
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        cellPhoto.kf.cancelDownloadTask()
        cellPhoto.image = UIImage(resource: .stubPhoto)
    }
    
    func setIsLiked(_ isLiked: Bool) {
 
        isLiked ? cellLikeButton.setImage(UIImage(resource: .likeButtonOn), for: .normal) : cellLikeButton.setImage(UIImage(resource: .likeButtonOff), for: .normal)
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListDidTapLike(_ cell: ImagesListCell)
}

import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return }
        cell.cellPhoto.image = image
        
        cell.cellDateLabel.text = dateFormatter.string(from: Date())
        cell.cellDateLabel.applyGradientToText()
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.cellLikeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return 0 }
        
        let cellWidth = tableView.bounds.width - 32
        let cellPhotoWidth = image.size.width
        let proportion: CGFloat = cellWidth / cellPhotoWidth
        let cellHeight = image.size.height * proportion + 8
        return cellHeight
    }
}

extension UILabel {
    func applyGradientToText() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor(red: 255/255, green: 160/255, blue: 122/255, alpha: 1).cgColor, UIColor(red: 255/255, green: 188/255, blue: 156/255, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.cornerRadius = 5
        
        let textLayer = CATextLayer()
        textLayer.frame = self.bounds
        textLayer.string = self.text
        textLayer.fontSize = self.font!.pointSize
        textLayer.alignmentMode = .center
        textLayer.foregroundColor = UIColor.white.cgColor
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.layer.insertSublayer(textLayer, above: gradientLayer)
        self.textColor = .clear
    }
}


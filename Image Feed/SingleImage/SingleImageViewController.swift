//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by semrumyantsev on 11.03.2025.
//

import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, let imageURL else { return }
            
            loadImage(url: imageURL)
        }
    }
    
    private var previousOffset: CGPoint = .zero
    @IBOutlet weak private var likeButton: UIButton!
    @IBOutlet weak private var shareButton: UIButton!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var singleImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.bouncesZoom = false
        if let imageURL = imageURL {
            loadImage(url: imageURL)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ProgressHUD.dismiss()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = singleImage.image else { return }
        let shareViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareViewController, animated: true, completion: nil)
    }
    
    private func loadImage(url: URL) {
        ProgressHUD.animate()
        let placeholder = UIImage(named: "StubPhoto")
        let placeholderImageView = UIImageView(image: placeholder)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        singleImage.addSubview(placeholderImageView)
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: singleImage.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: singleImage.centerYAnchor),
        ])
        
        singleImage.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.singleImage.image = imageResult.image
                self.singleImage.frame.size = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                ProgressHUD.dismiss()
            case .failure:
                print("Сервис SingleImage: Не удалось загрузить фото")
                DispatchQueue.main.async{
                    let alert = UIAlertController(title: "Ошибка",
                                                  message: "Не удалось загрузить изображение",
                                                  preferredStyle: .alert)
                    let action = UIAlertAction(title: "ОК",
                                               style: .default) { [weak self] (action) in
                        guard let self else { return }
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func rescaleAndCenterImageInScrollView (image: UIImage) {
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let xScale = visibleRectSize.width / image.size.width
        let yScale = visibleRectSize.height / image.size.height
        let scale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, min(xScale, yScale)))
        let currentOffset = scrollView.contentOffset
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        scrollView.contentOffset = currentOffset
        centerImage()
        
        //TODO: можно сделать прям на весь
    }
    private func centerImage() {
        let contentSize = scrollView.contentSize
        let viewSize = scrollView.bounds.size
        var insetX: CGFloat = 0
        var insetY: CGFloat = 0
        
        if contentSize.height < viewSize.height {
            insetX = (viewSize.height - contentSize.height) / 2
        }
        
        if contentSize.width < viewSize.width {
            insetY = (viewSize.width - contentSize.width) / 2
        }
        
        scrollView.contentInset = UIEdgeInsets(top: insetX, left: insetY, bottom: insetX, right: insetY)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImage
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImage()
    }
}

//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by semrumyantsev on 11.03.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            singleImage.image = image
            singleImage.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
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
        
        guard let image else { return }
        singleImage.image = image
        singleImage.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = singleImage.image else { return }
        let shareViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareViewController, animated: true, completion: nil)
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

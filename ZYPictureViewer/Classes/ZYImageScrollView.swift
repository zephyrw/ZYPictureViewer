//
//  PVImageScrollView.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/6/12.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

class ZYImageScrollView: UIScrollView {
    
    let imageView = UIImageView()
    fileprivate var currentImage : UIImage?
    fileprivate let observePath = "image"
    fileprivate var isDismissing: Bool = false
    fileprivate var avoidUp: Bool = false
    fileprivate var maxTopBottomInset: CGFloat = 0
    var scrollHandler: ((_ percent: CGFloat) -> Void)?
    var dismissHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isMultipleTouchEnabled = true
        maximumZoomScale = 1
        minimumZoomScale = 1
        alwaysBounceVertical = true
        delegate = self
        setupImageView()
    }
    
    fileprivate func setupImageView() {
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.addObserver(self, forKeyPath: observePath, options: .new, context: nil)
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == observePath {
            currentImage = change?[NSKeyValueChangeKey.newKey] as? UIImage
            imageView.zy_layerImage = currentImage
            update()
        }
    }
    
    func update() {
        if isDismissing { return }
        setZoomScale(1.0, animated: false)
        updateFrame()
        adjustCenter()
        adjustMaximumZoomScale()
        maxTopBottomInset = zy_height / 2 + imageView.zy_height / 2
    }
    
    fileprivate func updateFrame() {
        guard let image = currentImage else { return }
        let toH = image.size.height * zy_width / image.size.width
        imageView.frame = CGRect(x: 0, y: 0, width: zy_width, height: toH)
        if toH < zy_height {
            contentSize = bounds.size
        } else {
            contentSize = CGSize(width: zy_width, height: toH)
        }
    }
    
    fileprivate func adjustCenter() {
        let horizontalDiff = zy_width - contentSize.width
        let verticalDiff = zy_height - contentSize.height
        let horizontalAdd = horizontalDiff > 0 ? horizontalDiff : 0
        let verticalAdd = verticalDiff > 0 ? verticalDiff : 0
        imageView.center = CGPoint(x: (contentSize.width + horizontalAdd) / 2, y: (contentSize.height + verticalAdd) / 2)
    }
    
    fileprivate func adjustMaximumZoomScale() {
        guard let image = currentImage else { return }
        let iw = image.size.width
        let ih = image.size.height
        if iw < zy_width && ih < zy_height {
            maximumZoomScale = 1
        } else {
            maximumZoomScale = max(min(iw / zy_width, ih / zy_height), 3.0)
        }
    }
    
    func updateZoom(location: CGPoint) {
        guard let superview = superview else { return }
        let touchPoint = superview.convert(location, to: imageView)
        if zoomScale > 1 {
            setZoomScale(1, animated: true)
        } else if maximumZoomScale > 1 {
            let newScale = maximumZoomScale
            let horizontalSize = bounds.width / newScale
            let verticalSize = bounds.height / newScale
            zoom(to: CGRect(x: touchPoint.x - horizontalSize / 2, y: touchPoint.y - verticalSize / 2, width: horizontalSize, height: verticalSize), animated: true)
        }
    }
    
    deinit {
        imageView.removeObserver(self, forKeyPath: observePath)
    }

}

extension ZYImageScrollView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if zoomScale <= 1 && !isDismissing && panGestureRecognizer.translation(in: self).y < 0 {
            avoidUp = true
        } else {
            avoidUp = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if zoomScale <= 1 && !isDismissing && (imageView.zy_height < zy_height || (imageView.zy_height > zy_height && contentOffset.y < 0)) {
            contentOffset.y = 0
            if !avoidUp {
                doPan()
            }
        }
    }
    
    fileprivate func doPan() {
        switch panGestureRecognizer.state {
        case .began:
            PVLog("began")
        case .changed:
            let translation = panGestureRecognizer.translation(in: self)
            var percent = CGFloat(fabsf(Float((zy_height - imageView.zy_top - imageView.zy_height / 2) / (zy_height / 2))))
            if percent > 1 {
                percent = 1
            }
            imageView.transform = CGAffineTransform.identity.translatedBy(x: translation.x, y: translation.y).scaledBy(x: percent * 0.5 + 0.5, y: percent * 0.5 + 0.5)
            scrollHandler?(percent)
        case .cancelled, .failed, .ended:
            let velocity = panGestureRecognizer.velocity(in: self)
            if velocity.y > 0 {
                isDismissing = true
                dismissHandler?()
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.imageView.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            }
        case .possible:
            PVLog("possible")
        }
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if zoomScale <= 1 && velocity.y < 0 {
//            isDismissing = true
//            dismissHandler?()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if zoomScale <= 1 && !isDismissing {
            let velocity = panGestureRecognizer.velocity(in: self)
            if velocity.y > 0 {
                isDismissing = true
                dismissHandler?()
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.imageView.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.scrollHandler?(1)
                }
            }
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustCenter()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
